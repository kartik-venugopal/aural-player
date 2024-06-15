//
//  ViewMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Provides actions for the View menu that alters the layout of the app's windows and views.
 
    NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
 */
class ViewMenuController: NSObject, NSMenuDelegate {
    
    // Menu items whose states are toggled when they (or others) are clicked
    @IBOutlet weak var togglePlayQueueMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    @IBOutlet weak var toggleChaptersListMenuItem: NSMenuItem!
    @IBOutlet weak var toggleVisualizerMenuItem: NSMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        toggleChaptersListMenuItem.enableIf(playbackInfoDelegate.chapterCount > 0)
        
//        let showingModalComponent: Bool = windowLayoutsManager.isShowingModalComponent
        
//        [applyThemeMenuItem, saveThemeMenuItem, createThemeMenuItem].forEach {$0.enableIf(!showingModalComponent)}
//        manageThemesMenuItem.enableIf(!showingModalComponent && (themesManager.numberOfUserDefinedObjects > 0))
//        
//        [applyFontSchemeMenuItem, saveFontSchemeMenuItem].forEach {$0.enableIf(!showingModalComponent)}
//        manageFontSchemesMenuItem.enableIf(!showingModalComponent && (fontSchemesManager.numberOfUserDefinedObjects > 0))
//        
//        [applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach {$0.enableIf(!showingModalComponent)}
//        manageColorSchemesMenuItem.enableIf(!showingModalComponent && (colorSchemesManager.numberOfUserDefinedObjects > 0))
        
        //        manageLayoutsMenuItem.enableIf(!windowLayoutsManager.userDefinedObjects.isEmpty)
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
//        [togglePlayQueueMenuItem, toggleEffectsMenuItem].forEach {$0?.show()}
        
        togglePlayQueueMenuItem.onIf(appModeManager.isShowingPlayQueue)
        toggleEffectsMenuItem.onIf(appModeManager.isShowingEffects)
        toggleChaptersListMenuItem.onIf(appModeManager.isShowingChaptersList)
        toggleVisualizerMenuItem.onIf(appModeManager.isShowingVisualizer)
        
        cornerRadiusStepper.integerValue = playerUIState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
 
    // Shows/hides the playlist window
    @IBAction func togglePlayQueueAction(_ sender: NSMenuItem) {
        Messenger.publish(.View.togglePlayQueue)
    }
    
    // Shows/hides the effects window
    @IBAction func toggleEffectsAction(_ sender: NSMenuItem) {
        Messenger.publish(.View.toggleEffects)
    }
    
    // Shows/hides the chapters list window
    @IBAction func toggleChaptersListAction(_ sender: NSMenuItem) {
        Messenger.publish(.View.toggleChaptersList)
    }
    
    @IBAction func toggleVisualizerAction(_ sender: NSMenuItem) {
        Messenger.publish(.View.toggleVisualizer)
    }
    
    @IBAction func toggleTrackInfoAction(_ sender: AnyObject) {
        Messenger.publish(.View.toggleTrackInfo)
    }
}
