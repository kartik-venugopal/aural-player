import Cocoa

class FXWindow: NSWindow {
    
    override func mouseDragged(with event: NSEvent) {
        SyncMessenger.publishNotification(WindowDraggedNotification.instance)
        super.mouseDragged(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.isMovable = true
        super.mouseUp(with: event)
    }
}
