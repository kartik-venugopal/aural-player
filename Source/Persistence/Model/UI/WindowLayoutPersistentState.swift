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
    
    let mainWindowOrigin: NSPointPersistentState?
    let effectsWindowOrigin: NSPointPersistentState?
    let playlistWindowFrame: NSRectPersistentState?
    
    let userLayouts: [UserWindowLayoutPersistentState]?
}

struct UserWindowLayoutPersistentState: Codable {
    
    let name: String?
    let showEffects: Bool?
    let showPlaylist: Bool?
    
    let mainWindowOrigin: NSPointPersistentState?
    let effectsWindowOrigin: NSPointPersistentState?
    let playlistWindowFrame: NSRectPersistentState?
    
    init(layout: WindowLayout) {
        
        self.name = layout.name
        self.showEffects = layout.showEffects
        self.showPlaylist = layout.showPlaylist
        self.mainWindowOrigin = NSPointPersistentState(point: layout.mainWindowOrigin)
        
        if let effectsWindowOrigin = layout.effectsWindowOrigin {
            self.effectsWindowOrigin = NSPointPersistentState(point: effectsWindowOrigin)
        } else {
            self.effectsWindowOrigin = nil
        }
        
        if let playlistWindowFrame = layout.playlistWindowFrame {
            self.playlistWindowFrame = NSRectPersistentState(rect: playlistWindowFrame)
        } else {
            self.playlistWindowFrame = nil
        }
    }
}

extension WindowLayoutState {
    
    static func initialize(_ persistentState: WindowLayoutsPersistentState?) {
        
        Self.showPlaylist = persistentState?.showPlaylist ?? WindowLayoutDefaults.showPlaylist
        Self.showEffects = persistentState?.showEffects ?? WindowLayoutDefaults.showEffects
        
        Self.mainWindowOrigin = persistentState?.mainWindowOrigin?.toNSPoint() ?? WindowLayoutDefaults.mainWindowOrigin
        Self.playlistWindowFrame = persistentState?.playlistWindowFrame?.toNSRect() ?? WindowLayoutDefaults.playlistWindowFrame
        Self.effectsWindowOrigin = persistentState?.effectsWindowOrigin?.toNSPoint() ?? WindowLayoutDefaults.effectsWindowOrigin
    }
    
    static var persistentState: WindowLayoutsPersistentState {
        
        let userLayouts = ObjectGraph.windowLayoutsManager.userDefinedPresets.map {UserWindowLayoutPersistentState(layout: $0)}
        
        var effectsWindowOrigin: NSPointPersistentState? = nil
        var playlistWindowFrame: NSRectPersistentState? = nil
        
        if let windowManager = WindowManager.instance {
            
            if let origin = windowManager.effectsWindow?.origin {
                effectsWindowOrigin = NSPointPersistentState(point: origin)
            }
            
            if let frame = windowManager.playlistWindow?.frame {
                playlistWindowFrame = NSRectPersistentState(rect: frame)
            }
            
            return WindowLayoutsPersistentState(showEffects: windowManager.isShowingEffects,
                showPlaylist: windowManager.isShowingPlaylist,
                mainWindowOrigin: NSPointPersistentState(point: windowManager.mainWindowFrame.origin),
                effectsWindowOrigin: effectsWindowOrigin,
                playlistWindowFrame: playlistWindowFrame,
                userLayouts: userLayouts)
            
        } else {
            
            if let origin = WindowLayoutState.effectsWindowOrigin {
                effectsWindowOrigin = NSPointPersistentState(point: origin)
            }
            
            if let frame = WindowLayoutState.playlistWindowFrame {
                playlistWindowFrame = NSRectPersistentState(rect: frame)
            }
            
            return WindowLayoutsPersistentState(showEffects: WindowLayoutState.showEffects,
                showPlaylist: WindowLayoutState.showPlaylist,
                mainWindowOrigin: NSPointPersistentState(point: WindowLayoutState.mainWindowOrigin),
                effectsWindowOrigin: effectsWindowOrigin,
                playlistWindowFrame: playlistWindowFrame,
                userLayouts: userLayouts)
        }
    }
}
