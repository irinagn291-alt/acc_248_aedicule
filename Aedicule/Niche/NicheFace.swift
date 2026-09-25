import SwiftUI

/// Role: Niche. SF Pro via Font.system. Five steps. Display is title, title2 at large AX. No title3, callout, or subheadline.
enum NicheFace {
    enum Step: CaseIterable {
        case display
        case headline
        case body
        case caption
        case figure
    }

    static func font(_ step: Step, axle: DynamicTypeSize = .large) -> Font {
        switch step {
        case .display:
            if axle >= .accessibility2 {
                return .system(.title2).weight(.semibold)
            }
            return .system(.title).weight(.semibold)
        case .headline:
            return .system(.headline).weight(.semibold)
        case .body:
            return .system(.body)
        case .caption:
            return .system(.caption)
        case .figure:
            return .system(.body).monospacedDigit()
        }
    }
}

private struct NicheTypeMod: ViewModifier {
    var step: NicheFace.Step
    @Environment(\.dynamicTypeSize) private var axle

    func body(content: Content) -> some View {
        content.font(NicheFace.font(step, axle: axle))
    }
}

extension View {
    @MainActor
    func nicheFont(_ step: NicheFace.Step) -> some View {
        modifier(NicheTypeMod(step: step))
    }
}
