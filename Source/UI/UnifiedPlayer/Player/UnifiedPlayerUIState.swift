//
//  UnifiedPlayerUIState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AppKit

class UnifiedPlayerUIState {
    
    var windowFrame: NSRect?
    var isSidebarShown: Bool = true
    var isWaveformShown: Bool = false
    
    var sidebarItems: [UnifiedPlayerSidebarItem] = [.playQueueItem]
    var sidebarSelectedItem: UnifiedPlayerSidebarItem? = nil
    
    init(persistentState: UnifiedPlayerUIPersistentState?) {
        
        if let isSidebarShown = persistentState?.isSidebarShown {
            self.isSidebarShown = isSidebarShown
        }
        
        if let isWaveformShown = persistentState?.isWaveformShown {
            self.isWaveformShown = isWaveformShown
        }
        
        self.windowFrame = persistentState?.windowFrame
    }
    
    var persistentState: UnifiedPlayerUIPersistentState? {
        .init(windowFrame: windowFrame, isSidebarShown: isSidebarShown, isWaveformShown: isWaveformShown)
    }
}
