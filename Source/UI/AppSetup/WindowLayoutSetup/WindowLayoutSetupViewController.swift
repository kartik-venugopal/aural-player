//
//  WindowLayoutSetupViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class WindowLayoutSetupViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"WindowLayoutSetup"}
    
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblDescription: NSTextField!
    @IBOutlet weak var btnLayout: NSPopUpButton!
    @IBOutlet weak var previewView: PresetLayoutPreviewView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let defaultLayoutName = appSetup.windowLayoutPreset.name
        
        lblName.stringValue = defaultLayoutName
        lblDescription.stringValue = WindowLayoutPresets.defaultLayout.description
        
        previewView.drawPreviewForPreset(.defaultLayout)
        btnLayout.selectItem(withTitle: defaultLayoutName)
    }
    
    @IBAction func layoutSelectionAction(_ sender: Any) {
        
        guard let selLayoutName = btnLayout.titleOfSelectedItem,
              let preset = WindowLayoutPresets.fromDisplayName(selLayoutName) else {return}
        
        lblName.stringValue = selLayoutName
        lblDescription.stringValue = preset.description
        
        previewView.drawPreviewForPreset(preset)
        appSetup.windowLayoutPreset = preset
        
        print("Set window layout to: \(appSetup.windowLayoutPreset.rawValue)")
    }
}
