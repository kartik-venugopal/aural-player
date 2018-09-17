import Cocoa

/*
    A "smart" button that determines and sets its own tool tip dynamically based on logic (closure) that can be set externally. Useful when tool tips need to change based on app state, e.g. to display the previous/next track name in a tool tip for the previous/next track control buttons.
 */
class TrackPeekingButton: NSButton {
    
    // This function will be invoked, on the fly (when the user hovers over the button), to determine the button's tool tip
    var toolTipFunction: (() -> String)?
    
    override func awakeFromNib() {
        
        // Create a tracking area that covers the bounds of the button. It should respond whenever the mouse enters or e
        let trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingAreaOptions.activeAlways,  NSTrackingAreaOptions.mouseEnteredAndExited], owner: self, userInfo: nil)
        
        // Add the new tracking area to the button
        addTrackingArea(trackingArea)
    }
    
    // Whenever the user hovers over the button, determine the updated tool tip by invoking the closure
    override func mouseEntered(with event: NSEvent) {
        self.toolTip = toolTipFunction?() ?? nil
    }
}
