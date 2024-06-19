//
//  LayoutsManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class LayoutsManagerViewController: UIPresetsManagerViewController {
    
    override var nibName: NSNib.Name? {"LayoutsManager"}
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        presetsManager = windowLayoutsManager
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let selLayout = windowLayoutsManager.userDefinedObjects[index]
        windowLayoutsManager.applyLayout(selLayout)
    }
}
