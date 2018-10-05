/*
    View controller for the popover that displays a brief information message when a track is added to or removed from the Favorites list
 */
import Cocoa

// TODO: Can this be a general info popup ? "Tracks are being added ... (progress)" ?
class FavoritesPopupViewController: NSViewController, FavoritesPopupProtocol {
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    // The labels that display the informational messages (only one will be shown at a time)
    
    // Message that track has been added to Favorites
    @IBOutlet weak var lblAdded: NSTextField!
    
    // Message that track has been removed from Favorites
    @IBOutlet weak var lblRemoved: NSTextField!
    
    // Timer used to auto-hide the popover once it is shown
    private var viewHidingTimer: Timer?
    
    override var nibName: String? {return "FavoritesPopup"}
    
    static func create() -> FavoritesPopupViewController {
        
        let controller = FavoritesPopupViewController()
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        
        return controller
    }
    
    // Shows a message that a track has been added to Favorites
    func showAddedMessage(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        showAndAutoHide(relativeToView, preferredEdge)
        lblAdded.isHidden = false
        lblRemoved.isHidden = true
    }
    
    // Shows a message that a track has been removed from Favorites
    func showRemovedMessage(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        showAndAutoHide(relativeToView, preferredEdge)
        lblAdded.isHidden = true
        lblRemoved.isHidden = false
    }
    
    // Shows the popover and initiates a timer to auto-hide the popover after a preset time interval
    private func showAndAutoHide(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        show(relativeToView, preferredEdge)
        
        // Invalidate previously activated timer, if there is one
        viewHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the popover
        viewHidingTimer = Timer.scheduledTimer(timeInterval: UIConstants.favoritesPopupAutoHideIntervalSeconds, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
    }
    
    // Shows the popover
    private func show(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if (!popover.isShown) {
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
        }
    }
    
    // Closes the popover
    @objc func close() {
        
        if (popover.isShown) {
            popover.performClose(self)
        }
    }
}
