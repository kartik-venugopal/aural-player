//
//  PlayerColorSchemeViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var messenger = Messenger(for: self)
    
    override var nibName: NSNib.Name? {"PlayerColorScheme"}
    
    private var playerScheme: PlayerColorScheme {
        colorSchemesManager.systemScheme.player
    }
    
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
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard) {
        
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
        
        history.noteChange(ColorSchemeChange(tag: trackInfoPrimaryTextColorPicker.tag, undoValue: playerScheme.trackInfoPrimaryTextColor,
                                             redoValue: trackInfoPrimaryTextColorPicker.color, changeType: .changeColor))
        changePrimaryTextColor()
    }
    
    private func changePrimaryTextColor() {
        
        playerScheme.trackInfoPrimaryTextColor = trackInfoPrimaryTextColorPicker.color
        messenger.publish(.player_changeTrackInfoPrimaryTextColor, payload: trackInfoPrimaryTextColorPicker.color)
    }
    
    @IBAction func secondaryTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: trackInfoSecondaryTextColorPicker.tag, undoValue: playerScheme.trackInfoSecondaryTextColor,
                                             redoValue: trackInfoSecondaryTextColorPicker.color, changeType: .changeColor))
        changeSecondaryTextColor()
    }
    
    private func changeSecondaryTextColor() {
        
        playerScheme.trackInfoSecondaryTextColor = trackInfoSecondaryTextColorPicker.color
        messenger.publish(.player_changeTrackInfoSecondaryTextColor, payload: trackInfoSecondaryTextColorPicker.color)
    }
    
    @IBAction func tertiaryTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: trackInfoTertiaryTextColorPicker.tag, undoValue: playerScheme.trackInfoTertiaryTextColor,
                                             redoValue: trackInfoTertiaryTextColorPicker.color, changeType: .changeColor))
        changeTertiaryTextColor()
    }
    
    private func changeTertiaryTextColor() {
        
        playerScheme.trackInfoTertiaryTextColor = trackInfoTertiaryTextColorPicker.color
        messenger.publish(.player_changeTrackInfoTertiaryTextColor, payload: trackInfoTertiaryTextColorPicker.color)
    }
    
    @IBAction func sliderValueTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderValueTextColorPicker.tag, undoValue: playerScheme.sliderValueTextColor,
                                             redoValue: sliderValueTextColorPicker.color, changeType: .changeColor))
        changeSliderValueTextColor()
    }
    
    private func changeSliderValueTextColor() {
        
        playerScheme.sliderValueTextColor = sliderValueTextColorPicker.color
        messenger.publish(.player_changeSliderValueTextColor, payload: sliderValueTextColorPicker.color)
    }
    
    @IBAction func sliderForegroundColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderForegroundColorPicker.tag, undoValue: playerScheme.sliderForegroundColor,
                                             redoValue: sliderForegroundColorPicker.color, changeType: .changeColor))
        changeSliderForegroundColor()
    }
    
    private func changeSliderForegroundColor() {
        
        playerScheme.sliderForegroundColor = sliderForegroundColorPicker.color
        sliderForegroundChanged()
    }
    
    @IBAction func enableSliderForegroundGradientAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderForegroundGradientBtnGroup.tag, undoValue: playerScheme.sliderForegroundGradientType,
                                             redoValue: sliderForegroundGradientBtnGroup.gradientType, changeType: .changeGradient))
        
        changeSliderForegroundGradient()
    }
    
    private func changeSliderForegroundGradient() {
        
        if btnSliderForegroundGradientEnabled.isOn {
            playerScheme.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        } else {
            playerScheme.sliderForegroundGradientType = .none
        }
        
//        [btnSliderForegroundGradientDarken, btnSliderForegroundGradientBrighten, sliderForegroundGradientAmountStepper].forEach {$0?.enableIf(btnSliderForegroundGradientEnabled.isOn)}
        
        sliderForegroundChanged()
    }
    
    @IBAction func sliderForegroundGradientBrightenOrDarkenAction(_ sender: Any) {

        history.noteChange(ColorSchemeChange(tag: sliderForegroundGradientBtnGroup.tag, undoValue: playerScheme.sliderForegroundGradientType,
                                             redoValue: sliderForegroundGradientBtnGroup.gradientType, changeType: .changeGradient))
        
        changeSliderForegroundGradient()
    }
    
    @IBAction func sliderForegroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderForegroundGradientAmountStepper.tag, undoValue: playerScheme.sliderForegroundGradientAmount,
                                             redoValue: sliderForegroundGradientAmountStepper.integerValue, changeType: .setIntValue))
        
        changeSliderForegroundGradientAmount()
    }
    
    private func changeSliderForegroundGradientAmount() {
        
        playerScheme.sliderForegroundGradientAmount = sliderForegroundGradientAmountStepper.integerValue
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderForegroundChanged()
    }
    
    private func sliderForegroundChanged() {
        
        Colors.Player.updateSliderForegroundColor()
        messenger.publish(.player_changeSliderColors)
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderBackgroundColorPicker.tag, undoValue: playerScheme.sliderBackgroundColor,
                                             redoValue: sliderBackgroundColorPicker.color, changeType: .changeColor))
        changeSliderBackgroundColor()
    }
    
    private func changeSliderBackgroundColor() {
        
        playerScheme.sliderBackgroundColor = sliderBackgroundColorPicker.color
        sliderBackgroundChanged()
    }
    
    @IBAction func enableSliderBackgroundGradientAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderBackgroundGradientBtnGroup.tag, undoValue: playerScheme.sliderBackgroundGradientType,
                                             redoValue: sliderBackgroundGradientBtnGroup.gradientType, changeType: .changeGradient))
        
        changeSliderBackgroundGradient()
    }
    
    private func changeSliderBackgroundGradient() {
        
        if btnSliderBackgroundGradientEnabled.isOn {
            playerScheme.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        } else {
            playerScheme.sliderBackgroundGradientType = .none
        }
        
//        [btnSliderBackgroundGradientDarken, btnSliderBackgroundGradientBrighten, sliderBackgroundGradientAmountStepper].forEach {$0?.enableIf(btnSliderBackgroundGradientEnabled.isOn)}
        
        sliderBackgroundChanged()
    }
    
    @IBAction func sliderBackgroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderBackgroundGradientBtnGroup.tag, undoValue: playerScheme.sliderBackgroundGradientType,
                                             redoValue: sliderBackgroundGradientBtnGroup.gradientType, changeType: .changeGradient))
        
        changeSliderBackgroundGradient()
    }
    
    @IBAction func sliderBackgroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderBackgroundGradientAmountStepper.tag, undoValue: playerScheme.sliderBackgroundGradientAmount,
                                             redoValue: sliderBackgroundGradientAmountStepper.integerValue, changeType: .setIntValue))
        
        changeSliderBackgroundGradientAmount()
    }
    
    private func changeSliderBackgroundGradientAmount() {
        
        playerScheme.sliderBackgroundGradientAmount = sliderBackgroundGradientAmountStepper.integerValue
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderBackgroundChanged()
    }
    
    private func sliderBackgroundChanged() {
        
        Colors.Player.updateSliderBackgroundColor()
        messenger.publish(.player_changeSliderColors)
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderKnobColorPicker.tag, undoValue: playerScheme.sliderKnobColor,
                                             redoValue: sliderKnobColorPicker.color, changeType: .changeColor))
        changeSliderKnobColor()
    }
    
    private func changeSliderKnobColor() {
        
        playerScheme.sliderKnobColor = sliderKnobColorPicker.color
        messenger.publish(.player_changeSliderColors)
    }
    
    @IBAction func sliderKnobColorSameAsForegroundAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: btnSliderKnobColorSameAsForeground.tag, undoValue: playerScheme.sliderKnobColorSameAsForeground,
                                             redoValue: btnSliderKnobColorSameAsForeground.isOn, changeType: .toggle))
        toggleKnobColorSameAsForeground()
    }
    
    private func toggleKnobColorSameAsForeground() {
        
        playerScheme.sliderKnobColorSameAsForeground = btnSliderKnobColorSameAsForeground.isOn
        messenger.publish(.player_changeSliderColors)
    }
    
    @IBAction func sliderLoopSegmentColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: sliderLoopSegmentColorPicker.tag, undoValue: playerScheme.sliderLoopSegmentColor,
                                             redoValue: sliderLoopSegmentColorPicker.color, changeType: .changeColor))
        changeSliderLoopSegmentColor()
    }
    
    private func changeSliderLoopSegmentColor() {
        
        playerScheme.sliderLoopSegmentColor = sliderLoopSegmentColorPicker.color
        messenger.publish(.player_changeSliderColors)
    }
}
