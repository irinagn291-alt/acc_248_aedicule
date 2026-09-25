import SwiftUI

/// Role: Wick. Spoken role chip. Colour is never the only signal.
struct WickChip: View {
    var kind: GlowKind

    var body: some View {
        Text(NicheCopy.role(kind))
            .nicheFont(.caption)
            .foregroundStyle(NicheTint.Palette.ink)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, NicheCraft.space(2))
            .frame(minHeight: NicheCraft.tap / 2)
            .background(NicheTint.Palette.surface.opacity(0.9), in: NicheCraft.chipShape)
            .overlay {
                NicheCraft.chipShape.stroke(NicheTint.Palette.muted.opacity(0.45), lineWidth: NicheCraft.hairline)
            }
            .accessibilityLabel(NicheCopy.role(kind))
    }
}
