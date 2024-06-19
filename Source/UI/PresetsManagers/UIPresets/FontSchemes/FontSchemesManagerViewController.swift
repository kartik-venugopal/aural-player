//
//  FontSchemesManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 View controller for the manager that allows the user to manage user-defined font schemes.
 */
class FontSchemesManagerViewController: UIPresetsManagerViewController {
    
    override var nibName: NSNib.Name? {"FontSchemesManager"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        presetsManager = fontSchemesManager
    }
    
    // Applies the selected font scheme to the system.
    override func applyPreset(atIndex index: Int) {
        
        let selScheme = fontSchemesManager.userDefinedObjects[index]
        fontSchemesManager.applyScheme(selScheme)
    }
}
