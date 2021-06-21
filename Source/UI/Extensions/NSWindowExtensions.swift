import Cocoa

extension NSWindow {
    
    var origin: NSPoint {frame.origin}
    
    var width: CGFloat {frame.width}
    
    var height: CGFloat {frame.height}
    
    var size: NSSize {frame.size}
    
    func resize(_ newWidth: CGFloat, _ newHeight: CGFloat) {
        
        var newFrame = self.frame
        newFrame.size = NSSize(width: newWidth, height: newHeight)
        setFrame(newFrame, display: true)
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
    
    func show() {
        setIsVisible(true)
    }
    
    func hide() {
        setIsVisible(false)
    }
    
    func showCentered(relativeTo parent: NSWindow) {
        
        let posX = parent.x + ((parent.width - width) / 2)
        let posY = parent.y + ((parent.height - height) / 2)
        
        setFrameOrigin(NSPoint(x: posX, y: posY))
        setIsVisible(true)
    }
    
    // Centers this window with respect to the screen and shows it.
    func showCenteredOnScreen() {
        
//        let xPadding = (screen.width - dialog.width) / 2
//        let yPadding = (screen.height - dialog.height) / 2
//
//        setFrameOrigin(NSPoint(x: xPadding, y: yPadding))
        
        center()
        setIsVisible(true)
        makeKeyAndOrderFront(self)
    }
}

extension NSWindowController {
    
    var theWindow: NSWindow {self.window!}
}
