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
        
        guard appModeManager.currentMode == .compact, 
                let window = NSApp.windows.first(where: {$0.identifier?.rawValue == "compactPlayer"}) else {return nil}
        
        return window.origin
    }
    
    var trackInfoScrollingEnabled: Bool
    
    init(persistentState: CompactPlayerUIPersistentState?) {
        
        windowLocation = persistentState?.windowLocation?.toNSPoint()
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
    }
    
    var persistentState: CompactPlayerUIPersistentState {
        
        var windowLocation: NSPointPersistentState? = nil
        
        if let location = self.computedWindowLocation ?? self.windowLocation {
            windowLocation = NSPointPersistentState(point: location)
        }
        
        return CompactPlayerUIPersistentState(windowLocation: windowLocation,
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
