import Foundation

/// Role: Niche. Display fold for daykeys, Capsule counts, and RayMark counts. Round only here. Tabular figures.
enum NicheFigures {
    static func integer(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    static func dayKey(_ value: Int) -> String {
        integer(value)
    }

    static func day(_ value: Int, calendar: Calendar) -> String {
        let votive = VotiveDay(rawValue: value)
        guard let start = votive.startDate(calendar: calendar) else {
            return integer(value)
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: start)
    }
}
