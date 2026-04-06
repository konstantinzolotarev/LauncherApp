import AppKit
import Combine

@Observable
final class SearchViewModel {
    var query: String = "" {
        didSet {
            guard query != oldValue else { return }
            updateResults()
        }
    }
    var results: [SearchResult] = []
    var selectedIndex: Int = 0

    private var allApps: [AppItem] = []
    private let discoveryService = AppDiscoveryService()
    var settingsService: SettingsService?

    func loadApps() {
        allApps = discoveryService.loadApps()
    }

    func moveSelection(by offset: Int) {
        guard !results.isEmpty else { return }
        selectedIndex = max(0, min(results.count - 1, selectedIndex + offset))
    }

    func executeSelected() {
        guard selectedIndex >= 0, selectedIndex < results.count else { return }
        let result = results[selectedIndex]

        switch result {
        case .app(let item):
            settingsService?.recordLaunch(path: item.path.path)
            AppLaunchService.launch(item)
        case .calculation(_, let value):
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(value, forType: .string)
        }
    }

    func reset() {
        query = ""
        results = []
        selectedIndex = 0
    }

    func updateResults() {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else {
            results = []
            selectedIndex = 0
            return
        }

        var newResults: [SearchResult] = []

        // Calculator result
        if let calcResult = CalculatorService.evaluate(q) {
            newResults.append(.calculation(expression: q, result: calcResult))
        }

        // App search — filter out ignored apps
        let visibleApps = allApps.filter { !( settingsService?.isIgnored($0.path.path) ?? false) }
        let scored = visibleApps.compactMap { app -> (AppItem, Int)? in
            let score = matchScore(query: q.lowercased(), name: app.name.lowercased())
            return score > 0 ? (app, score) : nil
        }
        .sorted {
            if $0.1 != $1.1 { return $0.1 > $1.1 }
            let c0 = settingsService?.launchCount(for: $0.0.path.path) ?? 0
            let c1 = settingsService?.launchCount(for: $1.0.path.path) ?? 0
            return c0 > c1
        }
        .prefix(8)
        .map { SearchResult.app($0.0) }

        newResults.append(contentsOf: scored)

        results = newResults
        selectedIndex = 0
    }

    private func matchScore(query q: String, name: String) -> Int {
        // Exact prefix match — highest priority
        if name.hasPrefix(q) {
            return 100
        }

        // Word-start prefix match (e.g. "pre" matches "System Preferences")
        let words = name.split(separator: " ").map(String.init)
        for word in words {
            if word.lowercased().hasPrefix(q) {
                return 80
            }
        }

        // Contains match
        if name.contains(q) {
            return 60
        }

        // Subsequence match
        var qIdx = q.startIndex
        for ch in name {
            if qIdx < q.endIndex && ch == q[qIdx] {
                qIdx = q.index(after: qIdx)
            }
        }
        if qIdx == q.endIndex {
            return 40
        }

        return 0
    }
}
