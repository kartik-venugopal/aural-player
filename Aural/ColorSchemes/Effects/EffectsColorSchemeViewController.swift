import Cocoa

class EffectsColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var containerView: NSView!
    
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
    
    private var controlsMap: [Int: NSControl] = [:]
    private var actionsMap: [Int: ColorChangeAction] = [:]
    private var history: ColorSchemeHistory!
    
    override var nibName: NSNib.Name? {return "EffectsColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        for aView in containerView.subviews {
            
            if let control = aView as? NSControl,
                control is NSColorWell || control is NSButton || control is NSStepper {
                
                controlsMap[control.tag] = control
                print("Effects CS, mapped:", control.tag, control.className)
            }
        }
        
        actionsMap[functionCaptionTextColorPicker.tag] = self.changeFunctionCaptionTextColor
        actionsMap[functionValueTextColorPicker.tag] = self.changeFunctionValueTextColor
        
        actionsMap[sliderBackgroundColorPicker.tag] = self.changeSliderBackgroundColor
        actionsMap[btnSliderBackgroundGradientEnabled.tag] = self.enableSliderBackgroundGradient
        actionsMap[btnSliderBackgroundGradientDarken.tag] = self.brightenOrDarkenSliderBackgroundGradient
        actionsMap[sliderBackgroundGradientAmountStepper.tag] = self.changeSliderBackgroundGradientAmount
        
        actionsMap[btnSliderForegroundGradientEnabled.tag] = self.enableSliderForegroundGradient
        actionsMap[btnSliderForegroundGradientDarken.tag] = self.brightenOrDarkenSliderForegroundGradient
        actionsMap[sliderForegroundGradientAmountStepper.tag] = self.changeSliderForegroundGradientAmount
        
        actionsMap[sliderKnobColorPicker.tag] = self.changeSliderKnobColor
        actionsMap[btnSliderKnobColorSameAsForeground.tag] = self.toggleKnobColorSameAsForeground
        
        actionsMap[activeUnitStateColorPicker.tag] = self.changeActiveUnitStateColor
        actionsMap[bypassedUnitStateColorPicker.tag] = self.changeBypassedUnitStateColor
        actionsMap[suppressedUnitStateColorPicker.tag] = self.changeSuppressedUnitStateColor
    }
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory) {
        
        functionCaptionTextColorPicker.color = scheme.effects.functionCaptionTextColor
        functionValueTextColorPicker.color = scheme.effects.functionValueTextColor
        
        sliderBackgroundColorPicker.color = scheme.effects.sliderBackgroundColor
        btnSliderBackgroundGradientEnabled.onIf(scheme.effects.sliderBackgroundGradientType != .none)
        
        btnSliderBackgroundGradientDarken.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        btnSliderBackgroundGradientDarken.onIf(scheme.effects.sliderBackgroundGradientType != .brighten)
        
        btnSliderBackgroundGradientBrighten.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        btnSliderBackgroundGradientBrighten.onIf(scheme.effects.sliderBackgroundGradientType == .brighten)
        
        sliderBackgroundGradientAmountStepper.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        sliderBackgroundGradientAmountStepper.integerValue = scheme.effects.sliderBackgroundGradientAmount
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        btnSliderForegroundGradientEnabled.onIf(scheme.effects.sliderForegroundGradientType != .none)
        
        btnSliderForegroundGradientDarken.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientDarken.onIf(scheme.effects.sliderForegroundGradientType != .brighten)
        
        btnSliderForegroundGradientBrighten.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientBrighten.onIf(scheme.effects.sliderForegroundGradientType == .brighten)
        
        sliderForegroundGradientAmountStepper.enableIf(btnSliderForegroundGradientEnabled.isOn)
        sliderForegroundGradientAmountStepper.integerValue = scheme.effects.sliderForegroundGradientAmount
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderKnobColorPicker.color = scheme.effects.sliderKnobColor
        btnSliderKnobColorSameAsForeground.onIf(scheme.effects.sliderKnobColorSameAsForeground)
        
        sliderTickColorPicker.color = scheme.effects.sliderTickColor
        
        activeUnitStateColorPicker.color = scheme.effects.activeUnitStateColor
        bypassedUnitStateColorPicker.color = scheme.effects.bypassedUnitStateColor
        suppressedUnitStateColorPicker.color = scheme.effects.suppressedUnitStateColor
        
        // Only do this when the window is opening
        if !(self.view.window?.isVisible ?? true) {
            scrollToTop()
        }
    }
    
    private func scrollToTop() {
        
        let contentView: NSClipView = scrollView.contentView
        contentView.scroll(NSMakePoint(0, contentView.documentView!.frame.height))
    }
    
    func undoLastChange() -> Bool {
        
        if let lastChange = history.changeToUndo, let undoAction = actionsMap[lastChange.tag] {
            
            _ = history.undoLastChange()
            
            if let colPicker = controlsMap[lastChange.tag] as? NSColorWell, let undoColor = lastChange.undoValue as? NSColor {
                
                colPicker.color = undoColor
                
            } else if let btnToggle = controlsMap[lastChange.tag] as? NSButton, let boolVal = lastChange.undoValue as? Bool {
                
                btnToggle.onIf(boolVal)
                
            } else if let stepper = controlsMap[lastChange.tag] as? NSStepper, let intVal = lastChange.undoValue as? Int {
                
                stepper.integerValue = intVal
            }
            
            print("Found change:", lastChange.tag)
            
            undoAction()
            return true
        }
        
        return false
    }
    
    func redoLastChange() -> Bool {
        
        if let lastChange = history.changeToRedo, let redoAction = actionsMap[lastChange.tag] {
            
            _ = history.redoLastChange()
            
            if let colPicker = controlsMap[lastChange.tag] as? NSColorWell, let redoColor = lastChange.redoValue as? NSColor {
                
                colPicker.color = redoColor
                
            } else if let btnToggle = controlsMap[lastChange.tag] as? NSButton, let boolVal = lastChange.redoValue as? Bool {
                
                btnToggle.onIf(boolVal)
                
            } else if let stepper = controlsMap[lastChange.tag] as? NSStepper, let intVal = lastChange.redoValue as? Int {
                
                stepper.integerValue = intVal
            }
            
            print("Found change:", lastChange.tag)
            
            redoAction()
            return true
        }
        
        return false
    }
    
    @IBAction func functionCaptionTextColorAction(_ sender: Any) {
        
        history.noteChange(functionCaptionTextColorPicker.tag, ColorSchemes.systemScheme.effects.functionCaptionTextColor, functionCaptionTextColorPicker.color, .changeColor)
        changeFunctionCaptionTextColor()
    }
    
    private func changeFunctionCaptionTextColor() {
        
        ColorSchemes.systemScheme.effects.functionCaptionTextColor = functionCaptionTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsFunctionCaptionTextColor, functionCaptionTextColorPicker.color))
    }
    
    @IBAction func functionValueTextColorAction(_ sender: Any) {
        
        history.noteChange(functionValueTextColorPicker.tag, ColorSchemes.systemScheme.effects.functionValueTextColor, functionValueTextColorPicker.color, .changeColor)
        changeFunctionValueTextColor()
    }
    
    private func changeFunctionValueTextColor() {
        
        ColorSchemes.systemScheme.effects.functionValueTextColor = functionValueTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsFunctionValueTextColor, functionValueTextColorPicker.color))
    }
    
    @IBAction func enableSliderForegroundGradientAction(_ sender: Any) {
        
        history.noteChange(btnSliderForegroundGradientEnabled.tag, ColorSchemes.systemScheme.effects.sliderForegroundGradientType != .none, btnSliderForegroundGradientEnabled.isOn, .toggle)
        enableSliderForegroundGradient()
    }
    
    private func enableSliderForegroundGradient() {
        
        if btnSliderForegroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.effects.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.effects.sliderForegroundGradientType = .none
        }
        
        [btnSliderForegroundGradientDarken, btnSliderForegroundGradientBrighten, sliderForegroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderForegroundGradientEnabled.isOn)})
        
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(btnSliderForegroundGradientDarken.tag, ColorSchemes.systemScheme.effects.sliderForegroundGradientType == .darken, btnSliderForegroundGradientDarken.isOn, .toggle)
        brightenOrDarkenSliderForegroundGradient()
    }
    
    private func brightenOrDarkenSliderForegroundGradient() {
        
        ColorSchemes.systemScheme.effects.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(sliderForegroundGradientAmountStepper.tag, ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount, sliderForegroundGradientAmountStepper.integerValue, .setIntValue)
        changeSliderForegroundGradientAmount()
    }
    
    private func changeSliderForegroundGradientAmount() {
        
        ColorSchemes.systemScheme.effects.sliderForegroundGradientAmount = sliderForegroundGradientAmountStepper.integerValue
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderForegroundChanged()
    }
    
    private func sliderForegroundChanged() {

        // TODO - This is a hack. The message will result in a redraw regardless of whether the foreground/background has changed. Should consolidate the 2 event types into a single one - changeEffectsSliderColor
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundColorPicker.tag, ColorSchemes.systemScheme.effects.sliderBackgroundColor, sliderBackgroundColorPicker.color, .changeColor)
        changeSliderBackgroundColor()
    }
    
    private func changeSliderBackgroundColor() {
        
        ColorSchemes.systemScheme.effects.sliderBackgroundColor = sliderBackgroundColorPicker.color
        sliderBackgroundChanged()
    }
    
    @IBAction func enableSliderBackgroundGradientAction(_ sender: Any) {
        
        history.noteChange(btnSliderBackgroundGradientEnabled.tag, ColorSchemes.systemScheme.effects.sliderBackgroundGradientType != .none, btnSliderBackgroundGradientEnabled.isOn, .toggle)
        enableSliderBackgroundGradient()
    }
    
    private func enableSliderBackgroundGradient() {
        
        if btnSliderBackgroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.effects.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.effects.sliderBackgroundGradientType = .none
        }
        
        [btnSliderBackgroundGradientDarken, btnSliderBackgroundGradientBrighten, sliderBackgroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderBackgroundGradientEnabled.isOn)})
        
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(btnSliderBackgroundGradientDarken.tag, ColorSchemes.systemScheme.effects.sliderBackgroundGradientType == .darken, btnSliderBackgroundGradientDarken.isOn, .toggle)
        brightenOrDarkenSliderBackgroundGradient()
    }
    
    private func brightenOrDarkenSliderBackgroundGradient() {
        
        ColorSchemes.systemScheme.effects.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundGradientAmountStepper.tag, ColorSchemes.systemScheme.effects.sliderBackgroundGradientAmount, sliderBackgroundGradientAmountStepper.integerValue, .setIntValue)
        changeSliderBackgroundGradientAmount()
    }
    
    private func changeSliderBackgroundGradientAmount() {
        
        ColorSchemes.systemScheme.effects.sliderBackgroundGradientAmount = sliderBackgroundGradientAmountStepper.integerValue
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderBackgroundChanged()
    }
    
    private func sliderBackgroundChanged() {
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        history.noteChange(sliderKnobColorPicker.tag, ColorSchemes.systemScheme.effects.sliderKnobColor, sliderKnobColorPicker.color, .changeColor)
        changeSliderKnobColor()
    }
    
    private func changeSliderKnobColor() {
        
        ColorSchemes.systemScheme.effects.sliderKnobColor = sliderKnobColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderKnobColorSameAsForegroundAction(_ sender: Any) {
        
        history.noteChange(btnSliderKnobColorSameAsForeground.tag, ColorSchemes.systemScheme.effects.sliderKnobColorSameAsForeground, btnSliderKnobColorSameAsForeground.isOn, .toggle)
        toggleKnobColorSameAsForeground()
    }
    
    private func toggleKnobColorSameAsForeground() {
        
        ColorSchemes.systemScheme.effects.sliderKnobColorSameAsForeground = btnSliderKnobColorSameAsForeground.isOn
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderTickColorAction(_ sender: Any) {
        
        history.noteChange(sliderTickColorPicker.tag, ColorSchemes.systemScheme.effects.sliderTickColor, sliderTickColorPicker.color, .changeColor)
        changeSliderTickColor()
    }
    
    private func changeSliderTickColor() {
        
        ColorSchemes.systemScheme.effects.sliderTickColor = sliderTickColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsSliderBackgroundColor, sliderTickColorPicker.color))
    }
    
    @IBAction func activeUnitStateColorAction(_ sender: Any) {
        
        history.noteChange(activeUnitStateColorPicker.tag, ColorSchemes.systemScheme.effects.activeUnitStateColor, activeUnitStateColorPicker.color, .changeColor)
        changeActiveUnitStateColor()
    }
    
    private func changeActiveUnitStateColor() {
        
        ColorSchemes.systemScheme.effects.activeUnitStateColor = activeUnitStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsActiveUnitStateColor, activeUnitStateColorPicker.color))
    }
    
    @IBAction func bypassedUnitStateColorAction(_ sender: Any) {
        
        history.noteChange(bypassedUnitStateColorPicker.tag, ColorSchemes.systemScheme.effects.bypassedUnitStateColor, bypassedUnitStateColorPicker.color, .changeColor)
        changeBypassedUnitStateColor()
    }
    
    private func changeBypassedUnitStateColor() {

        ColorSchemes.systemScheme.effects.bypassedUnitStateColor = bypassedUnitStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsBypassedUnitStateColor, bypassedUnitStateColorPicker.color))
    }
    
    @IBAction func suppressedUnitStateColorAction(_ sender: Any) {
        
        history.noteChange(suppressedUnitStateColorPicker.tag, ColorSchemes.systemScheme.effects.suppressedUnitStateColor, suppressedUnitStateColorPicker.color, .changeColor)
        changeSuppressedUnitStateColor()
    }
    
    private func changeSuppressedUnitStateColor() {
        
        ColorSchemes.systemScheme.effects.suppressedUnitStateColor = suppressedUnitStateColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changeEffectsSuppressedUnitStateColor, suppressedUnitStateColorPicker.color))
    }
}
