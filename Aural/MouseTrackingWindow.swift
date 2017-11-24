import Cocoa

class MouseTrackingWindow: NSWindow {
    var within: Bool = false
    
    override func awakeFromNib() {
        self.acceptsMouseMovedEvents = true
    }
    
//    override func mouseEntered(with event: NSEvent) {
//        Swift.print("Enter ! W")
//    }
//    
//    override func mouseExited(with event: NSEvent) {
//        Swift.print("Exit ! W")
//    }
    
    override func mouseMoved(with event: NSEvent) {
        
        let x = event.locationInWindow.x, y = event.locationInWindow.y
//        Swift.print("Within", x, y, within)
        
        if (x >= 0 && y >= 0 && x <= self.width && y <= self.height) {
            
            if !within {
                Swift.print("Entered :)", x, y)
            }
            
            within = true
        } else {
            
            if within {
                Swift.print("Exited :)", x, y)
            }
            
            within = false
        }
    }
}
