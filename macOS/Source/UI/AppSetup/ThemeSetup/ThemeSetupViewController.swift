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
    
    override var nibName: String? {"ThemeSetup"}
    
    @IBOutlet weak var btnFontScheme: NSPopUpButton!
    @IBOutlet weak var btnColorScheme: NSPopUpButton!
    
    @IBOutlet weak var previewView: AppSetupThemePreviewView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

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
        let colorSchemePreset = ColorSchemePreset.presetByName(selSchemeName) else {return}
        
        previewView.colorScheme = scheme
        
        appSetup.colorSchemePreset = colorSchemePreset
        print("Set color scheme to: \(appSetup.colorSchemePreset.rawValue)")
    }
    
    @IBAction func fontSchemeSelectionAction(_ sender: Any) {
        
        guard let selSchemeName = btnFontScheme.titleOfSelectedItem,
              let scheme = fontSchemesManager.systemDefinedObject(named: selSchemeName),
              let preset = FontSchemePreset.presetByName(selSchemeName) else {return}
        
        previewView.fontScheme = scheme
        
        appSetup.fontSchemePreset = preset
        print("Set font scheme to: \(appSetup.fontSchemePreset.rawValue)")
    }
}
