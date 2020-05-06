import Cocoa

/*
    A special view that is able to track when the mouse cursor enters and/or exits the view.
    This is useful for views that need to auto-hide certain subviews in response to mouse movements.
 */
class MouseTrackingView: NSView {
    
    // Flag that indicates whether or not this view is currently tracking mouse movements.
    private var isTracking: Bool = false
    
    // Signals the view to start tracking mouse movements.
    func startTracking() {
        
        stopTracking()
        
        isTracking = true
        self.updateTrackingAreas()
    }
    
    // Signals the view to stop tracking mouse movements.
    func stopTracking() {
        
        isTracking = false
        self.removeAllTrackingAreas()
    }
 
    override func updateTrackingAreas() {
        
        if isTracking && self.trackingAreas.isEmpty {
        
            // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
            addTrackingArea(NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.mouseEnteredAndExited], owner: self, userInfo: nil))
            
            super.updateTrackingAreas()
        }
    }
    
//    override func mouseEntered(with event: NSEvent) {
//        
//        // Let observers know that the mouse has entered this view.
//        SyncMessenger.publishNotification(MouseTrackingNotification.mouseEntered)
//    }
//    
//    override func mouseExited(with event: NSEvent) {
//        
//        // Let observers know that the mouse has exited this view.
//        SyncMessenger.publishNotification(MouseTrackingNotification.mouseExited)
//    }
}
