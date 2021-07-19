//
//  GeneralColorSchemeViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the view that allows the user to edit general color scheme elements.
 */
class GeneralColorSchemeViewController: ColorSchemeViewController {
    
    @IBOutlet weak var appLogoColorPicker: AuralColorPicker!
    @IBOutlet weak var backgroundColorPicker: AuralColorPicker!
    
    @IBOutlet weak var functionButtonColorPicker: AuralColorPicker!
    @IBOutlet weak var textButtonMenuColorPicker: AuralColorPicker!
    @IBOutlet weak var toggleButtonOffStateColorPicker: AuralColorPicker!
    @IBOutlet weak var selectedTabButtonColorPicker: AuralColorPicker!
    
    @IBOutlet weak var mainCaptionTextColorPicker: AuralColorPicker!
    @IBOutlet weak var tabButtonTextColorPicker: AuralColorPicker!
    @IBOutlet weak var selectedTabButtonTextColorPicker: AuralColorPicker!
    @IBOutlet weak var buttonMenuTextColorPicker: AuralColorPicker!
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var messenger = Messenger(for: self)
    
    override var nibName: NSNib.Name? {return "GeneralColorScheme"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[appLogoColorPicker.tag] = self.changeAppLogoColor
        actionsMap[backgroundColorPicker.tag] = self.changeBackgroundColor
        actionsMap[functionButtonColorPicker.tag] = self.changeFunctionButtonColor
        actionsMap[textButtonMenuColorPicker.tag] = self.changeTextButtonMenuColor
        actionsMap[toggleButtonOffStateColorPicker.tag] = self.changeToggleButtonOffStateColor
        actionsMap[selectedTabButtonColorPicker.tag] = self.changeSelectedTabButtonColor
        actionsMap[mainCaptionTextColorPicker.tag] = self.changeMainCaptionTextColor
        actionsMap[tabButtonTextColorPicker.tag] = self.changeTabButtonTextColor
        actionsMap[selectedTabButtonTextColorPicker.tag] = self.changeSelectedTabButtonTextColor
        actionsMap[buttonMenuTextColorPicker.tag] = self.changeButtonMenuTextColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
        appLogoColorPicker.color = scheme.general.appLogoColor
        backgroundColorPicker.color = scheme.general.backgroundColor
        
        functionButtonColorPicker.color = scheme.general.functionButtonColor
        textButtonMenuColorPicker.color = scheme.general.textButtonMenuColor
        toggleButtonOffStateColorPicker.color = scheme.general.toggleButtonOffStateColor
        selectedTabButtonColorPicker.color = scheme.general.selectedTabButtonColor
        
        mainCaptionTextColorPicker.color = scheme.general.mainCaptionTextColor
        tabButtonTextColorPicker.color = scheme.general.tabButtonTextColor
        selectedTabButtonTextColorPicker.color = scheme.general.selectedTabButtonTextColor
        buttonMenuTextColorPicker.color = scheme.general.buttonMenuTextColor
    }
    
    @IBAction func appLogoColorAction(_ sender: Any) {
        
        history.noteChange(appLogoColorPicker.tag, colorSchemesManager.systemScheme.general.appLogoColor, appLogoColorPicker.color, .changeColor)
        changeAppLogoColor()
    }
    
    private func changeAppLogoColor() {
        
        colorSchemesManager.systemScheme.general.appLogoColor = appLogoColorPicker.color
        messenger.publish(.changeAppLogoColor, payload: appLogoColorPicker.color)
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        history.noteChange(backgroundColorPicker.tag, colorSchemesManager.systemScheme.general.backgroundColor, backgroundColorPicker.color, .changeColor)
        changeBackgroundColor()
    }
    
    private func changeBackgroundColor() {
        
        colorSchemesManager.systemScheme.general.backgroundColor = backgroundColorPicker.color
        messenger.publish(.changeBackgroundColor, payload: backgroundColorPicker.color)
    }
    
    @IBAction func functionButtonColorAction(_ sender: Any) {
        
        history.noteChange(functionButtonColorPicker.tag, colorSchemesManager.systemScheme.general.functionButtonColor, functionButtonColorPicker.color, .changeColor)
        changeFunctionButtonColor()
    }
    
    private func changeFunctionButtonColor() {
        
        colorSchemesManager.systemScheme.general.functionButtonColor = functionButtonColorPicker.color
        messenger.publish(.changeFunctionButtonColor, payload: functionButtonColorPicker.color)
    }
    
    @IBAction func textButtonMenuColorAction(_ sender: Any) {
        
        history.noteChange(textButtonMenuColorPicker.tag, colorSchemesManager.systemScheme.general.textButtonMenuColor, textButtonMenuColorPicker.color, .changeColor)
        changeTextButtonMenuColor()
    }
    
    private func changeTextButtonMenuColor() {
        
        colorSchemesManager.systemScheme.general.textButtonMenuColor = textButtonMenuColorPicker.color
        messenger.publish(.changeTextButtonMenuColor, payload: textButtonMenuColorPicker.color)
    }
    
    @IBAction func toggleButtonOffStateColorAction(_ sender: Any) {
        
        history.noteChange(toggleButtonOffStateColorPicker.tag, colorSchemesManager.systemScheme.general.toggleButtonOffStateColor, toggleButtonOffStateColorPicker.color, .changeColor)
        changeToggleButtonOffStateColor()
    }
    
    private func changeToggleButtonOffStateColor() {
        
        colorSchemesManager.systemScheme.general.toggleButtonOffStateColor = toggleButtonOffStateColorPicker.color
        messenger.publish(.changeToggleButtonOffStateColor, payload: toggleButtonOffStateColorPicker.color)
    }
    
    @IBAction func selectedTabButtonColorAction(_ sender: Any) {
        
        history.noteChange(selectedTabButtonColorPicker.tag, colorSchemesManager.systemScheme.general.selectedTabButtonColor, selectedTabButtonColorPicker.color, .changeColor)
        changeSelectedTabButtonColor()
    }
    
    private func changeSelectedTabButtonColor() {
        
        colorSchemesManager.systemScheme.general.selectedTabButtonColor = selectedTabButtonColorPicker.color
        messenger.publish(.changeSelectedTabButtonColor, payload: selectedTabButtonColorPicker.color)
    }
    
    @IBAction func mainCaptionTextColorAction(_ sender: Any) {
        
        history.noteChange(mainCaptionTextColorPicker.tag, colorSchemesManager.systemScheme.general.mainCaptionTextColor, mainCaptionTextColorPicker.color, .changeColor)
        changeMainCaptionTextColor()
    }
    
    private func changeMainCaptionTextColor() {
        
        colorSchemesManager.systemScheme.general.mainCaptionTextColor = mainCaptionTextColorPicker.color
        messenger.publish(.changeMainCaptionTextColor, payload: mainCaptionTextColorPicker.color)
    }
    
    @IBAction func tabButtonTextColorAction(_ sender: Any) {
        
        history.noteChange(tabButtonTextColorPicker.tag, colorSchemesManager.systemScheme.general.tabButtonTextColor, tabButtonTextColorPicker.color, .changeColor)
        changeTabButtonTextColor()
    }
    
    private func changeTabButtonTextColor()	{
        
        colorSchemesManager.systemScheme.general.tabButtonTextColor = tabButtonTextColorPicker.color
        messenger.publish(.changeTabButtonTextColor, payload: tabButtonTextColorPicker.color)
    }
    
    @IBAction func selectedTabButtonTextColorAction(_ sender: Any) {
        
        history.noteChange(selectedTabButtonTextColorPicker.tag, colorSchemesManager.systemScheme.general.selectedTabButtonTextColor, selectedTabButtonTextColorPicker.color, .changeColor)
        changeSelectedTabButtonTextColor()
    }
    
    private func changeSelectedTabButtonTextColor()    {
        
        colorSchemesManager.systemScheme.general.selectedTabButtonTextColor = selectedTabButtonTextColorPicker.color
        messenger.publish(.changeSelectedTabButtonTextColor, payload: selectedTabButtonTextColorPicker.color)
    }
    
    @IBAction func buttonMenuTextColorAction(_ sender: Any) {
        
        history.noteChange(buttonMenuTextColorPicker.tag, colorSchemesManager.systemScheme.general.buttonMenuTextColor, buttonMenuTextColorPicker.color, .changeColor)
        changeButtonMenuTextColor()
    }
    
    private func changeButtonMenuTextColor() {
        
        colorSchemesManager.systemScheme.general.buttonMenuTextColor = buttonMenuTextColorPicker.color
        messenger.publish(.changeButtonMenuTextColor, payload: buttonMenuTextColorPicker.color)
    }
}
