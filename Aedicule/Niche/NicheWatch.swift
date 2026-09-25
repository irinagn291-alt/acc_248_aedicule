import AVFAudio
import Foundation
import Observation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Role: Niche. Presentation fold over NicheStore. Views call catchGlow, attachMedia, foldMidnight, and drawRay.
@MainActor
@Observable
final class NicheWatch {
    let store: any NicheStoring
    var document: NicheDocument
    var notice: NicheNotice?
    var segment: NicheSegment = .moments
    var fault: String?
    var restoredLine: String?
    var didLoad = false
    var isHauling = false
    var isCommitting = false
    var commitTick = 0
    var showCatch = false
    var showTwist = false
    var showBloom = false
    var bloomID: UUID?
    var showMicAsk = false
    var showMicDenied = false
    var showSuccess = false
    var confirmReset = false
    var focusedGlowID: UUID?
    var catchHue: GlowHue = .ember
    var stillCache: [String: Data] = [:]
    var isRecording = false
    var isPlaying = false
    var pendingVoiceID: UUID?
    var busyVerb: NicheLiveVerb?

    private var hookConsumed = false
    private var haulToken: UUID?
    private var appeared = false
    private let calendar: Calendar
    private let clock: @Sendable () -> Date
    private let shouldLoad: Bool
    private let permitSeed: Bool
    var now: Date

    @ObservationIgnored private var recorder: AVAudioRecorder?
    @ObservationIgnored private var player: AVAudioPlayer?
    @ObservationIgnored private var recordURL: URL?

    init(
        store: any NicheStoring,
        document: NicheDocument = .empty,
        notice: NicheNotice? = nil,
        calendar: Calendar = .current,
        now: Date = Date(),
        clock: @escaping @Sendable () -> Date = { Date() },
        shouldLoad: Bool = true,
        permitSeed: Bool? = nil
    ) {
        self.store = store
        self.document = document
        self.notice = notice
        self.calendar = calendar
        self.now = now
        self.clock = clock
        self.shouldLoad = shouldLoad
        self.permitSeed = permitSeed ?? Self.simulatorSeed
    }

    static var simulatorSeed: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    static func live() -> NicheWatch {
        let directory: URL
        do {
            directory = try NicheStore.applicationSupportDirectory()
        } catch {
            directory = FileManager.default.temporaryDirectory.appendingPathComponent(
                "Aedicule",
                isDirectory: true
            )
        }
        return NicheWatch(store: NicheStore(directory: directory))
    }

    static func previewSeeded(now: Date = Date(), calendar: Calendar = .current) -> NicheWatch {
        let document = NicheSeed.document(at: now, calendar: calendar)
        let watch = NicheWatch(
            store: NicheHold(document: document),
            document: document,
            calendar: calendar,
            now: now,
            clock: { now },
            shouldLoad: false,
            permitSeed: false
        )
        watch.didLoad = true
        watch.syncFocus()
        return watch
    }

    static func previewEmpty() -> NicheWatch {
        var document = NicheDocument.empty
        document.onboardingComplete = true
        let watch = NicheWatch(
            store: NicheHold(document: document),
            document: document,
            shouldLoad: false,
            permitSeed: false
        )
        watch.didLoad = true
        return watch
    }

    var calendarForDisplay: Calendar { calendar }

    var showsOnboarding: Bool {
        didLoad && !document.onboardingComplete
    }

    var liveToday: [Glow] {
        document.liveToday(at: now, calendar: calendar)
    }

    var drawPool: [Glow] {
        document.drawPool(at: now, calendar: calendar)
    }

    var canCatch: Bool { document.canCatch }

    var canDraw: Bool { document.canDraw(at: now, calendar: calendar) }

    var stagedGlow: Glow? {
        guard let id = document.stagedGlowID else { return nil }
        return document.folded(at: now, calendar: calendar).first { $0.id == id }
    }

    var focusedLive: Glow? {
        if let focusedGlowID {
            return liveToday.first { $0.id == focusedGlowID }
        }
        return liveToday.first
    }

    var capsuleCount: Int {
        document.capsuleCount(at: now, calendar: calendar)
    }

    var rayCount: Int { document.rayCount }

    var collage: [(daykey: Int, glows: [Glow])] {
        document.capsuleCollage(at: now, calendar: calendar)
            .map { (daykey: $0.key, glows: $0.value) }
            .sorted { $0.daykey > $1.daykey }
    }

    var capsules: [Glow] {
        collage.flatMap(\.glows)
    }

    var collageYearLabel: String {
        let years = Set(capsules.map { $0.spark.daykey / 10_000 }).sorted()
        if years.isEmpty {
            return NicheFigures.integer(VotiveDay.from(now, calendar: calendar).rawValue / 10_000)
        }
        return years.map { NicheFigures.integer($0) }.joined(separator: ", ")
    }

    func rayOnCapsule(_ glow: Glow) -> Bool {
        document.rays.contains { $0.glowID == glow.id }
    }

    var bloomGlow: Glow? {
        guard let bloomID else { return nil }
        return capsules.first { $0.id == bloomID }
    }

    var momentsLoad: NicheLoad {
        if notice == .cleared { return .fault }
        if document.glows.isEmpty { return .empty }
        return .populated
    }

    var gardenLoad: NicheLoad {
        if notice == .cleared { return .fault }
        if capsuleCount == 0 { return .empty }
        return .populated
    }

    var settingsLoad: NicheLoad {
        if notice == .cleared { return .fault }
        if document.glows.isEmpty { return .empty }
        return .populated
    }

    var twistLoad: NicheLoad {
        if notice == .cleared { return .fault }
        if document.rays.isEmpty, stagedGlow == nil { return .empty }
        return .populated
    }

    var liveVerb: NicheLiveVerb {
        busyVerb ?? .catchGlow
    }

    var jobTitle: String { NicheCopy.jobTitle }

    var jobLine: String { NicheCopy.jobLine }

    var capsuleCountLabel: String { NicheFigures.integer(capsuleCount) }

    var rayCountLabel: String { NicheFigures.integer(rayCount) }

    func stillData(for spark: GlowSpark) -> Data? {
        guard let name = spark.stillName else { return nil }
        return stillCache[name]
    }

    func appear(arguments: [String] = ProcessInfo.processInfo.arguments) async {
        if appeared {
            applyHook(arguments: arguments)
            return
        }
        appeared = true
        now = clock()
        guard shouldLoad else {
            document = await store.snapshot()
            didLoad = true
            syncFocus()
            applyHook(arguments: arguments)
            return
        }
        let token = UUID()
        haulToken = token
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard let self, self.haulToken == token else { return }
            self.isHauling = true
        }
        if permitSeed {
            do {
                _ = try await store.seedDemoIfNeeded(permit: true, now: now, calendar: calendar)
            } catch {
                fault = NicheCopy.seedFault
            }
        }
        let loaded = await store.load(now: now, calendar: calendar)
        document = loaded.document
        notice = loaded.notice
        applyNotice()
        haulToken = nil
        isHauling = false
        didLoad = true
        syncFocus()
        await refreshStills()
        applyHook(arguments: arguments)
    }

    func retry() async {
        fault = nil
        restoredLine = nil
        notice = nil
        appeared = false
        didLoad = false
        hookConsumed = false
        await appear()
    }

    func flush() async {
        do {
            try await store.flush()
        } catch {
            fault = NicheCopy.writeFault
        }
    }

    func handlePhase(_ phase: ScenePhase) {
        switch phase {
        case .inactive, .background:
            stopVoice(commit: true)
            Task { await flush() }
        case .active:
            now = clock()
            Task { await foldDay() }
        @unknown default:
            break
        }
    }

    func foldDay() async {
        now = clock()
        do {
            document = try await store.foldMidnight(at: now, calendar: calendar)
            syncFocus()
        } catch {
            fault = NicheCopy.fault(error)
        }
    }

    func catchGlow() async {
        busyVerb = .catchGlow
        await commit {
            try await store.catchGlow(catchHue, at: clock(), calendar: calendar, id: UUID())
        }
        busyVerb = nil
        if fault == nil {
            focusedGlowID = document.glows.last?.id
            showCatch = false
            markCommit()
        }
    }

    func drawRay() async {
        busyVerb = .draw
        await commit {
            try await store.drawRay(at: clock(), calendar: calendar, slot: nil)
        }
        busyVerb = nil
        if fault == nil {
            markCommit()
        }
    }

    func attachStill(_ data: Data, glowID: UUID) async {
        let jpeg = Self.jpeg(from: data) ?? data
        await commit {
            try await store.attachMedia(
                glowID: glowID,
                still: jpeg,
                voice: nil,
                at: clock(),
                calendar: calendar
            )
        }
        if fault == nil {
            restoredLine = NicheCopy.saved
            await refreshStills()
        }
    }

    func attachVoice(_ data: Data, glowID: UUID) async {
        await commit {
            try await store.attachMedia(
                glowID: glowID,
                still: nil,
                voice: data,
                at: clock(),
                calendar: calendar
            )
        }
        if fault == nil {
            restoredLine = NicheCopy.saved
        }
    }

    func finishOnboarding(arguments: [String] = ProcessInfo.processInfo.arguments) async {
        document = await store.setOnboardingComplete(true)
        await flush()
        applyHook(arguments: arguments)
    }

    func reopenOnboarding() async {
        document = await store.setOnboardingComplete(false)
        segment = .moments
        showTwist = false
        showCatch = false
        showBloom = false
        bloomID = nil
        await flush()
    }

    func resetAll() async {
        isCommitting = true
        stopVoice(commit: false)
        do {
            try await store.resetAllData()
            document = await store.snapshot()
            notice = nil
            fault = nil
            restoredLine = nil
            stillCache = [:]
            segment = .moments
            showTwist = false
            showCatch = false
            showBloom = false
            bloomID = nil
            focusedGlowID = nil
            hookConsumed = false
        } catch {
            fault = NicheCopy.writeFault
        }
        isCommitting = false
    }

    func openCatch() {
        catchHue = .ember
        showCatch = true
    }

    func jumpMoments() {
        segment = .moments
        showTwist = false
        showBloom = false
        bloomID = nil
    }

    func openBloom(_ glow: Glow) {
        bloomID = glow.id
        showBloom = true
    }

    func applyHook(arguments: [String] = ProcessInfo.processInfo.arguments) {
        guard let pane = NicheLatch.consume(
            arguments: arguments,
            onboardingComplete: document.onboardingComplete,
            consumed: &hookConsumed
        ) else { return }
        segment = pane.segment
        showTwist = false
        showCatch = false
        showBloom = false
        bloomID = nil
    }

    func askMic(for glowID: UUID) {
        pendingVoiceID = glowID
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            startRecord(glowID: glowID)
        case .undetermined:
            showMicAsk = true
        case .denied:
            showMicDenied = true
        @unknown default:
            showMicDenied = true
        }
    }

    func continueMic() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                guard let self else { return }
                self.showMicAsk = false
                if granted, let id = self.pendingVoiceID {
                    self.startRecord(glowID: id)
                } else {
                    self.showMicDenied = true
                }
            }
        }
    }

    func openSystemSettings() {
        #if canImport(UIKit)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }

    func toggleRecord(for glowID: UUID) {
        if isRecording {
            stopVoice(commit: true)
        } else {
            askMic(for: glowID)
        }
    }

    func playVoice(named: String) async {
        stopPlay()
        guard let data = await store.mediaBytes(named: named) else { return }
        do {
            player = try AVAudioPlayer(data: data)
            player?.play()
            isPlaying = true
        } catch {
            fault = NicheCopy.voiceFault
            isPlaying = false
        }
    }

    func stopPlay() {
        player?.stop()
        player = nil
        isPlaying = false
    }

    func startRecord(glowID: UUID) {
        stopVoice(commit: false)
        pendingVoiceID = glowID
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("aed-voice.m4a")
        recordURL = url
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        ]
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
            let next = try AVAudioRecorder(url: url, settings: settings)
            next.prepareToRecord()
            next.record()
            recorder = next
            isRecording = true
        } catch {
            fault = NicheCopy.voiceFault
            isRecording = false
        }
    }

    func stopVoice(commit: Bool) {
        let wasRecording = isRecording
        let glowID = pendingVoiceID
        let url = recordURL
        recorder?.stop()
        recorder = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        guard commit, wasRecording, let glowID, let url else { return }
        guard let data = try? Data(contentsOf: url), !data.isEmpty else { return }
        Task { await attachVoice(data, glowID: glowID) }
    }

    func syncFocus() {
        let live = liveToday
        if let focusedGlowID, live.contains(where: { $0.id == focusedGlowID }) {
            return
        }
        focusedGlowID = live.first?.id
    }

    private func refreshStills() async {
        var next: [String: Data] = [:]
        for spark in document.glows {
            if let name = spark.stillName, let data = await store.mediaBytes(named: name) {
                next[name] = data
            }
        }
        stillCache = next
    }

    private func commit(_ work: () async throws -> NicheDocument) async {
        guard !isCommitting else { return }
        isCommitting = true
        defer { isCommitting = false }
        now = clock()
        do {
            document = try await work()
            fault = nil
            syncFocus()
        } catch {
            fault = NicheCopy.fault(error)
        }
    }

    private func markCommit() {
        commitTick += 1
        restoredLine = NicheCopy.saved
        showSuccess = true
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            self?.showSuccess = false
        }
    }

    private func applyNotice() {
        switch notice {
        case .restored:
            restoredLine = NicheCopy.restored
            if fault == NicheCopy.readFault {
                fault = nil
            }
        case .cleared:
            fault = NicheCopy.readFault
            restoredLine = nil
        case nil:
            break
        }
    }

    private static func jpeg(from data: Data) -> Data? {
        #if canImport(UIKit)
        guard let image = UIImage(data: data) else { return nil }
        return image.jpegData(compressionQuality: 0.82)
        #else
        return data
        #endif
    }
}

enum NicheLoad: Equatable, Sendable {
    case empty
    case populated
    case fault
}

enum NicheLiveVerb: Equatable, Sendable {
    case catchGlow
    case draw
}
