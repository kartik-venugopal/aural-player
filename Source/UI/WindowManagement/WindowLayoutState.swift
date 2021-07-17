//
//  WindowLayoutState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class WindowLayoutState {
    
    var showPlaylist_remembered: Bool = WindowLayoutDefaults.showPlaylist
    
    var isShowingPlaylist: Bool {
        windowManager?.isShowingPlaylist ?? showPlaylist_remembered
    }
    
    var showEffects_remembered: Bool = WindowLayoutDefaults.showEffects
    
    var isShowingEffects: Bool {
        windowManager?.isShowingEffects ?? showEffects_remembered
    }
    
    var effectsWindowLoaded: Bool {
        windowManager?.effectsWindowLoaded ?? false
    }
    
    var isShowingChaptersList: Bool {
        windowManager?.isShowingChaptersList ?? false
    }
    
    var isShowingVisualizer: Bool {
        windowManager?.isShowingVisualizer ?? false
    }
    
    var mainWindowOrigin_remembered: NSPoint = WindowLayoutDefaults.mainWindowOrigin
    
    var mainWindowOrigin: NSPoint {
        windowManager?.mainWindowFrame.origin ?? mainWindowOrigin_remembered
    }
    
    var mainWindowFrame: NSRect {
        windowManager!.mainWindowFrame
    }
    
    var mainWindowContentView: NSView {
        windowManager!.mainWindow.contentView!
    }
    
    var effectsWindowOrigin_remembered: NSPoint? = WindowLayoutDefaults.effectsWindowOrigin
    
    var effectsWindowOrigin: NSPoint? {
        windowManager?.effectsWindowFrame?.origin ?? effectsWindowOrigin_remembered
    }
    
    var playlistWindowFrame_remembered: NSRect? = WindowLayoutDefaults.playlistWindowFrame
    
    var playlistWindowFrame: NSRect? {
        windowManager?.playlistWindowFrame ?? playlistWindowFrame_remembered
    }
    
    var playlistWindowLoaded: Bool {
        windowManager?.playlistWindowLoaded ?? false
    }
    
    var playlistWindowContentView: NSView {
        windowManager!.playlistWindow!.contentView!
    }
    
    func isWindowEqualToPlaylistWindow(_ window: NSWindow) -> Bool {
        window === windowManager?.playlistWindow
    }
    
    var isShowingModalComponent: Bool {
        windowManager?.isShowingModalComponent ?? false
    }
    
    var isChaptersListWindowKey: Bool {
        windowManager?.isChaptersListWindowKey ?? false
    }
    
    var currentLayout: WindowLayout {
        windowManager!.currentWindowLayout
    }
    
    private weak var windowManager: WindowManager? {
        
        willSet {
            
            // If windowManager is going to be set to nil, transfer state from it into
            // this object.
            if newValue == nil, let windowManager = self.windowManager {
                
                showPlaylist_remembered = windowManager.isShowingPlaylist
                showEffects_remembered = windowManager.isShowingEffects
            }
        }
    }
    
    init(persistentState: WindowLayoutsPersistentState?) {
        
        showPlaylist_remembered = persistentState?.showPlaylist ?? WindowLayoutDefaults.showPlaylist
        showEffects_remembered = persistentState?.showEffects ?? WindowLayoutDefaults.showEffects

        mainWindowOrigin_remembered = persistentState?.mainWindowOrigin?.toNSPoint() ?? WindowLayoutDefaults.mainWindowOrigin
        playlistWindowFrame_remembered = persistentState?.playlistWindowFrame?.toNSRect() ?? WindowLayoutDefaults.playlistWindowFrame
        effectsWindowOrigin_remembered = persistentState?.effectsWindowOrigin?.toNSPoint() ?? WindowLayoutDefaults.effectsWindowOrigin
    }
    
    func registerModalComponent(_ component: ModalComponentProtocol) {
        windowManager?.registerModalComponent(component)
    }
    
    var persistentState: WindowLayoutsPersistentState {
        
        let userLayouts = objectGraph.windowLayoutsManager.userDefinedPresets.map {UserWindowLayoutPersistentState(layout: $0)}
        
        var effectsWindowOrigin: NSPointPersistentState? = nil
        var playlistWindowFrame: NSRectPersistentState? = nil
        
        if let origin = self.effectsWindowOrigin {
            effectsWindowOrigin = NSPointPersistentState(point: origin)
        }
        
        if let frame = self.playlistWindowFrame {
            playlistWindowFrame = NSRectPersistentState(rect: frame)
        }
        
        return WindowLayoutsPersistentState(showEffects: isShowingEffects,
                showPlaylist: isShowingPlaylist,
                mainWindowOrigin: NSPointPersistentState(point: mainWindowOrigin),
                effectsWindowOrigin: effectsWindowOrigin,
                playlistWindowFrame: playlistWindowFrame,
                userLayouts: userLayouts)
    }
}

class WindowLayoutDefaults {
    
    static let showEffects: Bool = true
    static let showPlaylist: Bool = true
    
    static let mainWindowOrigin: NSPoint = NSPoint.zero
    static let effectsWindowOrigin: NSPoint? = nil
    static let playlistWindowFrame: NSRect? = nil
}
