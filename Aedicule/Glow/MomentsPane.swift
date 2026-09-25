import SwiftUI

/// Role: Glow. Moments home. Coverflow of today's Live glows. Catch and Draw fuse here.
struct MomentsPane: View {
    @Bindable var watch: NicheWatch

    var body: some View {
        Group {
            switch watch.momentsLoad {
            case .fault:
                NicheVacancy(
                    image: NicheArt.emptyHome,
                    headline: NicheCopy.readFault,
                    line: watch.fault ?? "The last copy failed. Try again.",
                    actionTitle: "Retry",
                    loading: watch.isHauling
                ) {
                    Task { await watch.retry() }
                }
            case .empty:
                NicheVacancy(
                    image: NicheArt.emptyHome,
                    headline: NicheCopy.emptyHeadline,
                    line: NicheCopy.emptyLine,
                    actionTitle: NicheCopy.catchVerb,
                    enabled: watch.canCatch && !watch.isCommitting,
                    loading: watch.isCommitting,
                    jewel: true
                ) {
                    watch.openCatch()
                }
            case .populated:
                populated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NicheTint.Palette.background)
        .sheet(isPresented: $watch.showCatch) {
            CatchSheet(watch: watch)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(NicheCraft.sheetGlass)
        }
        .sheet(isPresented: $watch.showMicAsk) {
            micAsk
        }
        .sheet(isPresented: $watch.showMicDenied) {
            micDenied
        }
    }

    private var populated: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            header
            if let fault = watch.fault {
                NicheBanner(text: fault) {
                    Task { await watch.retry() }
                }
            } else if let line = watch.restoredLine {
                NicheBanner(text: line, retryTitle: "OK") {
                    watch.restoredLine = nil
                }
            }
            niche
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let staged = watch.stagedGlow {
                rayStrip(staged)
            }
            verbs
        }
        .padding(.horizontal, NicheCraft.space(2))
        .padding(.top, NicheCraft.space(1))
        .padding(.bottom, NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(1)) {
            Text(watch.jobTitle)
                .nicheFont(.display)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(watch.jobLine)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var niche: some View {
        let hue = watch.focusedLive?.spark.hue
        return ZStack {
            GlowAlcoveFill(hue: hue)
            Group {
                if watch.liveToday.isEmpty {
                    quietDay
                        .padding(.horizontal, NicheCraft.space(3))
                        .padding(.vertical, NicheCraft.space(3))
                } else {
                    GlowCoverflow(watch: watch, glows: watch.liveToday)
                        .padding(.horizontal, NicheCraft.space(1))
                        .padding(.vertical, NicheCraft.space(2))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Glass niche")
    }

    private var quietDay: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            Text(NicheCopy.quietDayTitle)
                .nicheFont(.headline)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(NicheCopy.quietDayLine)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            HStack(alignment: .firstTextBaseline, spacing: NicheCraft.space(2)) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(NicheFigures.integer(watch.drawPool.count))
                        .nicheFont(.display)
                        .monospacedDigit()
                        .foregroundStyle(NicheTint.Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("Cooled")
                        .nicheFont(.caption)
                        .foregroundStyle(NicheTint.Palette.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 0) {
                    Text(watch.rayCountLabel)
                        .nicheFont(.headline)
                        .monospacedDigit()
                        .foregroundStyle(NicheTint.Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("Rays")
                        .nicheFont(.caption)
                        .foregroundStyle(NicheTint.Palette.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(NicheCraft.space(2))
            .frame(maxWidth: .infinity, minHeight: NicheCraft.tap, alignment: .leading)
            .background(NicheCraft.glass, in: NicheCraft.cardShape)
            .overlay {
                NicheCraft.cardShape.stroke(
                    NicheTint.Palette.ink.opacity(0.12),
                    lineWidth: NicheCraft.hairline
                )
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(
                "Cooled \(NicheFigures.integer(watch.drawPool.count)), rays \(watch.rayCountLabel)"
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func rayStrip(_ glow: Glow) -> some View {
        HStack(alignment: .center, spacing: NicheCraft.space(2)) {
            VStack(alignment: .leading, spacing: 0) {
                Text(NicheCopy.rayCaption)
                    .nicheFont(.caption)
                    .foregroundStyle(NicheTint.Palette.muted)
                    .lineLimit(1)
                Text(glow.spark.hue.spokenName)
                    .nicheFont(.headline)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            WickChip(kind: glow.kind)
        }
        .padding(.horizontal, NicheCraft.space(2))
        .padding(.vertical, NicheCraft.space(1))
        .frame(maxWidth: .infinity, minHeight: NicheCraft.tap, alignment: .leading)
        .background(NicheCraft.glass, in: NicheCraft.cardShape)
        .overlay {
            NicheCraft.cardShape.stroke(
                NicheTint.Palette.muted.opacity(0.45),
                lineWidth: NicheCraft.hairline
            )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ray \(glow.spark.hue.spokenName) \(NicheCopy.role(glow.kind))")
    }

    private var verbs: some View {
        VStack(spacing: NicheCraft.space(1)) {
            NicheVerbButton(
                title: NicheCopy.catchVerb,
                kind: .primary,
                enabled: watch.canCatch && !watch.isCommitting,
                loading: watch.isCommitting && watch.liveVerb == .catchGlow,
                jewel: watch.liveVerb == .catchGlow,
                hint: "Save today's glow"
            ) {
                watch.openCatch()
            }
            NicheVerbButton(
                title: NicheCopy.drawVerb,
                detail: watch.canDraw ? "Later" : "Nothing cooled",
                kind: .quiet,
                enabled: watch.canDraw && !watch.isCommitting,
                loading: watch.isCommitting && watch.liveVerb == .draw,
                jewel: watch.liveVerb == .draw,
                hint: "Sample a Wick or Capsule"
            ) {
                Task { await watch.drawRay() }
            }
        }
    }

    private var micAsk: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            NicheSheetBar(title: "Voice") {
                watch.showMicAsk = false
            }
            Text(NicheCopy.micLine)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: NicheCraft.space(2))
            NicheVerbButton(title: "Continue", kind: .primary) {
                watch.continueMic()
            }
        }
        .padding(NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle().fill(NicheCraft.sheetGlass)
                .ignoresSafeArea()
        }
        .nicheSheetRise()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(NicheCraft.sheetGlass)
    }

    private var micDenied: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
            NicheSheetBar(title: "Voice") {
                watch.showMicDenied = false
            }
            Text(NicheCopy.micDenied)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: NicheCraft.space(2))
            NicheVerbButton(title: "Open Settings", kind: .primary) {
                watch.openSystemSettings()
            }
        }
        .padding(NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle().fill(NicheCraft.sheetGlass)
                .ignoresSafeArea()
        }
        .nicheSheetRise()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(NicheCraft.sheetGlass)
    }
}
