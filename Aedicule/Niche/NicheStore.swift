import Foundation

/// Role: Niche. Memory is the source of truth. UserDefaults aed.niche.v1 plus an Application Support projection. Views never touch UserDefaults.
actor NicheStore {
    private struct Disk {
        var root: URL

        var vault: URL { root.appendingPathComponent("niche.json") }
        var spare: URL { root.appendingPathComponent("niche.json.backup") }
        var media: URL { root.appendingPathComponent("media", isDirectory: true) }
    }

    private let disk: Disk
    private let suite: String?
    private let files: FileManager
    private let quietNanos: UInt64

    private var memory = NicheDocument.empty
    private var pending = false
    private var quietTask: Task<Void, Never>?
    private(set) var notice: NicheNotice?
    private(set) var lastWriteError: String?

    init(
        directory: URL,
        defaultsSuiteName: String? = nil,
        fileManager: FileManager = .default,
        quietNanos: UInt64 = 420_000_000
    ) {
        self.disk = Disk(root: directory)
        self.suite = defaultsSuiteName
        self.files = fileManager
        self.quietNanos = quietNanos
    }

    static func applicationSupportDirectory(fileManager: FileManager = .default) throws -> URL {
        let root = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return root.appendingPathComponent("Aedicule", isDirectory: true)
    }

    func load(now: Date = Date(), calendar: Calendar = .current) async -> (document: NicheDocument, notice: NicheNotice?) {
        notice = nil
        lastWriteError = nil
        pending = false
        switch recover() {
        case .clean(let document):
            memory = document
            memory.foldMidnight(at: now, calendar: calendar)
            return (memory, nil)
        case .spare(let document):
            memory = document
            memory.foldMidnight(at: now, calendar: calendar)
            notice = .restored
            return (memory, notice)
        case .blank(let hadPayload):
            memory = .empty
            if hadPayload {
                notice = .cleared
            }
            return (memory, notice)
        }
    }

    func snapshot() async -> NicheDocument {
        memory
    }

    func catchGlow(_ hue: GlowHue, at now: Date = Date(), calendar: Calendar = .current, id: UUID = UUID()) async throws -> NicheDocument {
        _ = memory.catchGlow(hue, at: now, calendar: calendar, id: id)
        try commit()
        return memory
    }

    func attachMedia(
        glowID: UUID,
        still: Data? = nil,
        voice: Data? = nil,
        at now: Date = Date(),
        calendar: Calendar = .current
    ) async throws -> NicheDocument {
        if still == nil && voice == nil { throw NicheFault.emptyMedia }
        if let still, still.isEmpty { throw NicheFault.emptyMedia }
        if let voice, voice.isEmpty { throw NicheFault.emptyMedia }

        let folded = Glow.fold(
            try spark(glowID),
            today: VotiveDay.from(now, calendar: calendar),
            calendar: calendar
        )
        guard folded.canAttach else { throw NicheFault.mediaFrozen }

        if let still {
            let name = "\(glowID.uuidString.lowercased())-still.jpg"
            try writeMedia(named: name, bytes: still)
            try memory.attachStill(id: glowID, name: name, at: now, calendar: calendar)
        }
        if let voice {
            let name = "\(glowID.uuidString.lowercased())-voice.m4a"
            try writeMedia(named: name, bytes: voice)
            try memory.attachVoice(id: glowID, name: name, at: now, calendar: calendar)
        }
        try commit()
        return memory
    }

    func foldMidnight(at now: Date = Date(), calendar: Calendar = .current) async throws -> NicheDocument {
        memory.foldMidnight(at: now, calendar: calendar)
        try commit()
        return memory
    }

    func drawRay(at now: Date = Date(), calendar: Calendar = .current, slot: Int? = nil) async throws -> NicheDocument {
        _ = try memory.drawRay(at: now, calendar: calendar, slot: slot)
        try commit()
        return memory
    }

    func setOnboardingComplete(_ flag: Bool) async -> NicheDocument {
        memory.onboardingComplete = flag
        pending = true
        armQuietWrite()
        return memory
    }

    func flush() async throws {
        quietTask?.cancel()
        quietTask = nil
        if pending {
            try commit()
        }
    }

    func resetAllData() async throws {
        quietTask?.cancel()
        quietTask = nil
        memory = .empty
        pending = false
        notice = nil
        lastWriteError = nil
        let defaults = defaults()
        defaults.removeObject(forKey: NicheVault.snapshot)
        defaults.removeObject(forKey: NicheVault.backup)
        defaults.removeObject(forKey: NicheVault.demo)
        if files.fileExists(atPath: disk.root.path) {
            try files.removeItem(at: disk.root)
        }
        prepareRoot()
    }

    func seedDemoIfNeeded(
        permit: Bool,
        now: Date = Date(),
        calendar: Calendar = .current
    ) async throws -> NicheDocument? {
        guard permit else { return nil }
        let defaults = defaults()
        guard defaults.object(forKey: NicheVault.demo) == nil else { return nil }
        memory = NicheSeed.document(at: now, calendar: calendar)
        try commit()
        defaults.set(true, forKey: NicheVault.demo)
        return memory
    }

    func mediaBytes(named: String) async -> Data? {
        let url = disk.media.appendingPathComponent(name: named)
        return try? Data(contentsOf: url)
    }

    private func spark(_ id: UUID) throws -> GlowSpark {
        guard let spark = memory.glows.first(where: { $0.id == id }) else {
            throw NicheFault.unknownGlow
        }
        return spark
    }

    private enum Recovered {
        case clean(NicheDocument)
        case spare(NicheDocument)
        case blank(Bool)
    }

    private func recover() -> Recovered {
        let defaults = defaults()
        if let data = defaults.data(forKey: NicheVault.snapshot), let document = decode(data) {
            return .clean(document)
        }
        if let document = decodeFile(disk.vault) {
            return .clean(document)
        }
        if let data = defaults.data(forKey: NicheVault.backup), let document = decode(data) {
            return .spare(document)
        }
        if let document = decodeFile(disk.spare) {
            return .spare(document)
        }
        let hadPayload = defaults.data(forKey: NicheVault.snapshot) != nil
            || files.fileExists(atPath: disk.vault.path)
        return .blank(hadPayload)
    }

    private func commit() throws {
        let data = try memory.encoded()
        let defaults = defaults()
        if let previous = defaults.data(forKey: NicheVault.snapshot) {
            defaults.set(previous, forKey: NicheVault.backup)
        }
        defaults.set(data, forKey: NicheVault.snapshot)
        prepareRoot()
        if files.fileExists(atPath: disk.vault.path) {
            try? files.removeItem(at: disk.spare)
            try? files.copyItem(at: disk.vault, to: disk.spare)
        }
        try data.write(to: disk.vault, options: .atomic)
        pending = false
        lastWriteError = nil
    }

    private func armQuietWrite() {
        quietTask?.cancel()
        let delay = quietNanos
        quietTask = Task { [weak self] in
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }
            guard !Task.isCancelled else { return }
            await self?.flushIfNeeded()
        }
    }

    private func flushIfNeeded() async {
        quietTask = nil
        do {
            if pending {
                try commit()
            }
        } catch {
            lastWriteError = String(describing: error)
        }
    }

    private func writeMedia(named: String, bytes: Data) throws {
        prepareRoot()
        let folder = disk.media
        if !files.fileExists(atPath: folder.path) {
            try files.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        let url = folder.appendingPathComponent(name: named)
        try bytes.write(to: url, options: .atomic)
    }

    private func decode(_ data: Data) -> NicheDocument? {
        try? NicheDocument.read(data)
    }

    private func decodeFile(_ url: URL) -> NicheDocument? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return decode(data)
    }

    private func defaults() -> UserDefaults {
        if let suite {
            return UserDefaults(suiteName: suite) ?? .standard
        }
        return .standard
    }

    private func prepareRoot() {
        if !files.fileExists(atPath: disk.root.path) {
            try? files.createDirectory(at: disk.root, withIntermediateDirectories: true)
        }
    }
}

private extension URL {
    func appendingPathComponent(name: String) -> URL {
        appendingPathComponent(name, isDirectory: false)
    }
}
