/*
    View controller for the popover that displays a brief information message when a track is added to or removed from the Favorites list
 */
import Cocoa

// TODO: Can this be a general info popup ? "Tracks are being added ... (progress)" ?
class FavoritesPopupViewController: NSViewController {
    
    // The actual popover that is shown
    private var popover: NSPopover?
    
    // The view relative to which the popover is shown
    private var relativeToView: NSView?
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    private let preferredEdge = NSRectEdge.maxX
    
    // The labels that display the informational messages (only one will be shown at a time)
    
    // Message that track has been added to Favorites
    @IBOutlet weak var lblAdded: NSTextField!
    
    // Message that track has been removed from Favorites
    @IBOutlet weak var lblRemoved: NSTextField!
    
    // Timer used to auto-hide the popover once it is shown
    private var viewHidingTimer: Timer?

    // Factory method to create an instance of this class
    static func create(_ relativeToView: NSView) -> FavoritesPopupViewController {
        
        let controller = FavoritesPopupViewController(nibName: "FavoritesPopup", bundle: Bundle.main)
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller!
        
        controller!.popover = popover
        controller!.relativeToView = relativeToView
        
        return controller!
    }
    
    // Shows a message that a track has been added to Favorites
    func showAddedMessage() {
        
        showAndAutoHide()
        lblAdded.isHidden = false
        lblRemoved.isHidden = true
    }
    
    // Shows a message that a track has been removed from Favorites
    func showRemovedMessage() {
        
        showAndAutoHide()
        lblAdded.isHidden = true
        lblRemoved.isHidden = false
    }
    
    // Shows the popover and initiates a timer to auto-hide the popover after a preset time interval
    private func showAndAutoHide() {
        
        show()
        
        // Invalidate previously activated timer, if there is one
        viewHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the popover
        viewHidingTimer = Timer.scheduledTimer(timeInterval: UIConstants.favoritesPopupAutoHideIntervalSeconds, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
    }
    
    // Shows the popover
    private func show() {
        
        if (!popover!.isShown) {
            popover!.show(relativeTo: positioningRect, of: relativeToView!, preferredEdge: preferredEdge)
        }
    }
    
    // Closes the popover
    func close() {
        
        if (popover!.isShown) {
            popover!.performClose(self)
        }
    }
}
