import SwiftUI

/// Role: Niche. Settings Form. Contact, re-run onboarding, confirmed resetAllData.
struct NicheSettings: View {
    @Bindable var watch: NicheWatch

    var body: some View {
        Group {
            switch watch.settingsLoad {
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
                empty
            case .populated:
                populated
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NicheTint.Palette.background)
        .confirmationDialog(
            NicheCopy.resetTitle,
            isPresented: $watch.confirmReset,
            titleVisibility: .visible
        ) {
            Button(NicheCopy.resetAction, role: .destructive) {
                Task { await watch.resetAll() }
            }
            Button("Keep", role: .cancel) {}
        } message: {
            Text(NicheCopy.resetBody)
        }
    }

    private var empty: some View {
        VStack(spacing: NicheCraft.space(2)) {
            VStack(spacing: NicheCraft.space(2)) {
                if NicheArt.present(NicheArt.emptyHome) {
                    Image(NicheArt.emptyHome)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: NicheCraft.space(28), maxHeight: NicheCraft.space(22))
                        .accessibilityHidden(true)
                }
                Text(NicheCopy.settingsEmptyHeadline)
                    .nicheFont(.display)
                    .foregroundStyle(NicheTint.Palette.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .frame(maxWidth: .infinity)
                Text(NicheCopy.settingsEmptyLine)
                    .nicheFont(.body)
                    .foregroundStyle(NicheTint.Palette.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                contactCard
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            NicheVerbButton(
                title: NicheCopy.catchVerb,
                kind: .primary,
                jewel: true
            ) {
                watch.jumpMoments()
                watch.openCatch()
            }
            NicheVerbButton(
                title: "Re-run onboarding",
                kind: .quiet,
                enabled: !watch.isCommitting
            ) {
                Task { await watch.reopenOnboarding() }
            }
            NicheVerbButton(
                title: "Reset all data",
                detail: "Erase glows on this device",
                kind: .destroy,
                enabled: !watch.isCommitting,
                loading: watch.isCommitting
            ) {
                watch.confirmReset = true
            }
        }
        .padding(.horizontal, NicheCraft.space(2))
        .padding(.bottom, NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populated: some View {
        Form {
            Section {
                counts
            }
            formSections
        }
        .scrollContentBackground(.hidden)
        .background(NicheTint.Palette.background)
        .tint(NicheTint.Palette.accent)
        .contentMargins(.bottom, NicheCraft.space(2))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var formSections: some View {
        Section {
            Button {
                watch.showTwist = true
            } label: {
                settingsLabel(title: NicheCopy.twistTitle, detail: NicheCopy.twistLine)
            }
            .listRowBackground(NicheTint.Palette.surface)
        }
        Section {
            contactRow
        }
        Section {
            Button {
                Task { await watch.reopenOnboarding() }
            } label: {
                settingsLabel(title: "Re-run onboarding", detail: nil)
            }
            .disabled(watch.isCommitting)
            .listRowBackground(NicheTint.Palette.surface)
            Button(role: .destructive) {
                watch.confirmReset = true
            } label: {
                settingsLabel(title: "Reset all data", detail: "Erase glows on this device")
            }
            .disabled(watch.isCommitting)
            .listRowBackground(NicheTint.Palette.surface)
        }
    }

    private var counts: some View {
        VStack(alignment: .leading, spacing: NicheCraft.space(1)) {
            Text(watch.jobTitle)
                .nicheFont(.headline)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(NicheFigures.integer(watch.liveToday.count))
                .nicheFont(.display)
                .monospacedDigit()
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Live today")
                .nicheFont(.caption)
                .foregroundStyle(NicheTint.Palette.muted)
            labeled("Capsules", watch.capsuleCountLabel)
            labeled("Rays", watch.rayCountLabel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(NicheTint.Palette.surface)
        .accessibilityElement(children: .combine)
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(1)
            Spacer(minLength: NicheCraft.space(1))
            Text(value)
                .nicheFont(.figure)
                .foregroundStyle(NicheTint.Palette.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(minHeight: NicheCraft.tap)
    }

    private var contactRow: some View {
        Link(destination: NicheClient.contactURL) {
            settingsLabel(title: NicheCopy.contact, detail: NicheClient.contactURL.absoluteString)
        }
        .listRowBackground(NicheTint.Palette.surface)
        .accessibilityLabel(NicheCopy.contact)
        .accessibilityValue(NicheClient.contactURL.absoluteString)
    }

    private var contactCard: some View {
        Link(destination: NicheClient.contactURL) {
            settingsLabel(title: NicheCopy.contact, detail: NicheClient.contactURL.absoluteString)
                .padding(NicheCraft.space(2))
                .frame(maxWidth: .infinity, minHeight: NicheCraft.tap, alignment: .leading)
                .background(NicheTint.Palette.surface, in: NicheCraft.cardShape)
                .overlay {
                    NicheCraft.cardShape.stroke(
                        NicheTint.Palette.muted.opacity(0.35),
                        lineWidth: NicheCraft.hairline
                    )
                }
                .contentShape(NicheCraft.cardShape)
        }
        .accessibilityLabel(NicheCopy.contact)
        .accessibilityValue(NicheClient.contactURL.absoluteString)
    }

    private func settingsLabel(title: String, detail: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .nicheFont(.body)
                .foregroundStyle(NicheTint.Palette.ink)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            if let detail {
                Text(detail)
                    .nicheFont(.caption)
                    .foregroundStyle(title == NicheCopy.contact ? NicheTint.Palette.accent : NicheTint.Palette.muted)
                    .underline(title == NicheCopy.contact)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: NicheCraft.tap, alignment: .leading)
    }
}
