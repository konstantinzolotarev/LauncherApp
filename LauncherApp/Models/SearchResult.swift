import AppKit

enum SearchResult: Identifiable {
    case app(AppItem)
    case calculation(expression: String, result: String)

    var id: String {
        switch self {
        case .app(let item): return "app-\(item.id)"
        case .calculation(let expr, _): return "calc-\(expr)"
        }
    }

    var title: String {
        switch self {
        case .app(let item): return item.name
        case .calculation(_, let result): return result
        }
    }

    var subtitle: String {
        switch self {
        case .app(let item): return item.path.path
        case .calculation(let expr, _): return expr
        }
    }

    var icon: NSImage {
        switch self {
        case .app(var item): return item.icon
        case .calculation:
            return NSImage(systemSymbolName: "equal.circle.fill", accessibilityDescription: "Calculator")
                ?? NSImage()
        }
    }
}
