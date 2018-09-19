import Cocoa

class MouseTrackingView: NSView {
    
    private var trackingArea: NSTrackingArea?
    
    override func awakeFromNib() {
        updateTrackingAreas()
    }
 
    override func updateTrackingAreas() {
        
        if let area = self.trackingArea {
            self.removeTrackingArea(area)
        }
        
        // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
        self.trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingAreaOptions.activeAlways,  NSTrackingAreaOptions.mouseEnteredAndExited], owner: self, userInfo: nil)
        
        // Add the new tracking area to the view
        addTrackingArea(self.trackingArea!)
        
        super.updateTrackingAreas()
    }
    
    // Whenever the user hovers over the button, determine the updated tool tip by invoking the closure
    override func mouseEntered(with event: NSEvent) {
        SyncMessenger.publishNotification(BarModeWindowMouseNotification.mouseEntered)
    }
    
    override func mouseExited(with event: NSEvent) {
        
        // TODO: There seems to be a bug/issue with false exit events triggered by hovering over player controls. So, this redundant validation is necessary to validate the X position.
        
        let loc = event.locationInWindow
        
        let xExit = loc.x < self.bounds.minX || loc.x > self.bounds.maxX
        let yExit = loc.y < self.bounds.minY || loc.y > self.bounds.maxY
        
        if (xExit || yExit) {
            SyncMessenger.publishNotification(BarModeWindowMouseNotification.mouseExited)
        }
    }
}
