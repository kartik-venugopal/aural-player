/*
 View controller for the "Track Info" popover
 */
import Cocoa

class FavoritesPopupViewController: NSViewController {
    
    // The actual popover that is shown
    private var popover: NSPopover?
    
    // The view relative to which the popover is shown
    private var relativeToView: NSView?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    private let preferredEdge = NSRectEdge.maxX
    
    @IBOutlet weak var lblAdded: NSTextField!
    @IBOutlet weak var lblRemoved: NSTextField!
    
    private var viewHidingTimer: Timer?

    // Factory method to create an instance of this class, exposed as an instance of PopoverViewDelegate
    static func create(_ relativeToView: NSView) -> FavoritesPopupViewController {
        
        let controller = FavoritesPopupViewController(nibName: "FavoritesPopup", bundle: Bundle.main)
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller!
        
        controller!.popover = popover
        controller!.relativeToView = relativeToView
        
        return controller!
    }
    
    func showAddedMessage() {
        
        showAndAutoHide()
        lblAdded.isHidden = false
        lblRemoved.isHidden = true
    }
    
    func showRemovedMessage() {
        
        showAndAutoHide()
        lblAdded.isHidden = true
        lblRemoved.isHidden = false
    }
    
    private func showAndAutoHide() {
        
        show()
        
        // Invalidate previously activated timer
        viewHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the label
        viewHidingTimer = Timer.scheduledTimer(timeInterval: UIConstants.favoritesPopupAutoHideIntervalSeconds, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
    }
    
    private func show() {
        
        if (!popover!.isShown) {
            popover!.show(relativeTo: positioningRect, of: relativeToView!, preferredEdge: preferredEdge)
        }
    }
    
    func close() {
        
        if (popover!.isShown) {
            popover!.performClose(self)
        }
    }
}
