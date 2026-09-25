import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Role: Capsule. Living garden. Plant blooms with each Capsule. Year collage keyed as Int YYYYMMDD.
struct GardenPane: View {
    @Bindable var watch: NicheWatch
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        Group {
            switch watch.gardenLoad {
            case .fault:
                NicheVacancy(
                    image: NicheArt.emptyList,
                    headline: NicheCopy.readFault,
                    line: watch.fault ?? "The last copy failed. Try again.",
                    actionTitle: "Retry",
                    loading: watch.isHauling
                ) {
                    Task { await watch.retry() }
                }
            case .empty:
                NicheVacancy(
                    image: NicheArt.emptyList,
                    headline: NicheCopy.gardenEmptyHeadline,
                    line: NicheCopy.gardenEmptyLine,
                    actionTitle: NicheCopy.openMoments
                ) {
                    watch.jumpMoments()
                }
            case .populated:
                populated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NicheTint.Palette.background)
        .sheet(isPresented: $watch.showBloom, onDismiss: { watch.bloomID = nil }) {
            bloomSheet
                .presentationDetents([.large])
        }
    }

    private var populated: some View {
        GeometryReader { geo in
            let gap = NicheCraft.space(2)
            let bannerH: CGFloat = (watch.fault != nil || watch.restoredLine != nil)
                ? NicheCraft.tap + gap
                : 0
            let usable = max(
                geo.size.height - NicheCraft.tap - bannerH - gap * 2,
                NicheCraft.space(28)
            )
            let wide = sizeClass == .regular && geo.size.width >= NicheCraft.space(70)
            let columns = wide ? min(max(watch.capsules.count, 1), 5) : 3
            let spanLead = !wide && watch.capsules.count > 2
            let compactH = collageHeight(columns: columns, spanLead: spanLead)
            let gardenH = max(usable - compactH - gap, NicheCraft.space(20))
            VStack(alignment: .leading, spacing: gap) {
                if let fault = watch.fault {
                    NicheBanner(text: fault) {
                        Task { await watch.retry() }
                    }
                } else if let line = watch.restoredLine {
                    NicheBanner(text: line, retryTitle: "OK") {
                        watch.restoredLine = nil
                    }
                }
                livingGarden
                    .frame(maxWidth: .infinity)
                    .frame(height: gardenH)
                yearCollage(columns: columns, height: compactH, spanLead: spanLead)
                    .frame(maxWidth: .infinity)
                    .frame(height: compactH, alignment: .top)
                NicheVerbButton(
                    title: NicheCopy.openMoments,
                    kind: .primary,
                    enabled: true,
                    hint: "Catch and Draw live on Moments"
                ) {
                    watch.jumpMoments()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .padding(.horizontal, NicheCraft.space(2))
        .padding(.top, NicheCraft.space(1))
        .padding(.bottom, NicheCraft.space(2))
    }

    private var livingGarden: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                NicheTint.Palette.surface.opacity(0.92)
                if let name = plantArt {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width * 0.92, maxHeight: geo.size.height * 0.92)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                        .accessibilityHidden(true)
                }
                ForEach(Array(watch.capsules.prefix(4).enumerated()), id: \.element.id) { index, glow in
                    bloomChip(glow)
                        .position(bloomPoint(index, in: geo.size))
                }
                plantCopy
                    .frame(maxWidth: geo.size.width * 0.62, alignment: .leading)
                    .padding(NicheCraft.space(2))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(NicheCraft.cardShape)
        .overlay {
            NicheCraft.cardShape.stroke(
                NicheTint.Palette.ink.opacity(0.12),
                lineWidth: NicheCraft.hairline
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            "\(NicheCopy.gardenJob) Capsules \(watch.capsuleCountLabel), rays \(watch.rayCountLabel)"
        )
    }

    private var plantCopy: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(1)) {
            Text(NicheCopy.gardenJob)
                .nicheFont(.display)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(NicheCopy.gardenNext)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(alignment: .firstTextBaseline, spacing: NicheCraft.space(2)) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(watch.capsuleCountLabel)
                        .nicheFont(.headline)
                        .monospacedDigit()
                        .foregroundStyle(NicheTint.Palette.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("Capsules")
                        .nicheFont(.caption)
                        .foregroundStyle(NicheTint.Palette.muted)
                }
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
            }
            .accessibilityElement(children: .combine)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bloomChip(_ glow: Glow) -> some View {
        Button {
            watch.openBloom(glow)
        } label: {
            Text(glow.spark.hue.spokenName)
                .nicheFont(.caption)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, NicheCraft.space(2))
                .frame(minWidth: NicheCraft.tap, minHeight: NicheCraft.tap)
                .background(glow.spark.hue.wash.opacity(0.42), in: NicheCraft.chipShape)
                .overlay {
                    NicheCraft.chipShape.stroke(
                        NicheTint.Palette.ink.opacity(0.28),
                        lineWidth: NicheCraft.hairline
                    )
                }
                .contentShape(NicheCraft.chipShape)
        }
        .buttonStyle(NichePressStyle(enabled: true))
        .accessibilityLabel("\(glow.spark.hue.spokenName) Capsule")
        .accessibilityHint("Open this cooled glow")
    }

    private func yearCollage(columns: Int, height: CGFloat, spanLead: Bool) -> some View {
        let gap = NicheCraft.space(2)
        let cells = watch.capsules
        let rest = Array(cells.dropFirst())
        let sizes = mosaicSizes(
            columns: columns,
            totalHeight: height,
            count: cells.count,
            spanLead: spanLead
        )
        let grid = Array(
            repeating: GridItem(.flexible(), spacing: gap),
            count: columns
        )
        return LazyVGrid(columns: grid, alignment: .leading, spacing: gap) {
            if spanLead, let lead = cells.first {
                CapsuleYearTile(
                    watch: watch,
                    glow: lead,
                    selected: lead.id == watch.bloomID,
                    lead: true,
                    ray: watch.rayOnCapsule(lead)
                ) {
                    watch.openBloom(lead)
                }
                .frame(maxWidth: .infinity)
                .frame(height: sizes.lead)
                .gridCellColumns(min(2, columns))
                ForEach(rest) { glow in
                    collageTile(glow, lead: false, height: sizes.tile)
                }
            } else {
                ForEach(Array(cells.enumerated()), id: \.element.id) { index, glow in
                    collageTile(glow, lead: index == 0, height: sizes.tile)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: height, alignment: .topLeading)
        .accessibilityLabel("Year collage of Capsules \(watch.collageYearLabel)")
    }

    private func collageTile(_ glow: Glow, lead: Bool, height: CGFloat) -> some View {
        CapsuleYearTile(
            watch: watch,
            glow: glow,
            selected: glow.id == watch.bloomID,
            lead: lead,
            ray: watch.rayOnCapsule(glow)
        ) {
            watch.openBloom(glow)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    @ViewBuilder
    private var bloomSheet: some View {
        if let glow = watch.bloomGlow {
            VStack(alignment: .leading, spacing: NicheCraft.space(2)) {
                NicheSheetBar(title: glow.spark.hue.spokenName) {
                    watch.showBloom = false
                }
                CapsuleYearTile(
                    watch: watch,
                    glow: glow,
                    selected: true,
                    lead: true,
                    ray: watch.rayOnCapsule(glow)
                ) {
                    watch.jumpMoments()
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: NicheCraft.space(22), maxHeight: NicheCraft.space(36))
                Text(NicheCopy.gardenNext)
                    .nicheFont(.body)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                NicheVerbButton(
                    title: NicheCopy.openMoments,
                    kind: .primary,
                    enabled: true,
                    hint: "Catch and Draw live on Moments"
                ) {
                    watch.jumpMoments()
                }
            }
            .padding(NicheCraft.space(2))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                Rectangle().fill(NicheCraft.sheetGlass)
                    .ignoresSafeArea()
            }
            .nicheSheetRise()
            .presentationDragIndicator(.visible)
            .presentationBackground(NicheCraft.sheetGlass)
        } else {
            Color.clear
                .onAppear { watch.showBloom = false }
        }
    }

    private var plantArt: String? {
        if NicheArt.present(NicheArt.onboarding3) {
            return NicheArt.onboarding3
        }
        if NicheArt.present(NicheArt.emptyHome) {
            return NicheArt.emptyHome
        }
        return nil
    }

    private func bloomPoint(_ index: Int, in size: CGSize) -> CGPoint {
        let sites: [(CGFloat, CGFloat)] = [
            (0.78, 0.22),
            (0.62, 0.34),
            (0.84, 0.46),
            (0.70, 0.18),
        ]
        let site = sites[index % sites.count]
        return CGPoint(x: size.width * site.0, y: size.height * site.1)
    }

    private func collageHeight(columns: Int, spanLead: Bool) -> CGFloat {
        let gap = NicheCraft.space(2)
        let tile = NicheCraft.space(14)
        let lead = NicheCraft.space(16)
        let count = watch.capsules.count
        if count == 0 {
            return tile
        }
        let extraRows = extraMosaicRows(count: count, columns: columns, spanLead: spanLead)
        if extraRows == 0 {
            return spanLead ? lead : tile
        }
        if spanLead {
            return lead + CGFloat(extraRows) * tile + CGFloat(extraRows) * gap
        }
        return CGFloat(extraRows + 1) * tile + CGFloat(extraRows) * gap
    }

    private func mosaicSizes(
        columns: Int,
        totalHeight: CGFloat,
        count: Int,
        spanLead: Bool
    ) -> (lead: CGFloat, tile: CGFloat) {
        let gap = NicheCraft.space(2)
        let minTile = NicheCraft.space(12)
        let minLead = NicheCraft.space(14)
        let extraRows = extraMosaicRows(count: count, columns: columns, spanLead: spanLead)
        if extraRows == 0 {
            let row = max(totalHeight, minLead)
            return (row, row)
        }
        let gaps = CGFloat(extraRows) * gap
        let leftover = max(totalHeight - gaps, minLead + minTile)
        if spanLead {
            let leadWeight: CGFloat = 1.2
            let tile = leftover / (leadWeight + CGFloat(extraRows))
            return (max(tile * leadWeight, minLead), max(tile, minTile))
        }
        let tile = leftover / CGFloat(extraRows + 1)
        return (max(tile, minLead), max(tile, minTile))
    }

    private func extraMosaicRows(count: Int, columns: Int, spanLead: Bool) -> Int {
        let cols = max(columns, 1)
        if count <= 1 {
            return 0
        }
        if spanLead {
            let rest = count - 1
            let heroSlots = max(cols - 2, 0)
            let leftover = max(rest - heroSlots, 0)
            return Int(ceil(Double(leftover) / Double(cols)))
        }
        return max(Int(ceil(Double(count) / Double(cols))) - 1, 0)
    }
}

/// Role: Capsule. One year-collage tile. Stock glass. Tappable bloom keyed by day, not a dated log row.
private struct CapsuleYearTile: View {
    @Bindable var watch: NicheWatch
    var glow: Glow
    var selected: Bool
    var lead: Bool
    var ray: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                bloomWell
                ink
                    .padding(.horizontal, NicheCraft.space(2))
                    .padding(.vertical, NicheCraft.space(1))
                    .frame(maxWidth: .infinity, minHeight: NicheCraft.space(6), alignment: .leading)
                    .background(NicheTint.Palette.surface.opacity(0.88))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .background(NicheCraft.glass, in: NicheCraft.cardShape)
            .clipShape(NicheCraft.cardShape)
            .overlay {
                NicheCraft.cardShape.stroke(
                    selected ? NicheTint.Palette.accent.opacity(0.7) : NicheTint.Palette.ink.opacity(0.12),
                    lineWidth: NicheCraft.hairline
                )
            }
            .contentShape(NicheCraft.cardShape)
        }
        .buttonStyle(NichePressStyle(enabled: true))
        .accessibilityLabel(accessLabel)
        .accessibilityHint("Open this cooled glow")
    }

    private var bloomWell: some View {
        ZStack {
            glow.spark.hue.wash.opacity(0.22)
            if let image = stillPhoto {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(NicheCraft.space(1))
                    .accessibilityHidden(true)
            } else if NicheArt.present(NicheArt.onboarding3) {
                Image(NicheArt.onboarding3)
                    .resizable()
                    .scaledToFit()
                    .padding(lead ? NicheCraft.space(2) : NicheCraft.space(1))
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

    private var ink: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(NicheFigures.day(glow.spark.daykey, calendar: watch.calendarForDisplay))
                .nicheFont(.caption)
                .foregroundStyle(NicheTint.Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            HStack(alignment: .firstTextBaseline, spacing: NicheCraft.space(1)) {
                Text(glow.spark.hue.spokenName)
                    .nicheFont(lead ? .headline : .body)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if ray {
                    Text(NicheCopy.rayCaption)
                        .nicheFont(.caption)
                        .foregroundStyle(NicheTint.Palette.ink)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accessLabel: String {
        let day = NicheFigures.day(glow.spark.daykey, calendar: watch.calendarForDisplay)
        if ray {
            return "\(glow.spark.hue.spokenName) Capsule \(day) \(NicheCopy.rayCaption)"
        }
        return "\(glow.spark.hue.spokenName) Capsule \(day)"
    }

    private var stillPhoto: UIImage? {
        #if canImport(UIKit)
        guard let data = watch.stillData(for: glow.spark) else { return nil }
        return UIImage(data: data)
        #else
        nil
        #endif
    }
}
