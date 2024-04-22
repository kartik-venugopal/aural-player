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
    
#if os(macOS)
    
    init(layout: WindowLayout) {
        
        self.name = layout.name
        
        self.mainWindowFrame = NSRectPersistentState(rect: layout.mainWindowFrame)
        self.displayedWindows = layout.displayedWindows.map {LayoutWindowPersistentState(window: $0)}
    }
    
#endif
}

struct LayoutWindowPersistentState: Codable {
    
#if os(macOS)
    
    let id: WindowID?
    let frame: NSRectPersistentState?

    
    init(window: LayoutWindow) {
        
        self.id = window.id
        self.frame = NSRectPersistentState(rect: window.frame)
    }
    
#endif
}
