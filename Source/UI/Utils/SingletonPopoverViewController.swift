//
//  SingletonPopoverViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

///
/// A base class for **NSViewController** classes that manage popover views and are
/// intended to be used as singletons across the UI.
///
/// For an example of how this class is used:
/// - SeeAlso: `InfoPopupViewController`
///
class SingletonPopoverViewController: NSViewController, Destroyable {
    
    private static var instances: [String: SingletonPopoverViewController] = [:]
    
    static var instance: Self {
        
        if let existingInstance = instances[Self.className()] as? Self {
            return existingInstance
        }
        
        let newInstance = create()
        instances[Self.className()] = newInstance
        return newInstance
    }
    
    private static func create() -> Self {
        
        let controller = Self.init()
        controller.popover = NSPopover(controller: controller)
        controller.forceLoadingOfView()
        
        return controller
    }
    
    static func destroy() {
        
        instances.values.forEach {$0.destroy()}
        instances.removeAll()
    }
    
    func destroy() {
        
        close()
        
        popover.contentViewController = nil
        self.popover = nil
    }
    
    // The actual popover that is shown
    var popover: NSPopover!
    
    var isShown: Bool {
        popover.isShown
    }
    
    // Popover positioning parameters
    let positioningRect = NSZeroRect
    
    func close() {
        
        if isShown {
            popover.performClose(self)
        }
    }
}
