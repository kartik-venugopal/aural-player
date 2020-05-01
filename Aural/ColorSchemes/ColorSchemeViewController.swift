import Cocoa

/*
    Base class for all subviews that alter the color scheme. Contains common logic (undo/redo, copy/paste, etc).
 */
class ColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var colorPickerContextMenu: NSMenu!
    
    var controlsMap: [Int: NSControl] = [:]
    var actionsMap: [Int: ColorChangeAction] = [:]
    var history: ColorSchemeHistory!
    
    var activeColorPicker: NSColorWell?
    var clipboardColor: NSColor?
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        for aView in containerView.subviews {
            
            if let control = aView as? NSControl,
                control is NSColorWell || control is NSButton || control is NSStepper {
                
                controlsMap[control.tag] = control
                
                if let acp = control as? AuralColorPicker {
                    
                    acp.menu = colorPickerContextMenu
                    acp.contextMenuInvokedHandler = {(picker: NSColorWell) -> Void in self.activeColorPicker = picker}
                }
            }
        }
    }
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory) {
        
        self.history = history
        
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
    
}
