//
//  LazyViewLoader.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class LazyViewLoader<T>: Destroyable where T: NSViewController, T: Destroyable {
    
    lazy var controller: T = {
        
        viewLoaded = true
        return T.init()
    }()
    
    lazy var view: NSView = controller.view
    
    var viewLoaded: Bool = false
    
    func destroy() {
        
        if viewLoaded {
            controller.destroy()
        }
    }
}
