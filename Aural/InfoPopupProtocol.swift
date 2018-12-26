import Cocoa

// Contract for displaying info notification popups
protocol InfoPopupProtocol {
    
    // Shows a info message
    func showMessage(_ message: String, _ relativeToView: NSView, _ preferredEdge: NSRectEdge)
}
