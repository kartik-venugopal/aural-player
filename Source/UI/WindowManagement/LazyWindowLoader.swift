//
//  LazyWindowLoader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class LazyWindowLoader<T>: Destroyable where T: NSWindowController, T: Destroyable {
    
    lazy var controller: T = {
        
        windowLoaded = true
        return T.init()
    }()
    
    lazy var window: NSWindow = controller.window!
    
    var windowLoaded: Bool = false
    
    func destroy() {
        
        if windowLoaded {
            controller.destroy()
        }
    }
}
