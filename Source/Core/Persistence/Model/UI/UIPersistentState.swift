//
//  UIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all persistent state for the application UI.
///
struct UIPersistentState: Codable {
    
    let appMode: AppMode?
    
    let windowLayout: WindowLayoutsPersistentState?
    let themes: ThemesPersistentState?
    let fontSchemes: FontSchemesPersistentState?
    let colorSchemes: ColorSchemesPersistentState?
    
    let modularPlayer: ModularPlayerUIPersistentState?
    let unifiedPlayer: UnifiedPlayerUIPersistentState?
    let menuBarPlayer: MenuBarPlayerUIPersistentState?
    let widgetPlayer: WidgetPlayerUIPersistentState?
    let compactPlayer: CompactPlayerUIPersistentState?
    
    let playQueue: PlayQueueUIPersistentState?
    let visualizer: VisualizerUIPersistentState?
//    let tuneBrowser: TuneBrowserUIPersistentState?
    
    init(appMode: AppMode?, windowLayout: WindowLayoutsPersistentState?, themes: ThemesPersistentState?, fontSchemes: FontSchemesPersistentState?, colorSchemes: ColorSchemesPersistentState?, modularPlayer: ModularPlayerUIPersistentState?, unifiedPlayer: UnifiedPlayerUIPersistentState?, menuBarPlayer: MenuBarPlayerUIPersistentState?, widgetPlayer: WidgetPlayerUIPersistentState?, compactPlayer: CompactPlayerUIPersistentState?, playQueue: PlayQueueUIPersistentState?, visualizer: VisualizerUIPersistentState?) {
        
        self.appMode = appMode
        
        self.windowLayout = windowLayout
        self.themes = themes
        self.fontSchemes = fontSchemes
        self.colorSchemes = colorSchemes
        
        self.modularPlayer = modularPlayer
        self.unifiedPlayer = unifiedPlayer
        self.menuBarPlayer = menuBarPlayer
        self.widgetPlayer = widgetPlayer
        self.compactPlayer = compactPlayer
        
        self.playQueue = playQueue
        self.visualizer = visualizer
//        self.tuneBrowser = tuneBrowser
    }
    
    init(legacyPersistentState: LegacyUIPersistentState?) {
        
        self.appMode = AppMode.fromLegacyAppMode(legacyPersistentState?.appMode)
        
        self.windowLayout = nil
        self.themes = nil
        self.fontSchemes = .init(legacyPersistentState: legacyPersistentState?.fontSchemes)
        self.colorSchemes = .init(legacyPersistentState: legacyPersistentState?.colorSchemes)
        
        self.modularPlayer = ModularPlayerUIPersistentState(legacyPersistentState: legacyPersistentState?.player,
                                                            legacyWindowAppearanceState: legacyPersistentState?.windowAppearance)
        self.unifiedPlayer = nil
        self.menuBarPlayer = nil
        self.widgetPlayer = nil
        self.compactPlayer = nil
        
        self.playQueue = nil
        self.visualizer = nil
//        self.tuneBrowser = nil
    }
}
