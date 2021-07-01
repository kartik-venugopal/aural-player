//
//  EffectsColorSchemeViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the view that allows the user to edit color scheme elements that apply to the effects panel UI.
 */
class EffectsColorSchemeViewController: ColorSchemeViewController {
    
    @IBOutlet weak var functionCaptionTextColorPicker: AuralColorPicker!
    @IBOutlet weak var functionValueTextColorPicker: AuralColorPicker!
    
    @IBOutlet weak var sliderBackgroundColorPicker: AuralColorPicker!
    
    @IBOutlet weak var sliderBackgroundGradientBtnGroup: GradientOptionsRadioButtonGroup!
    @IBOutlet weak var btnSliderBackgroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderBackgroundGradientBrighten: NSButton!
    
    @IBOutlet weak var sliderBackgroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderBackgroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderForegroundGradientBtnGroup: GradientOptionsRadioButtonGroup!
    @IBOutlet weak var btnSliderForegroundGradientEnabled: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientDarken: NSButton!
    @IBOutlet weak var btnSliderForegroundGradientBrighten: NSButton!
    
    @IBOutlet weak var sliderForegroundGradientAmountStepper: NSStepper!
    @IBOutlet weak var lblSliderForegroundGradientAmount: NSTextField!
    
    @IBOutlet weak var sliderKnobColorPicker: AuralColorPicker!
    @IBOutlet weak var btnSliderKnobColorSameAsForeground: NSButton!
    
    @IBOutlet weak var sliderTickColorPicker: AuralColorPicker!
    
    @IBOutlet weak var activeUnitStateColorPicker: AuralColorPicker!
    @IBOutlet weak var bypassedUnitStateColorPicker: AuralColorPicker!
    @IBOutlet weak var suppressedUnitStateColorPicker: AuralColorPicker!
    
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var nibName: NSNib.Name? {return "EffectsColorScheme"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[functionCaptionTextColorPicker.tag] = self.changeFunctionCaptionTextColor
        actionsMap[functionValueTextColorPicker.tag] = self.changeFunctionValueTextColor
        
        actionsMap[sliderBackgroundColorPicker.tag] = self.changeSliderBackgroundColor
        actionsMap[sliderBackgroundGradientBtnGroup.tag] = self.changeSliderBackgroundGradient
        actionsMap[sliderBackgroundGradientAmountStepper.tag] = self.changeSliderBackgroundGradientAmount
        
        actionsMap[sliderForegroundGradientBtnGroup.tag] = self.changeSliderForegroundGradient
        actionsMap[sliderForegroundGradientAmountStepper.tag] = self.changeSliderForegroundGradientAmount
        
        actionsMap[sliderKnobColorPicker.tag] = self.changeSliderKnobColor
        actionsMap[btnSliderKnobColorSameAsForeground.tag] = self.toggleKnobColorSameAsForeground
        
        actionsMap[activeUnitStateColorPicker.tag] = self.changeActiveUnitStateColor
        actionsMap[bypassedUnitStateColorPicker.tag] = self.changeBypassedUnitStateColor
        actionsMap[suppressedUnitStateColorPicker.tag] = self.changeSuppressedUnitStateColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
        functionCaptionTextColorPicker.color = scheme.effects.functionCaptionTextColor
        functionValueTextColorPicker.color = scheme.effects.functionValueTextColor
        
        sliderBackgroundColorPicker.color = scheme.effects.sliderBackgroundColor
        sliderBackgroundGradientBtnGroup.gradientType = scheme.effects.sliderBackgroundGradientType
        
        sliderBackgroundGradientAmountStepper.enableIf(btnSliderBackgroundGradientEnabled.isOn)
        sliderBackgroundGradientAmountStepper.integerValue = scheme.effects.sliderBackgroundGradientAmount
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderForegroundGradientBtnGroup.gradientType = scheme.effects.sliderForegroundGradientType
        
        sliderForegroundGradientAmountStepper.enableIf(btnSliderForegroundGradientEnabled.isOn)
        sliderForegroundGradientAmountStepper.integerValue = scheme.effects.sliderForegroundGradientAmount
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderKnobColorPicker.color = scheme.effects.sliderKnobColor
        btnSliderKnobColorSameAsForeground.onIf(scheme.effects.sliderKnobColorSameAsForeground)
        
        sliderTickColorPicker.color = scheme.effects.sliderTickColor
        
        activeUnitStateColorPicker.color = scheme.effects.activeUnitStateColor
        bypassedUnitStateColorPicker.color = scheme.effects.bypassedUnitStateColor
        suppressedUnitStateColorPicker.color = scheme.effects.suppressedUnitStateColor
    }
    
    @IBAction func functionCaptionTextColorAction(_ sender: Any) {
        
        history.noteChange(functionCaptionTextColorPicker.tag, colorSchemesManager.systemScheme.effects.functionCaptionTextColor, functionCaptionTextColorPicker.color, .changeColor)
        changeFunctionCaptionTextColor()
    }
    
    private func changeFunctionCaptionTextColor() {
        
        colorSchemesManager.systemScheme.effects.functionCaptionTextColor = functionCaptionTextColorPicker.color
        Messenger.publish(.effects_changeFunctionCaptionTextColor, payload: functionCaptionTextColorPicker.color)
    }
    
    @IBAction func functionValueTextColorAction(_ sender: Any) {
        
        history.noteChange(functionValueTextColorPicker.tag, colorSchemesManager.systemScheme.effects.functionValueTextColor, functionValueTextColorPicker.color, .changeColor)
        changeFunctionValueTextColor()
    }
    
    private func changeFunctionValueTextColor() {
        
        colorSchemesManager.systemScheme.effects.functionValueTextColor = functionValueTextColorPicker.color
        Messenger.publish(.effects_changeFunctionValueTextColor, payload: functionValueTextColorPicker.color)
    }
    
    @IBAction func enableSliderForegroundGradientAction(_ sender: Any) {
        
        history.noteChange(sliderForegroundGradientBtnGroup.tag, colorSchemesManager.systemScheme.effects.sliderForegroundGradientType, sliderForegroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderForegroundGradient()
    }
    
    private func changeSliderForegroundGradient() {
        
        if btnSliderForegroundGradientEnabled.isOn {
            colorSchemesManager.systemScheme.effects.sliderForegroundGradientType = btnSliderForegroundGradientDarken.isOn ? .darken : .brighten
        } else {
            colorSchemesManager.systemScheme.effects.sliderForegroundGradientType = .none
        }
        
//        [btnSliderForegroundGradientDarken, btnSliderForegroundGradientBrighten, sliderForegroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderForegroundGradientEnabled.isOn)})
        
        sliderColorsChanged()
    }
    
    @IBAction func sliderForegroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(sliderForegroundGradientBtnGroup.tag, colorSchemesManager.systemScheme.effects.sliderForegroundGradientType, sliderForegroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderForegroundGradient()
    }
    
    @IBAction func sliderForegroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(sliderForegroundGradientAmountStepper.tag, colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount, sliderForegroundGradientAmountStepper.integerValue, .setIntValue)
        
        changeSliderForegroundGradientAmount()
    }
    
    private func changeSliderForegroundGradientAmount() {
        
        colorSchemesManager.systemScheme.effects.sliderForegroundGradientAmount = sliderForegroundGradientAmountStepper.integerValue
        lblSliderForegroundGradientAmount.stringValue = String(format: "%d%%", sliderForegroundGradientAmountStepper.integerValue)
        
        sliderColorsChanged()
    }
    
    @IBAction func sliderBackgroundColorAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundColorPicker.tag, colorSchemesManager.systemScheme.effects.sliderBackgroundColor, sliderBackgroundColorPicker.color, .changeColor)
        changeSliderBackgroundColor()
    }
    
    private func changeSliderBackgroundColor() {
        
        colorSchemesManager.systemScheme.effects.sliderBackgroundColor = sliderBackgroundColorPicker.color
        sliderColorsChanged()
    }
    
    @IBAction func enableSliderBackgroundGradientAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundGradientBtnGroup.tag, colorSchemesManager.systemScheme.effects.sliderBackgroundGradientType, sliderBackgroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderBackgroundGradient()
    }
    
    private func changeSliderBackgroundGradient() {
        
        if btnSliderBackgroundGradientEnabled.isOn {
            colorSchemesManager.systemScheme.effects.sliderBackgroundGradientType = btnSliderBackgroundGradientDarken.isOn ? .darken : .brighten
        } else {
            colorSchemesManager.systemScheme.effects.sliderBackgroundGradientType = .none
        }
        
//        [btnSliderBackgroundGradientDarken, btnSliderBackgroundGradientBrighten, sliderBackgroundGradientAmountStepper].forEach({$0?.enableIf(btnSliderBackgroundGradientEnabled.isOn)})
        
        sliderColorsChanged()
    }
    
    @IBAction func sliderBackgroundGradientBrightenOrDarkenAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundGradientBtnGroup.tag, colorSchemesManager.systemScheme.effects.sliderBackgroundGradientType, sliderBackgroundGradientBtnGroup.gradientType, .changeGradient)
        
        changeSliderBackgroundGradient()
    }
    
    @IBAction func sliderBackgroundGradientAmountAction(_ sender: Any) {
        
        history.noteChange(sliderBackgroundGradientAmountStepper.tag, colorSchemesManager.systemScheme.effects.sliderBackgroundGradientAmount, sliderBackgroundGradientAmountStepper.integerValue, .setIntValue)
        changeSliderBackgroundGradientAmount()
    }
    
    private func changeSliderBackgroundGradientAmount() {
        
        colorSchemesManager.systemScheme.effects.sliderBackgroundGradientAmount = sliderBackgroundGradientAmountStepper.integerValue
        lblSliderBackgroundGradientAmount.stringValue = String(format: "%d%%", sliderBackgroundGradientAmountStepper.integerValue)
        
        sliderColorsChanged()
    }
    
    private func sliderColorsChanged() {
        Messenger.publish(.effects_changeSliderColors)
    }
    
    @IBAction func sliderKnobColorAction(_ sender: Any) {
        
        history.noteChange(sliderKnobColorPicker.tag, colorSchemesManager.systemScheme.effects.sliderKnobColor, sliderKnobColorPicker.color, .changeColor)
        changeSliderKnobColor()
    }
    
    private func changeSliderKnobColor() {
        
        colorSchemesManager.systemScheme.effects.sliderKnobColor = sliderKnobColorPicker.color
        Messenger.publish(.effects_changeSliderColors)
    }
    
    @IBAction func sliderKnobColorSameAsForegroundAction(_ sender: Any) {
        
        history.noteChange(btnSliderKnobColorSameAsForeground.tag, colorSchemesManager.systemScheme.effects.sliderKnobColorSameAsForeground, btnSliderKnobColorSameAsForeground.isOn, .toggle)
        toggleKnobColorSameAsForeground()
    }
    
    private func toggleKnobColorSameAsForeground() {
        
        colorSchemesManager.systemScheme.effects.sliderKnobColorSameAsForeground = btnSliderKnobColorSameAsForeground.isOn
        Messenger.publish(.effects_changeSliderColors)
    }
    
    @IBAction func sliderTickColorAction(_ sender: Any) {
        
        history.noteChange(sliderTickColorPicker.tag, colorSchemesManager.systemScheme.effects.sliderTickColor, sliderTickColorPicker.color, .changeColor)
        changeSliderTickColor()
    }
    
    private func changeSliderTickColor() {
        
        colorSchemesManager.systemScheme.effects.sliderTickColor = sliderTickColorPicker.color
        Messenger.publish(.effects_changeSliderColors)
    }
    
    @IBAction func activeUnitStateColorAction(_ sender: Any) {
        
        history.noteChange(activeUnitStateColorPicker.tag, colorSchemesManager.systemScheme.effects.activeUnitStateColor, activeUnitStateColorPicker.color, .changeColor)
        changeActiveUnitStateColor()
    }
    
    private func changeActiveUnitStateColor() {
        
        colorSchemesManager.systemScheme.effects.activeUnitStateColor = activeUnitStateColorPicker.color
        Messenger.publish(.effects_changeActiveUnitStateColor, payload: activeUnitStateColorPicker.color)
    }
    
    @IBAction func bypassedUnitStateColorAction(_ sender: Any) {
        
        history.noteChange(bypassedUnitStateColorPicker.tag, colorSchemesManager.systemScheme.effects.bypassedUnitStateColor, bypassedUnitStateColorPicker.color, .changeColor)
        changeBypassedUnitStateColor()
    }
    
    private func changeBypassedUnitStateColor() {

        colorSchemesManager.systemScheme.effects.bypassedUnitStateColor = bypassedUnitStateColorPicker.color
        Messenger.publish(.effects_changeBypassedUnitStateColor, payload: bypassedUnitStateColorPicker.color)
    }
    
    @IBAction func suppressedUnitStateColorAction(_ sender: Any) {
        
        history.noteChange(suppressedUnitStateColorPicker.tag, colorSchemesManager.systemScheme.effects.suppressedUnitStateColor, suppressedUnitStateColorPicker.color, .changeColor)
        changeSuppressedUnitStateColor()
    }
    
    private func changeSuppressedUnitStateColor() {
        
        colorSchemesManager.systemScheme.effects.suppressedUnitStateColor = suppressedUnitStateColorPicker.color
        Messenger.publish(.effects_changeSuppressedUnitStateColor, payload: suppressedUnitStateColorPicker.color)
    }
}
