import AppKit
import SwiftUI

extension NSView {
    fileprivate func findFirstTextField() -> NSTextField? {
        if let tf = self as? NSTextField, tf.isEditable { return tf }
        for sub in subviews {
            if let found = sub.findFirstTextField() { return found }
        }
        return nil
    }
}

final class FloatingPanelController: @unchecked Sendable {
    private var panel: FloatingPanel?
    private let viewModel: SearchViewModel
    private var observing = false

    private static let panelWidth: CGFloat = 680
    private static let searchBarHeight: CGFloat = 48
    private static let dividerHeight: CGFloat = 1
    private static let scrollPadding: CGFloat = 12

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }

    var isVisible: Bool {
        panel?.isVisible ?? false
    }

    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    func show() {
        if panel == nil {
            createPanel()
        }

        guard let panel, let screen = NSScreen.main else { return }

        viewModel.reset()

        // Position: centered horizontally, upper third of screen
        let panelHeight = Self.panelHeight(resultCount: viewModel.results.count)
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - Self.panelWidth / 2
        let y = screenFrame.origin.y + screenFrame.height * 0.7 - panelHeight / 2

        panel.setFrame(NSRect(x: x, y: y, width: Self.panelWidth, height: panelHeight), display: true)
        startObservingResults()
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
        }

        // Focus the text field
        DispatchQueue.main.async {
            panel.makeFirstResponder(panel.contentView?.findFirstTextField())
        }
    }

    func hide() {
        guard let panel, panel.isVisible else { return }
        observing = false

        NSAnimationContext.runAnimationGroup(
            { ctx in
                ctx.duration = 0.1
                ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
                panel.animator().alphaValue = 0
            },
            completionHandler: {
                panel.orderOut(nil)
            })
    }

    private static func panelHeight(resultCount: Int) -> CGFloat {
        let visibleCount = min(resultCount, 4)
        if visibleCount == 0 {
            return searchBarHeight
        }
        return searchBarHeight + dividerHeight + scrollPadding + ResultRowView.estimatedHeight * CGFloat(visibleCount)
    }

    private func startObservingResults() {
        guard !observing else { return }
        observing = true
        scheduleObservation()
    }

    private func scheduleObservation() {
        guard observing else { return }
        withObservationTracking {
            _ = viewModel.results
        } onChange: { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self, self.observing else { return }
                self.resizePanel(resultCount: self.viewModel.results.count)
                self.scheduleObservation()
            }
        }
    }

    private func resizePanel(resultCount: Int) {
        guard let panel, panel.isVisible else { return }
        let newHeight = Self.panelHeight(resultCount: resultCount)
        var frame = panel.frame
        let topY = frame.origin.y + frame.size.height
        frame.size.height = newHeight
        frame.origin.y = topY - newHeight
        panel.setFrame(frame, display: true, animate: true)
    }

    private func createPanel() {
        let panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: Self.panelWidth, height: Self.searchBarHeight))
        let searchView = SearchView(
            viewModel: viewModel,
            onDismiss: { [weak self] in
                self?.hide()
            })
        let hostingView = NSHostingView(rootView: searchView)
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 12
        hostingView.layer?.masksToBounds = true
        panel.contentView = hostingView
        self.panel = panel
    }
}
