//
//  SettingsPopupMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the settings popup menu on the main window.
 */
class SettingsPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var showPlayQueueMenuItem: NSMenuItem!
//    @IBOutlet weak var showLibraryMenuItem: NSMenuItem!
    @IBOutlet weak var showEffectsMenuItem: NSMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.font = .menuFont
        
        showPlayQueueMenuItem.onIf(windowLayoutsManager.isShowingPlayQueue)
//        showLibraryMenuItem.onIf(windowLayoutsManager.isShowingLibrary)
        showEffectsMenuItem.onIf(windowLayoutsManager.isShowingEffects)
        
        // These items should be enabled only if there is no modal component currently shown.
//        let isShowingModalComponent: Bool = windowLayoutsManager.isShowingModalComponent
//        [applyThemeMenuItem, saveThemeMenuItem, createThemeMenuItem, applyFontSchemeMenuItem, saveFontSchemeMenuItem, applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach {$0.enableIf(!isShowingModalComponent)}
        
        cornerRadiusStepper.integerValue = playerUIState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
    
    // Shows/hides the play queue window (by delegating)
    @IBAction func togglePlayQueueAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleWindow(withId: .playQueue)
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleWindow(withId: .effects)
    }
    
    // Shows/hides the library window (by delegating)
//    @IBAction func toggleLibraryAction(_ sender: AnyObject) {
//        windowLayoutsManager.toggleWindow(withId: .library)
//    }
}
