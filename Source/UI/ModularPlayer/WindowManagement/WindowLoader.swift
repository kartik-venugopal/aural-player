//
//  WindowLoader.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLoader: DestroyableAndRestorable {
    
    let windowID: WindowID
    
    private let controllerFactory: () -> NSWindowController
    
    private var controller: NSWindowController!
    var window: NSWindow!
    
    var isWindowLoaded: Bool = false
    
    var isWindowVisible: Bool {
        isWindowLoaded && window.isVisible
    }
    
    init<T>(windowID: WindowID, windowControllerType: T.Type) where T: NSWindowController {
        
        self.windowID = windowID
        self.controllerFactory = {
            T.init()
        }
    }
    
    func showWindow() {
        controller.showWindow(self)
    }
    
    func close() {
        controller.close()
    }
    
    func destroy() {
        
        guard isWindowLoaded else {return}
        
        controller.destroy()
        controller = nil
        window = nil
        isWindowLoaded = false
    }
    
    func restore() {
        
        guard !isWindowLoaded else {return}
        
        controller = controllerFactory()
        window = controller.window
        isWindowLoaded = true
    }
}

// Used for Playlist search / sort dialogs ... see if this class can be eliminated.
class LazyWindowLoader<T>: Destroyable where T: NSWindowController {
    
    lazy var controller: T = {
        
        isWindowLoaded = true
        
        let theController = T.init()
        controllerInitFunction(theController)
        
        return theController
    }()
    
    var controllerInitFunction: (T) -> Void = {_ in}
    
    lazy var window: NSWindow = controller.window!
    
    var isWindowLoaded: Bool = false
    
    func showWindow() {
        controller.showWindow(self)
    }
    
    func close() {
        
        if isWindowLoaded {
            controller.close()
        }
    }
    
    func destroy() {
        
        if isWindowLoaded {
            
            controller.close()
            controller.destroy()
        }
    }
}
