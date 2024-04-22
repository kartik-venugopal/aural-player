//
//  WindowLayoutPopupMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayoutPopupMenuController: GenericPresetPopupMenuController {

    private lazy var managerWindowController: PresetsManagerWindowController = PresetsManagerWindowController.instance
    
    override var descriptionOfPreset: String {"layout"}
    override var descriptionOfPreset_plural: String {"layouts"}
    
    override var userDefinedPresets: [UserManagedObject] {windowLayoutsManager.userDefinedObjects}
    override var numberOfUserDefinedPresets: Int {windowLayoutsManager.numberOfUserDefinedObjects}
    
    override func presetExists(named name: String) -> Bool {
        windowLayoutsManager.objectExists(named: name)
    }
    
    // Receives a new layout name and saves the new layout.
    override func addPreset(named name: String) {
        
        let newLayout = windowLayoutsManager.currentWindowLayout
        newLayout.name = name
        newLayout.systemDefined = false
        
        windowLayoutsManager.addObject(newLayout)
    }
    
    override func applyPreset(named name: String) {
        windowLayoutsManager.applyLayout(named: name)
    }
    
    @IBAction func manageLayoutsAction(_ sender: Any) {
        managerWindowController.showLayoutsManager()
    }
}
