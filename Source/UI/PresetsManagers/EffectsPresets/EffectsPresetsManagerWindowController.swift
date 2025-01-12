//
//  EffectsPresetsManagerWindowController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit
class EffectsPresetsManagerWindowController: SingletonWindowController {
    
    override var windowNibName: NSNib.Name? {"EffectsPresetsManager"}
    
    @IBOutlet weak var viewController: EffectsPresetsManagerViewController!
    @IBOutlet weak var toolbar: NSToolbar!
    
    @IBOutlet weak var masterUnitToolbarItem: NSToolbarItem!
    @IBOutlet weak var eqUnitToolbarItem: NSToolbarItem!
    @IBOutlet weak var pitchShiftUnitToolbarItem: NSToolbarItem!
    @IBOutlet weak var timeStretchUnitToolbarItem: NSToolbarItem!
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("Master")
        
        masterUnitToolbarItem.image = .imgMasterUnit.withSymbolConfiguration(.init(scale: .small))
        
        if System.osVersion.majorVersion == 11 {
            
            [eqUnitToolbarItem, pitchShiftUnitToolbarItem, timeStretchUnitToolbarItem].forEach {
                $0?.image = $0?.image?.withSymbolConfiguration(.init(scale: .small))
            }
        }
        
        window?.showCenteredOnScreen()
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        window?.close()
    }
}
