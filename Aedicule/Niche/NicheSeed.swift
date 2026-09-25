import Foundation

/// Role: Niche. Simulator demo behind aed.demo.v1. Device never writes this. Catch and Draw stay enabled.
enum NicheSeed {
    static func document(at now: Date, calendar: Calendar) -> NicheDocument {
        let today = VotiveDay.from(now, calendar: calendar)
        let unix = now.timeIntervalSince1970

        let live = [
            spark(
                id: fixed("aaaaaaaa-1111-4000-8000-000000000001"),
                daykey: today.rawValue,
                hue: .ember,
                stillName: "seed-ember.jpg",
                voiceName: nil,
                caughtUnix: unix - 3_600
            ),
            spark(
                id: fixed("aaaaaaaa-1111-4000-8000-000000000002"),
                daykey: today.rawValue,
                hue: .hush,
                stillName: nil,
                voiceName: "seed-hush.m4a",
                caughtUnix: unix - 2_400
            ),
            spark(
                id: fixed("aaaaaaaa-1111-4000-8000-000000000003"),
                daykey: today.rawValue,
                hue: .bloom,
                stillName: nil,
                voiceName: nil,
                caughtUnix: unix - 1_200
            ),
            spark(
                id: fixed("aaaaaaaa-1111-4000-8000-000000000004"),
                daykey: today.rawValue,
                hue: .tide,
                stillName: nil,
                voiceName: nil,
                caughtUnix: unix - 400
            ),
        ]

        let wickA = today.shifted(by: -3, calendar: calendar)
        let wickB = today.shifted(by: -8, calendar: calendar)
        let wickC = today.shifted(by: -15, calendar: calendar)
        let wicks = [
            spark(
                id: fixed("bbbbbbbb-2222-4000-8000-000000000001"),
                daykey: wickA.rawValue,
                hue: .hearth,
                stillName: "seed-hearth.jpg",
                voiceName: nil,
                caughtUnix: unix - 259_200
            ),
            spark(
                id: fixed("bbbbbbbb-2222-4000-8000-000000000002"),
                daykey: wickB.rawValue,
                hue: .gleam,
                stillName: nil,
                voiceName: "seed-gleam.m4a",
                caughtUnix: unix - 691_200
            ),
            spark(
                id: fixed("bbbbbbbb-2222-4000-8000-000000000003"),
                daykey: wickC.rawValue,
                hue: .still,
                stillName: nil,
                voiceName: nil,
                caughtUnix: unix - 1_296_000
            ),
        ]

        let capsuleA = today.shifted(by: -40, calendar: calendar)
        let capsuleB = today.shifted(by: -62, calendar: calendar)
        let capsuleC = today.shifted(by: -95, calendar: calendar)
        let capsuleD = today.shifted(by: -140, calendar: calendar)
        let capsuleE = today.shifted(by: -188, calendar: calendar)
        let capsules = [
            spark(
                id: fixed("cccccccc-3333-4000-8000-000000000001"),
                daykey: capsuleA.rawValue,
                hue: .lift,
                stillName: "seed-lift.jpg",
                voiceName: nil,
                caughtUnix: unix - 3_456_000
            ),
            spark(
                id: fixed("cccccccc-3333-4000-8000-000000000002"),
                daykey: capsuleB.rawValue,
                hue: .ember,
                stillName: nil,
                voiceName: nil,
                caughtUnix: unix - 5_356_800
            ),
            spark(
                id: fixed("cccccccc-3333-4000-8000-000000000003"),
                daykey: capsuleC.rawValue,
                hue: .bloom,
                stillName: nil,
                voiceName: nil,
                caughtUnix: unix - 8_208_000
            ),
            spark(
                id: fixed("cccccccc-3333-4000-8000-000000000004"),
                daykey: capsuleD.rawValue,
                hue: .tide,
                stillName: nil,
                voiceName: nil,
                caughtUnix: unix - 12_096_000
            ),
            spark(
                id: fixed("cccccccc-3333-4000-8000-000000000005"),
                daykey: capsuleE.rawValue,
                hue: .hearth,
                stillName: nil,
                voiceName: nil,
                caughtUnix: unix - 16_243_200
            ),
        ]

        let rays = [
            RayMark(
                id: fixed("dddddddd-4444-4000-8000-000000000001"),
                glowID: capsules[0].id,
                drawnUnix: unix - 86_400,
                drawnDaykey: today.shifted(by: -1, calendar: calendar).rawValue
            ),
            RayMark(
                id: fixed("dddddddd-4444-4000-8000-000000000002"),
                glowID: wicks[0].id,
                drawnUnix: unix - 7_200,
                drawnDaykey: today.rawValue
            ),
        ]

        return NicheDocument(
            schemaVersion: NicheDocument.schema,
            onboardingComplete: true,
            glows: live + wicks + capsules,
            rays: rays,
            stagedGlowID: capsules[0].id
        )
    }

    private static func spark(
        id: UUID,
        daykey: Int,
        hue: GlowHue,
        stillName: String?,
        voiceName: String?,
        caughtUnix: Double
    ) -> GlowSpark {
        GlowSpark(
            id: id,
            daykey: daykey,
            hue: hue,
            stillName: stillName,
            voiceName: voiceName,
            caughtUnix: caughtUnix
        )
    }

    private static func fixed(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }
}
