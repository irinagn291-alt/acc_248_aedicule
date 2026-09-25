import SwiftUI

/// Role: Niche. One-shot cover. Three pages. Skip writes defaults. Re-runnable from Settings.
struct NicheOnboard: View {
    @Bindable var watch: NicheWatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    var body: some View {
        VStack(spacing: NicheCraft.space(2)) {
            pageCard
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .id(page)
            NicheVerbButton(
                title: page == 2 ? "Continue" : "Next",
                kind: .primary
            ) {
                if page == 2 {
                    Task { await watch.finishOnboarding() }
                } else if reduceMotion {
                    page += 1
                } else {
                    withAnimation(NicheCraft.motion(reduce: reduceMotion)) {
                        page += 1
                    }
                }
            }
            NicheVerbButton(
                title: "Skip",
                kind: .quiet
            ) {
                Task { await watch.finishOnboarding() }
            }
        }
        .padding(NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NicheTint.Palette.background.ignoresSafeArea())
        .interactiveDismissDisabled()
    }

    private var pageCard: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            if NicheArt.present(art) {
                Image(art)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                    .accessibilityHidden(true)
            }
            Text(title)
                .nicheFont(.display)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(line)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var art: String {
        switch page {
        case 0: NicheArt.onboarding1
        case 1: NicheArt.onboarding2
        default: NicheArt.onboarding3
        }
    }

    private var title: String {
        switch page {
        case 0: "Today's glow sits in the niche"
        case 1: "Catch while it is Live"
        default: "Draw a cooled wick"
        }
    }

    private var line: String {
        switch page {
        case 0:
            "Catch a feeling into today's glass. It stays on this device."
        case 1:
            "Photo and voice attach today. Midnight freezes them."
        default:
            "Draw samples a Wick or Capsule. Live today stays out of the pool."
        }
    }
}
