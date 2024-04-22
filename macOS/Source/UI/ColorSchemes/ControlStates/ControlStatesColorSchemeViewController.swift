//
//  ControlStatesColorSchemeViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the view that allows the user to edit general color scheme elements.
 */
class ControlStatesColorSchemeViewController: ColorSchemeViewController {
    
    override var nibName: NSNib.Name? {"ControlStatesColorScheme"}
    
    @IBOutlet weak var activeControlColorPicker: AuralColorPicker!
    @IBOutlet weak var inactiveControlColorPicker: AuralColorPicker!
    @IBOutlet weak var suppressedControlColorPicker: AuralColorPicker!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[activeControlColorPicker.tag] = changeActiveControlColor
        actionsMap[inactiveControlColorPicker.tag] = changeInactiveControlColor
        actionsMap[suppressedControlColorPicker.tag] = changeSuppressedControlColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
        activeControlColorPicker.color = systemColorScheme.activeControlColor
        inactiveControlColorPicker.color = systemColorScheme.inactiveControlColor
        suppressedControlColorPicker.color = systemColorScheme.suppressedControlColor
    }
    
    @IBAction func activeControlColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: activeControlColorPicker.tag, undoValue: systemColorScheme.activeControlColor,
                                             redoValue: activeControlColorPicker.color, changeType: .changeColor))
        changeActiveControlColor()
    }
    
    private func changeActiveControlColor() {
        
        systemColorScheme.activeControlColor = activeControlColorPicker.color
        colorSchemesManager.propertyChanged(\.activeControlColor)
    }
    
    @IBAction func inactiveControlColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: inactiveControlColorPicker.tag, undoValue: systemColorScheme.inactiveControlColor,
                                             redoValue: inactiveControlColorPicker.color, changeType: .changeColor))
        changeInactiveControlColor()
    }
    
    private func changeInactiveControlColor() {
        
        systemColorScheme.inactiveControlColor = inactiveControlColorPicker.color
        colorSchemesManager.propertyChanged(\.inactiveControlColor)
    }
    
    @IBAction func suppressedControlColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: suppressedControlColorPicker.tag, undoValue: systemColorScheme.suppressedControlColor,
                                             redoValue: suppressedControlColorPicker.color, changeType: .changeColor))
        changeSuppressedControlColor()
    }
    
    private func changeSuppressedControlColor() {
        
        systemColorScheme.suppressedControlColor = suppressedControlColorPicker.color
        colorSchemesManager.propertyChanged(\.suppressedControlColor)
    }
}
