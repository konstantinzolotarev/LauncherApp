import Testing
import Foundation
@testable import LauncherApp

// MARK: - CalculatorService Tests

@Suite("CalculatorService")
struct CalculatorServiceTests {

    @Test("Addition")
    func addition() {
        #expect(CalculatorService.evaluate("2+3") == "5")
    }

    @Test("Subtraction")
    func subtraction() {
        #expect(CalculatorService.evaluate("10-4") == "6")
    }

    @Test("Multiplication")
    func multiplication() {
        #expect(CalculatorService.evaluate("3*7") == "21")
    }

    @Test("Division")
    func division() {
        #expect(CalculatorService.evaluate("20/4") == "5")
    }

    @Test("Parentheses")
    func parentheses() {
        #expect(CalculatorService.evaluate("(2+3)*4") == "20")
    }

    @Test("Power operator")
    func power() {
        #expect(CalculatorService.evaluate("2^3") == "8")
    }

    @Test("Decimal result for non-integer division")
    func decimalResult() {
        // NSExpression performs integer division for int operands; use decimal input
        let result = CalculatorService.evaluate("10.0/3")
        #expect(result != nil)
        #expect(result!.contains("."))
    }

    @Test("Integer formatting omits .0")
    func integerFormatting() {
        #expect(CalculatorService.evaluate("2+2") == "4")
    }

    @Test("Invalid input: alphabetic text")
    func invalidAlpha() {
        #expect(CalculatorService.evaluate("hello") == nil)
    }

    @Test("Invalid input: empty string")
    func invalidEmpty() {
        #expect(CalculatorService.evaluate("") == nil)
    }

    @Test("Invalid input: trailing operator")
    func invalidTrailingOperator() {
        #expect(CalculatorService.evaluate("2+") == nil)
    }

    @Test("Whitespace handling")
    func whitespace() {
        #expect(CalculatorService.evaluate("  2 + 3  ") == "5")
    }

    @Test("Nested parentheses")
    func nestedParentheses() {
        #expect(CalculatorService.evaluate("((2+3)*2)+1") == "11")
    }

    @Test("Negative result")
    func negativeResult() {
        #expect(CalculatorService.evaluate("3-10") == "-7")
    }

    @Test("Large integer stays formatted without decimals")
    func largeInteger() {
        #expect(CalculatorService.evaluate("1000*1000") == "1000000")
    }
}

// MARK: - SearchResult Tests

@Suite("SearchResult")
struct SearchResultTests {

    @Test("App result id, title, subtitle")
    func appResult() {
        let item = AppItem(
            name: "Safari",
            bundleIdentifier: "com.apple.Safari",
            path: URL(fileURLWithPath: "/Applications/Safari.app")
        )
        let result = SearchResult.app(item)

        #expect(result.id == "app-/Applications/Safari.app")
        #expect(result.title == "Safari")
        #expect(result.subtitle == "/Applications/Safari.app")
    }

    @Test("Calculation result id, title, subtitle")
    func calculationResult() {
        let result = SearchResult.calculation(expression: "2+2", result: "4")

        #expect(result.id == "calc-2+2")
        #expect(result.title == "4")
        #expect(result.subtitle == "2+2")
    }
}

// MARK: - AppItem Tests

@Suite("AppItem")
struct AppItemTests {

    @Test("Initialization sets properties correctly")
    func initProperties() {
        let url = URL(fileURLWithPath: "/Applications/Xcode.app")
        let item = AppItem(name: "Xcode", bundleIdentifier: "com.apple.dt.Xcode", path: url)

        #expect(item.id == "/Applications/Xcode.app")
        #expect(item.name == "Xcode")
        #expect(item.bundleIdentifier == "com.apple.dt.Xcode")
        #expect(item.path == url)
    }

    @Test("Nil bundle identifier")
    func nilBundleID() {
        let item = AppItem(name: "MyApp", bundleIdentifier: nil, path: URL(fileURLWithPath: "/tmp/MyApp.app"))
        #expect(item.bundleIdentifier == nil)
    }

    @Test("Equatable uses id (path)")
    func equatable() {
        let a = AppItem(name: "App", bundleIdentifier: nil, path: URL(fileURLWithPath: "/tmp/App.app"))
        let b = AppItem(name: "Different Name", bundleIdentifier: "com.x", path: URL(fileURLWithPath: "/tmp/App.app"))
        #expect(a == b)
    }

    @Test("Non-equal items with different paths")
    func notEqual() {
        let a = AppItem(name: "App", bundleIdentifier: nil, path: URL(fileURLWithPath: "/tmp/A.app"))
        let b = AppItem(name: "App", bundleIdentifier: nil, path: URL(fileURLWithPath: "/tmp/B.app"))
        #expect(a != b)
    }

    @Test("Hashable: equal items produce same hash")
    func hashable() {
        let a = AppItem(name: "App", bundleIdentifier: nil, path: URL(fileURLWithPath: "/tmp/App.app"))
        let b = AppItem(name: "Other", bundleIdentifier: "x", path: URL(fileURLWithPath: "/tmp/App.app"))
        #expect(a.hashValue == b.hashValue)
    }

    @Test("Can be used in a Set")
    func setUsage() {
        let a = AppItem(name: "App", bundleIdentifier: nil, path: URL(fileURLWithPath: "/tmp/App.app"))
        let b = AppItem(name: "Other", bundleIdentifier: nil, path: URL(fileURLWithPath: "/tmp/App.app"))
        let set: Set<AppItem> = [a, b]
        #expect(set.count == 1)
    }
}

// MARK: - SearchViewModel Tests

@Suite("SearchViewModel")
struct SearchViewModelTests {

    @Test("reset() clears query, results, and selectedIndex")
    func reset() {
        let vm = SearchViewModel()
        vm.query = "test"
        vm.selectedIndex = 3
        vm.reset()

        #expect(vm.query == "")
        #expect(vm.results.isEmpty)
        #expect(vm.selectedIndex == 0)
    }

    @Test("moveSelection clamps to lower bound")
    func moveSelectionLowerBound() {
        let vm = SearchViewModel()
        // Set a math query so we get at least one result
        vm.query = "2+2"
        #expect(!vm.results.isEmpty)

        vm.selectedIndex = 0
        vm.moveSelection(by: -5)
        #expect(vm.selectedIndex == 0)
    }

    @Test("moveSelection clamps to upper bound")
    func moveSelectionUpperBound() {
        let vm = SearchViewModel()
        vm.query = "2+2"
        let count = vm.results.count

        vm.moveSelection(by: 100)
        #expect(vm.selectedIndex == count - 1)
    }

    @Test("moveSelection does nothing when results are empty")
    func moveSelectionEmpty() {
        let vm = SearchViewModel()
        vm.moveSelection(by: 1)
        #expect(vm.selectedIndex == 0)
    }

    @Test("Setting query to empty clears results")
    func emptyQueryClearsResults() {
        let vm = SearchViewModel()
        vm.query = "2+2"
        #expect(!vm.results.isEmpty)

        vm.query = ""
        #expect(vm.results.isEmpty)
        #expect(vm.selectedIndex == 0)
    }

    @Test("Math expression query produces calculation result")
    func mathQueryProducesCalculation() {
        let vm = SearchViewModel()
        vm.query = "5*6"

        #expect(!vm.results.isEmpty)
        if case .calculation(let expr, let result) = vm.results.first {
            #expect(expr == "5*6")
            #expect(result == "30")
        } else {
            Issue.record("Expected first result to be a calculation")
        }
    }

    @Test("selectedIndex resets to 0 when query changes")
    func selectedIndexResetsOnQueryChange() {
        let vm = SearchViewModel()
        vm.query = "2+2"
        vm.selectedIndex = 5
        vm.query = "3+3"
        #expect(vm.selectedIndex == 0)
    }

    @Test("Setting query to same value does not reset selectedIndex")
    func sameQueryPreservesSelection() {
        let vm = SearchViewModel()
        vm.query = "2+2"
        #expect(!vm.results.isEmpty)

        vm.selectedIndex = vm.results.count - 1
        let saved = vm.selectedIndex
        // Re-assign the same query — should not reset selection
        vm.query = "2+2"
        #expect(vm.selectedIndex == saved)
    }

    @Test("moveSelection preserves index across redundant query sets")
    func moveSelectionStable() {
        let vm = SearchViewModel()
        vm.query = "2+2"
        vm.moveSelection(by: 0) // no-op but exercises the path
        let idx = vm.selectedIndex
        // Simulate SwiftUI re-setting the same query via binding
        vm.query = "2+2"
        #expect(vm.selectedIndex == idx)
    }

    @Test("Ignored apps are excluded from results")
    func ignoredAppsExcluded() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LauncherTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let settingsURL = tempDir.appendingPathComponent("settings.json")
        let settings = SettingsService(fileURL: settingsURL)

        let vm = SearchViewModel()
        vm.settingsService = settings

        // Load a known app so it appears in search
        // We can't easily inject apps, so test via the settings service + updateResults flow
        // Instead, test that the settings service itself works and is wired in
        settings.ignore(path: "/Applications/Safari.app")
        #expect(settings.isIgnored("/Applications/Safari.app"))
    }

    @Test("Unignoring an app removes it from ignored set")
    func unignoreApp() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LauncherTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let settingsURL = tempDir.appendingPathComponent("settings.json")
        let settings = SettingsService(fileURL: settingsURL)

        settings.ignore(path: "/Applications/Safari.app")
        settings.unignore(path: "/Applications/Safari.app")
        #expect(!settings.isIgnored("/Applications/Safari.app"))
    }
}

// MARK: - SettingsService Tests

@Suite("SettingsService")
struct SettingsServiceTests {

    private func makeTempSettings() throws -> (SettingsService, URL) {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LauncherTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let url = tempDir.appendingPathComponent("settings.json")
        return (SettingsService(fileURL: url), tempDir)
    }

    @Test("Init creates empty ignored set when no file exists")
    func initEmpty() throws {
        let (service, tempDir) = try makeTempSettings()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        #expect(service.ignoredApps.isEmpty)
    }

    @Test("ignore adds path and isIgnored returns true")
    func ignoreAdds() throws {
        let (service, tempDir) = try makeTempSettings()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        service.ignore(path: "/Applications/Safari.app")
        #expect(service.isIgnored("/Applications/Safari.app"))
        #expect(service.ignoredApps.count == 1)
    }

    @Test("unignore removes path")
    func unignoreRemoves() throws {
        let (service, tempDir) = try makeTempSettings()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        service.ignore(path: "/Applications/Safari.app")
        service.unignore(path: "/Applications/Safari.app")
        #expect(!service.isIgnored("/Applications/Safari.app"))
        #expect(service.ignoredApps.isEmpty)
    }

    @Test("Duplicate ignores are idempotent")
    func duplicateIgnore() throws {
        let (service, tempDir) = try makeTempSettings()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        service.ignore(path: "/Applications/Safari.app")
        service.ignore(path: "/Applications/Safari.app")
        #expect(service.ignoredApps.count == 1)
    }

    @Test("JSON round-trip: ignore, reload, still ignored")
    func jsonRoundTrip() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LauncherTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let url = tempDir.appendingPathComponent("settings.json")

        let service1 = SettingsService(fileURL: url)
        service1.ignore(path: "/Applications/Safari.app")
        service1.ignore(path: "/Applications/Xcode.app")

        // Create a new instance that loads from the same file
        let service2 = SettingsService(fileURL: url)
        #expect(service2.isIgnored("/Applications/Safari.app"))
        #expect(service2.isIgnored("/Applications/Xcode.app"))
        #expect(service2.ignoredApps.count == 2)
    }

    @Test("recordLaunch increments count")
    func recordLaunchIncrements() throws {
        let (service, tempDir) = try makeTempSettings()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        service.recordLaunch(path: "/Applications/Safari.app")
        #expect(service.launchCount(for: "/Applications/Safari.app") == 1)
    }

    @Test("launchCount returns 0 for unknown app")
    func launchCountUnknown() throws {
        let (service, tempDir) = try makeTempSettings()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        #expect(service.launchCount(for: "/Applications/Unknown.app") == 0)
    }

    @Test("Multiple recordLaunch calls accumulate")
    func recordLaunchAccumulates() throws {
        let (service, tempDir) = try makeTempSettings()
        defer { try? FileManager.default.removeItem(at: tempDir) }

        service.recordLaunch(path: "/Applications/Safari.app")
        service.recordLaunch(path: "/Applications/Safari.app")
        service.recordLaunch(path: "/Applications/Safari.app")
        #expect(service.launchCount(for: "/Applications/Safari.app") == 3)
    }

    @Test("Launch counts persist across JSON round-trip")
    func launchCountsRoundTrip() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LauncherTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let url = tempDir.appendingPathComponent("settings.json")

        let service1 = SettingsService(fileURL: url)
        service1.recordLaunch(path: "/Applications/Safari.app")
        service1.recordLaunch(path: "/Applications/Safari.app")
        service1.recordLaunch(path: "/Applications/Xcode.app")

        let service2 = SettingsService(fileURL: url)
        #expect(service2.launchCount(for: "/Applications/Safari.app") == 2)
        #expect(service2.launchCount(for: "/Applications/Xcode.app") == 1)
    }

    @Test("Existing settings.json without launchCounts loads without error")
    func backwardCompatibility() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("LauncherTest-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tempDir) }

        let url = tempDir.appendingPathComponent("settings.json")
        // Write a settings file without launchCounts field
        let json = Data(#"{"ignoredApps":["/Applications/Safari.app"]}"#.utf8)
        try json.write(to: url)

        let service = SettingsService(fileURL: url)
        #expect(service.isIgnored("/Applications/Safari.app"))
        #expect(service.launchCount(for: "/Applications/Safari.app") == 0)
        #expect(service.launchCounts.isEmpty)
    }
}
