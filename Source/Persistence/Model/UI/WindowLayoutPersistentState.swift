//
//  WindowLayoutPersistentState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all persistent state for application window layouts.
///
/// - SeeAlso: `WindowLayoutsManager`
///
struct WindowLayoutsPersistentState: Codable {
    
    let showEffects: Bool?
    let showPlaylist: Bool?
    
    let mainWindowOrigin: NSPointPersistentState?
    let effectsWindowOrigin: NSPointPersistentState?
    let playlistWindowFrame: NSRectPersistentState?
    
    let userLayouts: [UserWindowLayoutPersistentState]?
}

///
/// Persistent state for a single user-defined window layout.
///
/// - SeeAlso: `WindowLayout`
///
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
