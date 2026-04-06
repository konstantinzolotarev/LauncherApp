import SwiftUI

@main
struct LauncherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra("Launcher", systemImage: "magnifyingglass") {
            Button("Show Launcher") {
                appDelegate.togglePanel()
            }
            .keyboardShortcut("l", modifiers: [.command])

            Divider()

            Button("Preferences...") {
                openWindow(id: "preferences")
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut(",", modifiers: [.command])

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }

        Window("Preferences", id: "preferences") {
            PreferencesView(settingsService: appDelegate.settingsService)
        }
        .windowResizability(.contentSize)
    }
}
