import AppKit

struct AppItem: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String?
    let path: URL
    private var _icon: NSImage?

    var icon: NSImage {
        mutating get {
            if let cached = _icon { return cached }
            let loaded = NSWorkspace.shared.icon(forFile: path.path)
            loaded.size = NSSize(width: 32, height: 32)
            _icon = loaded
            return loaded
        }
    }

    init(name: String, bundleIdentifier: String?, path: URL) {
        self.id = path.path
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.path = path
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
