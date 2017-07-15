/*
    Customizes the look and feel of the track info popover
    NOTE - This class is currently unused
*/

import Cocoa

class PopoverView: NSView {
    
    var backgroundView:PopoverBackgroundView?
    
    override func viewDidMoveToWindow() {
        
        super.viewDidMoveToWindow()
        
        if let frameView = self.window?.contentView?.superview {
//            if backgroundView == nil {
                backgroundView = PopoverBackgroundView(frame: frameView.bounds)
                backgroundView!.autoresizingMask = NSAutoresizingMaskOptions([.viewWidthSizable, .viewHeightSizable]);
                frameView.addSubview(backgroundView!, positioned: NSWindowOrderingMode.below, relativeTo: frameView)
//            }
        }
    }
}

class PopoverBackgroundView:NSView {
    
    override func draw(_ dirtyRect: NSRect) {
        UIConstants.colorScheme.boxColor.set()
        NSRectFill(self.bounds)
    }
}
