//
//  EffectsPresetsManagerWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit
class EffectsPresetsManagerWindowController: NSWindowController {
    
    override var windowNibName: NSNib.Name? {"EffectsPresetsManager"}
    
    @IBOutlet weak var viewController: EffectsPresetsManagerViewController!
    @IBOutlet weak var toolbar: NSToolbar!
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
    }
    
    override func showWindow(_ sender: Any?) {
        
        super.showWindow(sender)
        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier("Master")
        
        window?.showCenteredOnScreen()
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        window?.close()
    }
}
