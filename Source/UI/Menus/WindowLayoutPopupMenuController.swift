//
//  WindowLayoutPopupMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayoutPopupMenuController: GenericPresetPopupMenuController {
    
    private lazy var managerWindowController: UIPresetsManagerWindowController = UIPresetsManagerWindowController.instance
    
    override var descriptionOfPreset: String {"layout"}
    override var descriptionOfPreset_plural: String {"layouts"}
    
    override var userDefinedPresets: [UserManagedObject] {windowLayoutsManager.userDefinedObjects}
    override var numberOfUserDefinedPresets: Int {windowLayoutsManager.numberOfUserDefinedObjects}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        if !builtInPresetsAdded {
            
            for preset in WindowLayoutPresets.allCases {
                
                theMenu.addItem(withTitle: preset.name,
                                action: #selector(applyPresetAction(_:)),
                                target: self)
            }
            
            builtInPresetsAdded = true
        }
    }
    
    override func presetExists(named name: String) -> Bool {
        windowLayoutsManager.objectExists(named: name)
    }
    
    // Receives a new layout name and saves the new layout.
    override func addPreset(named name: String) {
        
        let newLayout = windowLayoutsManager.currentWindowLayout
        newLayout.name = name
        newLayout.type = .custom
        
        windowLayoutsManager.addObject(newLayout)
    }
    
    override func applyPreset(named name: String) {
        windowLayoutsManager.applyLayout(named: name)
    }
    
    @IBAction func manageLayoutsAction(_ sender: Any) {
        managerWindowController.showLayoutsManager()
    }
    
    override func menuNeedsUpdate(_ menu: NSMenu) {
        
        if appModeManager.currentMode == .modular {
            super.menuNeedsUpdate(menu)
        }
    }
}
