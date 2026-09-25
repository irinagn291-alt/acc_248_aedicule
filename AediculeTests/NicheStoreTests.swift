import XCTest
@testable import Aedicule

final class NicheStoreTests: XCTestCase {
    private var directory: URL!
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var calendar: Calendar { AediculeGMT.calendar }

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(
            UUID().uuidString,
            isDirectory: true
        )
        suiteName = "aed.test.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        if let directory {
            try? FileManager.default.removeItem(at: directory)
        }
        if let suiteName {
            defaults?.removePersistentDomain(forName: suiteName)
        }
        directory = nil
        defaults = nil
        suiteName = nil
    }

    func test_roundTripReloadPreservesCatchAttachAndRay() async throws {
        let now = AediculeGMT.instant(2026, 9, 17, hour: 16)
        let store = makeStore()
        let liveID = UUID()
        _ = try await store.catchGlow(.ember, at: now, calendar: calendar, id: liveID)
        _ = try await store.attachMedia(
            glowID: liveID,
            still: Data("still".utf8),
            voice: Data("voice".utf8),
            at: now,
            calendar: calendar
        )
        let past = AediculeGMT.instant(2026, 9, 4)
        _ = try await store.catchGlow(.hearth, at: past, calendar: calendar)
        _ = try await store.drawRay(at: now, calendar: calendar, slot: 0)
        try await store.flush()

        let relaunched = makeStore()
        let loaded = await relaunched.load(now: now, calendar: calendar)
        XCTAssertNil(loaded.notice)
        XCTAssertEqual(loaded.document.glows.count, 2)
        XCTAssertEqual(loaded.document.liveToday(at: now, calendar: calendar).count, 1)
        XCTAssertEqual(loaded.document.rays.count, 1)
        XCTAssertEqual(loaded.document.stagedGlowID, loaded.document.drawPool(at: now, calendar: calendar).first?.id)
        let live = try XCTUnwrap(loaded.document.glows.first { $0.id == liveID })
        XCTAssertEqual(live.stillName, "\(liveID.uuidString.lowercased())-still.jpg")
        XCTAssertEqual(live.voiceName, "\(liveID.uuidString.lowercased())-voice.m4a")
        let still = await relaunched.mediaBytes(named: live.stillName ?? "")
        XCTAssertEqual(still, Data("still".utf8))
        XCTAssertEqual(VotiveDay.from(now, calendar: calendar).rawValue, 20260917)
    }

    func test_corruptSnapshotFallsBackToBackup() async throws {
        let now = AediculeGMT.instant(2026, 9, 17)
        let store = makeStore()
        _ = try await store.catchGlow(.bloom, at: now, calendar: calendar)
        _ = try await store.catchGlow(.hearth, at: AediculeGMT.instant(2026, 9, 10), calendar: calendar)
        if let good = defaults.data(forKey: NicheVault.snapshot) {
            defaults.set(good, forKey: NicheVault.backup)
        }
        let file = directory.appendingPathComponent("niche.json")
        let backup = directory.appendingPathComponent("niche.json.backup")
        if FileManager.default.fileExists(atPath: file.path) {
            try? FileManager.default.removeItem(at: backup)
            try FileManager.default.copyItem(at: file, to: backup)
        }
        defaults.set(Data("{not-json".utf8), forKey: NicheVault.snapshot)
        try Data("{not-json".utf8).write(to: file)

        let loaded = await makeStore().load(now: now, calendar: calendar)
        XCTAssertEqual(loaded.notice, .restored)
        XCTAssertEqual(loaded.document.glows.count, 2)
        XCTAssertEqual(loaded.document.liveToday(at: now, calendar: calendar).count, 1)
    }

    func test_corruptSnapshotWithoutBackupStartsEmpty() async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defaults.set(Data("nope".utf8), forKey: NicheVault.snapshot)
        try Data("nope".utf8).write(to: directory.appendingPathComponent("niche.json"))
        let loaded = await makeStore().load(now: AediculeGMT.instant(2026, 9, 17), calendar: calendar)
        XCTAssertEqual(loaded.notice, .cleared)
        XCTAssertEqual(loaded.document.glows, [])
        XCTAssertFalse(loaded.document.onboardingComplete)
    }

    func test_resetAllDataClearsSnapshotFilesAndMedia() async throws {
        let store = makeStore()
        let now = AediculeGMT.instant(2026, 9, 17)
        let id = UUID()
        _ = try await store.catchGlow(.ember, at: now, calendar: calendar, id: id)
        _ = try await store.attachMedia(glowID: id, still: Data("x".utf8), at: now, calendar: calendar)
        try await store.resetAllData()
        let loaded = await store.load(now: now, calendar: calendar)
        XCTAssertEqual(loaded.document.glows, [])
        XCTAssertNil(defaults.data(forKey: NicheVault.snapshot))
        XCTAssertNil(defaults.data(forKey: NicheVault.backup))
        let leftovers = (try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)) ?? []
        XCTAssertTrue(leftovers.filter { $0.pathExtension == "json" }.isEmpty)
        let media = await store.mediaBytes(named: "\(id.uuidString.lowercased())-still.jpg")
        XCTAssertNil(media)
    }

    func test_onboardingFlagDebouncesUntilFlush() async throws {
        let store = makeStore()
        _ = try await store.catchGlow(.ember, at: AediculeGMT.instant(2026, 9, 17), calendar: calendar)
        _ = await store.setOnboardingComplete(true)
        try await store.flush()
        let loaded = await makeStore().load(now: AediculeGMT.instant(2026, 9, 17), calendar: calendar)
        XCTAssertTrue(loaded.document.onboardingComplete)
    }

    func test_seedWritesOnceAndLeavesVerbsEnabled() async throws {
        let store = makeStore()
        let now = AediculeGMT.instant(2026, 9, 17, hour: 10)
        let denied = try await store.seedDemoIfNeeded(permit: false, now: now, calendar: calendar)
        XCTAssertNil(denied)

        let first = try await store.seedDemoIfNeeded(permit: true, now: now, calendar: calendar)
        let second = try await store.seedDemoIfNeeded(permit: true, now: now, calendar: calendar)
        XCTAssertNil(second)
        XCTAssertEqual(first?.onboardingComplete, true)
        XCTAssertEqual(first?.canCatch, true)
        XCTAssertEqual(first?.canDraw(at: now, calendar: calendar), true)
        XCTAssertGreaterThanOrEqual(first?.liveToday(at: now, calendar: calendar).count ?? 0, 4)
        XCTAssertGreaterThanOrEqual(first?.capsuleCount(at: now, calendar: calendar) ?? 0, 1)
        XCTAssertGreaterThanOrEqual(first?.rays.count ?? 0, 1)
        XCTAssertTrue(defaults.bool(forKey: NicheVault.demo))
        XCTAssertNotNil(defaults.data(forKey: NicheVault.snapshot))
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: directory.appendingPathComponent("niche.json").path)
        )
    }

    private func makeStore() -> NicheStore {
        NicheStore(
            directory: directory,
            defaultsSuiteName: suiteName,
            quietNanos: 0
        )
    }
}
