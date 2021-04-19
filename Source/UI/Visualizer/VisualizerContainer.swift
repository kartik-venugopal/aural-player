import Cocoa

class VisualizerContainer: NSBox {
    
    override func viewDidEndLiveResize() {
        
        super.viewDidEndLiveResize()
        
        self.removeAllTrackingAreas()
        self.updateTrackingAreas()

        Messenger.publish(.visualizer_hideOptions)
    }
    
    // Signals the view to start tracking mouse movements.
    func startTracking() {
        
        self.removeAllTrackingAreas()
        self.updateTrackingAreas()
    }
    
    // Signals the view to stop tracking mouse movements.
    func stopTracking() {
        self.removeAllTrackingAreas()
    }
    
    override func updateTrackingAreas() {
        
        // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
        addTrackingArea(NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.mouseEnteredAndExited], owner: self, userInfo: nil))
        
        super.updateTrackingAreas()
    }
    
    override func mouseEntered(with event: NSEvent) {
        Messenger.publish(.visualizer_showOptions)
    }
    
    override func mouseExited(with event: NSEvent) {
        Messenger.publish(.visualizer_hideOptions)
    }
}
