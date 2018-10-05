import Cocoa

/*
    Utility to show and automatically hide a view after a brief interval (ex - feedback labels)
 */
class AutoHidingView: NSObject {
    
    // The view that is to be shown and auto-hidden
    let view: NSView
    
    // The time interval, specified in seconds, after which the view will be hidden, after it is shown
    let autoHideInterval: TimeInterval
    
    // Timer used to time the auto-hide operation
    private var viewHidingTimer: Timer?
    
    init(_ view: NSView, _ autoHideInterval: TimeInterval) {
        self.view = view
        self.autoHideInterval = autoHideInterval
    }
 
    // Show the view. If the view is already shown, the auto-hide time interval will be reset, invalidating the previous one.
    func showView() {
        
        view.isHidden = false
        
        // Invalidate previously activated timer
        viewHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the view
        viewHidingTimer = Timer.scheduledTimer(timeInterval: autoHideInterval, target: self, selector: #selector(self.hideView), userInfo: nil, repeats: false)
    }
    
    // Hide the view
    @objc func hideView() {
        view.isHidden = true
    }
}

class AutoHidingMenu: NSObject {
    
    // The view that is to be shown and auto-hidden
    let menu: NSMenu
    let menuItem: NSMenuItem
    let relativeToView: NSView
    let point: NSPoint
    
    // The time interval, specified in seconds, after which the view will be hidden, after it is shown
    let autoHideInterval: TimeInterval
    
    // Timer used to time the auto-hide operation
    private var viewHidingTimer: Timer?
    
    init(_ menu: NSMenu, _ menuItem: NSMenuItem, _ relativeToView: NSView, _ point: NSPoint, _ autoHideInterval: TimeInterval) {
        
        self.menu = menu
        self.menuItem = menuItem
        self.relativeToView = relativeToView
        self.point = point
        self.autoHideInterval = autoHideInterval
    }
    
    // Show the view. If the view is already shown, the auto-hide time interval will be reset, invalidating the previous one.
    func showMenu() {
        print("\nShowing menu")
        
        
        
        // Invalidate previously activated timer
        viewHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the view
        viewHidingTimer = Timer.scheduledTimer(timeInterval: autoHideInterval, target: self, selector: #selector(self.hideMenu), userInfo: nil, repeats: false)
        
        DispatchQueue.main.async {
            self.menu.popUp(positioning: self.menuItem, at: self.point, in: self.relativeToView)
        }
    }
    
    // Hide the view
    @objc func hideMenu() {
        print("\nHiding menu")
        menu.cancelTracking()
    }
}
