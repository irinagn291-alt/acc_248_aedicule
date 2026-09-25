import SwiftUI

/// Role: Niche. Host. The niche glass stays mounted. Scene flush and day fold sit above it.
struct ContentView: View {
    @State private var watch = NicheWatch.live()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NicheShell(watch: watch)
            .task {
                await watch.appear()
            }
            .onChange(of: scenePhase) { _, phase in
                watch.handlePhase(phase)
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                Task { await watch.foldDay() }
            }
    }
}

#Preview("Seeded") {
    NicheShell(watch: .previewSeeded())
}

#Preview("Empty") {
    NicheShell(watch: .previewEmpty())
}
