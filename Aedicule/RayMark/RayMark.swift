import Foundation

/// Role: RayMark. Draw samples one Wick or Capsule, never a Live glow, and writes this mark.
struct RayMark: Equatable, Sendable, Identifiable, Codable {
    var id: UUID
    var glowID: UUID
    var drawnUnix: Double
    var drawnDaykey: Int
}
