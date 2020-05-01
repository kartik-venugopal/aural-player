import Cocoa

/*
 Base class for all subviews that alter the color scheme. Contains common logic (undo/redo, copy/paste, etc).
 */
class ColorSchemeViewController: NSViewController, NSMenuDelegate, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var colorPickerContextMenu: NSMenu!
    @IBOutlet weak var pasteColorMenuItem: NSMenuItem!
    
    var controlsMap: [Int: NSControl] = [:]
    var actionsMap: [Int: ColorChangeAction] = [:]
    
    var history: ColorSchemeHistory!
    var clipboard: ColorClipboard!
    
    var activeColorPicker: AuralColorPicker?
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        for aView in containerView.subviews {
            
            if let control = aView as? NSControl,
                control is AuralColorPicker || control is NSButton || control is NSStepper {
                
                controlsMap[control.tag] = control
                
                if let colorPicker = control as? AuralColorPicker {
                    
                    colorPicker.menu = colorPickerContextMenu
                    colorPicker.menuInvocationCallback = {(picker: AuralColorPicker) -> Void in self.activeColorPicker = picker}
                }
            }
        }
    }
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!) {
        
        self.history = history
        self.clipboard = clipboard
        
        // If the window is already visible, no need to scroll. Only scroll to top when the window is first opened.
        if !(self.view.window?.isVisible ?? false) {
            scrollToTop()
        }
    }
    
    func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    func undoChange(_ lastChange: ColorSchemeChange) -> Bool {
        
        if let undoAction = actionsMap[lastChange.tag] {
            
            if let colPicker = controlsMap[lastChange.tag] as? NSColorWell, let undoColor = lastChange.undoValue as? NSColor {
                
                colPicker.color = undoColor
                
            } else if let btnToggle = controlsMap[lastChange.tag] as? NSButton, let boolVal = lastChange.undoValue as? Bool {
                
                btnToggle.onIf(boolVal)
                
            } else if let stepper = controlsMap[lastChange.tag] as? NSStepper, let intVal = lastChange.undoValue as? Int {
                
                stepper.integerValue = intVal
            }
            
            undoAction()
            return true
        }
        
        return false
    }
    
    func redoChange(_ lastChange: ColorSchemeChange) -> Bool {
        
        if let redoAction = actionsMap[lastChange.tag] {
            
            if let colPicker = controlsMap[lastChange.tag] as? NSColorWell, let redoColor = lastChange.redoValue as? NSColor {
                
                colPicker.color = redoColor
                
            } else if let btnToggle = controlsMap[lastChange.tag] as? NSButton, let boolVal = lastChange.redoValue as? Bool {
                
                btnToggle.onIf(boolVal)
                
            } else if let stepper = controlsMap[lastChange.tag] as? NSStepper, let intVal = lastChange.redoValue as? Int {
                
                stepper.integerValue = intVal
            }
            
            redoAction()
            return true
        }
        
        return false
    }
    
    @IBAction func copyColorAction(_ sender: Any) {
        
        if let picker = activeColorPicker {
            
            picker.copyToClipboard(clipboard)
            activeColorPicker = nil
            
            if let clipboardColor = clipboard.color {
                print("\nCopied color:", clipboardColor.toString())
            }
        }
    }
    
    @IBAction func pasteColorAction(_ sender: Any) {
        
        if let picker = activeColorPicker, let clipboardColor = clipboard.color {
            
            print("\nPasted color:", clipboardColor.toString())
            
            // Picker's current value is the undo value, clipboard color is the redo value.
            history.noteChange(picker.tag, picker.color, clipboardColor, .changeColor)
            
            // Paste into the picker
            picker.pasteFromClipboard(clipboard)
            
            // Perform the appropriate update notification
            if let notifyAction = actionsMap[picker.tag] {
                notifyAction()
            }
            
            activeColorPicker = nil
        }
    }
    
    // MARK - MenuDelegate functions
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        pasteColorMenuItem.enableIf(self.clipboard.hasColor)
    }
}
