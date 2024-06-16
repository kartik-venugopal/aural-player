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
    @IBOutlet weak var togglePlayerMenuItem: NSMenuItem!
    @IBOutlet weak var togglePlayQueueMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    @IBOutlet weak var toggleChaptersListMenuItem: NSMenuItem!
    @IBOutlet weak var toggleTrackInfoMenuItem: NSMenuItem!
    @IBOutlet weak var toggleVisualizerMenuItem: NSMenuItem!
    
    @IBOutlet weak var manageThemesMenuItem: NSMenuItem!
    @IBOutlet weak var createThemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveCurrentThemeMenuItem: NSMenuItem!
    
    @IBOutlet weak var manageFontSchemesMenuItem: NSMenuItem!
    @IBOutlet weak var saveCurrentFontSchemeMenuItem: NSMenuItem!
    
    @IBOutlet weak var manageColorSchemesMenuItem: NSMenuItem!
    @IBOutlet weak var saveCurrentColorSchemeMenuItem: NSMenuItem!
    
    @IBOutlet weak var windowLayoutsMenuItem: NSMenuItem!
    @IBOutlet weak var saveCurrentWindowLayoutMenuItem: NSMenuItem!
    @IBOutlet weak var manageWindowLayoutsMenuItem: NSMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        toggleChaptersListMenuItem.enableIf(playbackInfoDelegate.chapterCount > 0)
        
        let isCompactMode = appModeManager.currentMode == .compact
        toggleTrackInfoMenuItem.showIf(isCompactMode)
        
        manageWindowLayoutsMenuItem?.enableIf(windowLayoutsManager.numberOfUserDefinedObjects > 0)
        manageThemesMenuItem?.enableIf(themesManager.numberOfUserDefinedObjects > 0)
        manageFontSchemesMenuItem?.enableIf(fontSchemesManager.numberOfUserDefinedObjects > 0)
        manageColorSchemesMenuItem?.enableIf(colorSchemesManager.numberOfUserDefinedObjects > 0)
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        let isCompactMode = appModeManager.currentMode == .compact
        
        togglePlayerMenuItem.showIf(isCompactMode)
        togglePlayerMenuItem.onIf(isCompactMode && compactPlayerUIState.displayedView == .player)
        togglePlayQueueMenuItem.onIf(appModeManager.isShowingPlayQueue)
        toggleEffectsMenuItem.onIf(appModeManager.isShowingEffects)
        toggleChaptersListMenuItem.onIf(appModeManager.isShowingChaptersList)
        toggleVisualizerMenuItem.onIf(appModeManager.isShowingVisualizer)
        
        if appModeManager.currentMode == .compact {
            
            let isPlaying = playbackInfoDelegate.state.isPlayingOrPaused
            let isShowingTrackInfo = appModeManager.isShowingTrackInfo

            toggleTrackInfoMenuItem.onIf(isShowingTrackInfo)
            toggleTrackInfoMenuItem.enableIf(isShowingTrackInfo || isPlaying)
        }
        
        // Can't save current theme/scheme in Compact mode (can't customize, so saving is irrelevant)
        [createThemeMenuItem, saveCurrentThemeMenuItem, saveCurrentFontSchemeMenuItem, saveCurrentColorSchemeMenuItem].forEach {
            $0?.showIf(!isCompactMode)
        }
        
        // Window Layouts only relevant in Modular mode
        [windowLayoutsMenuItem, saveCurrentWindowLayoutMenuItem, manageWindowLayoutsMenuItem].forEach {
            $0?.showIf(appModeManager.currentMode == .modular)
        }
        
        cornerRadiusStepper.integerValue = playerUIState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue)px"
    }
    
    // Compact mode only
    @IBAction func showPlayerAction(_ sender: NSMenuItem) {
        Messenger.publish(.View.CompactPlayer.showPlayer)
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
