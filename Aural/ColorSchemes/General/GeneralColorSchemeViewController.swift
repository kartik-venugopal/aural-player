import Cocoa

class GeneralColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var appLogoColorPicker: NSColorWell!
    @IBOutlet weak var backgroundColorPicker: NSColorWell!
    
    @IBOutlet weak var viewControlButtonColorPicker: NSColorWell!
    @IBOutlet weak var functionButtonColorPicker: NSColorWell!
    @IBOutlet weak var textButtonMenuColorPicker: NSColorWell!
    @IBOutlet weak var toggleButtonOffStateColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonColorPicker: NSColorWell!
    
    @IBOutlet weak var mainCaptionTextColorPicker: NSColorWell!
    @IBOutlet weak var tabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var buttonMenuTextColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "GeneralColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        appLogoColorPicker.color = scheme.general.appLogoColor
        backgroundColorPicker.color = scheme.general.backgroundColor
        
        viewControlButtonColorPicker.color = scheme.general.viewControlButtonColor
        functionButtonColorPicker.color = scheme.general.functionButtonColor
        textButtonMenuColorPicker.color = scheme.general.textButtonMenuColor
        toggleButtonOffStateColorPicker.color = scheme.general.toggleButtonOffStateColor
        selectedTabButtonColorPicker.color = scheme.general.selectedTabButtonColor
        
        mainCaptionTextColorPicker.color = scheme.general.mainCaptionTextColor
        tabButtonTextColorPicker.color = scheme.general.tabButtonTextColor
        selectedTabButtonTextColorPicker.color = scheme.general.selectedTabButtonTextColor
        buttonMenuTextColorPicker.color = scheme.general.buttonMenuTextColor
        
        scrollToTop()
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    @IBAction func appLogoColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.appLogoColor = appLogoColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeAppLogoColor, appLogoColorPicker.color))
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.backgroundColor = backgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeBackgroundColor, backgroundColorPicker.color))
    }
    
    @IBAction func viewControlButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.viewControlButtonColor = viewControlButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeViewControlButtonColor, viewControlButtonColorPicker.color))
    }
    
    @IBAction func functionButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.functionButtonColor = functionButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeFunctionButtonColor, functionButtonColorPicker.color))
    }
    
    @IBAction func textButtonMenuColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.textButtonMenuColor = textButtonMenuColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeTextButtonMenuColor, textButtonMenuColorPicker.color))
    }
    
    @IBAction func toggleButtonOffStateColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.toggleButtonOffStateColor = toggleButtonOffStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeToggleButtonOffStateColor, toggleButtonOffStateColorPicker.color))
    }
    
    @IBAction func selectedTabButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.selectedTabButtonColor = selectedTabButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeSelectedTabButtonColor, selectedTabButtonColorPicker.color))
    }
    
    @IBAction func mainCaptionTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.mainCaptionTextColor = mainCaptionTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeMainCaptionTextColor, mainCaptionTextColorPicker.color))
    }
    
    @IBAction func tabButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.tabButtonTextColor = tabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeTabButtonTextColor, tabButtonTextColorPicker.color))
    }
    
    @IBAction func selectedTabButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.selectedTabButtonTextColor = selectedTabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeSelectedTabButtonTextColor, selectedTabButtonTextColorPicker.color))
    }
    
    @IBAction func buttonMenuTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.general.buttonMenuTextColor = buttonMenuTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeButtonMenuTextColor, buttonMenuTextColorPicker.color))
    }
}
