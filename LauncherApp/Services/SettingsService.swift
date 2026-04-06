import Foundation

@Observable
final class SettingsService {
    private(set) var ignoredApps: Set<String> = []
    private(set) var launchCounts: [String: Int] = [:]
    private let fileURL: URL

    init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? Self.defaultFileURL
        load()
    }

    func ignore(path: String) {
        guard ignoredApps.insert(path).inserted else { return }
        save()
    }

    func unignore(path: String) {
        guard ignoredApps.remove(path) != nil else { return }
        save()
    }

    func isIgnored(_ path: String) -> Bool {
        ignoredApps.contains(path)
    }

    func recordLaunch(path: String) {
        launchCounts[path, default: 0] += 1
        save()
    }

    func launchCount(for path: String) -> Int {
        launchCounts[path] ?? 0
    }

    // MARK: - Persistence

    private static var defaultFileURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("LauncherApp/settings.json")
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        guard let settings = try? JSONDecoder().decode(SettingsFile.self, from: data) else { return }
        ignoredApps = Set(settings.ignoredApps)
        launchCounts = settings.launchCounts
    }

    private func save() {
        let settings = SettingsFile(ignoredApps: Array(ignoredApps).sorted(), launchCounts: launchCounts)
        guard let data = try? JSONEncoder.prettyPrinted.encode(settings) else { return }
        let dir = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try? data.write(to: fileURL, options: .atomic)
    }
}

private struct SettingsFile: Codable {
    var ignoredApps: [String]
    var launchCounts: [String: Int]

    init(ignoredApps: [String] = [], launchCounts: [String: Int] = [:]) {
        self.ignoredApps = ignoredApps
        self.launchCounts = launchCounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ignoredApps = try container.decodeIfPresent([String].self, forKey: .ignoredApps) ?? []
        launchCounts = try container.decodeIfPresent([String: Int].self, forKey: .launchCounts) ?? [:]
    }
}

private extension JSONEncoder {
    static let prettyPrinted: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }()
}
