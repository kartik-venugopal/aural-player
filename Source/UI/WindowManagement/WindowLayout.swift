//
//  WindowLayout.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayout {
    
    var name: String
    let showEffects: Bool
    let showPlaylist: Bool
    
    var mainWindowOrigin: NSPoint
    var effectsWindowOrigin: NSPoint?
    var playlistWindowFrame: NSRect?
    
    let systemDefined: Bool
    
    init(_ name: String, _ showEffects: Bool, _ showPlaylist: Bool, _ mainWindowOrigin: NSPoint, _ effectsWindowOrigin: NSPoint?, _ playlistWindowFrame: NSRect?, _ systemDefined: Bool) {
        
        self.name = name
        self.showEffects = showEffects
        self.showPlaylist = showPlaylist
        self.mainWindowOrigin = mainWindowOrigin
        self.effectsWindowOrigin = effectsWindowOrigin
        self.playlistWindowFrame = playlistWindowFrame
        self.systemDefined = systemDefined
        
        // TODO: Validate that 1 - if showEffects is true, effectsOrigin is present, and 2 - if showPlaylist is true,
        // playlistFrame is present.
    }
    
    init?(persistentState: UserWindowLayoutPersistentState) {
        
        guard let name = persistentState.name,
              let showEffects = persistentState.showEffects,
              let showPlaylist = persistentState.showPlaylist,
              let mainWindowOrigin = persistentState.mainWindowOrigin else {return nil}
        
        if showEffects {
            
            guard let effectsWindowOrigin = persistentState.effectsWindowOrigin else {return nil}
            self.effectsWindowOrigin = effectsWindowOrigin
        }
        
        if showPlaylist {
            
            guard let playlistWindowFrame = persistentState.playlistWindowFrame else {return nil}
            self.playlistWindowFrame = playlistWindowFrame
        }
        
        self.name = name
        self.systemDefined = false
        
        self.mainWindowOrigin = mainWindowOrigin
        self.showEffects = showEffects
        self.showPlaylist = showPlaylist
    }
}

extension WindowLayout: MappedPreset {
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}
}
