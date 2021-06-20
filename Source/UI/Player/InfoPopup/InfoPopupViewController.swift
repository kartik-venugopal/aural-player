/*
    View controller for the popover that displays a brief information message when a track is added to or removed from the Favorites list
 */
import Cocoa

class InfoPopupViewController: NSViewController, InfoPopupProtocol, Destroyable {
    
    static let favoritesPopupAutoHideIntervalSeconds: TimeInterval = 1.5
    
    private static var _instance: InfoPopupViewController?
    static var instance: InfoPopupViewController {
        
        if _instance == nil {
            _instance = create()
        }
        
        return _instance!
    }
    
    private static func create() -> InfoPopupViewController {
        
        let controller = InfoPopupViewController()
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        
        controller.popover = popover
        
        return controller
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    func destroy() {
        
        close()
        
        popover.contentViewController = nil
        self.popover = nil
    }
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    // The label that displays informational messages
    @IBOutlet weak var lblInfo: NSTextField!
    
    // Timer used to auto-hide the popover once it is shown
    private var viewHidingTimer: Timer?
    
    override var nibName: String? {"InfoPopup"}
    
    // Shows a message that a track has been added to Favorites
    func showMessage(_ message: String, _ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        lblInfo?.hide()
        setTextAndResize(message)
        
        showAndAutoHide(relativeToView, preferredEdge)
        
        setTextAndResize(message)
        lblInfo?.show()
    }
    
    private func setTextAndResize(_ message: String) {
        
        if let label = lblInfo, label.stringValue != message {
            
            label.stringValue = message
            
            // TODO
            
//            let msg: NSString = message as NSString
//            let stringSize: CGSize = msg.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): label.font as AnyObject]))
//            let lblWidth = label.frame.width
//            let textWidth = min(stringSize.width, lblWidth) + 20
//
//            label.setFrameSize(NSMakeSize(textWidth, label.frame.height))
//
//            var wFrame = self.view.window!.frame
//            wFrame.size = NSMakeSize(textWidth, self.view.frame.height)
//            self.view.window?.setFrame(wFrame, display: true)
        }
    }
    
    // Shows the popover and initiates a timer to auto-hide the popover after a preset time interval
    private func showAndAutoHide(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        show(relativeToView, preferredEdge)
        
        // Invalidate previously activated timer, if there is one
        viewHidingTimer?.invalidate()
        
        // Activate a new timer task to auto-hide the popover
        viewHidingTimer = Timer.scheduledTimer(timeInterval: Self.favoritesPopupAutoHideIntervalSeconds, target: self, selector: #selector(self.close), userInfo: nil, repeats: false)
    }
    
    // Shows the popover
    private func show(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if !popover.isShown {
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
        }
    }
    
    // Closes the popover
    @objc func close() {
        
        if popover.isShown {
            popover.performClose(self)
        }
    }
}
