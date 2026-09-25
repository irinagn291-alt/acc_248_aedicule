import Foundation

/// Role: RayMark. Draw pool is Wick and Capsule only. Today is never drawn.
enum DrawRay {
    static func pool(_ glows: [Glow], today: VotiveDay) -> [Glow] {
        glows.filter { glow in
            switch glow {
            case .live:
                return false
            case .wick(let spark), .capsule(let spark):
                return spark.daykey != today.rawValue
            }
        }
    }

    static func sample(_ pool: [Glow], slot: Int?) throws -> Glow {
        guard !pool.isEmpty else { throw NicheFault.emptyDraw }
        if let slot, pool.indices.contains(slot) {
            return pool[slot]
        }
        return pool[Int.random(in: 0 ..< pool.count)]
    }
}
