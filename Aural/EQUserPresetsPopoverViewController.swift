/*
    View controller for the popover that lets the user save an Equalizer preset
 */
import Cocoa

class EQUserPresetsPopoverViewController: NSViewController, NSPopoverDelegate {
    
    // The actual popover that is shown
    private var popover: NSPopover!
    
    // Popover positioning parameters
    private let positioningRect = NSZeroRect
    
    @IBOutlet weak var nameField: ColoredCursorTextField!
    
    // Message that track has been removed from Favorites
    @IBOutlet weak var errorBox: NSBox!
    
    override var nibName: String? {return "EQUserPresetsPopover"}
    
    static func create() -> EQUserPresetsPopoverViewController {
        
        let controller = EQUserPresetsPopoverViewController()
        
        let popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentViewController = controller
        popover.delegate = controller
        
        controller.popover = popover
        
        return controller
    }
    
    // Shows the popover
    func show(_ relativeToView: NSView, _ preferredEdge: NSRectEdge) {
        
        if (!popover.isShown) {
            
            popover.show(relativeTo: positioningRect, of: relativeToView, preferredEdge: preferredEdge)
            nameField?.stringValue = ""
            errorBox.isHidden = true
        }
    }
    
    // Closes the popover
    func close() {
        
        if (popover.isShown) {
            popover.performClose(self)
        }
    }
    
    @IBAction func saveBtnAction(_ sender: Any) {
        
        // Validate new preset name
        if EQPresets.presetWithNameExists(nameField.stringValue) {
            
            errorBox.isHidden = false
            
        } else {
        
            _ = SyncMessenger.publishRequest(SaveEQUserPresetRequest(nameField.stringValue))
            self.close()
        }
    }
    
    @IBAction func cancelBtnAction(_ sender: Any) {
        self.close()
    }
    
    // MARK: Popover Delegate functions
    
    func popoverDidShow(_ notification: Notification) {
        WindowState.showingPopover = true
    }
    
    func popoverDidClose(_ notification: Notification) {
        WindowState.showingPopover = false
    }
}
