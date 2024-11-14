//
//  WindowLayoutPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    let systemLayout: WindowLayoutPersistentState?
    let userLayouts: [WindowLayoutPersistentState]?
}

///
/// Persistent state for a single window layout.
///
/// - SeeAlso: `WindowLayout`
///
struct WindowLayoutPersistentState: Codable {
    
    let name: String?
    
    let mainWindowFrame: NSRectPersistentState?
    let displayedWindows: [LayoutWindowPersistentState]?
    
    init(layout: WindowLayout) {
        
        self.name = layout.name
        
        self.mainWindowFrame = NSRectPersistentState(rect: layout.mainWindowFrame)
        self.displayedWindows = layout.displayedWindows.map {LayoutWindowPersistentState(window: $0)}
    }
    
    init?(legacyPersistentState: LegacyUserWindowLayoutPersistentState?) {
        
        guard let showEffects = legacyPersistentState?.showEffects,
              let showPlaylist = legacyPersistentState?.showPlaylist,
        let mainWindowOrigin = legacyPersistentState?.mainWindowOrigin,
            let effectsWindowOrigin = legacyPersistentState?.effectsWindowOrigin,
            let playlistWindowFrame = legacyPersistentState?.playlistWindowFrame else {return nil}
        
        self.name = legacyPersistentState?.name
        self.mainWindowFrame = NSRectPersistentState(origin: mainWindowOrigin, size: NSSizePersistentState(size: WindowLayoutPresets.mainWindowSize))
        
        self.displayedWindows = []
        
        // TODO: Set relative gap between main + FX and main + PQ, based on legacy state, don't use frames literally ... look at gaps.
        
//        if showEffects {
//            displayedWindows?.append(LayoutWindowPersistentState(id: .effects, frame: ))
//        }
    }
}

struct LayoutWindowPersistentState: Codable {
    
    let id: WindowID?
    let frame: NSRectPersistentState?

    init(window: LayoutWindow) {
        
        self.id = window.id
        self.frame = NSRectPersistentState(rect: window.frame)
    }
}
