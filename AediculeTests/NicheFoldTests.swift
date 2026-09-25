import XCTest
@testable import Aedicule

/// Architecture: Glow ADT fold Live | Wick | Capsule. Midnight freeze. Draw never samples today. No View.
final class NicheFoldTests: XCTestCase {
    private var calendar: Calendar { AediculeGMT.calendar }

    func test_midnightFoldsLiveToWickAndFreezesMedia() throws {
        let monday = AediculeGMT.instant(2026, 9, 14, hour: 21)
        var niche = NicheDocument.empty
        let id = UUID()
        _ = niche.catchGlow(.tide, at: monday, calendar: calendar, id: id)
        try niche.attachStill(id: id, name: "tide.jpg", at: monday, calendar: calendar)
        XCTAssertEqual(niche.liveToday(at: monday, calendar: calendar).count, 1)
        XCTAssertTrue(niche.folded(at: monday, calendar: calendar)[0].canAttach)

        let tuesday = AediculeGMT.instant(2026, 9, 15, hour: 1)
        niche.foldMidnight(at: tuesday, calendar: calendar)
        let folded = niche.folded(at: tuesday, calendar: calendar)[0]
        XCTAssertEqual(folded.kind, .wick)
        XCTAssertEqual(folded.foldToWick(today: VotiveDay.from(tuesday, calendar: calendar), calendar: calendar).kind, .wick)
        XCTAssertFalse(folded.canAttach)
        XCTAssertThrowsError(try niche.attachVoice(id: id, name: "late.m4a", at: tuesday, calendar: calendar)) { error in
            XCTAssertEqual(error as? NicheFault, .mediaFrozen)
        }
        XCTAssertEqual(niche.glows[0].stillName, "tide.jpg")
        XCTAssertNil(niche.glows[0].voiceName)
        XCTAssertTrue(niche.liveToday(at: tuesday, calendar: calendar).isEmpty)
    }

    func test_capsuleBloomsAfterThirtyDaysNotOnTheThirtieth() {
        let origin = AediculeGMT.instant(2026, 8, 17)
        var niche = NicheDocument.empty
        _ = niche.catchGlow(.lift, at: origin, calendar: calendar)
        let spark = niche.glows[0]
        let day30 = AediculeGMT.instant(2026, 9, 16)
        let day31 = AediculeGMT.instant(2026, 9, 17)
        XCTAssertEqual(Glow.fold(spark, today: VotiveDay.from(day30, calendar: calendar), calendar: calendar).kind, .wick)
        XCTAssertEqual(Glow.fold(spark, today: VotiveDay.from(day31, calendar: calendar), calendar: calendar).kind, .capsule)
        XCTAssertEqual(niche.capsuleCount(at: day30, calendar: calendar), 0)
        XCTAssertEqual(niche.capsuleCount(at: day31, calendar: calendar), 1)
    }

    func test_primaryVerbEmptyPopulatedInvalid() throws {
        var empty = NicheDocument.empty
        XCTAssertTrue(empty.canCatch)
        XCTAssertFalse(empty.canDraw(at: AediculeGMT.instant(2026, 9, 17), calendar: calendar))
        XCTAssertThrowsError(try empty.drawRay(at: AediculeGMT.instant(2026, 9, 17), calendar: calendar)) { error in
            XCTAssertEqual(error as? NicheFault, .emptyDraw)
        }

        let now = AediculeGMT.instant(2026, 9, 17)
        let first = empty.catchGlow(.ember, at: now, calendar: calendar)
        XCTAssertEqual(empty.liveToday(at: now, calendar: calendar).count, 1)
        XCTAssertEqual(first.kind, .live)
        XCTAssertTrue(empty.canCatch)
        XCTAssertFalse(empty.canDraw(at: now, calendar: calendar))

        _ = empty.catchGlow(.hush, at: now, calendar: calendar)
        XCTAssertEqual(empty.liveToday(at: now, calendar: calendar).count, 2)

        XCTAssertThrowsError(try empty.attachStill(id: UUID(), name: "gone.jpg", at: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? NicheFault, .unknownGlow)
        }
        XCTAssertThrowsError(try empty.attachStill(id: first.id, name: "", at: now, calendar: calendar)) { error in
            XCTAssertEqual(error as? NicheFault, .emptyMedia)
        }

        let past = AediculeGMT.instant(2026, 8, 1)
        _ = empty.catchGlow(.gleam, at: past, calendar: calendar)
        XCTAssertTrue(empty.canDraw(at: now, calendar: calendar))
        XCTAssertEqual(empty.drawPool(at: now, calendar: calendar).count, 1)
        XCTAssertFalse(empty.drawPool(at: now, calendar: calendar).contains { $0.kind == .live })
    }

    func test_rolesAreFoldedNotStored() throws {
        let now = AediculeGMT.instant(2026, 9, 17)
        let niche = NicheSeed.document(at: now, calendar: calendar)
        let data = try niche.encoded()
        let text = String(data: data, encoding: .utf8) ?? ""
        XCTAssertFalse(text.contains("\"kind\""))
        XCTAssertFalse(text.contains("\"live\""))
        XCTAssertFalse(text.contains("\"wick\""))
        XCTAssertFalse(text.contains("\"capsule\""))
        XCTAssertTrue(text.contains("\"daykey\""))
        XCTAssertTrue(text.contains("\"hue\""))

        let reloaded = try NicheDocument.read(data)
        XCTAssertEqual(reloaded.glows.count, niche.glows.count)
        XCTAssertGreaterThanOrEqual(reloaded.liveToday(at: now, calendar: calendar).count, 4)
        XCTAssertGreaterThanOrEqual(reloaded.drawPool(at: now, calendar: calendar).count, 4)
        XCTAssertGreaterThanOrEqual(reloaded.capsuleCount(at: now, calendar: calendar), 1)
        XCTAssertTrue(reloaded.canCatch)
        XCTAssertTrue(reloaded.canDraw(at: now, calendar: calendar))
        XCTAssertTrue(reloaded.onboardingComplete)
        for glow in reloaded.folded(at: now, calendar: calendar) {
            XCTAssertFalse(glow.spark.hue.spokenName.isEmpty)
        }
    }

    func test_seedLeavesCatchAndDrawEnabled() {
        let now = AediculeGMT.instant(2026, 9, 17, hour: 10)
        let niche = NicheSeed.document(at: now, calendar: calendar)
        XCTAssertTrue(niche.canCatch)
        XCTAssertTrue(niche.canDraw(at: now, calendar: calendar))
        XCTAssertGreaterThanOrEqual(niche.liveToday(at: now, calendar: calendar).count, 4)
        XCTAssertGreaterThanOrEqual(niche.rays.count, 1)
        XCTAssertGreaterThanOrEqual(niche.capsuleCount(at: now, calendar: calendar), 4)
        XCTAssertGreaterThanOrEqual(niche.capsuleCollage(at: now, calendar: calendar).count, 4)
        XCTAssertFalse(niche.liveToday(at: now, calendar: calendar).isEmpty)
        XCTAssertEqual(Set(niche.liveToday(at: now, calendar: calendar).map(\.spark.daykey)).count, 1)
    }

    func test_codecSwitchesOnSchemaVersion() throws {
        let niche = NicheSeed.document(at: AediculeGMT.instant(2026, 9, 17), calendar: calendar)
        let data = try niche.encoded()
        let decoded = try NicheDocument.read(data)
        XCTAssertEqual(decoded.schemaVersion, 1)
        XCTAssertEqual(decoded.glows.count, niche.glows.count)
        XCTAssertEqual(decoded.rays.count, niche.rays.count)

        XCTAssertThrowsError(try NicheDocument.read(Data("{\"schemaVersion\":99}".utf8))) { error in
            XCTAssertEqual(error as? NicheCodecError, .unknownSchema(99))
        }
        XCTAssertThrowsError(try NicheDocument.read(Data("[]".utf8))) { error in
            XCTAssertEqual(error as? NicheCodecError, .damaged)
        }
    }
}
