//
//  UnifiedPlayerUIState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
        
        self.windowFrame = persistentState?.windowFrame?.toNSRect()
    }
    
    var persistentState: UnifiedPlayerUIPersistentState? {
        
        if let windowFrame = self.windowFrame {
            return .init(windowFrame: NSRectPersistentState(rect: windowFrame), isSidebarShown: isSidebarShown, isWaveformShown: isWaveformShown)
        } else {
            return nil
        }
    }
}
