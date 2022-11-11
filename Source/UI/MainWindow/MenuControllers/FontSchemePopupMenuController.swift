//
//  FontSchemePopupMenuController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the popup menu that lists the available font schemes and opens the font scheme editor panel.
 */
class FontSchemePopupMenuController: GenericPresetPopupMenuController {
    
    private lazy var customizationDialogController: FontSchemesWindowController = FontSchemesWindowController.instance
    private lazy var managerWindowController: PresetsManagerWindowController = PresetsManagerWindowController.instance
    
    private lazy var fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    override var descriptionOfPreset: String {"font scheme"}
    override var descriptionOfPreset_plural: String {"font schemes"}
    
    override var userDefinedPresets: [UserManagedObject] {fontSchemesManager.userDefinedObjects}
    override var numberOfUserDefinedPresets: Int {fontSchemesManager.numberOfUserDefinedObjects}
    
    override func presetExists(named name: String) -> Bool {
        fontSchemesManager.objectExists(named: name)
    }
    
    // Receives a new font scheme name and saves the new scheme
    override func addPreset(named name: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let newScheme: FontScheme = FontScheme(name, false, fontSchemesManager.systemScheme)
        fontSchemesManager.addObject(newScheme)
    }
    
    override func applyPreset(named name: String) {
        fontSchemesManager.applyScheme(named: name)
    }
    
    @IBAction func customizeFontSchemeAction(_ sender: NSMenuItem) {
        _ = customizationDialogController.showDialog()
    }
    
    @IBAction func manageSchemesAction(_ sender: NSMenuItem) {
        managerWindowController.showFontSchemesManager()
    }
    
    deinit {
        FontSchemesWindowController.destroy()
    }
}
