import PhotosUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Role: Glow. Horizontal coverflow of today's Live glows. Fills remaining height and iPad width.
struct GlowCoverflow: View {
    @Bindable var watch: NicheWatch
    var glows: [Glow]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { geo in
            let width = cardWidth(in: geo.size)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: NicheCraft.space(2)) {
                    ForEach(glows) { glow in
                        GlowLiveCard(
                            watch: watch,
                            glow: glow,
                            focused: glow.id == watch.focusedGlowID
                        )
                        .frame(width: width, height: geo.size.height)
                        .id(glow.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.leading, NicheCraft.space(2))
                .padding(.trailing, NicheCraft.space(2))
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: focusBind)
            .animation(NicheCraft.motion(reduce: reduceMotion), value: watch.focusedGlowID)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func cardWidth(in size: CGSize) -> CGFloat {
        let floor = NicheCraft.space(22)
        let gap = NicheCraft.space(2)
        let usable = max(size.width, floor)
        if horizontalSizeClass == .regular {
            return max(floor, (usable - gap) * 0.47)
        }
        return max(floor, usable - NicheCraft.space(16))
    }

    private var focusBind: Binding<UUID?> {
        Binding(
            get: { watch.focusedGlowID },
            set: { watch.focusedGlowID = $0 }
        )
    }
}

/// Role: Glow. Named Live spark. Feeling name sits in a reserved plate. Photo and voice attach only while Live.
struct GlowLiveCard: View {
    @Bindable var watch: NicheWatch
    var glow: Glow
    var focused: Bool
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                watch.focusedGlowID = glow.id
            } label: {
                namePlate
                    .contentShape(Rectangle())
            }
            .buttonStyle(NichePressStyle(enabled: true))
            .accessibilityLabel("\(glow.spark.hue.spokenName) Live")
            atmosphere
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .allowsHitTesting(false)
            if focused, glow.canAttach {
                attachRow
                    .padding(.horizontal, NicheCraft.space(2))
                    .padding(.vertical, NicheCraft.space(1))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(NicheCraft.glass, in: NicheCraft.cardShape)
        .overlay {
            NicheCraft.cardShape.stroke(
                focused ? NicheTint.Palette.accent.opacity(0.7) : NicheTint.Palette.ink.opacity(0.12),
                lineWidth: NicheCraft.hairline
            )
        }
        .clipShape(NicheCraft.cardShape)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await importStill(item) }
        }
        .accessibilityElement(children: .contain)
    }

    private var namePlate: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(1)) {
            Text(glow.spark.hue.spokenName)
                .nicheFont(.display)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity, alignment: .leading)
            WickChip(kind: .live)
        }
        .padding(NicheCraft.space(2))
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(glow.spark.hue.wash.opacity(0.22))
        .layoutPriority(1)
    }

    private var atmosphere: some View {
        Rectangle()
            .fill(glow.spark.hue.wash.opacity(0.28))
            .overlay {
                stillFill
            }
            .clipped()
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var stillFill: some View {
        if let data = watch.stillData(for: glow.spark), let image = stillImage(data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if NicheArt.present(NicheArt.cardBackdrop) {
            Image(NicheArt.cardBackdrop)
                .resizable()
                .scaledToFill()
                .opacity(0.4)
        }
    }

    private var attachRow: some View {
        HStack(spacing: NicheCraft.space(1)) {
            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                NicheAttachChip(title: "Photo", systemImage: "photo")
            }
            .buttonStyle(NichePressStyle(enabled: !watch.isCommitting))
            .disabled(watch.isCommitting)
            .accessibilityLabel("Photo")

            Button {
                watch.toggleRecord(for: glow.id)
            } label: {
                NicheAttachChip(
                    title: watch.isRecording ? "Stop" : "Voice",
                    systemImage: watch.isRecording ? "stop.fill" : "mic"
                )
            }
            .buttonStyle(NichePressStyle(enabled: !watch.isCommitting))
            .disabled(watch.isCommitting)
            .accessibilityLabel(watch.isRecording ? "Stop" : "Voice")

            if let name = glow.spark.voiceName {
                Button {
                    Task { await watch.playVoice(named: name) }
                } label: {
                    Image(systemName: watch.isPlaying ? "speaker.wave.2.fill" : "speaker.wave.2")
                        .nicheFont(.body)
                        .foregroundStyle(NicheTint.Palette.ink)
                        .frame(width: NicheCraft.tap, height: NicheCraft.tap)
                        .background(NicheTint.Palette.surface.opacity(0.9), in: NicheCraft.chipShape)
                        .overlay {
                            NicheCraft.chipShape.stroke(
                                NicheTint.Palette.muted.opacity(0.45),
                                lineWidth: NicheCraft.hairline
                            )
                        }
                        .contentShape(NicheCraft.chipShape)
                }
                .buttonStyle(NichePressStyle(enabled: true))
                .accessibilityLabel("Play voice")
            }
        }
    }

    private func importStill(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                watch.fault = NicheCopy.photoFault
                return
            }
            await watch.attachStill(data, glowID: glow.id)
        } catch {
            watch.fault = NicheCopy.photoFault
        }
        pickerItem = nil
    }

    private func stillImage(_ data: Data) -> UIImage? {
        #if canImport(UIKit)
        UIImage(data: data)
        #else
        nil
        #endif
    }
}

/// Role: Glow. Chip chrome for Photo and Voice. Isolated from PhotosPicker's nonisolated label.
struct NicheAttachChip: View {
    var title: String
    var systemImage: String

    var body: some View {
        HStack(spacing: NicheCraft.space(1)) {
            Image(systemName: systemImage)
                .nicheFont(.caption)
            Text(title)
                .nicheFont(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(NicheTint.Palette.ink)
        .padding(.horizontal, NicheCraft.space(2))
        .frame(maxWidth: .infinity, minHeight: NicheCraft.tap)
        .background(NicheTint.Palette.surface.opacity(0.9), in: NicheCraft.chipShape)
        .overlay {
            NicheCraft.chipShape.stroke(
                NicheTint.Palette.muted.opacity(0.45),
                lineWidth: NicheCraft.hairline
            )
        }
        .contentShape(NicheCraft.chipShape)
    }
}
