import Cocoa

class SnappingWindow: NoTitleBarWindow {
    
    var snapped: Bool = false
    var snapLocation: NSPoint?
    
    var userMovingWindow: Bool = false

    override func mouseUp(with event: NSEvent) {
        
        // Mark Bool flag to indicate that user-initiated movement has ended
        userMovingWindow = false
        
        // Snap window to its pre-determined snap location
        if snapped {
            
            self.setFrameOrigin(snapLocation!)
            
            snapped = false
            snapLocation = nil
        }
        
        super.mouseUp(with: event)
    }
    
    // Mark Bool flag to indicate that window movement is user-initiated
    override func mouseDown(with event: NSEvent) {
        
        userMovingWindow = true
        super.mouseDown(with: event)
    }
}

class SnappingNonKeyWindow: SnappingWindow {
    
    override var canBecomeKey: Bool {return false}
}
