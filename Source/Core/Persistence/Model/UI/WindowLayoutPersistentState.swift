//
//  WindowLayoutPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AppKit

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
    
    let mainWindow: LayoutWindowPersistentState?
    let auxiliaryWindows: [LayoutWindowPersistentState]?
    
    init(layout: WindowLayout) {
        
        self.name = layout.name
        
        self.mainWindow = LayoutWindowPersistentState(window: layout.mainWindow)
        self.auxiliaryWindows = layout.auxiliaryWindows.map {LayoutWindowPersistentState(window: $0)}
    }
}

struct LayoutWindowPersistentState: Codable {
    
    let id: WindowID?
    let screen: ScreenPersistentState?
    
    let screenOffset: NSSizePersistentState?
    let size: NSSizePersistentState?

    init(window: LayoutWindow) {
        
        self.id = window.id
        self.screen = .init(screen: window.screen)
        
        self.size = .init(size: window.size)
        
        if let screenOffset = window.screenOffset {
            self.screenOffset = .init(size: screenOffset)
        } else {
            self.screenOffset = nil
        }
    }
}

struct ScreenPersistentState: Codable {

    let name: String?
    let frame: NSRectPersistentState?
    
    init?(screen: NSScreen?) {
        
        guard let screen else {return nil}
        
        self.name = screen.localizedName
        self.frame = .init(rect: screen.frame)
    }
}
