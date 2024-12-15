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

enum WindowLayoutType: String, Codable {
    
    // Computed preset
    case computed
    
    // Auto-saved on app exit
    case autoSaved
    
    // User-defined, custom
    case custom
}

class WindowLayout {
    
    var name: String
    var type: WindowLayoutType
    
    var mainWindow: LayoutWindow
    var auxiliaryWindows: [LayoutWindow]
    
    var mainWindowFrame: NSRect? {
        mainWindow.frame
    }
    
    var screens: [NSScreen] {
        ([mainWindow] + auxiliaryWindows).compactMap { $0.screen }
    }
    
    var screenFrames: [NSRect] {
        ([mainWindow] + auxiliaryWindows).compactMap { $0.screenFrame }
    }
    
    var numberOfWindows: Int {
        auxiliaryWindows.count + 1
    }
    
    // All windows must be on the same screen.
    var boundingBox: NSRect? {
        
        let allWindows = [mainWindow] + auxiliaryWindows
        let screenFrames = self.screenFrames
        
        if Set(screenFrames).count > 1 {return nil}
        
        return NSRect.boundingBox(of: allWindows.compactMap {$0.frame})
    }
    
    var layoutBoundingBox: WindowLayoutBoundingBox? {
        
        guard let box = self.boundingBox else {return nil}
        
        var offsets: [WindowID: NSSize] = [:]
        
        for window in [mainWindow] + auxiliaryWindows {
            
            if let frame = window.frame {
                offsets[window.id] = frame.origin.distanceFrom(box.origin)
            }
        }
        
        return WindowLayoutBoundingBox(boundingBox: box, windowOffsets: offsets)
    }
    
    var effectsWindowFrame: NSRect? {
        
        if let effectsWindow = auxiliaryWindows.first(where: {$0.id == .effects}) {
           return effectsWindow.frame
        }
        
        return nil
    }
    
    var playQueueWindowFrame: NSRect? {
        
        if let playQueueWindow = auxiliaryWindows.first(where: {$0.id == .playQueue}) {
            return playQueueWindow.frame
        }
        
        return nil
    }
    
    init(name: String, type: WindowLayoutType, mainWindow: LayoutWindow, auxiliaryWindows: [LayoutWindow]) {
        
        self.name = name
        self.type = type
        self.mainWindow = mainWindow
        self.auxiliaryWindows = auxiliaryWindows
    }
    
    // Custom layouts
    init?(persistentState: WindowLayoutPersistentState) {
        
        guard let name = persistentState.name,
        let mainWindowState = persistentState.mainWindow,
        let mainWindow = LayoutWindow(persistentState: mainWindowState),
        mainWindow.id == .main else {return nil}
        
        self.name = name
        self.type = persistentState.type ?? .custom
        
        self.mainWindow = mainWindow
        self.auxiliaryWindows = persistentState.auxiliaryWindows?.compactMap {LayoutWindow(persistentState: $0)} ?? []
    }
    
    // Auto-saved layout
    init?(autoSavedLayoutFrom persistentState: WindowLayoutsPersistentState?) {

        guard let systemLayout = persistentState?.systemLayout,
              let mainWindowState = systemLayout.mainWindow,
              let mainWindow = LayoutWindow(persistentState: mainWindowState),
              mainWindow.id == .main else {return nil}

        self.name = "_autoSaved_"
        self.type = .autoSaved

        self.mainWindow = mainWindow
        self.auxiliaryWindows = systemLayout.auxiliaryWindows?.compactMap {LayoutWindow(persistentState: $0)} ?? []
    }
}

extension WindowLayout: UserManagedObject {
    
    var key: String {
        
        get {name}
        set {name = newValue}
    }
    
    var userDefined: Bool {type == .custom}
}

struct WindowLayoutBoundingBox {
    
    let boundingBox: NSRect
    let windowOffsets: [WindowID: NSSize]
    
    init(boundingBox: NSRect, windowOffsets: [WindowID : NSSize]) {
        
        self.boundingBox = boundingBox
        self.windowOffsets = windowOffsets
    }
}

struct LayoutWindow {
    
    let id: WindowID
    let screen: NSScreen?
    
    let screenFrame: NSRect?
    let screenOffset: NSSize?
    let offsetFromMainWindow: NSSize?
    let size: NSSize
    
    var frame: NSRect? {
        
        if let screen, let screenOffset {
            
            let origin = screen.visibleFrame.origin.translating(screenOffset.width, screenOffset.height)
            return NSRect(origin: origin, size: size)
            
        } else if let screenFrame, let screenOffset {
            
            let origin = screenFrame.origin.translating(screenOffset.width, screenOffset.height)
            return NSRect(origin: origin, size: size)
        }
        
        return nil
    }
    
    init(id: WindowID, screen: NSScreen?, screenFrame: NSRect?, screenOffset: NSSize?, offsetFromMainWindow: NSSize, size: NSSize) {
        
        self.id = id
        self.screen = screen
        
        self.screenFrame = screenFrame
        self.screenOffset = screenOffset
        self.offsetFromMainWindow = offsetFromMainWindow
        self.size = size
    }
                
    init?(persistentState: LayoutWindowPersistentState) {
        
        guard let id = persistentState.id,
              let screen = persistentState.screen,
              let screenOffset = persistentState.screenOffset,
              let size = persistentState.size else {return nil}
        
        self.id = id

        //
        // Even if the screen doesn't exist currently, restore the layout, because that
        // screen might exist on a later app launch. For example - user switching
        // between monitor setups.
        //
        self.screen = NSScreen.screens.first {
            $0.localizedName == screen.name
        }
        
        self.screenFrame = screen.frame
        self.screenOffset = screenOffset
        self.offsetFromMainWindow = persistentState.offsetFromMainWindow
        self.size = size
    }
}
