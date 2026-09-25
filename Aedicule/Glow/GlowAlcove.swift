import SwiftUI

/// Role: Glow. The one custom hero. Arched glass alcove. Shape, Path, tinted Material. Nowhere else.
struct GlowAlcove: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let inset = rect.insetBy(dx: rect.width * 0.06, dy: rect.height * 0.04)
        let arch = min(inset.width * 0.48, inset.height * 0.28)
        let startY = inset.minY + arch
        path.move(to: CGPoint(x: inset.minX, y: inset.maxY))
        path.addLine(to: CGPoint(x: inset.minX, y: startY))
        path.addQuadCurve(
            to: CGPoint(x: inset.maxX, y: startY),
            control: CGPoint(x: inset.midX, y: inset.minY - arch * 0.12)
        )
        path.addLine(to: CGPoint(x: inset.maxX, y: inset.maxY))
        path.closeSubpath()
        return path
    }
}

/// Role: Glow. Tinted glass fill for the alcove. Emotion wash rides with the spoken hue name.
struct GlowAlcoveFill: View {
    var hue: GlowHue?

    var body: some View {
        let wash = hue?.wash ?? NicheTint.Palette.surface
        GlowAlcove()
            .fill(NicheCraft.glass)
            .overlay {
                GlowAlcove().fill(wash.opacity(0.22))
            }
            .overlay {
                GlowAlcove().stroke(NicheTint.Palette.ink.opacity(0.16), lineWidth: NicheCraft.hairline)
            }
            .accessibilityHidden(true)
    }
}
