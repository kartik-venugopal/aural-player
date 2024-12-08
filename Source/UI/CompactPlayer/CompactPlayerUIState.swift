//
//  CompactPlayerUIState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactPlayerUIState {
    
    var displayedView: CompactPlayerDisplayedView = .player
    
    var windowLocation: NSPoint?
    
    var computedWindowLocation: NSPoint? {
        
        appModeManager.currentMode == .compact ?
        appModeManager.mainWindow?.origin :
        nil
    }
    
    var trackInfoScrollingEnabled: Bool
    
    init(persistentState: CompactPlayerUIPersistentState?) {
        
        windowLocation = persistentState?.windowLocation
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
    }
    
    var persistentState: CompactPlayerUIPersistentState {
        
        CompactPlayerUIPersistentState(windowLocation: self.computedWindowLocation ?? self.windowLocation,
                                              trackInfoScrollingEnabled: trackInfoScrollingEnabled)
    }
}

enum CompactPlayerDisplayedView {
    
    case player
    case playQueue
    case chaptersList
    case search
    case effects
    case trackInfo
}
