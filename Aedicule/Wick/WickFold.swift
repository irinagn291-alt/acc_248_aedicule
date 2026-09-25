import Foundation

/// Role: Wick. Next local midnight folds every Live spark whose daykey is no longer today. Media then refuses attach.
enum WickFold {
    static func midnight(sparks: [GlowSpark], now: Date, calendar: Calendar) -> [Glow] {
        let today = VotiveDay.from(now, calendar: calendar)
        return sparks.map { Glow.fold($0, today: today, calendar: calendar) }
    }
}
