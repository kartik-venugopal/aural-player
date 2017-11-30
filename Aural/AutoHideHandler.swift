import Cocoa

class AutoHideHandler {
    
    private var view: NSView
    private var popover: NSPopover
    
    init(_ view: NSView, _ popover: NSPopover) {
        self.view = view
        self.popover = popover
    }
    
    var within: Bool = false
    
    // Handles a single event
    func handle(_ event: NSEvent) {
        
        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)
        if (NSApp.modalWindow != nil || event.window == WindowState.playlistWindow) {
            return
        }
        
        // Delegate to an appropriate handler function based on event type
        switch event.type {
            
        case .mouseMoved:
            
            let x = event.locationInWindow.x, y = event.locationInWindow.y
            //        Swift.print("Within", x, y, within)
            
            if (x >= 0 && y >= 0 && x <= view.frame.width && y <= view.frame.height) {
                
                if !within {
                    Swift.print("Entered :)", x, y)
                    if (popover.contentSize.height < 218) {
//                        view.setFrameSize(NSMakeSize(view.width, view.height + 66))
                        popover.contentSize = NSMakeSize(view.width, popover.contentSize.height + 66)
                    }
//                    if popover.contentSize.height < 218 {
//                        
//                    }
                }
                
                within = true
            } else {
                
                if within {
                    Swift.print("Exited :)", x, y)
                    if (popover.contentSize.height == 218) {
//                        view.setFrameSize(NSMakeSize(view.width, popover.contentSize.height - 66))
                        popover.contentSize = NSMakeSize(view.width, popover.contentSize.height - 66)
                    }
                }
                
                within = false
            }
            
        default: return
            
        }
    }
}

extension NSView {
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
}
