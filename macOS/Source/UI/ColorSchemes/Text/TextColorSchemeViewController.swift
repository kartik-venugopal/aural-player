//
//  TextColorSchemeViewController.swift
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
class TextColorSchemeViewController: ColorSchemeViewController {
    
    override var nibName: NSNib.Name? {"TextColorScheme"}
    
    @IBOutlet weak var captionColorPicker: AuralColorPicker!
    
    @IBOutlet weak var primaryTextColorPicker: AuralColorPicker!
    @IBOutlet weak var secondaryTextColorPicker: AuralColorPicker!
    @IBOutlet weak var tertiaryTextColorPicker: AuralColorPicker!
    
    @IBOutlet weak var primarySelectedTextColorPicker: AuralColorPicker!
    @IBOutlet weak var secondarySelectedTextColorPicker: AuralColorPicker!
    @IBOutlet weak var tertiarySelectedTextColorPicker: AuralColorPicker!
    
    @IBOutlet weak var textSelectionColorPicker: AuralColorPicker!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Map control tags to their corresponding undo/redo actions
        
        actionsMap[captionColorPicker.tag] = changeCaptionColor
        
        actionsMap[primaryTextColorPicker.tag] = changePrimaryTextColor
        actionsMap[secondaryTextColorPicker.tag] = changeSecondaryTextColor
        actionsMap[tertiaryTextColorPicker.tag] = changeTertiaryTextColor
        
        actionsMap[primarySelectedTextColorPicker.tag] = changePrimarySelectedTextColor
        actionsMap[secondarySelectedTextColorPicker.tag] = changeSecondarySelectedTextColor
        actionsMap[tertiarySelectedTextColorPicker.tag] = changeTertiarySelectedTextColor
        
        actionsMap[textSelectionColorPicker.tag] = changeTextSelectionColor
    }
    
    override func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard) {
        
        super.resetFields(scheme, history, clipboard)
        
        // Update the UI to reflect the current system color scheme
        
        captionColorPicker.color = systemColorScheme.captionTextColor
        
        primaryTextColorPicker.color = systemColorScheme.primaryTextColor
        secondaryTextColorPicker.color = systemColorScheme.secondaryTextColor
        tertiaryTextColorPicker.color = systemColorScheme.tertiaryTextColor
        
        primarySelectedTextColorPicker.color = systemColorScheme.primarySelectedTextColor
        secondarySelectedTextColorPicker.color = systemColorScheme.secondarySelectedTextColor
        tertiarySelectedTextColorPicker.color = systemColorScheme.tertiarySelectedTextColor
        
        textSelectionColorPicker.color = systemColorScheme.textSelectionColor
    }
    
    @IBAction func captionColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: captionColorPicker.tag, undoValue: systemColorScheme.captionTextColor,
                                             redoValue: captionColorPicker.color, changeType: .changeColor))
        changeCaptionColor()
    }
    
    private func changeCaptionColor() {
        
        systemColorScheme.captionTextColor = captionColorPicker.color
        colorSchemesManager.propertyChanged(\.captionTextColor)
    }
    
    @IBAction func primaryTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: primaryTextColorPicker.tag, undoValue: systemColorScheme.primaryTextColor,
                                             redoValue: primaryTextColorPicker.color, changeType: .changeColor))
        changePrimaryTextColor()
    }
    
    private func changePrimaryTextColor() {
        
        systemColorScheme.primaryTextColor = primaryTextColorPicker.color
        colorSchemesManager.propertyChanged(\.primaryTextColor)
    }
    
    @IBAction func secondaryTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: secondaryTextColorPicker.tag, undoValue: systemColorScheme.secondaryTextColor,
                                             redoValue: secondaryTextColorPicker.color, changeType: .changeColor))
        changeSecondaryTextColor()
    }
    
    private func changeSecondaryTextColor() {
        
        systemColorScheme.secondaryTextColor = secondaryTextColorPicker.color
        colorSchemesManager.propertyChanged(\.secondaryTextColor)
    }
    
    @IBAction func tertiaryTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: tertiaryTextColorPicker.tag, undoValue: systemColorScheme.tertiaryTextColor,
                                             redoValue: tertiaryTextColorPicker.color, changeType: .changeColor))
        changeTertiaryTextColor()
    }
    
    private func changeTertiaryTextColor() {
        
        systemColorScheme.tertiaryTextColor = tertiaryTextColorPicker.color
        colorSchemesManager.propertyChanged(\.tertiaryTextColor)
    }
    
    @IBAction func primarySelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: primarySelectedTextColorPicker.tag, undoValue: systemColorScheme.primarySelectedTextColor,
                                             redoValue: primarySelectedTextColorPicker.color, changeType: .changeColor))
        changePrimarySelectedTextColor()
    }
    
    private func changePrimarySelectedTextColor() {
        
        systemColorScheme.primarySelectedTextColor = primarySelectedTextColorPicker.color
        colorSchemesManager.propertyChanged(\.primarySelectedTextColor)
    }
    
    @IBAction func secondarySelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: secondarySelectedTextColorPicker.tag, undoValue: systemColorScheme.secondarySelectedTextColor,
                                             redoValue: secondarySelectedTextColorPicker.color, changeType: .changeColor))
        changeSecondarySelectedTextColor()
    }
    
    private func changeSecondarySelectedTextColor() {
        
        systemColorScheme.secondarySelectedTextColor = secondarySelectedTextColorPicker.color
        colorSchemesManager.propertyChanged(\.secondarySelectedTextColor)
    }
    
    @IBAction func tertiarySelectedTextColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: tertiarySelectedTextColorPicker.tag, undoValue: systemColorScheme.tertiarySelectedTextColor,
                                             redoValue: tertiarySelectedTextColorPicker.color, changeType: .changeColor))
        changeTertiarySelectedTextColor()
    }
    
    private func changeTertiarySelectedTextColor() {
        
        systemColorScheme.tertiarySelectedTextColor = tertiarySelectedTextColorPicker.color
        colorSchemesManager.propertyChanged(\.tertiarySelectedTextColor)
    }
    
    @IBAction func textSelectionColorAction(_ sender: Any) {
        
        history.noteChange(ColorSchemeChange(tag: textSelectionColorPicker.tag, undoValue: systemColorScheme.textSelectionColor,
                                             redoValue: textSelectionColorPicker.color, changeType: .changeColor))
        changeTextSelectionColor()
    }
    
    private func changeTextSelectionColor() {
        
        systemColorScheme.textSelectionColor = textSelectionColorPicker.color
        colorSchemesManager.propertyChanged(\.textSelectionColor)
    }
}
