import Foundation

/// Role: Niche. Persistence seam. Views call the watch. They never touch UserDefaults.
protocol NicheStoring: Sendable {
    func load(now: Date, calendar: Calendar) async -> (document: NicheDocument, notice: NicheNotice?)
    func snapshot() async -> NicheDocument
    func catchGlow(_ hue: GlowHue, at now: Date, calendar: Calendar, id: UUID) async throws -> NicheDocument
    func attachMedia(
        glowID: UUID,
        still: Data?,
        voice: Data?,
        at now: Date,
        calendar: Calendar
    ) async throws -> NicheDocument
    func foldMidnight(at now: Date, calendar: Calendar) async throws -> NicheDocument
    func drawRay(at now: Date, calendar: Calendar, slot: Int?) async throws -> NicheDocument
    func setOnboardingComplete(_ flag: Bool) async -> NicheDocument
    func flush() async throws
    func resetAllData() async throws
    func seedDemoIfNeeded(permit: Bool, now: Date, calendar: Calendar) async throws -> NicheDocument?
    func mediaBytes(named: String) async -> Data?
}

extension NicheStore: NicheStoring {}
