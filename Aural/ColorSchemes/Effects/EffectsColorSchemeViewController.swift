import Cocoa

class EffectsColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    @IBOutlet weak var functionCaptionTextColorPicker: NSColorWell!
    @IBOutlet weak var functionValueTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!
    @IBOutlet weak var btnSliderBackgroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientBrighten: NSButton!
    @IBOutlet weak var sliderBackgroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderBackgroundGradientAmount: NSTextField!
    
    @IBOutlet weak var btnSliderForegroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientBrighten: NSButton!
    @IBOutlet weak var sliderForegroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderForegroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderKnobColorPicker: NSColorWell!
    @IBOutlet weak var btnSliderKnobColorSameAsForeground: NSButton!
    
    @IBOutlet weak var sliderTickColorPicker: NSColorWell!
    
    @IBOutlet weak var activeUnitStateColorPicker: NSColorWell!
    @IBOutlet weak var bypassedUnitStateColorPicker: NSColorWell!
    @IBOutlet weak var suppressedUnitStateColorPicker: NSColorWell!
    
    override var nibName: NSNib.Name? {return "EffectsColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    func resetFields(_ scheme: ColorScheme) {
        
        functionCaptionTextColorPicker.color = scheme.effects.functionCaptionTextColor
        functionValueTextColorPicker.color = scheme.effects.functionValueTextColor
        
        sliderBackgroundColorPicker.color = scheme.effects.sliderBackgroundColor
        btnSliderBackgroundGradientEnabled.onIf(scheme.effects.sliderBackgroundGradientType != .none)
        
        btnSliderBackgroundGradientDarken.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        btnSliderBackgroundGradientDarken.onIf(scheme.effects.sliderBackgroundGradientType != .brighten)
        
        btnSliderBackgroundGradientBrighten.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        btnSliderBackgroundGradientBrighten.onIf(scheme.effects.sliderBackgroundGradientType == .brighten)
        
        sliderBackgroundGradientAmountStepper.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        sliderBackgroundGradientAmountStepper.integerValue = ColorSchemes.systemScheme.effects.sliderBackgroundGradientAmount
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        btnSliderForegroundGradientEnabled.onIf(scheme.effects.sliderForegroundGradientType != .none)
        
        btnSliderForegroundGradientDarken.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientDarken.onIf(scheme.effects.sliderForegroundGradientType != .brighten)
        
        btnSliderForegroundGradientBrighten.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientBrighten.onIf(scheme.effects.sliderForegroundGradientType == .brighten)
        
        sliderForegroundGradientAmountStepper.enableIf(btnSliderForegroundGradientEnabled.isOn)
        sliderForegroundGradientAmountStepper.integerValue = ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderKnobColorPicker.color = scheme.effects.sliderKnobColor
        btnSliderKnobColorSameAsForeground.onIf(scheme.effects.sliderKnobColorSameAsForeground)
        
        sliderTickColorPicker.color = scheme.effects.sliderTickColor
        
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
    
    @IBAction func enableSliderForegroundGradientAction(_ sender: Any) {
        
        if btnSliderForegroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.effects.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.effects.sliderForegroundGradientType = .none
        }
        
        [btnSliderForegroundGradientDarken, btnSliderForegroundGradientBrighten, sliderForegroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderForegroundGradientEnabled.isOn)})
        
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientAmountAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount = sliderForegroundGradientAmountStepper.integerValue
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderForegroundChanged()
    }
    
    private func sliderForegroundChanged() {

        // TODO - This is a hack. The message will result in a redraw regardless of whether the foreground/background has changed. Should consolidate the 2 event types into a single one - changeEffectsSliderColor
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func enableSliderBackgroundGradientAction(_ sender: Any) {
        
        if btnSliderBackgroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.effects.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.effects.sliderBackgroundGradientType = .none
        }
        
        [btnSliderBackgroundGradientDarken, btnSliderBackgroundGradientBrighten, sliderBackgroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderBackgroundGradientEnabled.isOn)})
        
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientAmountAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderBackgroundGradientAmount = sliderBackgroundGradientAmountStepper.integerValue
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderBackgroundChanged()
    }
    
    private func sliderBackgroundChanged() {
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderKnobColor = sliderKnobColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderKnobColorSameAsForegroundAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderKnobColorSameAsForeground = btnSliderKnobColorSameAsForeground.isOn
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderTickColorAction(_ sender: Any) {
        
        ColorSchemes.systemScheme.effects.sliderTickColor = sliderTickColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(.changeEffectsSliderBackgroundColor, sliderTickColorPicker.color))
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
