import Cocoa

class GeneralColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    
    @IBOutlet weak var controlButtonColorPicker: NSColorWell!
    @IBOutlet weak var controlButtonOffStateColorPicker: NSColorWell!
    
    @IBOutlet weak var logoTextColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "GeneralColorScheme"}
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.backgroundColor = backgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeBackgroundColor, backgroundColorPicker.color))
    }
    
    @IBAction func controlButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.controlButtonColor = controlButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeControlButtonColor, controlButtonColorPicker.color))
    }
    
    @IBAction func controlButtonOffStateColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.controlButtonOffStateColor = controlButtonOffStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeControlButtonOffStateColor, controlButtonOffStateColorPicker.color))
    }
    
    @IBAction func logoTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.logoTextColor = logoTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeLogoTextColor, logoTextColorPicker.color))
    }
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
    }
}
