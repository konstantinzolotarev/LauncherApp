# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

```sh
swift build              # Build the app
swift run LauncherApp    # Build and run
swift test               # Run all tests (Swift Testing framework)
swiftlint lint --strict  # Lint all Swift files
swift-format lint --strict -r LauncherApp/ Tests/  # Check formatting
```

Xcode workflow (requires `xcodegen`):
```sh
xcodegen generate        # Regenerate LauncherApp.xcodeproj from project.yml
open LauncherApp.xcodeproj
```

Release build:
```sh
xcodebuild -project LauncherApp.xcodeproj -scheme LauncherApp -configuration Release -derivedDataPath build/DerivedData build
# Output: build/DerivedData/Build/Products/Release/LauncherApp.app
```

## Architecture

macOS menu bar launcher app (no dock icon). Activated via **Option+Space** global hotkey. Two features: app search and inline calculator.

**Data flow:** Global hotkey → `AppDelegate` → `FloatingPanelController.toggle()` → `FloatingPanel` (NSPanel) hosts `SearchView` (SwiftUI) → `SearchViewModel` (@Observable) processes keystrokes → queries `AppDiscoveryService` and `CalculatorService` → returns `[SearchResult]` → user selects → `AppLaunchService.launch()` or clipboard copy.

**Key design decisions:**
- `NSPanel` with `.nonactivatingPanel` style mask — essential so the panel doesn't steal focus from the active app. Regular `NSWindow` would break this.
- Panel show/hide is instant (no animations) for maximum responsiveness. Panel auto-dismisses via `resignKey()` override. Panel dynamically resizes to fit content — search bar only when empty, expanding up to 4 result rows. `FloatingPanelController` observes `viewModel.results` via `withObservationTracking` and adjusts the panel frame anchored at the top edge. Marked `@unchecked Sendable` since it's only used from the main thread.
- `NSExpression` for calculator — does integer division for int operands (e.g., `10/3 = 3`). Use decimal input (`10.0/3`) for float results. `NSExpression` throws ObjC exceptions (not Swift errors) on malformed input, so input is validated via regex before evaluation.
- App discovery uses Spotlight `MDQuery` with a `FileManager` directory-scan fallback. Directory scan covers `/Applications`, `/System/Applications`, `/System/Applications/Utilities`, and `~/Applications`.
- Search scoring: prefix match (100) > word-start prefix (80) > contains (60) > subsequence (40). Within the same score tier, apps are ranked by launch count (usage frequency). Top 8 results shown. Launch counts are stored in `settings.json` alongside `ignoredApps`.
- `SearchViewModel.query` uses a `guard query != oldValue` in `didSet` to prevent `@Observable`/SwiftUI binding re-renders from resetting `selectedIndex` via redundant `updateResults()` calls.

## Dependencies

Single external dependency: [HotKey](https://github.com/soffes/HotKey) (0.2.1+) — wraps Carbon `RegisterEventHotKey` for global keyboard shortcuts. Dependabot monitors for updates weekly (`.github/dependabot.yml`).

## CI & Linting

GitHub Actions CI (`.github/workflows/ci.yml`) runs on push to `main` and all PRs with three jobs: build-and-test, swiftlint, swift-format.

- **SwiftLint** (`.swiftlint.yml`) — enforces style rules. `force_try` and `force_unwrapping` are opt-in rules with inline disables where justified. Short identifier names are allowed (`min_length: 1`).
- **swift-format** (`.swift-format`) — enforces formatting with 4-space indentation. Run `swift-format format -i -r LauncherApp/ Tests/` to auto-fix.

## Testing

Tests use **Swift Testing** (`import Testing`, `@Suite`, `@Test`, `#expect`) — not XCTest. All tests are in `Tests/LauncherAppTests.swift`. Six suites: CalculatorService, SearchResult, AppItem, SearchViewModel, AppDiscoveryService, SettingsService (46 tests total).

## Platform

macOS 14.0+, Swift 5.10. App sandbox is disabled (entitlements). `LSUIElement = YES` in Info.plist hides dock icon.
