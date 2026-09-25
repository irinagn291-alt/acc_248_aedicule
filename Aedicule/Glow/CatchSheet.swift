import SwiftUI

/// Role: Glow. Catch sheet. Pick a feeling, then Catch writes a Glow.
struct CatchSheet: View {
    @Bindable var watch: NicheWatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            NicheSheetBar(title: NicheCopy.catchVerb) {
                watch.showCatch = false
            }
            Text("Pick a feeling.")
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView {
                VStack(spacing: NicheCraft.space(1)) {
                    ForEach(GlowHue.allCases, id: \.self) { hue in
                        hueRow(hue)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            NicheVerbButton(
                title: NicheCopy.catchVerb,
                kind: .primary,
                enabled: !watch.isCommitting,
                loading: watch.isCommitting,
                jewel: true,
                hint: "Saves today's glow into the niche"
            ) {
                Task { await watch.catchGlow() }
            }
        }
        .padding(NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle().fill(NicheCraft.sheetGlass)
                .ignoresSafeArea()
        }
        .nicheSheetRise()
        .animation(NicheCraft.motion(reduce: reduceMotion), value: watch.catchHue)
    }

    private func hueRow(_ hue: GlowHue) -> some View {
        let selected = watch.catchHue == hue
        return Button {
            watch.catchHue = hue
        } label: {
            HStack(spacing: NicheCraft.space(2)) {
                NicheCraft.chipShape
                    .fill(hue.wash)
                    .frame(width: NicheCraft.space(2), height: NicheCraft.space(3))
                    .overlay {
                        NicheCraft.chipShape.stroke(
                            NicheTint.Palette.ink.opacity(0.35),
                            lineWidth: NicheCraft.hairline
                        )
                    }
                    .accessibilityHidden(true)
                Text(hue.spokenName)
                    .nicheFont(.body)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if selected {
                    Image(systemName: "checkmark")
                        .nicheFont(.body)
                        .foregroundStyle(NicheTint.Palette.accent)
                        .frame(width: NicheCraft.tap, height: NicheCraft.tap)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, NicheCraft.space(2))
            .frame(maxWidth: .infinity, minHeight: NicheCraft.tap)
            .background(
                selected ? NicheTint.Palette.accent.opacity(0.22) : NicheTint.Palette.surface.opacity(0.8),
                in: NicheCraft.cardShape
            )
            .overlay {
                NicheCraft.cardShape.stroke(
                    selected ? NicheTint.Palette.accent.opacity(0.7) : NicheTint.Palette.muted.opacity(0.35),
                    lineWidth: NicheCraft.hairline
                )
            }
            .contentShape(NicheCraft.cardShape)
        }
        .buttonStyle(NichePressStyle(enabled: true))
        .accessibilityLabel(hue.spokenName)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
