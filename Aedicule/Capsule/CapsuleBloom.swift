import Foundation

/// Role: Capsule. Age over 30 days from the daykey blooms the garden. Year collage is Capsules keyed as Int YYYYMMDD.
enum CapsuleBloom {
    static let thresholdDays = 30

    static func isDue(_ daykey: Int, today: VotiveDay, calendar: Calendar) -> Bool {
        VotiveDay(rawValue: daykey).ageDays(until: today, calendar: calendar) > thresholdDays
    }

    static func collage(_ glows: [Glow]) -> [Int: [Glow]] {
        var grouped: [Int: [Glow]] = [:]
        for glow in glows {
            guard case .capsule(let spark) = glow else { continue }
            grouped[spark.daykey, default: []].append(glow)
        }
        return grouped
    }
}
