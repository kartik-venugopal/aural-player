//
//  WindowLayout.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayout {
    
    var name: String
    var systemDefined: Bool
    
    var mainWindowFrame: NSRect
    var displayedWindows: [LayoutWindow]
    
    var effectsWindowFrame: NSRect? {
        
        if let effectsWindow = displayedWindows.first(where: {$0.id == .effects}) {
//            return effectsWindow.frame
            return .zero
        }
        
        return nil
    }
    
    var playQueueWindowFrame: NSRect? {
        
        if let playQueueWindow = displayedWindows.first(where: {$0.id == .playQueue}) {
//            return playQueueWindow.frame
            return .zero
        }
        
        return nil
    }
    
    init(name: String, systemDefined: Bool, mainWindowFrame: NSRect, displayedWindows: [LayoutWindow]) {
        
        self.name = name
        self.systemDefined = systemDefined
        self.mainWindowFrame = mainWindowFrame
        self.displayedWindows = displayedWindows
    }
    
    init?(persistentState: WindowLayoutPersistentState) {
        
        guard let name = persistentState.name else {return nil}
        
        self.name = name
        self.systemDefined = false
        
        self.mainWindowFrame = persistentState.mainWindowFrame?.toNSRect() ?? .zero
        self.displayedWindows = persistentState.displayedWindows?.compactMap {LayoutWindow(persistentState: $0)} ?? []
    }
    
    init?(systemLayoutFrom persistentState: WindowLayoutsPersistentState?) {

        guard let systemLayout = persistentState?.systemLayout,
              let mainWindowFrame = systemLayout.mainWindowFrame?.toNSRect() else {return nil}

        self.name = "_system_"
        self.systemDefined = true

        self.mainWindowFrame = mainWindowFrame
        self.displayedWindows = systemLayout.displayedWindows?.compactMap {LayoutWindow(persistentState: $0)} ?? []
    }
}

extension WindowLayout: UserManagedObject {
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {!systemDefined}
}

struct LayoutWindow {
    
    let id: WindowID
    let screen: NSScreen?
    
    let screenOffset: NSSize?
    let size: NSSize
    
    init(id: WindowID, screen: NSScreen?, screenOffset: NSSize?, size: NSSize) {
        
        self.id = id
        self.screen = screen
        
        self.screenOffset = screenOffset
        self.size = size
    }
                
    init?(persistentState: LayoutWindowPersistentState) {
        
        guard let id = persistentState.id,
              let screen = persistentState.screen,
              let offset = persistentState.screenOffset,
        let size = persistentState.size,
        let width = size.width, let height = size.height else {return nil}
        
        self.id = id
        
        self.screen = NSScreen.screens.first {
            $0.localizedName == screen.name
        }
        
        if let screenOffset = persistentState.screenOffset,
           let width = screenOffset.width, let height = screenOffset.height {
            
            self.screenOffset = NSMakeSize(width, height)
            
        } else {
            self.screenOffset = nil
        }
        
        self.size = .init(width: width, height: height)
    }
}
