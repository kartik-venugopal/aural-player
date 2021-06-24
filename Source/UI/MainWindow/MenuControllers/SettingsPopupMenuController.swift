//
//  SettingsPopupMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the settings popup menu on the main window.
 */
class SettingsPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var applyThemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveThemeMenuItem: NSMenuItem!
    @IBOutlet weak var createThemeMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyFontSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveFontSchemeMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveColorSchemeMenuItem: NSMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // These items should be enabled only if there is no modal component currently shown.
        [applyThemeMenuItem, saveThemeMenuItem, createThemeMenuItem, applyFontSchemeMenuItem, saveFontSchemeMenuItem, applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach {$0.enableIf(!WindowManager.instance.isShowingModalComponent)}
        
        cornerRadiusStepper.integerValue = WindowAppearanceState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
    }
}
