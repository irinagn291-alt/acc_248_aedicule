import Foundation

/// Role: Niche. Dry votive copy. Period or comma. Never an axis value as a title.
enum NicheCopy {
    static let emptyHeadline = "Nothing saved yet."
    static let emptyLine = "Catch a warm moment."
    static let catchVerb = "Catch"
    static let drawVerb = "Draw"
    static let saved = "Saved."
    static let jobTitle = "Catch a glow"
    static let jobLine = "Tap Catch. Draw a ray later."
    static let rayCaption = "Ray"
    static let quietDayTitle = "No live glow today."
    static let quietDayLine = "Catch one, or Draw a wick."
    static let gardenEmptyHeadline = "Nothing in bloom."
    static let gardenEmptyLine = "A glow becomes a Capsule after 30 days."
    static let gardenJob = "The garden bloomed."
    static let gardenNext = "Tap a Capsule, or Open Moments to Catch."
    static let openMoments = "Open Moments"
    static let settingsEmptyHeadline = "No glows on this device"
    static let settingsEmptyLine = "Contact stays here. Catch from Moments."
    static let readFault = "The niche could not be read."
    static let writeFault = "The niche could not be written."
    static let seedFault = "The niche could not be seeded."
    static let photoFault = "Photo could not be read."
    static let voiceFault = "Voice could not be saved."
    static let restored = "Restored from a backup copy."
    static let micLine = "A clip attaches only while this glow is Live."
    static let micDenied = "Mic is off. Open Settings to record."
    static let resetTitle = "Erase the niche?"
    static let resetAction = "Erase every glow and ray"
    static let resetBody = "This clears glows, clips, photos, and rays on this device."
    static let twistTitle = "Wick then ray"
    static let twistLine = "Draw samples a Wick or Capsule. Live today stays out of the pool."
    static let contact = "Contact"

    static func role(_ kind: GlowKind) -> String {
        switch kind {
        case .live: "Live"
        case .wick: "Wick"
        case .capsule: "Capsule"
        }
    }

    static func fault(_ error: Error) -> String {
        switch error as? NicheFault {
        case .unknownGlow:
            "That glow is gone."
        case .mediaFrozen:
            "Media freezes after midnight."
        case .emptyDraw:
            "Nothing cooled to draw."
        case .emptyMedia:
            "Attach a photo or a clip."
        case .none:
            "The niche could not be updated."
        }
    }
}
