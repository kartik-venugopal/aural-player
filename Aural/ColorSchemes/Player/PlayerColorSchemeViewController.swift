import Cocoa

class PlayerColorSchemeViewController: NSViewController, ColorSchemesViewProtocol {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var containerView: NSView!
    
    @IBOutlet weak var trackInfoPrimaryTextColorPicker: NSColorWell!
    @IBOutlet weak var trackInfoSecondaryTextColorPicker: NSColorWell!
    @IBOutlet weak var trackInfoTertiaryTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderValueTextColorPicker: NSColorWell!
    
    @IBOutlet weak var sliderBackgroundColorPicker: NSColorWell!
    @IBOutlet weak var btnSliderBackgroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientBrighten: NSButton!
    @IBOutlet weak var sliderBackgroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderBackgroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderForegroundColorPicker: NSColorWell!
    @IBOutlet weak var btnSliderForegroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientBrighten: NSButton!
    @IBOutlet weak var sliderForegroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderForegroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderKnobColorPicker: NSColorWell!
    @IBOutlet weak var btnSliderKnobColorSameAsForeground: NSButton!
    
    @IBOutlet weak var sliderLoopSegmentColorPicker: NSColorWell!
    
    private var controlsMap: [Int: NSControl] = [:]
    private var actionsMap: [Int: ColorChangeAction] = [:]
    private var history: ColorSchemeHistory!
    
    override var nibName: NSNib.Name? {return "PlayerColorScheme"}
    
    var colorSchemeView: NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        for aView in containerView.subviews {
            
            if let control = aView as? NSControl,
                control is NSColorWell || control is NSButton || control is NSStepper {
                
                controlsMap[control.tag] = control
                print("Player CS, mapped:", control.tag, control.className)
            }
        }
        
        actionsMap[trackInfoPrimaryTextColorPicker.tag] = self.changePrimaryTextColor
        actionsMap[trackInfoSecondaryTextColorPicker.tag] = self.changeSecondaryTextColor
        actionsMap[trackInfoTertiaryTextColorPicker.tag] = self.changeTertiaryTextColor
        
        actionsMap[sliderValueTextColorPicker.tag] = self.changeSliderValueTextColor
        
        actionsMap[sliderBackgroundColorPicker.tag] = self.changeSliderBackgroundColor
        actionsMap[btnSliderBackgroundGradientEnabled.tag] = self.enableSliderBackgroundGradient
        actionsMap[btnSliderBackgroundGradientDarken.tag] = self.brightenOrDarkenSliderBackgroundGradient
        actionsMap[btnSliderBackgroundGradientBrighten.tag] = self.brightenOrDarkenSliderBackgroundGradient
        actionsMap[sliderBackgroundGradientAmountStepper.tag] = self.changeSliderBackgroundGradientAmount
        
        actionsMap[sliderForegroundColorPicker.tag] = self.changeSliderForegroundColor
        actionsMap[btnSliderForegroundGradientEnabled.tag] = self.enableSliderForegroundGradient
        actionsMap[btnSliderForegroundGradientDarken.tag] = self.brightenOrDarkenSliderForegroundGradient
        actionsMap[btnSliderForegroundGradientBrighten.tag] = self.brightenOrDarkenSliderForegroundGradient
        actionsMap[sliderForegroundGradientAmountStepper.tag] = self.changeSliderForegroundGradientAmount
        
        actionsMap[sliderKnobColorPicker.tag] = self.changeSliderKnobColor
        actionsMap[btnSliderKnobColorSameAsForeground.tag] = self.toggleKnobColorSameAsForeground
        
        actionsMap[sliderLoopSegmentColorPicker.tag] = self.changeSliderLoopSegmentColor
    }
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory) {
        
        self.history = history
        
        trackInfoPrimaryTextColorPicker.color = scheme.player.trackInfoPrimaryTextColor
        trackInfoSecondaryTextColorPicker.color = scheme.player.trackInfoSecondaryTextColor
        trackInfoTertiaryTextColorPicker.color = scheme.player.trackInfoTertiaryTextColor
        
        sliderValueTextColorPicker.color = scheme.player.sliderValueTextColor
        
        sliderBackgroundColorPicker.color = scheme.player.sliderBackgroundColor
        
        btnSliderBackgroundGradientEnabled.onIf(scheme.player.sliderBackgroundGradientType != .none)
        
        btnSliderBackgroundGradientDarken.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        btnSliderBackgroundGradientDarken.onIf(scheme.player.sliderBackgroundGradientType != .brighten)
        
        btnSliderBackgroundGradientBrighten.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        btnSliderBackgroundGradientBrighten.onIf(scheme.player.sliderBackgroundGradientType == .brighten)
        
        sliderBackgroundGradientAmountStepper.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        sliderBackgroundGradientAmountStepper.integerValue = scheme.player.sliderBackgroundGradientAmount
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderForegroundColorPicker.color = scheme.player.sliderForegroundColor
        
        btnSliderForegroundGradientEnabled.onIf(scheme.player.sliderForegroundGradientType != .none)
        
        btnSliderForegroundGradientDarken.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientDarken.onIf(scheme.player.sliderForegroundGradientType != .brighten)
        
        btnSliderForegroundGradientBrighten.enableIf(btnSliderForegroundGradientEnabled.isOn)
        btnSliderForegroundGradientBrighten.onIf(scheme.player.sliderForegroundGradientType == .brighten)
        
        sliderForegroundGradientAmountStepper.enableIf(btnSliderForegroundGradientEnabled.isOn)
        sliderForegroundGradientAmountStepper.integerValue = scheme.player.sliderForegroundGradientAmount
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderKnobColorPicker.color = scheme.player.sliderKnobColor
        btnSliderKnobColorSameAsForeground.onIf(scheme.player.sliderKnobColorSameAsForeground)
        sliderLoopSegmentColorPicker.color = scheme.player.sliderLoopSegmentColor
        
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
    
    @IBAction func primaryTextColorAction(_ sender: Any) {
        
        history.noteChange(trackInfoPrimaryTextColorPicker.tag, ColorSchemes.systemScheme.player.trackInfoPrimaryTextColor, trackInfoPrimaryTextColorPicker.color, .changeColor)
        changePrimaryTextColor()
    }
    
    private func changePrimaryTextColor() {
        
        ColorSchemes.systemScheme.player.trackInfoPrimaryTextColor = trackInfoPrimaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerTrackInfoPrimaryTextColor, trackInfoPrimaryTextColorPicker.color))
    }
    
    @IBAction func secondaryTextColorAction(_ sender: Any) {
        
        history.noteChange(trackInfoSecondaryTextColorPicker.tag, ColorSchemes.systemScheme.player.trackInfoSecondaryTextColor, trackInfoSecondaryTextColorPicker.color, .changeColor)
        changeSecondaryTextColor()
    }
    
    private func changeSecondaryTextColor() {
        
        ColorSchemes.systemScheme.player.trackInfoSecondaryTextColor = trackInfoSecondaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerTrackInfoSecondaryTextColor, trackInfoSecondaryTextColorPicker.color))
    }
    
    @IBAction func tertiaryTextColorAction(_ sender: Any) {
        
        history.noteChange(trackInfoTertiaryTextColorPicker.tag, ColorSchemes.systemScheme.player.trackInfoTertiaryTextColor, trackInfoTertiaryTextColorPicker.color, .changeColor)
        changeTertiaryTextColor()
    }
    
    private func changeTertiaryTextColor() {
        
        ColorSchemes.systemScheme.player.trackInfoTertiaryTextColor = trackInfoTertiaryTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerTrackInfoTertiaryTextColor, trackInfoTertiaryTextColorPicker.color))
    }
    
    @IBAction func sliderValueTextColorAction(_ sender: Any) {
        
        history.noteChange(sliderValueTextColorPicker.tag, ColorSchemes.systemScheme.player.sliderValueTextColor, sliderValueTextColorPicker.color, .changeColor)
        changeSliderValueTextColor()
    }
    
    private func changeSliderValueTextColor() {
        
        ColorSchemes.systemScheme.player.sliderValueTextColor = sliderValueTextColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerSliderValueTextColor, sliderValueTextColorPicker.color))
    }
    
    @IBAction func sliderForegroundColorAction(_ sender: Any) {
        
        history.noteChange(sliderForegroundColorPicker.tag, ColorSchemes.systemScheme.player.sliderForegroundColor, sliderForegroundColorPicker.color, .changeColor)
        changeSliderForegroundColor()
    }
    
    private func changeSliderForegroundColor() {
        
        ColorSchemes.systemScheme.player.sliderForegroundColor = sliderForegroundColorPicker.color
        sliderForegroundChanged()
    }
    
    @IBAction func enableSliderForegroundGradientAction(_ sender: Any) {
        
        history.noteChange(btnSliderForegroundGradientEnabled.tag, ColorSchemes.systemScheme.player.sliderForegroundGradientType != .none, btnSliderForegroundGradientEnabled.isOn, .toggle)
        enableSliderForegroundGradient()
    }
    
    private func enableSliderForegroundGradient() {
        
        if btnSliderForegroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.player.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.player.sliderForegroundGradientType = .none
        }
        
        [btnSliderForegroundGradientDarken, btnSliderForegroundGradientBrighten, sliderForegroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderForegroundGradientEnabled.isOn)})
        
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(btnSliderForegroundGradientDarken.tag, ColorSchemes.systemScheme.player.sliderForegroundGradientType == .darken, btnSliderForegroundGradientDarken.isOn, .toggle)
        brightenOrDarkenSliderForegroundGradient()
    }
    
    private func brightenOrDarkenSliderForegroundGradient() {
        
        ColorSchemes.systemScheme.player.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(sliderForegroundGradientAmountStepper.tag, ColorSchemes.systemScheme.player.sliderForegroundGradientAmount, sliderForegroundGradientAmountStepper.integerValue, .setIntValue)
        changeSliderForegroundGradientAmount()
    }
    
    private func changeSliderForegroundGradientAmount() {
        
        ColorSchemes.systemScheme.player.sliderForegroundGradientAmount = sliderForegroundGradientAmountStepper.integerValue
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderForegroundChanged()
    }
    
    private func sliderForegroundChanged() {
        
        Colors.Player.updateSliderForegroundColor()
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerSliderForegroundColor, sliderForegroundColorPicker.color))
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundColorPicker.tag, ColorSchemes.systemScheme.player.sliderBackgroundColor, sliderBackgroundColorPicker.color, .changeColor)
        changeSliderBackgroundColor()
    }
    
    private func changeSliderBackgroundColor() {
        
        ColorSchemes.systemScheme.player.sliderBackgroundColor = sliderBackgroundColorPicker.color
        sliderBackgroundChanged()
    }
    
    @IBAction func enableSliderBackgroundGradientAction(_ sender: Any) {
        
        history.noteChange(btnSliderBackgroundGradientEnabled.tag, ColorSchemes.systemScheme.player.sliderBackgroundGradientType != .none, btnSliderBackgroundGradientEnabled.isOn, .toggle)
        enableSliderBackgroundGradient()
    }
    
    private func enableSliderBackgroundGradient() {
        
        if btnSliderBackgroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.player.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.player.sliderBackgroundGradientType = .none
        }
        
        [btnSliderBackgroundGradientDarken, btnSliderBackgroundGradientBrighten, sliderBackgroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderBackgroundGradientEnabled.isOn)})
        
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(btnSliderBackgroundGradientDarken.tag, ColorSchemes.systemScheme.player.sliderBackgroundGradientType == .darken, btnSliderBackgroundGradientDarken.isOn, .toggle)
        brightenOrDarkenSliderBackgroundGradient()
    }
    
    private func brightenOrDarkenSliderBackgroundGradient() {
        
        ColorSchemes.systemScheme.player.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundGradientAmountStepper.tag, ColorSchemes.systemScheme.player.sliderBackgroundGradientAmount, sliderBackgroundGradientAmountStepper.integerValue, .setIntValue)
        changeSliderBackgroundGradientAmount()
    }
    
    private func changeSliderBackgroundGradientAmount() {
        
        ColorSchemes.systemScheme.player.sliderBackgroundGradientAmount = sliderBackgroundGradientAmountStepper.integerValue
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderBackgroundChanged()
    }
    
    private func sliderBackgroundChanged() {
        
        Colors.Player.updateSliderBackgroundColor()
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerSliderBackgroundColor, sliderBackgroundColorPicker.color))
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        history.noteChange(sliderKnobColorPicker.tag, ColorSchemes.systemScheme.player.sliderKnobColor, sliderKnobColorPicker.color, .changeColor)
        changeSliderKnobColor()
    }
    
    private func changeSliderKnobColor() {
        
        ColorSchemes.systemScheme.player.sliderKnobColor = sliderKnobColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerSliderKnobColor, sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderKnobColorSameAsForegroundAction(_ sender: Any) {
        
        history.noteChange(btnSliderKnobColorSameAsForeground.tag, ColorSchemes.systemScheme.player.sliderKnobColorSameAsForeground, btnSliderKnobColorSameAsForeground.isOn, .toggle)
        toggleKnobColorSameAsForeground()
    }
    
    private func toggleKnobColorSameAsForeground() {
        
        ColorSchemes.systemScheme.player.sliderKnobColorSameAsForeground = btnSliderKnobColorSameAsForeground.isOn
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerSliderKnobColor, btnSliderKnobColorSameAsForeground.isOn ? sliderForegroundColorPicker.color : sliderKnobColorPicker.color))
    }
    
    @IBAction func sliderLoopSegmentColorAction(_ sender: Any) {
        
        history.noteChange(sliderLoopSegmentColorPicker.tag, ColorSchemes.systemScheme.player.sliderLoopSegmentColor, sliderLoopSegmentColorPicker.color, .changeColor)
        changeSliderLoopSegmentColor()
    }
    
    private func changeSliderLoopSegmentColor() {
        
        ColorSchemes.systemScheme.player.sliderLoopSegmentColor = sliderLoopSegmentColorPicker.color
        SyncMessenger.publishActionMessage(ColorSchemeComponentActionMessage(.changePlayerSliderLoopSegmentColor, sliderLoopSegmentColorPicker.color))
    }
}
