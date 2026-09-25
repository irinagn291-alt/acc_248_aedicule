import Foundation

/// Role: Niche. Moments, Garden, Settings. One glass. No Game segment.
enum NicheSegment: String, Equatable, Sendable {
    case moments
    case garden
    case settings
}

/// Role: Niche. Launch keys for live shots. today, log, and goals open three different screens.
enum NichePane: String, Equatable, Sendable {
    case today
    case log
    case goals

    var segment: NicheSegment {
        switch self {
        case .today: .moments
        case .log: .garden
        case .goals: .settings
        }
    }
}

/// Role: Niche. Reads ProcessInfo `-ReviewScreen today|log|goals` once after onboarding. No View.
enum NicheLatch {
    static let flag = "-ReviewScreen"

    static func consume(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        onboardingComplete: Bool,
        consumed: inout Bool
    ) -> NichePane? {
        guard onboardingComplete, !consumed else { return nil }
        consumed = true
        guard let index = arguments.firstIndex(of: NicheLatch.flag) else { return nil }
        let next = arguments.index(after: index)
        guard arguments.indices.contains(next) else { return nil }
        return NichePane(rawValue: arguments[next])
    }
}
