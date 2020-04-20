import Cocoa

class ColorSchemesWindowController: NSWindowController {
    
    // TODO: Store history of changes for each color (to allow Undo feature)
    
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    @IBOutlet weak var controlButtonColorPicker: NSColorWell!
    
    @IBOutlet weak var primaryTextColorPicker: NSColorWell!
    @IBOutlet weak var secondaryTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!
    @IBOutlet weak var sliderForegroundColorPicker: NSColorWell!
    @IBOutlet weak var sliderKnobColorPicker: NSColorWell!
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    private var wm: WindowManagerProtocol = ObjectGraph.windowManager
    
    override func windowDidLoad() {
        NSColorPanel.shared.showsAlpha = true
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        ColorScheme.systemScheme.backgroundColor = backgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeBackgroundColor, backgroundColorPicker.color))
    }
    
    @IBAction func primaryTextColorAction(_ sender: Any) {
        
        ColorScheme.systemScheme.primaryTextColor = primaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePrimaryTextColor, primaryTextColorPicker.color))
    }
    
    @IBAction func secondaryTextColorAction(_ sender: Any) {
        
        ColorScheme.systemScheme.secondaryTextColor = secondaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeSecondaryTextColor, secondaryTextColorPicker.color))
    }
    
    @IBAction func controlColorAction(_ sender: Any) {
        
        ColorScheme.systemScheme.controlButtonColor = controlButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeControlButtonColor, controlButtonColorPicker.color))
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        ColorScheme.systemScheme.playerSliderBackgroundColor = sliderBackgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderForegroundColorAction(_ sender: Any) {
        
        ColorScheme.systemScheme.playerSliderForegroundColor = sliderForegroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderForegroundColor, sliderForegroundColorPicker.color))
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        ColorScheme.systemScheme.playerSliderKnobColor = sliderKnobColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changePlayerSliderKnobColor, sliderKnobColorPicker.color))
    }
}
