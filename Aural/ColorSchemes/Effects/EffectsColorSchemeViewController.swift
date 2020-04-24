import Cocoa

class EffectsColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var functionCaptionTextColorPicker: NSColorWell!
    @IBOutlet weak var functionValueTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!    // GRADIENT
    
    @IBOutlet weak var activeUnitStateColorPicker: NSColorWell!    // GRADIENT
    @IBOutlet weak var bypassedUnitStateColorPicker: NSColorWell!    // GRADIENT
    @IBOutlet weak var suppressedUnitStateColorPicker: NSColorWell!    // GRADIENT
    
    override var nibName: NSNib.Name? {return "EffectsColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        functionCaptionTextColorPicker.color = scheme.effects.functionCaptionTextColor
        functionValueTextColorPicker.color = scheme.effects.functionValueTextColor
        
        sliderBackgroundColorPicker.color = scheme.effects.sliderBackgroundColor
        
        activeUnitStateColorPicker.color = scheme.effects.activeUnitStateColor
        bypassedUnitStateColorPicker.color = scheme.effects.bypassedUnitStateColor
        suppressedUnitStateColorPicker.color = scheme.effects.suppressedUnitStateColor
        
        scrollToTop()
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    @IBAction func functionCaptionTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.functionCaptionTextColor = functionCaptionTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsFunctionCaptionTextColor, functionCaptionTextColorPicker.color))
    }
    
    @IBAction func functionValueTextColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.functionValueTextColor = functionValueTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsFunctionValueTextColor, functionValueTextColorPicker.color))
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
    
}
