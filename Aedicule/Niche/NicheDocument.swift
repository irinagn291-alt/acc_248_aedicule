import Foundation

/// Role: Niche. Typed refusals of attach and Draw. Views map these; they never mutate sparks.
enum NicheFault: Error, Equatable, Sendable {
    case unknownGlow
    case mediaFrozen
    case emptyDraw
    case emptyMedia
}

enum NicheCodecError: Error, Equatable, Sendable {
    case unknownSchema(Int)
    case damaged
}

enum NicheNotice: Equatable, Sendable {
    case restored
    case cleared
}

enum NicheVault {
    static let snapshot = "aed.niche.v1"
    static let backup = "aed.niche.v1.backup"
    static let demo = "aed.demo.v1"
}

/// Role: Niche. Codable document. schemaVersion from 1. Glows, RayMarks, daykeys as Int YYYYMMDD. Roles are folded, not a second list.
struct NicheDocument: Equatable, Sendable, Codable {
    var schemaVersion: Int
    var onboardingComplete: Bool
    var glows: [GlowSpark]
    var rays: [RayMark]
    var stagedGlowID: UUID?

    static let schema = 1

    static let empty = NicheDocument(
        schemaVersion: schema,
        onboardingComplete: false,
        glows: [],
        rays: [],
        stagedGlowID: nil
    )

    var canCatch: Bool { true }

    var rayCount: Int { rays.count }

    func canDraw(at now: Date, calendar: Calendar) -> Bool {
        !drawPool(at: now, calendar: calendar).isEmpty
    }

    func folded(at now: Date, calendar: Calendar) -> [Glow] {
        WickFold.midnight(sparks: glows, now: now, calendar: calendar)
    }

    func liveToday(at now: Date, calendar: Calendar) -> [Glow] {
        folded(at: now, calendar: calendar).filter { $0.kind == .live }
    }

    func drawPool(at now: Date, calendar: Calendar) -> [Glow] {
        DrawRay.pool(folded(at: now, calendar: calendar), today: VotiveDay.from(now, calendar: calendar))
    }

    func capsuleCollage(at now: Date, calendar: Calendar) -> [Int: [Glow]] {
        CapsuleBloom.collage(folded(at: now, calendar: calendar))
    }

    func capsuleCount(at now: Date, calendar: Calendar) -> Int {
        folded(at: now, calendar: calendar).filter { $0.kind == .capsule }.count
    }

    @discardableResult
    mutating func catchGlow(_ hue: GlowHue, at now: Date, calendar: Calendar, id: UUID = UUID()) -> Glow {
        let spark = GlowSpark(
            id: id,
            daykey: VotiveDay.from(now, calendar: calendar).rawValue,
            hue: hue,
            stillName: nil,
            voiceName: nil,
            caughtUnix: now.timeIntervalSince1970
        )
        glows.append(spark)
        return .live(spark)
    }

    mutating func attachStill(id: UUID, name: String, at now: Date, calendar: Calendar) throws {
        try bindMedia(id: id, still: name, voice: nil, at: now, calendar: calendar)
    }

    mutating func attachVoice(id: UUID, name: String, at now: Date, calendar: Calendar) throws {
        try bindMedia(id: id, still: nil, voice: name, at: now, calendar: calendar)
    }

    mutating func foldMidnight(at now: Date, calendar: Calendar) {
        _ = folded(at: now, calendar: calendar)
    }

    @discardableResult
    mutating func drawRay(
        at now: Date,
        calendar: Calendar,
        slot: Int? = nil,
        markID: UUID = UUID()
    ) throws -> (Glow, RayMark) {
        let pool = drawPool(at: now, calendar: calendar)
        let glow = try DrawRay.sample(pool, slot: slot)
        let mark = RayMark(
            id: markID,
            glowID: glow.id,
            drawnUnix: now.timeIntervalSince1970,
            drawnDaykey: VotiveDay.from(now, calendar: calendar).rawValue
        )
        rays.append(mark)
        stagedGlowID = glow.id
        return (glow, mark)
    }

    static func read(_ data: Data) throws -> NicheDocument {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let probe: SchemaProbe
        do {
            probe = try decoder.decode(SchemaProbe.self, from: data)
        } catch {
            throw NicheCodecError.damaged
        }
        switch probe.schemaVersion {
        case 1:
            do {
                var document = try decoder.decode(NicheDocument.self, from: data)
                document.schemaVersion = schema
                return document
            } catch {
                throw NicheCodecError.damaged
            }
        default:
            throw NicheCodecError.unknownSchema(probe.schemaVersion)
        }
    }

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        var copy = self
        copy.schemaVersion = Self.schema
        return try encoder.encode(copy)
    }

    private mutating func bindMedia(
        id: UUID,
        still: String?,
        voice: String?,
        at now: Date,
        calendar: Calendar
    ) throws {
        if let still, still.isEmpty { throw NicheFault.emptyMedia }
        if let voice, voice.isEmpty { throw NicheFault.emptyMedia }
        guard let index = glows.firstIndex(where: { $0.id == id }) else {
            throw NicheFault.unknownGlow
        }
        let folded = Glow.fold(glows[index], today: VotiveDay.from(now, calendar: calendar), calendar: calendar)
        guard folded.canAttach else { throw NicheFault.mediaFrozen }
        if let still {
            glows[index].stillName = still
        }
        if let voice {
            glows[index].voiceName = voice
        }
    }
}

private struct SchemaProbe: Decodable {
    var schemaVersion: Int
}
