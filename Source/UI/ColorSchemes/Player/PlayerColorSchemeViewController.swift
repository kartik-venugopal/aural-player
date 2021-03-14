import Cocoa

/*
    Controller for the view that allows the user to edit color scheme elements that apply to the player UI.
 */
class PlayerColorSchemeViewController: ColorSchemeViewController {
    
    @IBOutlet weak var trackInfoPrimaryTextColorPicker: AuralColorPicker!
    @IBOutlet weak var trackInfoSecondaryTextColorPicker: AuralColorPicker!
    @IBOutlet weak var trackInfoTertiaryTextColorPicker: AuralColorPicker!
    
    @IBOutlet weak var sliderValueTextColorPicker: AuralColorPicker!
    
    @IBOutlet weak var sliderBackgroundColorPicker: AuralColorPicker!
    
    @IBOutlet weak var sliderBackgroundGradientBtnGroup: GradientOptionsRadioButtonGroup!
    @IBOutlet weak var btnSliderBackgroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientBrighten: NSButton!
    
    @IBOutlet weak var sliderBackgroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderBackgroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderForegroundColorPicker: AuralColorPicker!
    
    @IBOutlet weak var sliderForegroundGradientBtnGroup: GradientOptionsRadioButtonGroup!
    @IBOutlet weak var btnSliderForegroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientBrighten: NSButton!
    
    @IBOutlet weak var sliderForegroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderForegroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderKnobColorPicker: AuralColorPicker!
    @IBOutlet weak var btnSliderKnobColorSameAsForeground: NSButton!
    
    @IBOutlet weak var sliderLoopSegmentColorPicker: AuralColorPicker!
    
    override var nibName: NSNib.Name? {return "PlayerColorScheme"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[trackInfoPrimaryTextColorPicker.tag] = self.changePrimaryTextColor
        actionsMap[trackInfoSecondaryTextColorPicker.tag] = self.changeSecondaryTextColor
        actionsMap[trackInfoTertiaryTextColorPicker.tag] = self.changeTertiaryTextColor
        
        actionsMap[sliderValueTextColorPicker.tag] = self.changeSliderValueTextColor
        
        actionsMap[sliderBackgroundColorPicker.tag] = self.changeSliderBackgroundColor
        actionsMap[sliderBackgroundGradientBtnGroup.tag] = self.changeSliderBackgroundGradient
        actionsMap[sliderBackgroundGradientAmountStepper.tag] = self.changeSliderBackgroundGradientAmount
        
        actionsMap[sliderForegroundColorPicker.tag] = self.changeSliderForegroundColor
        actionsMap[sliderForegroundGradientBtnGroup.tag] = self.changeSliderForegroundGradient
        actionsMap[sliderForegroundGradientAmountStepper.tag] = self.changeSliderForegroundGradientAmount
        
        actionsMap[sliderKnobColorPicker.tag] = self.changeSliderKnobColor
        actionsMap[btnSliderKnobColorSameAsForeground.tag] = self.toggleKnobColorSameAsForeground
        
        actionsMap[sliderLoopSegmentColorPicker.tag] = self.changeSliderLoopSegmentColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
        trackInfoPrimaryTextColorPicker.color = scheme.player.trackInfoPrimaryTextColor
        trackInfoSecondaryTextColorPicker.color = scheme.player.trackInfoSecondaryTextColor
        trackInfoTertiaryTextColorPicker.color = scheme.player.trackInfoTertiaryTextColor
        
        sliderValueTextColorPicker.color = scheme.player.sliderValueTextColor
        
        sliderBackgroundColorPicker.color = scheme.player.sliderBackgroundColor
        
        sliderBackgroundGradientBtnGroup.gradientType = scheme.player.sliderBackgroundGradientType
        sliderBackgroundGradientAmountStepper.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        sliderBackgroundGradientAmountStepper.integerValue = scheme.player.sliderBackgroundGradientAmount
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderForegroundColorPicker.color = scheme.player.sliderForegroundColor
        
        sliderForegroundGradientBtnGroup.gradientType = scheme.player.sliderForegroundGradientType
        
        sliderForegroundGradientAmountStepper.enableIf(btnSliderForegroundGradientEnabled.isOn)
        sliderForegroundGradientAmountStepper.integerValue = scheme.player.sliderForegroundGradientAmount
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderKnobColorPicker.color = scheme.player.sliderKnobColor
        btnSliderKnobColorSameAsForeground.onIf(scheme.player.sliderKnobColorSameAsForeground)
        sliderLoopSegmentColorPicker.color = scheme.player.sliderLoopSegmentColor
    }
    
    @IBAction func primaryTextColorAction(_ sender: Any) {
        
        history.noteChange(trackInfoPrimaryTextColorPicker.tag, ColorSchemes.systemScheme.player.trackInfoPrimaryTextColor, trackInfoPrimaryTextColorPicker.color, .changeColor)
        changePrimaryTextColor()
    }
    
    private func changePrimaryTextColor() {
        
        ColorSchemes.systemScheme.player.trackInfoPrimaryTextColor = trackInfoPrimaryTextColorPicker.color
        Messenger.publish(.player_changeTrackInfoPrimaryTextColor, payload: trackInfoPrimaryTextColorPicker.color)
    }
    
    @IBAction func secondaryTextColorAction(_ sender: Any) {
        
        history.noteChange(trackInfoSecondaryTextColorPicker.tag, ColorSchemes.systemScheme.player.trackInfoSecondaryTextColor, trackInfoSecondaryTextColorPicker.color, .changeColor)
        changeSecondaryTextColor()
    }
    
    private func changeSecondaryTextColor() {
        
        ColorSchemes.systemScheme.player.trackInfoSecondaryTextColor = trackInfoSecondaryTextColorPicker.color
        Messenger.publish(.player_changeTrackInfoSecondaryTextColor, payload: trackInfoSecondaryTextColorPicker.color)
    }
    
    @IBAction func tertiaryTextColorAction(_ sender: Any) {
        
        history.noteChange(trackInfoTertiaryTextColorPicker.tag, ColorSchemes.systemScheme.player.trackInfoTertiaryTextColor, trackInfoTertiaryTextColorPicker.color, .changeColor)
        changeTertiaryTextColor()
    }
    
    private func changeTertiaryTextColor() {
        
        ColorSchemes.systemScheme.player.trackInfoTertiaryTextColor = trackInfoTertiaryTextColorPicker.color
        Messenger.publish(.player_changeTrackInfoTertiaryTextColor, payload: trackInfoTertiaryTextColorPicker.color)
    }
    
    @IBAction func sliderValueTextColorAction(_ sender: Any) {
        
        history.noteChange(sliderValueTextColorPicker.tag, ColorSchemes.systemScheme.player.sliderValueTextColor, sliderValueTextColorPicker.color, .changeColor)
        changeSliderValueTextColor()
    }
    
    private func changeSliderValueTextColor() {
        
        ColorSchemes.systemScheme.player.sliderValueTextColor = sliderValueTextColorPicker.color
        Messenger.publish(.player_changeSliderValueTextColor, payload: sliderValueTextColorPicker.color)
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
        
        history.noteChange(sliderForegroundGradientBtnGroup.tag, ColorSchemes.systemScheme.player.sliderForegroundGradientType, sliderForegroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderForegroundGradient()
    }
    
    private func changeSliderForegroundGradient() {
        
        if btnSliderForegroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.player.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.player.sliderForegroundGradientType = .none
        }
        
        [btnSliderForegroundGradientDarken, btnSliderForegroundGradientBrighten, sliderForegroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderForegroundGradientEnabled.isOn)})
        
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientBrightenOrDarkenAction(_ sender: Any) {

        history.noteChange(sliderForegroundGradientBtnGroup.tag, ColorSchemes.systemScheme.player.sliderForegroundGradientType, sliderForegroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderForegroundGradient()
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
        Messenger.publish(.player_changeSliderColors)
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
        
        history.noteChange(sliderBackgroundGradientBtnGroup.tag, ColorSchemes.systemScheme.player.sliderBackgroundGradientType, sliderBackgroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderBackgroundGradient()
    }
    
    private func changeSliderBackgroundGradient() {
        
        if btnSliderBackgroundGradientEnabled.isOn {
            ColorSchemes.systemScheme.player.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        } else {
            ColorSchemes.systemScheme.player.sliderBackgroundGradientType = .none
        }
        
        [btnSliderBackgroundGradientDarken, btnSliderBackgroundGradientBrighten, sliderBackgroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderBackgroundGradientEnabled.isOn)})
        
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundGradientBtnGroup.tag, ColorSchemes.systemScheme.player.sliderBackgroundGradientType, sliderBackgroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderBackgroundGradient()
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
        Messenger.publish(.player_changeSliderColors)
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        history.noteChange(sliderKnobColorPicker.tag, ColorSchemes.systemScheme.player.sliderKnobColor, sliderKnobColorPicker.color, .changeColor)
        changeSliderKnobColor()
    }
    
    private func changeSliderKnobColor() {
        
        ColorSchemes.systemScheme.player.sliderKnobColor = sliderKnobColorPicker.color
        Messenger.publish(.player_changeSliderColors)
    }
    
    @IBAction func sliderKnobColorSameAsForegroundAction(_ sender: Any) {
        
        history.noteChange(btnSliderKnobColorSameAsForeground.tag, ColorSchemes.systemScheme.player.sliderKnobColorSameAsForeground, btnSliderKnobColorSameAsForeground.isOn, .toggle)
        toggleKnobColorSameAsForeground()
    }
    
    private func toggleKnobColorSameAsForeground() {
        
        ColorSchemes.systemScheme.player.sliderKnobColorSameAsForeground = btnSliderKnobColorSameAsForeground.isOn
        Messenger.publish(.player_changeSliderColors)
    }
    
    @IBAction func sliderLoopSegmentColorAction(_ sender: Any) {
        
        history.noteChange(sliderLoopSegmentColorPicker.tag, ColorSchemes.systemScheme.player.sliderLoopSegmentColor, sliderLoopSegmentColorPicker.color, .changeColor)
        changeSliderLoopSegmentColor()
    }
    
    private func changeSliderLoopSegmentColor() {
        
        ColorSchemes.systemScheme.player.sliderLoopSegmentColor = sliderLoopSegmentColorPicker.color
        Messenger.publish(.player_changeSliderColors)
    }
}
