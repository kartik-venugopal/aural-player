
import Cocoa

/*
    Helper class that manages window resizing and hiding/showing collapsible views
*/
class WindowManager {
    
    private var window: NSWindow
    
    // The collapsible views that are to be hidden/shown
    private var views: [CollapsibleView]
    
    init(window: NSWindow, views: [CollapsibleView]) {
        self.window = window
        self.views = views
    }
    
    func hideView(view: CollapsibleView) {
        
        // Hide view
        view.hide()
        
        // Resize (shrink) window to cover up extra (empty) space left by the hidden view
        var wFrame = window.frame
        let oldOrigin = wFrame.origin
        
        wFrame.size = NSMakeSize(window.frame.width, window.frame.height - view.height)
        wFrame.origin = NSMakePoint(oldOrigin.x, oldOrigin.y + view.height)
        window.setFrame(wFrame, display: true, animate: true)
    }
    
    func showView(view: CollapsibleView) {
        
        // Resize (enlarge) window to make room for the view that is to be shown
        var wFrame = window.frame
        let oldOrigin = wFrame.origin
        
        wFrame.size = NSMakeSize(window.frame.width, window.frame.height + view.height)
        wFrame.origin = NSMakePoint(oldOrigin.x, oldOrigin.y - view.height)
        window.setFrame(wFrame, display: true, animate: true)
        
        // Show view
        view.show()
    }
    
    // Toggles between hidden and shown, for a particular view
    func toggleView(view: CollapsibleView) {
        
        let hidden = view.hidden
        
        if (hidden) {
            showView(view)
        } else {
            hideView(view)
        }
    }
}
