//
//  UnifiedPlayerUIState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import AppKit

class UnifiedPlayerUIState {
    
    var windowFrame: NSRect?
    
    var sidebarItems: [UnifiedPlayerSidebarItem] = []
    var sidebarSelectedItem: UnifiedPlayerSidebarItem? = nil {
        
        didSet {
            print("SelItem: \(sidebarSelectedItem?.module.description ?? "<None>")")
        }
    }
    
    init(persistentState: UnifiedPlayerUIPersistentState?) {
        self.windowFrame = persistentState?.windowFrame?.toNSRect()
    }
    
    var persistentState: UnifiedPlayerUIPersistentState? {
        
        if let windowFrame = self.windowFrame {
            return .init(windowFrame: NSRectPersistentState(rect: windowFrame))
        } else {
            return nil
        }
    }
}
