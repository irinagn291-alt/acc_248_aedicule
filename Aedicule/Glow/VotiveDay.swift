import Foundation

/// Role: Glow. Daykey as Int YYYYMMDD from Calendar.startOfDay in the current zone.
struct VotiveDay: RawRepresentable, Hashable, Sendable, Comparable {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static func from(_ date: Date, calendar: Calendar) -> VotiveDay {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 1970
        let month = parts.month ?? 1
        let day = parts.day ?? 1
        return VotiveDay(rawValue: year * 10_000 + month * 100 + day)
    }

    func startDate(calendar: Calendar) -> Date? {
        var parts = DateComponents()
        parts.year = rawValue / 10_000
        parts.month = (rawValue / 100) % 100
        parts.day = rawValue % 100
        guard let date = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: date)
    }

    func ageDays(until today: VotiveDay, calendar: Calendar) -> Int {
        guard let origin = startDate(calendar: calendar),
              let edge = today.startDate(calendar: calendar)
        else {
            return 0
        }
        return calendar.dateComponents([.day], from: origin, to: edge).day ?? 0
    }

    func shifted(by days: Int, calendar: Calendar) -> VotiveDay {
        guard let start = startDate(calendar: calendar),
              let moved = calendar.date(byAdding: .day, value: days, to: start)
        else {
            return self
        }
        return VotiveDay.from(moved, calendar: calendar)
    }

    static func < (lhs: VotiveDay, rhs: VotiveDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
