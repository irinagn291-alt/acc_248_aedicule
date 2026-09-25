import SwiftUI

/// Role: Niche. Typed colour accessor. Hex stays in NicheTint. Views never hard-code a colour name.
extension NicheTint {
    enum Palette {
        static let background = Color("background")
        static let surface = Color("surface")
        static let ink = Color("ink")
        static let accent = Color("aedAccent")
        static let muted = Color("muted")
    }
}

extension GlowHue {
    /// Emotion wash from the 7.1 tokens. Colour is never the only signal.
    var wash: Color {
        switch self {
        case .ember:
            NicheTint.Palette.accent
        case .hush:
            NicheTint.Palette.muted
        case .bloom:
            NicheTint.Palette.ink
        case .tide:
            NicheTint.Palette.ink.opacity(0.55)
        case .hearth:
            NicheTint.Palette.accent.opacity(0.55)
        case .gleam:
            NicheTint.Palette.ink.opacity(0.82)
        case .still:
            NicheTint.Palette.muted.opacity(0.7)
        case .lift:
            NicheTint.Palette.accent.opacity(0.82)
        }
    }
}
