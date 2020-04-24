import Cocoa

class GeneralColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var appLogoColorPicker: NSColorWell!
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    
    @IBOutlet weak var viewControlButtonColorPicker: NSColorWell!
    @IBOutlet weak var functionButtonColorPicker: NSColorWell!
    @IBOutlet weak var functionButtonOffStateColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonColorPicker: NSColorWell!
    
    @IBOutlet weak var mainCaptionTextColorPicker: NSColorWell!
    @IBOutlet weak var tabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var functionButtonTextColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "GeneralColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        appLogoColorPicker.color = scheme.general.appLogoColor
        backgroundColorPicker.color = scheme.general.backgroundColor
        
        viewControlButtonColorPicker.color = scheme.general.viewControlButtonColor
        functionButtonColorPicker.color = scheme.general.functionButtonColor
        functionButtonOffStateColorPicker.color = scheme.general.functionButtonOffStateColor
        selectedTabButtonColorPicker.color = scheme.general.selectedTabButtonColor
        
        mainCaptionTextColorPicker.color = scheme.general.mainCaptionTextColor
        tabButtonTextColorPicker.color = scheme.general.tabButtonTextColor
        selectedTabButtonTextColorPicker.color = scheme.general.selectedTabButtonTextColor
        functionButtonTextColorPicker.color = scheme.general.functionButtonTextColor
    }
    
    @IBAction func appLogoColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.appLogoColor = appLogoColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeAppLogoColor, appLogoColorPicker.color))
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.backgroundColor = backgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeBackgroundColor, backgroundColorPicker.color))
    }
    
    @IBAction func viewControlButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.viewControlButtonColor = viewControlButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeViewControlButtonColor, viewControlButtonColorPicker.color))
    }
    
    @IBAction func functionButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.functionButtonColor = functionButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeFunctionButtonColor, functionButtonColorPicker.color))
    }
    
    @IBAction func functionButtonOffStateColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.functionButtonOffStateColor = functionButtonOffStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeFunctionButtonOffStateColor, functionButtonOffStateColorPicker.color))
    }
    
    @IBAction func selectedTabButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.selectedTabButtonColor = selectedTabButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeSelectedTabButtonColor, selectedTabButtonColorPicker.color))
    }
    
    @IBAction func mainCaptionTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.mainCaptionTextColor = mainCaptionTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeMainCaptionTextColor, mainCaptionTextColorPicker.color))
    }
    
    @IBAction func tabButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.tabButtonTextColor = tabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeTabButtonTextColor, tabButtonTextColorPicker.color))
    }
    
    @IBAction func selectedTabButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.selectedTabButtonTextColor = selectedTabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeSelectedTabButtonTextColor, selectedTabButtonTextColorPicker.color))
    }
    
    @IBAction func functionButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.functionButtonTextColor = functionButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeFunctionButtonTextColor, functionButtonTextColorPicker.color))
    }
}
