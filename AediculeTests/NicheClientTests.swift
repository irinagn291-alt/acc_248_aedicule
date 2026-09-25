import XCTest
@testable import Aedicule

private actor ScriptedCourier: VotiveCourier {
    private var results: [Result<(Data, URLResponse), Error>]
    private var requests: [URLRequest] = []

    init(results: [Result<(Data, URLResponse), Error>]) {
        self.results = results
    }

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        requests.append(request)
        guard !results.isEmpty else { throw URLError(.cannotConnectToHost) }
        return try results.removeFirst().get()
    }

    func recordedRequests() -> [URLRequest] {
        requests
    }
}

final class NicheClientTests: XCTestCase {
    private let url = URL(string: "https://aedicule-niche.pro/probe")!

    func test_setsUserAgentOnEveryRequest() async throws {
        let courier = ScriptedCourier(results: [
            .success((Data("{\"span\":1}".utf8), http(200))),
        ])
        let client = NicheClient(courier: courier)
        _ = try await client.pull(VotiveEchoDTO.self, at: url)
        let request = await courier.recordedRequests().first
        XCTAssertEqual(request?.value(forHTTPHeaderField: "User-Agent"), NicheClient.userAgent)
        XCTAssertEqual(request?.timeoutInterval, 15)
        XCTAssertEqual(NicheClient.userAgent, "Aedicule/1.0 (iOS; +https://aedicule-niche.pro)")
        XCTAssertEqual(NicheClient.contactURL.absoluteString, "https://aedicule-niche.pro/contact-us")
    }

    func test_retriesTransientTransportOnce() async throws {
        let courier = ScriptedCourier(results: [
            .failure(URLError(.timedOut)),
            .success((Data("{\"span\":\"4.5\",\"label\":\"ok\"}".utf8), http(200))),
        ])
        let client = NicheClient(courier: courier)
        let echo = try await client.echo(at: url)
        XCTAssertEqual(echo.span, 4.5)
        XCTAssertEqual(echo.label, "ok")
        let count = await courier.recordedRequests().count
        XCTAssertEqual(count, 2)
    }

    func test_doesNotRetry404() async {
        let courier = ScriptedCourier(results: [
            .success((Data(), http(404))),
            .success((Data("{\"span\":1}".utf8), http(200))),
        ])
        let client = NicheClient(courier: courier)
        do {
            _ = try await client.pull(VotiveEchoDTO.self, at: url)
            XCTFail("expected miss")
        } catch {
            XCTAssertEqual(error as? VotiveWire, .miss)
        }
        let count = await courier.recordedRequests().count
        XCTAssertEqual(count, 1)
    }

    func test_malformedJSONIsSmear() async {
        let courier = ScriptedCourier(results: [
            .success((Data("{".utf8), http(200))),
        ])
        let client = NicheClient(courier: courier)
        do {
            _ = try await client.pull(VotiveEchoDTO.self, at: url)
            XCTFail("expected smear")
        } catch {
            XCTAssertEqual(error as? VotiveWire, .smear)
        }
    }

    func test_looseNumberAcceptsNumberAndString() throws {
        let number = try JSONDecoder().decode(VotiveEchoDTO.self, from: Data("{\"span\":12.5}".utf8))
        let string = try JSONDecoder().decode(VotiveEchoDTO.self, from: Data("{\"span\":\"12.5\"}".utf8))
        let missing = try JSONDecoder().decode(VotiveEchoDTO.self, from: Data("{\"span\":null}".utf8))
        XCTAssertEqual(number.span?.value, 12.5)
        XCTAssertEqual(string.span?.value, 12.5)
        XCTAssertNil(missing.span?.value)
    }

    func test_statusZeroIsMiss() throws {
        XCTAssertThrowsError(try VotiveStatus.accept(0)) { error in
            XCTAssertEqual(error as? VotiveWire, .miss)
        }
        XCTAssertNoThrow(try VotiveStatus.accept(1))
        XCTAssertThrowsError(try VotiveEcho(dto: VotiveEchoDTO(status: 0, span: nil, label: nil))) { error in
            XCTAssertEqual(error as? VotiveWire, .miss)
        }
    }

    private func http(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
    }
}
