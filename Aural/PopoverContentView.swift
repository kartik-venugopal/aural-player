/*
    Custom view for popovers. This is needed in order to set its background color.
 */

import Cocoa

class PopoverContentView: NSView {
    
    private var backgroundView: PopoverBackgroundView?
    
    override func viewDidMoveToWindow() {
        
        super.viewDidMoveToWindow()
        
        if let frameView = self.window?.contentView?.superview {
            
            if backgroundView == nil {
                
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView!.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewHeightSizable]);
                frameView.addSubview(backgroundView!, positioned: NSWindowOrderingMode.below, relativeTo: frameView)
            }
        }
    }
}

class PopoverBackgroundView: NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        Colors.popoverBackgroundColor.setFill()
        NSRectFill(self.bounds)
    }
}
