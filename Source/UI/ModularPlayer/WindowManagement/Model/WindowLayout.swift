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
    
    var mainWindow: LayoutWindow
    var auxiliaryWindows: [LayoutWindow]
    
    var effectsWindowFrame: NSRect? {
        
        if let effectsWindow = auxiliaryWindows.first(where: {$0.id == .effects}) {
//            return effectsWindow.frame
            return .zero
        }
        
        return nil
    }
    
    var playQueueWindowFrame: NSRect? {
        
        if let playQueueWindow = auxiliaryWindows.first(where: {$0.id == .playQueue}) {
//            return playQueueWindow.frame
            return .zero
        }
        
        return nil
    }
    
    init(name: String, systemDefined: Bool, mainWindow: LayoutWindow, auxiliaryWindows: [LayoutWindow]) {
        
        self.name = name
        self.systemDefined = systemDefined
        self.mainWindow = mainWindow
        self.auxiliaryWindows = auxiliaryWindows
    }
    
    init?(persistentState: WindowLayoutPersistentState) {
        
        guard let name = persistentState.name,
        let mainWindowState = persistentState.mainWindow,
        let mainWindow = LayoutWindow(persistentState: mainWindowState),
        mainWindow.id == .main else {return nil}
        
        self.name = name
        self.systemDefined = false
        
        self.mainWindow = mainWindow
        self.auxiliaryWindows = persistentState.auxiliaryWindows?.compactMap {LayoutWindow(persistentState: $0)} ?? []
    }
    
    init?(systemLayoutFrom persistentState: WindowLayoutsPersistentState?) {

        guard let systemLayout = persistentState?.systemLayout,
              let mainWindowState = systemLayout.mainWindow,
              let mainWindow = LayoutWindow(persistentState: mainWindowState),
              mainWindow.id == .main else {return nil}

        self.name = "_system_"
        self.systemDefined = true

        self.mainWindow = mainWindow
        self.auxiliaryWindows = systemLayout.auxiliaryWindows?.compactMap {LayoutWindow(persistentState: $0)} ?? []
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
              let screenOffset = persistentState.screenOffset,
              let offsetWidth = screenOffset.width,
              let offsetHeight = screenOffset.height,
              let size = persistentState.size,
              let width = size.width, let height = size.height else {return nil}
        
        self.id = id
        
        self.screen = NSScreen.screens.first {
            $0.localizedName == screen.name
        }
        
        self.screenOffset = NSMakeSize(offsetWidth, offsetHeight)
        self.size = .init(width: width, height: height)
    }
}
