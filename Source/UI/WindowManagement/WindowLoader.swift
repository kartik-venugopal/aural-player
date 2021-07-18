//
//  WindowLoader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLoader<T>: DestroyableAndRestorable where T: NSWindowController, T: Destroyable {
    
    private var lazyLoader: LazyWindowLoader<T>? = LazyWindowLoader()
    
    var isWindowLoaded: Bool {lazyLoader?.isWindowLoaded ?? false}
    var window: NSWindow {lazyLoader!.controller.window!}
    
    func showWindow() {
        lazyLoader?.controller.showWindow(self)
    }
    
    func close() {
        lazyLoader?.controller.close()
    }
    
    func destroy() {
        
        lazyLoader?.destroy()
        lazyLoader = nil
    }
    
    func restore() {
        
        if lazyLoader == nil {
            lazyLoader = LazyWindowLoader()
        }
    }
}

class LazyWindowLoader<T>: Destroyable where T: NSWindowController, T: Destroyable {
    
    lazy var controller: T = {
        
        isWindowLoaded = true
        return T.init()
    }()
    
    lazy var window: NSWindow = controller.window!
    
    var isWindowLoaded: Bool = false
    
    func destroy() {
        
        if isWindowLoaded {
            controller.destroy()
        }
    }
}
