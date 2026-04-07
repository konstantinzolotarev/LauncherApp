import AppKit

final class AppDiscoveryService {
    private var apps: [AppItem] = []
    private var mdQuery: MDQuery?

    func loadApps() -> [AppItem] {
        var discovered: [AppItem] = []

        // Spotlight + directory scan (some system apps aren't Spotlight-indexed)
        if let results = querySpotlight() {
            discovered = results
        }
        discovered.append(contentsOf: scanDirectories())

        // Deduplicate by path
        var seen = Set<String>()
        apps = discovered.filter { seen.insert($0.path.path).inserted }
        apps.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return apps
    }

    private func querySpotlight() -> [AppItem]? {
        let queryString = "kMDItemContentTypeTree == 'com.apple.application-bundle'"
        guard let query = MDQueryCreate(kCFAllocatorDefault, queryString as CFString, nil, nil) else {
            return nil
        }

        guard MDQueryExecute(query, CFOptionFlags(kMDQuerySynchronous.rawValue)) else {
            return nil
        }

        let count = MDQueryGetResultCount(query)
        guard count > 0 else { return nil }

        var items: [AppItem] = []
        for i in 0..<count {
            guard let rawPtr = MDQueryGetResultAtIndex(query, i) else { continue }
            let mdItem = Unmanaged<MDItem>.fromOpaque(rawPtr).takeUnretainedValue()

            guard let path = MDItemCopyAttribute(mdItem, kMDItemPath) as? String else { continue }
            let url = URL(fileURLWithPath: path)
            let name =
                MDItemCopyAttribute(mdItem, kMDItemDisplayName) as? String
                ?? url.deletingPathExtension().lastPathComponent

            let bundle = Bundle(path: path)
            let bundleID = bundle?.bundleIdentifier

            items.append(AppItem(name: name, bundleIdentifier: bundleID, path: url))
        }

        return items.isEmpty ? nil : items
    }

    private func scanDirectories() -> [AppItem] {
        let directories = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: "/System/Applications/Utilities"),
            FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications"),
        ]

        var items: [AppItem] = []
        let fm = FileManager.default

        for dir in directories {
            guard
                let contents = try? fm.contentsOfDirectory(
                    at: dir,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )
            else { continue }

            for url in contents where url.pathExtension == "app" {
                let name = url.deletingPathExtension().lastPathComponent
                let bundle = Bundle(url: url)
                let bundleID = bundle?.bundleIdentifier
                items.append(AppItem(name: name, bundleIdentifier: bundleID, path: url))
            }
        }

        return items
    }
}
