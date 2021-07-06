//
//  WindowLayoutState.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class WindowLayoutState {
    
    static var showEffects: Bool = WindowLayoutDefaults.showEffects
    static var showPlaylist: Bool = WindowLayoutDefaults.showPlaylist
    
    static var mainWindowOrigin: NSPoint = WindowLayoutDefaults.mainWindowOrigin
    static var effectsWindowOrigin: NSPoint? = WindowLayoutDefaults.effectsWindowOrigin
    static var playlistWindowFrame: NSRect? = WindowLayoutDefaults.playlistWindowFrame
    
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

class WindowLayoutDefaults {
    
    static let showEffects: Bool = true
    static let showPlaylist: Bool = true
    
    static let mainWindowOrigin: NSPoint = NSPoint.zero
    static let effectsWindowOrigin: NSPoint? = nil
    static let playlistWindowFrame: NSRect? = nil
}

// Convenient accessor for information about the current appearance settings for the app's main windows.
class WindowAppearanceState {
    
    static let defaultCornerRadius: CGFloat = 3
    static var cornerRadius: CGFloat = defaultCornerRadius
}

// A snapshot of WindowAppearanceState
struct WindowAppearance {
    let cornerRadius: CGFloat
}
