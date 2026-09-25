import Foundation

/// Role: Wick. Desk weave_pace. weeksRemaining = (target − done) / last7d meters. Nil when this week has no meters.
struct WickPace: Equatable, Sendable {
    var target: Double
    var done: Double
    var last7d: Double?

    var weeksRemaining: Double? {
        guard let last7d, last7d > 0 else { return nil }
        return (target - done) / last7d
    }
}
