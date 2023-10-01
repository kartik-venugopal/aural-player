//
//  SingletonWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

///
/// A base class for **NSWindowController** classes that are
/// intended to be used as singletons across the UI.
///
/// For an example of how this class is used:
/// - SeeAlso: `PresetsManagerWindowController`
///
class SingletonWindowController: NSWindowController, Destroyable {
    
    private static var instances: [String: SingletonWindowController] = [:]
    
    static var instance: Self {
        
        if let existingInstance = instances[Self.className()] as? Self {
            return existingInstance
        }
        
        let newInstance = Self.init()
        instances[Self.className()] = newInstance
        return newInstance
    }
    
    static func destroy() {
        
        instances.values.forEach {$0.destroy()}
        instances.removeAll()
    }
}
