import SwiftUI

/// Role: RayMark. Twist screen. Wick then ray. Own surface plus Draw on Moments.
struct RayMarkPane: View {
    @Bindable var watch: NicheWatch

    var body: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            NicheSheetBar(title: NicheCopy.twistTitle) {
                watch.showTwist = false
            }
            Group {
                switch watch.twistLoad {
                case .fault:
                    NicheVacancy(
                        image: NicheArt.twistHero,
                        headline: NicheCopy.readFault,
                        line: watch.fault ?? "The last copy failed. Try again.",
                        actionTitle: "Retry",
                        loading: watch.isHauling
                    ) {
                        Task { await watch.retry() }
                    }
                case .empty:
                    NicheVacancy(
                        image: NicheArt.twistHero,
                        headline: NicheCopy.twistTitle,
                        line: NicheCopy.twistLine,
                        actionTitle: "Open Moments"
                    ) {
                        watch.jumpMoments()
                    }
                case .populated:
                    populated
                }
            }
        }
        .padding(NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle().fill(NicheCraft.sheetGlass)
                .ignoresSafeArea()
        }
        .nicheSheetRise()
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            if NicheArt.present(NicheArt.twistHero) {
                Image(NicheArt.twistHero)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: NicheCraft.space(22))
                    .accessibilityHidden(true)
            }
            Text(watch.rayCountLabel)
                .nicheFont(.display)
                .monospacedDigit()
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Rays on this device")
                .nicheFont(.headline)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(NicheCopy.twistLine)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
            if let glow = watch.stagedGlow {
                staged(glow)
            }
            Text("Capsules \(watch.capsuleCountLabel).")
                .nicheFont(.caption)
                .foregroundStyle(NicheTint.Palette.muted)
            Spacer(minLength: NicheCraft.space(2))
            NicheVerbButton(
                title: "Open Moments",
                kind: .primary
            ) {
                watch.jumpMoments()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func staged(_ glow: Glow) -> some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(1)) {
            HStack(spacing: NicheCraft.space(1)) {
                Text(glow.spark.hue.spokenName)
                    .nicheFont(.body)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                WickChip(kind: glow.kind)
            }
            Text(NicheFigures.dayKey(glow.spark.daykey))
                .nicheFont(.figure)
                .foregroundStyle(NicheTint.Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .accessibilityLabel(NicheFigures.day(glow.spark.daykey, calendar: watch.calendarForDisplay))
        }
        .padding(NicheCraft.space(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(glow.spark.hue.wash.opacity(0.18), in: NicheCraft.cardShape)
        .overlay {
            NicheCraft.cardShape.stroke(glow.spark.hue.wash.opacity(0.45), lineWidth: NicheCraft.hairline)
        }
        .accessibilityElement(children: .combine)
    }
}
