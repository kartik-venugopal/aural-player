import Cocoa

class EffectsColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var mainCaptionTextColorPicker: NSColorWell!
    @IBOutlet weak var functionCaptionTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!    // GRADIENT
    
    @IBOutlet weak var activeUnitStateColorPicker: NSColorWell!    // GRADIENT
    @IBOutlet weak var bypassedUnitStateColorPicker: NSColorWell!    // GRADIENT
    @IBOutlet weak var suppressedUnitStateColorPicker: NSColorWell!    // GRADIENT
    
    @IBOutlet weak var tabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonTextColorPicker: NSColorWell!
    @IBOutlet weak var selectedTabButtonColorPicker: NSColorWell!
    
    @IBOutlet weak var functionButtonColorPicker: NSColorWell!    // GRADIENT
    @IBOutlet weak var functionButtonTextColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "EffectsColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        mainCaptionTextColorPicker.color = scheme.effects.mainCaptionTextColor
        functionCaptionTextColorPicker.color = scheme.effects.functionCaptionTextColor
        
        sliderBackgroundColorPicker.color = scheme.effects.sliderBackgroundColor
        
        activeUnitStateColorPicker.color = scheme.effects.activeUnitStateColor
        bypassedUnitStateColorPicker.color = scheme.effects.bypassedUnitStateColor
        suppressedUnitStateColorPicker.color = scheme.effects.suppressedUnitStateColor
        
        tabButtonTextColorPicker.color = scheme.effects.tabButtonTextColor
        selectedTabButtonTextColorPicker.color = scheme.effects.selectedTabButtonTextColor
        selectedTabButtonColorPicker.color = scheme.effects.selectedTabButtonColor
        
        functionButtonColorPicker.color = scheme.effects.functionButtonColor
        functionButtonTextColorPicker.color = scheme.effects.functionButtonTextColor
        
        scrollToTop()
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    @IBAction func mainCaptionTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.mainCaptionTextColor = mainCaptionTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsMainCaptionTextColor, mainCaptionTextColorPicker.color))
    }
    
    @IBAction func functionCaptionTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.functionCaptionTextColor = functionCaptionTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsFunctionCaptionTextColor, functionCaptionTextColorPicker.color))
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderBackgroundColor = sliderBackgroundColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func activeUnitStateColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.activeUnitStateColor = activeUnitStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsActiveUnitStateColor, activeUnitStateColorPicker.color))
    }
    
    @IBAction func bypassedUnitStateColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.bypassedUnitStateColor = bypassedUnitStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsBypassedUnitStateColor, bypassedUnitStateColorPicker.color))
    }
    
    @IBAction func suppressedUnitStateColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.suppressedUnitStateColor = suppressedUnitStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSuppressedUnitStateColor, suppressedUnitStateColorPicker.color))
    }
    
    @IBAction func tabButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.tabButtonTextColor = tabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsTabButtonTextColor, tabButtonTextColorPicker.color))
    }
    
    @IBAction func selectedTabButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.selectedTabButtonTextColor = selectedTabButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSelectedTabButtonTextColor, selectedTabButtonTextColorPicker.color))
    }
    
    @IBAction func selectedTabButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.selectedTabButtonColor = selectedTabButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSelectedTabButtonColor, selectedTabButtonColorPicker.color))
    }
    
    @IBAction func functionButtonColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.functionButtonColor = functionButtonColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsFunctionButtonColor, functionButtonColorPicker.color))
    }
    
    @IBAction func functionButtonTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.functionButtonTextColor = functionButtonTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsFunctionButtonTextColor, functionButtonTextColorPicker.color))
    }
}
