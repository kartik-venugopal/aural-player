//
//  WindowLayoutPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct WindowLayoutsPersistentState: Codable {
    
    let showEffects: Bool?
    let showPlaylist: Bool?
    
    let mainWindowOrigin: NSPoint?
    let effectsWindowOrigin: NSPoint?
    let playlistWindowFrame: NSRect?
    
    let userLayouts: [UserWindowLayoutPersistentState]?
}

struct UserWindowLayoutPersistentState: Codable {
    
    let name: String?
    let showEffects: Bool?
    let showPlaylist: Bool?
    
    let mainWindowOrigin: NSPoint?
    let effectsWindowOrigin: NSPoint?
    let playlistWindowFrame: NSRect?
    
    init(layout: WindowLayout) {
        
        self.name = layout.name
        self.showEffects = layout.showEffects
        self.showPlaylist = layout.showPlaylist
        self.mainWindowOrigin = layout.mainWindowOrigin
        self.effectsWindowOrigin = layout.effectsWindowOrigin
        self.playlistWindowFrame = layout.playlistWindowFrame
    }
}

extension WindowLayoutState {
    
    static func initialize(_ persistentState: WindowLayoutsPersistentState?) {
        
        Self.showPlaylist = persistentState?.showPlaylist ?? WindowLayoutDefaults.showPlaylist
        Self.showEffects = persistentState?.showEffects ?? WindowLayoutDefaults.showEffects
        
        Self.mainWindowOrigin = persistentState?.mainWindowOrigin ?? WindowLayoutDefaults.mainWindowOrigin
        Self.playlistWindowFrame = persistentState?.playlistWindowFrame ?? WindowLayoutDefaults.playlistWindowFrame
        Self.effectsWindowOrigin = persistentState?.effectsWindowOrigin ?? WindowLayoutDefaults.effectsWindowOrigin
    }
    
    static var persistentState: WindowLayoutsPersistentState {
        
        let userLayouts = ObjectGraph.windowLayoutsManager.userDefinedPresets.map {UserWindowLayoutPersistentState(layout: $0)}
        
        if let windowManager = WindowManager.instance {
            
            return WindowLayoutsPersistentState(showEffects: windowManager.isShowingEffects,
                showPlaylist: windowManager.isShowingPlaylist,
                mainWindowOrigin: windowManager.mainWindowFrame.origin,
                effectsWindowOrigin: windowManager.effectsWindow?.origin,
                playlistWindowFrame: windowManager.playlistWindow?.frame,
                userLayouts: userLayouts)
            
        } else {
            
            return WindowLayoutsPersistentState(showEffects: WindowLayoutState.showEffects,
                showPlaylist: WindowLayoutState.showPlaylist,
                mainWindowOrigin: WindowLayoutState.mainWindowOrigin,
                effectsWindowOrigin: WindowLayoutState.effectsWindowOrigin,
                playlistWindowFrame: WindowLayoutState.playlistWindowFrame,
                userLayouts: userLayouts)
        }
    }
}
