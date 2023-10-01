//
//  SettingsPopupMenuController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    private lazy var uiState: WindowAppearanceState = objectGraph.windowAppearanceState
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.font = .menuFont
        
        // These items should be enabled only if there is no modal component currently shown.
        let isShowingModalComponent: Bool = objectGraph.windowLayoutsManager.isShowingModalComponent
        [applyThemeMenuItem, saveThemeMenuItem, createThemeMenuItem, applyFontSchemeMenuItem, saveFontSchemeMenuItem, applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach {$0.enableIf(!isShowingModalComponent)}
        
        cornerRadiusStepper.integerValue = uiState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
    }
}
