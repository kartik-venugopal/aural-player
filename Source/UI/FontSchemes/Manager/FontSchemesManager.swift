//
//  FontSchemesManager.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FontSchemesManager: UserManagedObjects<FontScheme> {
    
    // The current system color scheme. It is initialized with the default scheme.
    let systemScheme: FontScheme
    
    private lazy var messenger = Messenger(for: self)
    
    var schemeObservers: [Int: FontSchemeObserver] = [:]
    
    var isObserving: Bool = false
    var schemeChanged: Bool = false
    
    init(persistentState: FontSchemesPersistentState?) {
        
        let systemDefinedSchemes = FontScheme.allSystemDefinedSchemes
        let userDefinedSchemes = (persistentState?.userSchemes ?? []).compactMap {FontScheme(persistentState: $0, systemDefined: false)}
        
        lazy var copyOfDefaultScheme = FontScheme(name: "_system_", copying: .defaultScheme)
        
        if let persistentSystemScheme = persistentState?.systemScheme {
            self.systemScheme = FontScheme(persistentState: persistentSystemScheme, systemDefined: true) ?? copyOfDefaultScheme
            
        } else {
            
            self.systemScheme = copyOfDefaultScheme
        }
        
        super.init(systemDefinedObjects: systemDefinedSchemes, userDefinedObjects: userDefinedSchemes)
    }
    
    func applyScheme(named name: String) {
        
        if let scheme = object(named: name) {
            applyScheme(scheme)
        }
    }
    
    func applyScheme(_ fontScheme: FontScheme) {
        
        schemeChanged = true
        
        systemScheme.applyScheme(fontScheme)
        systemSchemeChanged()
        
        schemeChanged = false
    }
    
    private func systemSchemeChanged() {
        
        schemeObservers.values.forEach {
            $0.fontSchemeChanged()
        }
    }
    
    // State to be persisted to disk.
    var persistentState: FontSchemesPersistentState {
        
        FontSchemesPersistentState(systemScheme: FontSchemePersistentState(systemScheme),
                                   userSchemes: userDefinedObjects.map {FontSchemePersistentState($0)})
    }
}
