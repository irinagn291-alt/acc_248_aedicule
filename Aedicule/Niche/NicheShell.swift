import SwiftUI

/// Role: Niche. One root glass. Moments, Garden, and Settings swap in place. Catch and Draw stay on Moments.
struct NicheShell: View {
    @Bindable var watch: NicheWatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if !watch.didLoad {
                loading
            } else {
                shell
            }
        }
        .tint(NicheTint.Palette.accent)
        .background(NicheTint.Palette.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: onboardingBind) {
            NicheOnboard(watch: watch)
        }
        .sheet(isPresented: $watch.showTwist) {
            RayMarkPane(watch: watch)
                .presentationDragIndicator(.visible)
                .presentationBackground(NicheCraft.sheetGlass)
        }
        .sensoryFeedback(.success, trigger: watch.commitTick)
        .overlay(alignment: .top) {
            if watch.showSuccess, NicheArt.present(NicheArt.successMark) {
                Image(NicheArt.successMark)
                    .resizable()
                    .scaledToFit()
                    .frame(width: NicheCraft.space(8), height: NicheCraft.space(8))
                    .padding(.top, NicheCraft.space(2))
                    .opacity(0.95)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
        }
    }

    private var loading: some View {
        ZStack {
            NicheTint.Palette.background
            if watch.isHauling {
                ProgressView()
                    .tint(NicheTint.Palette.accent)
                    .accessibilityLabel("Opening the niche")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var shell: some View {
        VStack(spacing: NicheCraft.space(1)) {
            picker
            pane
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(NicheCraft.motion(reduce: reduceMotion), value: watch.segment)
        }
        .background(NicheTint.Palette.background.ignoresSafeArea())
    }

    private var picker: some View {
        Picker("Niche", selection: $watch.segment) {
            Text("Moments").tag(NicheSegment.moments)
            Text("Garden").tag(NicheSegment.garden)
            Text("Settings").tag(NicheSegment.settings)
        }
        .pickerStyle(.segmented)
        .frame(minHeight: NicheCraft.tap)
        .padding(.horizontal, NicheCraft.space(2))
        .padding(.top, NicheCraft.space(1))
        .accessibilityLabel("Niche")
    }

    @ViewBuilder
    private var pane: some View {
        switch watch.segment {
        case .moments:
            MomentsPane(watch: watch)
        case .garden:
            GardenPane(watch: watch)
        case .settings:
            NicheSettings(watch: watch)
        }
    }

    private var onboardingBind: Binding<Bool> {
        Binding(
            get: { watch.showsOnboarding },
            set: { presented in
                if !presented {
                    Task { await watch.finishOnboarding() }
                }
            }
        )
    }
}
