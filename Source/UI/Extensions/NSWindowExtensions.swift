import Cocoa

extension NSWindow {
    
    var origin: NSPoint {
        return self.frame.origin
    }
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    // X co-ordinate of location
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    // Y co-ordinate of location
    var y: CGFloat {
        return self.frame.origin.y
    }
    
    var maxX: CGFloat {
        return self.frame.maxX
    }
    
    var maxY: CGFloat {
        return self.frame.maxY
    }
    
    func resizeTo(newWidth: CGFloat, newHeight: CGFloat) {
        
        var newFrame = self.frame
        newFrame.size = NSSize(width: newWidth, height: newHeight)
        setFrame(newFrame, display: true)
    }
    
    func show() {
        setIsVisible(true)
    }
    
    func hide() {
        setIsVisible(false)
    }
}
