import AppKit

final class KeyboardHandler {
    private var monitor: Any?
    private weak var viewModel: SearchViewModel?
    private var onEscape: (() -> Void)?

    func start(viewModel: SearchViewModel, onEscape: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onEscape = onEscape

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }
            return self.handleKeyDown(event)
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }

    private func handleKeyDown(_ event: NSEvent) -> NSEvent? {
        switch Int(event.keyCode) {
        case 125:  // Down arrow
            viewModel?.moveSelection(by: 1)
            return nil
        case 126:  // Up arrow
            viewModel?.moveSelection(by: -1)
            return nil
        case 53:  // Escape
            onEscape?()
            return nil
        case 36:  // Return — handled by SwiftUI onSubmit, but as backup
            return event
        default:
            return event
        }
    }
}
