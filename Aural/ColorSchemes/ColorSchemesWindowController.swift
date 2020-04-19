import Cocoa

class ColorSchemesWindowController: NSWindowController {
    
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    @IBOutlet weak var controlButtonColorPicker: NSColorWell!
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    private var wm: WindowManagerProtocol = ObjectGraph.windowManager
    
    override func windowDidLoad() {
        NSColorPanel.shared.showsAlpha = true
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeBackgroundColor, backgroundColorPicker.color))
    }
    
    @IBAction func controlColorAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeControlButtonColor, controlButtonColorPicker.color))
    }
}
