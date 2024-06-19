//
//  ColorSchemesManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 View controller for the manager that allows the user to manage user-defined color schemes.
 */
class ColorSchemesManagerViewController: UIPresetsManagerViewController {
    
    override var nibName: NSNib.Name? {"ColorSchemesManager"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        presetsManager = colorSchemesManager
    }
    
    // Applies the selected font scheme to the system.
    override func applyPreset(atIndex index: Int) {
        
        let selScheme = colorSchemesManager.userDefinedObjects[index]
        colorSchemesManager.applyScheme(selScheme)
    }
}
