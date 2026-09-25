import Foundation

/// Role: Glow. Persisted spark. Role is not a stored field; the niche folds this into Live, Wick, or Capsule.
struct GlowSpark: Equatable, Sendable, Identifiable, Codable {
    var id: UUID
    var daykey: Int
    var hue: GlowHue
    var stillName: String?
    var voiceName: String?
    var caughtUnix: Double
}

/// Role: Glow. Emotion hue on every spark. Colour is never the only signal; `spokenName` travels with it.
enum GlowHue: String, Codable, CaseIterable, Sendable {
    case ember
    case hush
    case bloom
    case tide
    case hearth
    case gleam
    case still
    case lift

    var spokenName: String {
        switch self {
        case .ember: "Ember"
        case .hush: "Hush"
        case .bloom: "Bloom"
        case .tide: "Tide"
        case .hearth: "Hearth"
        case .gleam: "Gleam"
        case .still: "Still"
        case .lift: "Lift"
        }
    }
}

enum GlowKind: Equatable, Sendable {
    case live
    case wick
    case capsule
}

/// Role: Glow. ADT Live | Wick | Capsule. Catch writes a spark. Midnight folds Live to Wick and freezes media. Age over 30 days writes Capsule.
enum Glow: Equatable, Sendable, Identifiable {
    case live(GlowSpark)
    case wick(GlowSpark)
    case capsule(GlowSpark)

    var id: UUID { spark.id }

    var spark: GlowSpark {
        switch self {
        case .live(let spark), .wick(let spark), .capsule(let spark):
            return spark
        }
    }

    var kind: GlowKind {
        switch self {
        case .live: .live
        case .wick: .wick
        case .capsule: .capsule
        }
    }

    var canAttach: Bool {
        if case .live = self { return true }
        return false
    }

    static func fold(_ spark: GlowSpark, today: VotiveDay, calendar: Calendar) -> Glow {
        if spark.daykey == today.rawValue {
            return .live(spark)
        }
        if CapsuleBloom.isDue(spark.daykey, today: today, calendar: calendar) {
            return .capsule(spark)
        }
        return .wick(spark)
    }

    func foldToWick(today: VotiveDay, calendar: Calendar) -> Glow {
        Self.fold(spark, today: today, calendar: calendar)
    }
}
