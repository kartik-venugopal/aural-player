//
//  ViewMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    @IBOutlet weak var togglePlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var toggleEffectsMenuItem: NSMenuItem!
    @IBOutlet weak var toggleChaptersListMenuItem: NSMenuItem!
    @IBOutlet weak var toggleVisualizerMenuItem: NSMenuItem!
    
    @IBOutlet weak var playerViewMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyThemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveThemeMenuItem: NSMenuItem!
    @IBOutlet weak var createThemeMenuItem: NSMenuItem!
    @IBOutlet weak var manageThemesMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyFontSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveFontSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var manageFontSchemesMenuItem: NSMenuItem!
    
    @IBOutlet weak var applyColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var saveColorSchemeMenuItem: NSMenuItem!
    @IBOutlet weak var manageColorSchemesMenuItem: NSMenuItem!
    
    @IBOutlet weak var manageLayoutsMenuItem: NSMenuItem!
    
    @IBOutlet weak var cornerRadiusStepper: NSStepper!
    @IBOutlet weak var lblCornerRadius: NSTextField!
    
    private let player: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    private lazy var themesManager: ThemesManager = objectGraph.themesManager
    private lazy var fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private lazy var colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var windowLayoutState: WindowLayoutState = objectGraph.windowLayoutState
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        manageLayoutsMenuItem.enableIf(!windowLayoutsManager.userDefinedPresets.isEmpty)
        toggleChaptersListMenuItem.enableIf(player.chapterCount > 0)
        
        let showingModalComponent: Bool = objectGraph.windowLayoutState.isShowingModalComponent
        
        [applyThemeMenuItem, saveThemeMenuItem, createThemeMenuItem].forEach({$0.enableIf(!showingModalComponent)})
        manageThemesMenuItem.enableIf(!showingModalComponent && (themesManager.numberOfUserDefinedPresets > 0))
        
        [applyFontSchemeMenuItem, saveFontSchemeMenuItem].forEach({$0.enableIf(!showingModalComponent)})
        manageFontSchemesMenuItem.enableIf(!showingModalComponent && (fontSchemesManager.numberOfUserDefinedPresets > 0))
        
        [applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach({$0.enableIf(!showingModalComponent)})
        manageColorSchemesMenuItem.enableIf(!showingModalComponent && (colorSchemesManager.numberOfUserDefinedPresets > 0))
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach({$0?.show()})
        
        togglePlaylistMenuItem.onIf(windowLayoutState.isShowingPlaylist)
        toggleEffectsMenuItem.onIf(windowLayoutState.isShowingEffects)
        toggleChaptersListMenuItem.onIf(windowLayoutState.isShowingChaptersList)
        toggleVisualizerMenuItem.onIf(windowLayoutState.isShowingVisualizer)
        
        playerViewMenuItem.off()
        
        cornerRadiusStepper.integerValue = WindowAppearanceState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
    }
 
    // Shows/hides the playlist window
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        messenger.publish(.windowManager_togglePlaylistWindow)
    }
    
    // Shows/hides the effects window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        messenger.publish(.windowManager_toggleEffectsWindow)
    }
    
    // Shows/hides the chapters list window
    @IBAction func toggleChaptersListAction(_ sender: AnyObject) {
        messenger.publish(.windowManager_toggleChaptersListWindow)
    }
    
    @IBAction func toggleVisualizerAction(_ sender: AnyObject) {
        messenger.publish(.windowManager_toggleVisualizerWindow)
    }
    
    @IBAction func toggleTuneBrowserAction(_ sender: AnyObject) {
        messenger.publish(.windowManager_toggleTuneBrowserWindow)
    }
}
