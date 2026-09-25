import Foundation

/// Role: Niche. Typed transport failures. This product has no remote catalog.
enum VotiveWire: Error, Equatable, Sendable {
    case miss
    case smear
    case lapse
    case halt
    case odd
}

/// Role: Niche. One HTTP exchange. Tests inject a script.
protocol VotiveCourier: Sendable {
    func send(_ request: URLRequest) async throws -> (Data, URLResponse)
}

/// Role: Niche. 15 s timeout and the app User-Agent on every request.
struct VotiveSession: VotiveCourier, Sendable {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = NicheClient.timeout
        configuration.timeoutIntervalForResource = NicheClient.timeout
        configuration.httpAdditionalHeaders = ["User-Agent": NicheClient.userAgent]
        self.session = URLSession(configuration: configuration)
    }

    func send(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

/// Role: Niche. JSON number or numeric string. Missing stays nil.
struct VotiveFigure: Sendable, Equatable {
    var value: Double?
}

extension VotiveFigure: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
            return
        }
        if let number = try? container.decode(Double.self) {
            value = number
            return
        }
        if let number = try? container.decode(Int.self) {
            value = Double(number)
            return
        }
        if let text = try? container.decode(String.self) {
            value = Double(text)
            return
        }
        value = nil
    }
}

/// Role: Niche. status 0 means miss. No Open Food Facts catalog is wired.
enum VotiveStatus {
    static func accept(_ status: Int) throws {
        if status == 0 { throw VotiveWire.miss }
    }
}

struct VotiveEchoDTO: Decodable {
    var status: Int?
    var span: VotiveFigure?
    var label: String?
}

struct VotiveEcho: Equatable, Sendable {
    var status: Int
    var span: Double?
    var label: String

    init(dto: VotiveEchoDTO) throws {
        let status = dto.status ?? 1
        try VotiveStatus.accept(status)
        self.status = status
        self.span = dto.span?.value
        self.label = dto.label ?? ""
    }
}

/// Role: Niche. Owns the session. Decode DTO then map. Never into domain types. Contact is a Settings link.
actor NicheClient {
    static let userAgent = "Aedicule/1.0 (iOS; +https://aedicule-niche.pro)"
    static let timeout: TimeInterval = 15
    /// Programmer constant; the domain string is fixed in SPEC.md.
    static let contactURL = URL(string: "https://aedicule-niche.pro/contact-us")!

    private let courier: any VotiveCourier

    init(courier: any VotiveCourier) {
        self.courier = courier
    }

    init() {
        self.courier = VotiveSession()
    }

    func echo(at url: URL) async throws -> VotiveEcho {
        let dto = try await pull(VotiveEchoDTO.self, at: url)
        return try VotiveEcho(dto: dto)
    }

    func pull<DTO: Decodable>(_ type: DTO.Type, at url: URL) async throws -> DTO {
        try Task.checkCancellation()
        let body = try await fetch(makeRequest(at: url))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            return try decoder.decode(DTO.self, from: body)
        } catch is CancellationError {
            throw VotiveWire.halt
        } catch {
            throw VotiveWire.smear
        }
    }

    private func makeRequest(at url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: NicheClient.timeout)
        request.setValue(NicheClient.userAgent, forHTTPHeaderField: "User-Agent")
        return request
    }

    private func fetch(_ request: URLRequest) async throws -> Data {
        var lastError: Error = VotiveWire.lapse
        for attempt in 0 ... 1 {
            try Task.checkCancellation()
            do {
                return try await once(request)
            } catch let wire as VotiveWire {
                throw wire
            } catch is CancellationError {
                throw VotiveWire.halt
            } catch {
                if votiveHalted(error) { throw VotiveWire.halt }
                lastError = error
                if attempt == 0, votiveTransient(error) {
                    continue
                }
                throw VotiveWire.lapse
            }
        }
        throw lastError
    }

    private func once(_ request: URLRequest) async throws -> Data {
        try Task.checkCancellation()
        let (data, response) = try await courier.send(request)
        guard let http = response as? HTTPURLResponse else {
            throw VotiveWire.odd
        }
        if http.statusCode == 404 {
            throw VotiveWire.miss
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            throw VotiveWire.lapse
        }
        return data
    }
}

func votiveTransient(_ error: Error) -> Bool {
    guard let urlError = error as? URLError else { return false }
    switch urlError.code {
    case .timedOut, .networkConnectionLost, .notConnectedToInternet,
         .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
        return true
    default:
        return false
    }
}

func votiveHalted(_ error: Error) -> Bool {
    if error is CancellationError { return true }
    return (error as? URLError)?.code == .cancelled
}
