//
//  ColorSchemeSetupViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class ThemeSetupViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"ThemeSetup"}
    
    @IBOutlet weak var btnFontScheme: NSPopUpButton!
    @IBOutlet weak var btnColorScheme: NSPopUpButton!
    
    @IBOutlet weak var previewView: AppSetupThemePreviewView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btnFontScheme.menu?.removeAllItems()
        
        for scheme in FontScheme.allSystemDefinedSchemes {
            btnFontScheme.menu?.addItem(withTitle: scheme.name)
        }
        
        btnColorScheme.menu?.removeAllItems()
        
        for scheme in ColorScheme.allSystemDefinedSchemes {
            btnColorScheme.menu?.addItem(withTitle: scheme.name)
        }

        let fontSchemeName = appSetup.fontSchemePreset.name
        let colorSchemeName = appSetup.colorSchemePreset.name
        
        previewView.fontScheme = fontSchemesManager.systemDefinedObject(named: fontSchemeName)
        previewView.colorScheme = colorSchemesManager.systemDefinedObject(named: colorSchemeName)
        
        btnFontScheme.selectItem(withTitle: fontSchemeName)
        btnColorScheme.selectItem(withTitle: colorSchemeName)
    }
    
    @IBAction func colorSchemeSelectionAction(_ sender: Any) {
        
        guard let selSchemeName = btnColorScheme.titleOfSelectedItem,
              let scheme = colorSchemesManager.systemDefinedObject(named: selSchemeName),
        let preset = ColorSchemePreset.presetByName(selSchemeName) else {return}
        
        previewView.colorScheme = scheme
        appSetup.colorSchemePreset = preset
    }
    
    @IBAction func fontSchemeSelectionAction(_ sender: Any) {
        
        guard let selSchemeName = btnFontScheme.titleOfSelectedItem,
              let scheme = fontSchemesManager.systemDefinedObject(named: selSchemeName),
              let preset = FontSchemePreset.presetByName(selSchemeName) else {return}
        
        previewView.fontScheme = scheme
        appSetup.fontSchemePreset = preset
    }
}
