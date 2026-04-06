import AppKit

struct AppLaunchService {
    static func launch(_ app: AppItem) {
        let config = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: app.path, configuration: config) { _, error in
            if let error {
                print("Failed to launch \(app.name): \(error.localizedDescription)")
            }
        }
    }
}
