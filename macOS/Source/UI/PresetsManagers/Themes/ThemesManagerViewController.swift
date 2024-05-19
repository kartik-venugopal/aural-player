//
//  ThemesManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 View controller for the manager that allows the user to manage user-defined themes.
 */
class ThemesManagerViewController: PresetsManagerViewController<Theme> {
    
    // A view that gives the user a visual preview of what each theme looks like.
    override var nibName: NSNib.Name? {"ThemesManager"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        presetsManager = themesManager
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let selTheme = themesManager.userDefinedObjects[index]
        themesManager.applyTheme(selTheme)
    }
}
