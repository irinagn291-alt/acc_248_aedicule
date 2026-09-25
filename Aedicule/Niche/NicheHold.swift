import Foundation

/// Role: Niche. In-memory niche for previews and tests. Views never see this type.
actor NicheHold: NicheStoring {
    private var memory: NicheDocument
    private var notice: NicheNotice?
    private var files: [String: Data] = [:]

    init(document: NicheDocument = .empty, notice: NicheNotice? = nil) {
        self.memory = document
        self.notice = notice
    }

    func load(now: Date, calendar: Calendar) async -> (document: NicheDocument, notice: NicheNotice?) {
        memory.foldMidnight(at: now, calendar: calendar)
        return (memory, notice)
    }

    func snapshot() async -> NicheDocument {
        memory
    }

    func catchGlow(_ hue: GlowHue, at now: Date, calendar: Calendar, id: UUID) async throws -> NicheDocument {
        _ = memory.catchGlow(hue, at: now, calendar: calendar, id: id)
        return memory
    }

    func attachMedia(
        glowID: UUID,
        still: Data?,
        voice: Data?,
        at now: Date,
        calendar: Calendar
    ) async throws -> NicheDocument {
        if still == nil && voice == nil { throw NicheFault.emptyMedia }
        if let still, still.isEmpty { throw NicheFault.emptyMedia }
        if let voice, voice.isEmpty { throw NicheFault.emptyMedia }
        if let still {
            let name = "\(glowID.uuidString.lowercased())-still.jpg"
            files[name] = still
            try memory.attachStill(id: glowID, name: name, at: now, calendar: calendar)
        }
        if let voice {
            let name = "\(glowID.uuidString.lowercased())-voice.m4a"
            files[name] = voice
            try memory.attachVoice(id: glowID, name: name, at: now, calendar: calendar)
        }
        return memory
    }

    func foldMidnight(at now: Date, calendar: Calendar) async throws -> NicheDocument {
        memory.foldMidnight(at: now, calendar: calendar)
        return memory
    }

    func drawRay(at now: Date, calendar: Calendar, slot: Int?) async throws -> NicheDocument {
        _ = try memory.drawRay(at: now, calendar: calendar, slot: slot)
        return memory
    }

    func setOnboardingComplete(_ flag: Bool) async -> NicheDocument {
        memory.onboardingComplete = flag
        return memory
    }

    func flush() async throws {}

    func resetAllData() async throws {
        memory = .empty
        notice = nil
        files = [:]
    }

    func seedDemoIfNeeded(permit: Bool, now: Date, calendar: Calendar) async throws -> NicheDocument? {
        _ = permit
        _ = now
        _ = calendar
        return nil
    }

    func mediaBytes(named: String) async -> Data? {
        files[named]
    }
}
