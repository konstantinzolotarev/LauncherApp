# LauncherApp

A lightweight macOS application launcher — a minimal Spotlight/Raycast alternative built with SwiftUI.

<!-- screenshot -->

## Features

- **App launching** — discovers installed apps via Spotlight (MDQuery) with filesystem fallback, fuzzy search with prefix/substring/subsequence matching
- **Inline calculator** — type math expressions (e.g. `2+2`, `3^4`, `100/7`) and get instant results; Enter copies the result to clipboard
- **Global hotkey** — Option+Space to toggle the launcher from anywhere
- **Menu bar agent** — runs as a menu bar app (no Dock icon), with quick access to show/quit

## Requirements

- macOS 14.0+
- Swift 5.10+
- Xcode 15+ (for Xcode project workflow)

## Getting Started

### Using Swift Package Manager

```sh
swift build
swift run LauncherApp
```

### Using Xcode

Generate the Xcode project with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
xcodegen generate
open LauncherApp.xcodeproj
```

Then build and run the `LauncherApp` scheme (Cmd+R).

### Build & Install to /Applications

```sh
# Generate Xcode project (requires xcodegen: brew install xcodegen)
xcodegen generate

# Build the .app bundle
xcodebuild -project LauncherApp.xcodeproj -scheme LauncherApp -configuration Release -derivedDataPath build clean build

# Copy to Applications
cp -R build/Build/Products/Release/LauncherApp.app /Applications/LauncherApp.app

# Launch
open /Applications/LauncherApp.app
```

## Usage

| Action | Key |
|---|---|
| Toggle launcher | Option+Space |
| Search apps | Start typing |
| Navigate results | Up/Down arrows |
| Launch app / copy calc result | Enter |
| Dismiss | Escape (or click outside) |

The menu bar icon (magnifying glass) provides **Show Launcher** (Cmd+L) and **Quit** (Cmd+Q) options.

## Architecture

```
LauncherApp/
├── App/
│   ├── LauncherApp.swift      # @main entry, MenuBarExtra scene
│   └── AppDelegate.swift      # Global hotkey registration, lifecycle
├── Panel/
│   └── FloatingPanel.swift    # NSPanel subclass — floating, non-activating overlay
├── Services/
│   ├── AppDiscoveryService.swift  # Spotlight MDQuery + directory scan fallback
│   ├── AppLaunchService.swift     # NSWorkspace app launching
│   └── CalculatorService.swift    # NSExpression-based math evaluation
├── ViewModels/
│   └── SearchViewModel.swift  # @Observable, drives search + selection state
├── Views/                     # SwiftUI search bar and result list
└── Models/                    # AppItem, SearchResult types
```

Key patterns:
- **FloatingPanel** — a non-activating `NSPanel` that floats above other windows and auto-dismisses on focus loss
- **AppDiscoveryService** — tries Spotlight first for full app discovery, falls back to scanning `/Applications` directories
- **SearchViewModel** — `@Observable` view model with scored fuzzy matching (prefix > word-start > contains > subsequence)

## Dependencies

- [HotKey](https://github.com/soffes/HotKey) (0.2.1+) by Sam Soffes — simple global keyboard shortcut handling

## License

MIT
