import Cocoa

class FXWindow: NSWindow {
    
    var snapped: Bool = false
    var snapLocation: NSPoint?

    override func mouseUp(with event: NSEvent) {
        
        if snapped {
            
            self.setFrameOrigin(snapLocation!)
            
            snapped = false
            snapLocation = nil
        }
        
        super.mouseUp(with: event)
    }
}
