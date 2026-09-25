import XCTest
@testable import Aedicule

final class NicheWatchTests: XCTestCase {
    private var calendar: Calendar { AediculeGMT.calendar }
    private var now: Date { AediculeGMT.instant(2026, 9, 17, hour: 10) }

    @MainActor
    func test_reviewScreenOpensThreeDifferentSegmentsAfterOnboarding() async {
        let seeded = NicheSeed.document(at: now, calendar: calendar)
        XCTAssertTrue(seeded.onboardingComplete)

        let today = makeWatch(seeded)
        await today.appear(arguments: ["-ReviewScreen", "today"])
        XCTAssertEqual(today.segment, .moments)

        let log = makeWatch(seeded)
        await log.appear(arguments: ["-ReviewScreen", "log"])
        XCTAssertEqual(log.segment, .garden)

        let goals = makeWatch(seeded)
        await goals.appear(arguments: ["-ReviewScreen", "goals"])
        XCTAssertEqual(goals.segment, .settings)

        XCTAssertNotEqual(today.segment, log.segment)
        XCTAssertNotEqual(log.segment, goals.segment)
        XCTAssertNotEqual(today.segment, goals.segment)
    }

    @MainActor
    func test_hookIgnoredUntilOnboardingCompletesThenReadsOnce() async {
        let watch = makeWatch(.empty)
        await watch.appear(arguments: ["-ReviewScreen", "log"])
        XCTAssertTrue(watch.showsOnboarding)
        XCTAssertEqual(watch.segment, .moments)

        await watch.finishOnboarding(arguments: ["-ReviewScreen", "log"])
        XCTAssertFalse(watch.showsOnboarding)
        XCTAssertEqual(watch.segment, .garden)

        let second = makeWatch(watch.document)
        await second.appear(arguments: ["-ReviewScreen", "goals"])
        XCTAssertEqual(second.segment, .settings)
        await second.appear(arguments: ["-ReviewScreen", "today"])
        XCTAssertEqual(second.segment, .settings)
    }

    @MainActor
    func test_momentsGardenSettingsLoadEmptyPopulatedFaultAndVerbsEnabledOnSeed() async {
        let emptyWatch = NicheWatch.previewEmpty()
        await emptyWatch.appear()
        XCTAssertEqual(emptyWatch.momentsLoad, .empty)
        XCTAssertEqual(emptyWatch.gardenLoad, .empty)
        XCTAssertEqual(emptyWatch.settingsLoad, .empty)
        XCTAssertTrue(emptyWatch.canCatch)
        XCTAssertFalse(emptyWatch.canDraw)

        let seeded = NicheSeed.document(at: now, calendar: calendar)
        let populated = makeWatch(seeded)
        await populated.appear()
        XCTAssertEqual(populated.momentsLoad, .populated)
        XCTAssertEqual(populated.gardenLoad, .populated)
        XCTAssertEqual(populated.settingsLoad, .populated)
        XCTAssertTrue(populated.canCatch)
        XCTAssertTrue(populated.canDraw)
        XCTAssertTrue(populated.document.onboardingComplete)
        XCTAssertEqual(populated.jobTitle, NicheCopy.jobTitle)
        XCTAssertEqual(populated.jobLine, NicheCopy.jobLine)
        XCTAssertFalse(populated.liveToday.isEmpty)
        XCTAssertGreaterThanOrEqual(populated.capsuleCount, 4)
        XCTAssertGreaterThanOrEqual(populated.rayCount, 1)
        XCTAssertEqual(populated.capsules.count, populated.capsuleCount)
        XCTAssertFalse(populated.capsules.contains { $0.kind != .capsule })
        XCTAssertFalse(populated.collageYearLabel.isEmpty)
        if let first = populated.capsules.first {
            XCTAssertEqual(populated.rayOnCapsule(first), populated.document.rays.contains { $0.glowID == first.id })
        }

        var brokenDoc = NicheDocument.empty
        brokenDoc.onboardingComplete = true
        let frozen = now
        let broken = NicheWatch(
            store: NicheHold(document: brokenDoc, notice: .cleared),
            document: brokenDoc,
            notice: .cleared,
            calendar: calendar,
            now: frozen,
            clock: { frozen },
            shouldLoad: false,
            permitSeed: false
        )
        await broken.appear()
        XCTAssertEqual(broken.momentsLoad, .fault)
        XCTAssertEqual(broken.gardenLoad, .fault)
        XCTAssertEqual(broken.settingsLoad, .fault)
    }

    @MainActor
    func test_catchWritesLiveGlowAndDrawLeavesTodayOut() async throws {
        var niche = NicheDocument.empty
        niche.onboardingComplete = true
        _ = niche.catchGlow(.hearth, at: AediculeGMT.instant(2026, 9, 10), calendar: calendar)
        let watch = makeWatch(niche)
        await watch.appear()
        watch.catchHue = .ember
        await watch.catchGlow()
        XCTAssertEqual(watch.liveToday.count, 1)
        XCTAssertEqual(watch.liveToday.first?.spark.hue, .ember)
        XCTAssertEqual(watch.restoredLine, NicheCopy.saved)
        XCTAssertEqual(watch.commitTick, 1)

        let liveID = try XCTUnwrap(watch.liveToday.first?.id)
        await watch.drawRay()
        XCTAssertEqual(watch.commitTick, 2)
        XCTAssertNotEqual(watch.document.stagedGlowID, liveID)
        XCTAssertFalse(watch.drawPool.contains { $0.kind == .live })
        XCTAssertFalse(watch.drawPool.contains { $0.spark.daykey == VotiveDay.from(now, calendar: calendar).rawValue })
        XCTAssertEqual(watch.stagedGlow?.kind, .wick)
    }

    func test_craftRadiiCopyAndContactStayOnContract() {
        XCTAssertEqual(NicheCraft.cardRadius, 16)
        XCTAssertEqual(NicheCraft.chipRadius, 10)
        XCTAssertEqual(NicheCraft.unit, 8)
        XCTAssertEqual(NicheCraft.tap, 44)
        XCTAssertEqual(NicheCraft.pressScale, 0.97)
        XCTAssertEqual(NicheFace.Step.allCases.count, 5)
        XCTAssertEqual(NicheClient.contactURL.absoluteString, "https://aedicule-niche.pro/contact-us")
        XCTAssertEqual(NicheCopy.emptyHeadline, "Nothing saved yet.")
        XCTAssertEqual(NicheCopy.emptyLine, "Catch a warm moment.")
        XCTAssertEqual(NicheCopy.catchVerb, "Catch")
        XCTAssertEqual(NicheCopy.drawVerb, "Draw")
        XCTAssertEqual(NicheCopy.saved, "Saved.")
        XCTAssertFalse(NicheCopy.jobLine.contains("\u{2014}"))
        XCTAssertFalse(NicheCopy.twistLine.contains("\u{2014}"))
        XCTAssertFalse(NicheCopy.jobTitle.contains("\u{2014}"))
        XCTAssertEqual(NicheCopy.jobTitle, "Catch a glow")
        XCTAssertEqual(NicheCopy.jobLine, "Tap Catch. Draw a ray later.")
        XCTAssertEqual(NicheCopy.rayCaption, "Ray")
        XCTAssertEqual(NicheCopy.gardenJob, "The garden bloomed.")
        XCTAssertEqual(NicheCopy.gardenNext, "Tap a Capsule, or Open Moments to Catch.")
        XCTAssertEqual(NicheCopy.openMoments, "Open Moments")
        XCTAssertFalse(NicheCopy.gardenJob.contains("\u{2014}"))
        XCTAssertFalse(NicheCopy.gardenNext.contains("\u{2014}"))
        XCTAssertEqual(NichePane.today.segment, .moments)
        XCTAssertEqual(NicheLatch.flag, "-ReviewScreen")
        XCTAssertEqual(NicheFigures.integer(31), NumberFormatter.localizedString(from: 31, number: .decimal))
        XCTAssertEqual(NicheFigures.dayKey(20260917), NicheFigures.integer(20260917))
        XCTAssertEqual(NicheCopy.role(.live), "Live")
        XCTAssertEqual(NicheCopy.role(.wick), "Wick")
        XCTAssertEqual(NicheCopy.role(.capsule), "Capsule")
        XCTAssertEqual(NicheCopy.fault(NicheFault.emptyDraw), "Nothing cooled to draw.")
    }

    @MainActor
    func test_openBloomThenJumpMomentsClearsGardenSheet() async throws {
        let seeded = NicheSeed.document(at: now, calendar: calendar)
        let watch = makeWatch(seeded)
        await watch.appear()
        let glow = try XCTUnwrap(watch.capsules.first)
        watch.openBloom(glow)
        XCTAssertTrue(watch.showBloom)
        XCTAssertEqual(watch.bloomID, glow.id)
        XCTAssertEqual(watch.bloomGlow?.id, glow.id)
        watch.jumpMoments()
        XCTAssertEqual(watch.segment, .moments)
        XCTAssertFalse(watch.showBloom)
        XCTAssertNil(watch.bloomID)
    }

    @MainActor
    private func makeWatch(_ document: NicheDocument) -> NicheWatch {
        let frozen = now
        let cal = calendar
        let watch = NicheWatch(
            store: NicheHold(document: document),
            document: document,
            calendar: cal,
            now: frozen,
            clock: { frozen },
            shouldLoad: false,
            permitSeed: false
        )
        watch.didLoad = true
        return watch
    }
}
