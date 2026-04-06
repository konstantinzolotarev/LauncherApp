import AppKit
import HotKey

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotKey: HotKey?
    private var keyboardHandler = KeyboardHandler()
    let settingsService = SettingsService()
    private let viewModel = SearchViewModel()
    private lazy var panelController = FloatingPanelController(viewModel: viewModel)

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Inject settings service
        viewModel.settingsService = settingsService

        // Load apps in background
        DispatchQueue.global(qos: .userInitiated).async { [viewModel] in
            viewModel.loadApps()
        }

        // Register global hotkey: Option+Space
        hotKey = HotKey(key: .space, modifiers: [.option])
        hotKey?.keyDownHandler = { [weak self] in
            self?.togglePanel()
        }

        // Start keyboard handler
        keyboardHandler.start(viewModel: viewModel) { [weak self] in
            self?.panelController.hide()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        keyboardHandler.stop()
    }

    func togglePanel() {
        panelController.toggle()
    }
}
