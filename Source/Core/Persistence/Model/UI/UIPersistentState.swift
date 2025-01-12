//
//  UIPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    let waveform: WaveformPersistentState?
//    let tuneBrowser: TuneBrowserUIPersistentState?
    
    init(appMode: AppMode?, windowLayout: WindowLayoutsPersistentState?, themes: ThemesPersistentState?, fontSchemes: FontSchemesPersistentState?, colorSchemes: ColorSchemesPersistentState?, modularPlayer: ModularPlayerUIPersistentState?, unifiedPlayer: UnifiedPlayerUIPersistentState?, menuBarPlayer: MenuBarPlayerUIPersistentState?, widgetPlayer: WidgetPlayerUIPersistentState?, compactPlayer: CompactPlayerUIPersistentState?, playQueue: PlayQueueUIPersistentState?, visualizer: VisualizerUIPersistentState?, waveform: WaveformPersistentState?) {
        
        self.appMode = appMode
        
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
        self.waveform = waveform
//        self.tuneBrowser = tuneBrowser
    }
    
    init(legacyPersistentState: LegacyUIPersistentState?) {
        
        self.appMode = AppMode.fromLegacyAppMode(legacyPersistentState?.appMode)
        
        self.themes = nil
        self.fontSchemes = .init(legacyPersistentState: legacyPersistentState?.fontSchemes)
        self.colorSchemes = .init(legacyPersistentState: legacyPersistentState?.colorSchemes)
        
        self.modularPlayer = ModularPlayerUIPersistentState(legacyPersistentState: legacyPersistentState)
        self.unifiedPlayer = nil
        self.menuBarPlayer = nil
        self.widgetPlayer = nil
        self.compactPlayer = nil
        
        self.playQueue = nil
        self.visualizer = nil
        self.waveform = nil
//        self.tuneBrowser = nil
    }
}
