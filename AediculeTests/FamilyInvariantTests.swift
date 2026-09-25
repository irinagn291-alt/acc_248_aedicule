import XCTest
@testable import Aedicule

/// Family invariant: Emotion color + optional local photo/voice. Ray = random moment not today. Year collage. Capsules = moments >30d.
final class FamilyInvariantTests: XCTestCase {
    private var calendar: Calendar { AediculeGMT.calendar }

    func test_emotionHueOnEveryGlowWithOptionalLocalPhotoAndVoice() throws {
        let now = AediculeGMT.instant(2026, 9, 17)
        var niche = NicheDocument.empty
        let caught = niche.catchGlow(.ember, at: now, calendar: calendar)
        XCTAssertEqual(caught.spark.hue, .ember)
        XCTAssertEqual(caught.spark.hue.spokenName, "Ember")
        XCTAssertNil(caught.spark.stillName)
        XCTAssertNil(caught.spark.voiceName)

        try niche.attachStill(id: caught.id, name: "ember.jpg", at: now, calendar: calendar)
        try niche.attachVoice(id: caught.id, name: "ember.m4a", at: now, calendar: calendar)
        let live = try XCTUnwrap(niche.liveToday(at: now, calendar: calendar).first)
        XCTAssertEqual(live.spark.stillName, "ember.jpg")
        XCTAssertEqual(live.spark.voiceName, "ember.m4a")
        XCTAssertEqual(live.kind, .live)

        for glow in niche.folded(at: now, calendar: calendar) {
            XCTAssertFalse(glow.spark.hue.spokenName.isEmpty)
        }
    }

    func test_raySamplesWickOrCapsuleNeverToday() throws {
        let now = AediculeGMT.instant(2026, 9, 17)
        var niche = NicheDocument.empty
        let liveID = UUID()
        _ = niche.catchGlow(.bloom, at: now, calendar: calendar, id: liveID)

        let past = AediculeGMT.instant(2026, 9, 10)
        let wickID = UUID()
        _ = niche.catchGlow(.hearth, at: past, calendar: calendar, id: wickID)

        let drawn = try niche.drawRay(at: now, calendar: calendar, slot: 0)
        XCTAssertEqual(drawn.0.id, wickID)
        XCTAssertNotEqual(drawn.0.id, liveID)
        XCTAssertEqual(drawn.0.kind, .wick)
        XCTAssertEqual(drawn.1.glowID, wickID)
        XCTAssertFalse(niche.drawPool(at: now, calendar: calendar).contains { $0.kind == .live })
        XCTAssertFalse(niche.drawPool(at: now, calendar: calendar).contains { $0.spark.daykey == VotiveDay.from(now, calendar: calendar).rawValue })
        XCTAssertEqual(niche.stagedGlowID, wickID)
        XCTAssertEqual(niche.rayCount, 1)
    }

    func test_yearCollageCapsulesOlderThan30d() {
        let now = AediculeGMT.instant(2026, 9, 17)
        var niche = NicheDocument.empty
        _ = niche.catchGlow(.lift, at: AediculeGMT.instant(2026, 8, 17), calendar: calendar)
        _ = niche.catchGlow(.ember, at: AediculeGMT.instant(2026, 7, 10), calendar: calendar)
        _ = niche.catchGlow(.hush, at: AediculeGMT.instant(2026, 9, 1), calendar: calendar)

        let thirty = AediculeGMT.instant(2026, 9, 16)
        XCTAssertEqual(
            Glow.fold(niche.glows[0], today: VotiveDay.from(thirty, calendar: calendar), calendar: calendar).kind,
            .wick
        )

        let collage = niche.capsuleCollage(at: now, calendar: calendar)
        XCTAssertEqual(niche.capsuleCount(at: now, calendar: calendar), 2)
        XCTAssertEqual(Set(collage.keys), [
            VotiveDay.from(AediculeGMT.instant(2026, 8, 17), calendar: calendar).rawValue,
            VotiveDay.from(AediculeGMT.instant(2026, 7, 10), calendar: calendar).rawValue,
        ])
        XCTAssertEqual(CapsuleBloom.thresholdDays, 30)
        XCTAssertTrue(CapsuleBloom.isDue(
            VotiveDay.from(AediculeGMT.instant(2026, 8, 16), calendar: calendar).rawValue,
            today: VotiveDay.from(now, calendar: calendar),
            calendar: calendar
        ))
        XCTAssertFalse(CapsuleBloom.isDue(
            VotiveDay.from(AediculeGMT.instant(2026, 8, 18), calendar: calendar).rawValue,
            today: VotiveDay.from(now, calendar: calendar),
            calendar: calendar
        ))
        let wick = niche.folded(at: now, calendar: calendar).first { $0.spark.hue == .hush }
        XCTAssertEqual(wick?.kind, .wick)
    }

    func test_startOfDayKeyIsYYYYMMDDInteger() {
        let late = AediculeGMT.instant(2026, 8, 31, hour: 23)
        let next = AediculeGMT.instant(2026, 9, 1, hour: 1)
        XCTAssertEqual(VotiveDay.from(late, calendar: calendar).rawValue, 20260831)
        XCTAssertEqual(VotiveDay.from(next, calendar: calendar).rawValue, 20260901)
        XCTAssertEqual(
            calendar.startOfDay(for: late).timeIntervalSince1970,
            VotiveDay.from(late, calendar: calendar).startDate(calendar: calendar)?.timeIntervalSince1970
        )
    }

    func test_weeksRemainingIsTargetMinusDoneOverLast7dMeters() {
        let paced = WickPace(target: 12, done: 6, last7d: 2)
        XCTAssertEqual(paced.weeksRemaining, 3)
        XCTAssertEqual(paced.last7d, 2)

        XCTAssertNil(WickPace(target: 12, done: 6, last7d: nil).weeksRemaining)
        XCTAssertNil(WickPace(target: 12, done: 6, last7d: 0).weeksRemaining)
        XCTAssertEqual(WickPace(target: 10, done: 4, last7d: 3).weeksRemaining, 2)
    }
}
