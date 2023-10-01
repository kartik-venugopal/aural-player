//
//  ViewMenuController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    private let audioGraph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    private lazy var themesManager: ThemesManager = objectGraph.themesManager
    private lazy var fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    private lazy var colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private lazy var uiState: WindowAppearanceState = objectGraph.windowAppearanceState
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        manageLayoutsMenuItem.enableIf(!windowLayoutsManager.userDefinedObjects.isEmpty)
        toggleChaptersListMenuItem.enableIf(player.chapterCount > 0)
        
        let showingModalComponent: Bool = objectGraph.windowLayoutsManager.isShowingModalComponent
        
        [applyThemeMenuItem, saveThemeMenuItem, createThemeMenuItem].forEach {$0.enableIf(!showingModalComponent)}
        manageThemesMenuItem.enableIf(!showingModalComponent && (themesManager.numberOfUserDefinedObjects > 0))
        
        [applyFontSchemeMenuItem, saveFontSchemeMenuItem].forEach {$0.enableIf(!showingModalComponent)}
        manageFontSchemesMenuItem.enableIf(!showingModalComponent && (fontSchemesManager.numberOfUserDefinedObjects > 0))
        
        [applyColorSchemeMenuItem, saveColorSchemeMenuItem].forEach {$0.enableIf(!showingModalComponent)}
        manageColorSchemesMenuItem.enableIf(!showingModalComponent && (colorSchemesManager.numberOfUserDefinedObjects > 0))
        
        // To prevent invalid sample rates if the visualizer is launched immediately upon app startup ... give the audio engine a few seconds to start up.
        toggleVisualizerMenuItem.enableIf(windowLayoutsManager.isShowingVisualizer || audioGraph.outputDeviceSampleRate > 1000)
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuWillOpen(_ menu: NSMenu) {
        
        [togglePlaylistMenuItem, toggleEffectsMenuItem].forEach {$0?.show()}
        
        togglePlaylistMenuItem.onIf(windowLayoutsManager.isShowingPlaylist)
        toggleEffectsMenuItem.onIf(windowLayoutsManager.isShowingEffects)
        toggleChaptersListMenuItem.onIf(windowLayoutsManager.isShowingChaptersList)
        toggleVisualizerMenuItem.onIf(windowLayoutsManager.isShowingVisualizer)
        
        playerViewMenuItem.off()
        
        cornerRadiusStepper.integerValue = uiState.cornerRadius.roundedInt
        lblCornerRadius.stringValue = "\(cornerRadiusStepper.integerValue) px"
    }
 
    // Shows/hides the playlist window
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        windowLayoutsManager.togglePlaylistWindow()
    }
    
    // Shows/hides the effects window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleEffectsWindow()
    }
    
    // Shows/hides the chapters list window
    @IBAction func toggleChaptersListAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleChaptersListWindow()
    }
    
    @IBAction func toggleVisualizerAction(_ sender: AnyObject) {
        windowLayoutsManager.toggleVisualizerWindow()
    }
}
