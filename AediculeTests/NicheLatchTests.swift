import XCTest
@testable import Aedicule

final class NicheLatchTests: XCTestCase {
    func test_readsOnceAfterOnboarding() {
        var consumed = false
        XCTAssertNil(
            NicheLatch.consume(
                arguments: ["-ReviewScreen", "log"],
                onboardingComplete: false,
                consumed: &consumed
            )
        )
        XCTAssertFalse(consumed)

        let first = NicheLatch.consume(
            arguments: ["app", "-ReviewScreen", "log"],
            onboardingComplete: true,
            consumed: &consumed
        )
        XCTAssertEqual(first, .log)
        XCTAssertEqual(first?.segment, .garden)
        XCTAssertTrue(consumed)
        XCTAssertNil(
            NicheLatch.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
    }

    func test_threeKeysAreDistinctScreens() {
        XCTAssertEqual(NichePane.today.rawValue, "today")
        XCTAssertEqual(NichePane.log.rawValue, "log")
        XCTAssertEqual(NichePane.goals.rawValue, "goals")
        XCTAssertNotEqual(NichePane.today, .log)
        XCTAssertNotEqual(NichePane.log, .goals)
        XCTAssertNotEqual(NichePane.today, .goals)
        XCTAssertEqual(NichePane.today.segment, .moments)
        XCTAssertEqual(NichePane.log.segment, .garden)
        XCTAssertEqual(NichePane.goals.segment, .settings)
        XCTAssertNotEqual(NichePane.today.segment, NichePane.log.segment)
        XCTAssertNotEqual(NichePane.log.segment, NichePane.goals.segment)
        XCTAssertNotEqual(NicheSegment.moments, .garden)
        XCTAssertNotEqual(NicheSegment.garden, .settings)

        var consumed = false
        XCTAssertEqual(
            NicheLatch.consume(
                arguments: ["-ReviewScreen", "today"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .today
        )
        consumed = false
        XCTAssertEqual(
            NicheLatch.consume(
                arguments: ["-ReviewScreen", "goals"],
                onboardingComplete: true,
                consumed: &consumed
            ),
            .goals
        )
        XCTAssertEqual(NicheLatch.flag, "-ReviewScreen")
    }

    func test_unknownKeyIsIgnored() {
        var consumed = false
        XCTAssertNil(
            NicheLatch.consume(
                arguments: ["-ReviewScreen", "aura"],
                onboardingComplete: true,
                consumed: &consumed
            )
        )
        XCTAssertTrue(consumed)
    }
}
