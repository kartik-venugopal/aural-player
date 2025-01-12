//
//  GeneralColorSchemeViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the view that allows the user to edit general color scheme elements.
 */
class GeneralColorSchemeViewController: ColorSchemeViewController {
    
    override var nibName: NSNib.Name? {"GeneralColorScheme"}
    
    @IBOutlet weak var backgroundColorPicker: AuralColorPicker!
    @IBOutlet weak var buttonColorPicker: AuralColorPicker!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[backgroundColorPicker.tag] = changeBackgroundColor
        actionsMap[buttonColorPicker.tag] = changeButtonColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
        backgroundColorPicker.color = systemColorScheme.backgroundColor
        buttonColorPicker.color = systemColorScheme.buttonColor
    }
    
    @IBAction func backgroundColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: backgroundColorPicker.tag, undoValue: systemColorScheme.backgroundColor,
                                             redoValue: backgroundColorPicker.color, changeType: .changeColor))
        changeBackgroundColor()
    }
    
    private func changeBackgroundColor() {
        
        systemColorScheme.backgroundColor = backgroundColorPicker.color
        colorSchemesManager.propertyChanged(\.backgroundColor)
    }
    
    @IBAction func buttonColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: buttonColorPicker.tag, undoValue: systemColorScheme.buttonColor,
                                             redoValue: buttonColorPicker.color, changeType: .changeColor))
        changeButtonColor()
    }
    
    private func changeButtonColor() {
        
        systemColorScheme.buttonColor = buttonColorPicker.color
        colorSchemesManager.propertyChanged(\.buttonColor)
    }
}
