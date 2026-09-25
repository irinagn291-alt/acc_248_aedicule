import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Role: Niche. Spacing, radii, Material elevation, and snap motion. Views never invent a second radius.
enum NicheCraft {
    static let unit: CGFloat = 8
    static let tap: CGFloat = 44
    static let cardRadius: CGFloat = 16
    static let chipRadius: CGFloat = 10
    static let hairline: CGFloat = 1
    static let pressScale: CGFloat = 0.97
    static let sheetScale: CGFloat = 0.96
    static let glass: Material = .thinMaterial
    static let sheetGlass: Material = .regularMaterial
    static let snap = Animation.easeOut(duration: 0.16)
    static let fade = Animation.easeOut(duration: 0.16)

    static func space(_ steps: Int) -> CGFloat {
        unit * CGFloat(steps)
    }

    static var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
    }

    static var chipShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: chipRadius, style: .continuous)
    }

    static func motion(reduce: Bool) -> Animation {
        reduce ? fade : snap
    }
}

/// Role: Niche. Named art only when the imageset holds a bitmap.
enum NicheArt {
    static let onboarding1 = "aed_Onboarding1"
    static let onboarding2 = "aed_Onboarding2"
    static let onboarding3 = "aed_Onboarding3"
    static let emptyHome = "aed_EmptyHome"
    static let emptyList = "aed_EmptyList"
    static let cardBackdrop = "aed_CardBackdrop"
    static let controlFace = "aed_ControlFace"
    static let twistHero = "aed_TwistHero"
    static let successMark = "aed_SuccessMark"
    static let headerDecor = "aed_HeaderDecor"

    static func present(_ name: String) -> Bool {
        #if canImport(UIKit)
        UIImage(named: name) != nil
        #else
        false
        #endif
    }
}

/// Role: Niche. Press scale 0.97. Reduce Motion fades. Disabled is faded.
struct NichePressStyle: ButtonStyle {
    var enabled: Bool
    var loading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        NichePressBody(configuration: configuration, enabled: enabled, loading: loading)
    }
}

private struct NichePressBody: View {
    var configuration: ButtonStyle.Configuration
    var enabled: Bool
    var loading: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .scaleEffect(!reduceMotion && configuration.isPressed && enabled && !loading ? NicheCraft.pressScale : 1)
            .opacity(enabled ? (configuration.isPressed ? 0.88 : 1) : 0.45)
            .animation(NicheCraft.motion(reduce: reduceMotion), value: configuration.isPressed)
    }
}

enum NicheVerbKind: Equatable, Sendable {
    case primary
    case quiet
    case destroy
}

/// Role: Niche. Primary is tinted glass. One jewel glow on the live Catch or Draw control.
struct NicheVerbButton: View {
    var title: String
    var detail: String? = nil
    var kind: NicheVerbKind
    var fills: Bool = true
    var enabled: Bool = true
    var loading: Bool = false
    var jewel: Bool = false
    var hint: String? = nil
    var art: String? = nil
    var action: () -> Void

    private var active: Bool { enabled && !loading }

    var body: some View {
        Button(action: action) {
            HStack(spacing: NicheCraft.space(1)) {
                if loading {
                    ProgressView()
                        .tint(labelInk)
                        .frame(width: NicheCraft.space(2), height: NicheCraft.space(2))
                } else if let art, NicheArt.present(art) {
                    Image(art)
                        .resizable()
                        .scaledToFit()
                        .frame(width: NicheCraft.space(4), height: NicheCraft.space(4))
                        .accessibilityHidden(true)
                }
                VStack(spacing: 0) {
                    Text(title)
                        .nicheFont(.body)
                        .foregroundStyle(labelInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if let detail {
                        Text(detail)
                            .nicheFont(.caption)
                            .foregroundStyle(labelInk.opacity(0.86))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: fills ? .infinity : nil)
            }
            .padding(.horizontal, NicheCraft.space(2))
            .frame(maxWidth: fills ? .infinity : nil, minHeight: NicheCraft.tap)
            .background { chrome }
            .clipShape(NicheCraft.cardShape)
            .overlay {
                NicheCraft.cardShape.stroke(strokePaint, lineWidth: NicheCraft.hairline)
            }
            .contentShape(NicheCraft.cardShape)
        }
        .buttonStyle(NichePressStyle(enabled: active, loading: loading))
        .disabled(!active)
        .accessibilityLabel(detail.map { "\(title). \($0)" } ?? title)
        .accessibilityHint(hint ?? "")
    }

    @ViewBuilder
    private var chrome: some View {
        switch kind {
        case .primary:
            ZStack {
                NicheCraft.cardShape.fill(NicheCraft.glass)
                NicheCraft.cardShape.fill(NicheTint.Palette.accent.opacity(active ? 0.28 : 0.12))
                if jewel {
                    RadialGradient(
                        colors: [
                            NicheTint.Palette.accent.opacity(active ? 0.55 : 0.16),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 2,
                        endRadius: NicheCraft.space(8)
                    )
                    .clipShape(NicheCraft.cardShape)
                }
            }
        case .quiet, .destroy:
            NicheCraft.cardShape.fill(fillPaint)
        }
    }

    private var labelInk: Color {
        active ? NicheTint.Palette.ink : NicheTint.Palette.muted
    }

    private var fillPaint: Color {
        switch kind {
        case .primary:
            NicheTint.Palette.accent.opacity(active ? 0.28 : 0.12)
        case .quiet:
            NicheTint.Palette.surface.opacity(active ? 0.92 : 0.6)
        case .destroy:
            NicheTint.Palette.muted.opacity(active ? 0.22 : 0.12)
        }
    }

    private var strokePaint: Color {
        switch kind {
        case .primary:
            NicheTint.Palette.accent.opacity(active ? 0.7 : 0.25)
        case .quiet:
            NicheTint.Palette.muted.opacity(0.45)
        case .destroy:
            NicheTint.Palette.muted.opacity(0.55)
        }
    }
}

/// Role: Niche. Full-page empty or fault. Cutout art, one headline, one line, bottom full-width Catch or Continue.
struct NicheVacancy: View {
    var image: String
    var headline: String
    var line: String
    var actionTitle: String
    var enabled: Bool = true
    var loading: Bool = false
    var jewel: Bool = false
    var action: () -> Void

    var body: some View {
        VStack(spacing: NicheCraft.space(2)) {
            VStack(spacing: NicheCraft.space(2)) {
                if NicheArt.present(image) {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: NicheCraft.space(28), maxHeight: NicheCraft.space(28))
                        .accessibilityHidden(true)
                }
                Text(headline)
                    .nicheFont(.display)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                Text(line)
                    .nicheFont(.body)
                    .foregroundStyle(NicheTint.Palette.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            NicheVerbButton(
                title: actionTitle,
                kind: .primary,
                enabled: enabled,
                loading: loading,
                jewel: jewel,
                action: action
            )
        }
        .padding(.horizontal, NicheCraft.space(2))
        .padding(.bottom, NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NicheTint.Palette.background)
    }
}

/// Role: Niche. Recoverable fault with Retry.
struct NicheBanner: View {
    var text: String
    var retryTitle: String = "Retry"
    var retry: () -> Void

    var body: some View {
        HStack(spacing: NicheCraft.space(1)) {
            Text(text)
                .nicheFont(.caption)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: retry) {
                Text(retryTitle)
                    .nicheFont(.caption)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .frame(minWidth: NicheCraft.tap, minHeight: NicheCraft.tap)
                    .padding(.horizontal, NicheCraft.space(1))
                    .background(NicheTint.Palette.surface, in: NicheCraft.chipShape)
                    .overlay {
                        NicheCraft.chipShape.stroke(
                            NicheTint.Palette.muted.opacity(0.45),
                            lineWidth: NicheCraft.hairline
                        )
                    }
                    .contentShape(NicheCraft.chipShape)
            }
            .buttonStyle(NichePressStyle(enabled: true))
            .accessibilityLabel(retryTitle)
        }
        .padding(.horizontal, NicheCraft.space(2))
        .padding(.vertical, NicheCraft.space(1))
        .frame(maxWidth: .infinity, minHeight: NicheCraft.tap, alignment: .leading)
        .background(NicheCraft.glass, in: NicheCraft.cardShape)
        .overlay {
            NicheCraft.cardShape.stroke(NicheTint.Palette.muted.opacity(0.45), lineWidth: NicheCraft.hairline)
        }
    }
}

/// Role: Niche. Sheet header with a dismiss that always works.
struct NicheSheetBar: View {
    var title: String
    var onClose: () -> Void

    var body: some View {
        HStack(spacing: NicheCraft.space(1)) {
            Text(title)
                .nicheFont(.headline)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .nicheFont(.body)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .frame(width: NicheCraft.tap, height: NicheCraft.tap)
                    .contentShape(Rectangle())
            }
            .buttonStyle(NichePressStyle(enabled: true))
            .accessibilityLabel("Close")
        }
        .frame(maxWidth: .infinity, minHeight: NicheCraft.tap)
    }
}

struct NicheSheetRise: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(reduceMotion || appeared ? 1 : NicheCraft.sheetScale)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(NicheCraft.motion(reduce: reduceMotion)) {
                    appeared = true
                }
            }
    }
}

extension View {
    func nicheScreen() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(NicheTint.Palette.background.ignoresSafeArea())
    }

    func nicheSheetRise() -> some View {
        modifier(NicheSheetRise())
    }

    func nicheGlassCard() -> some View {
        background(NicheCraft.glass, in: NicheCraft.cardShape)
            .overlay {
                NicheCraft.cardShape.stroke(NicheTint.Palette.ink.opacity(0.12), lineWidth: NicheCraft.hairline)
            }
    }
}
