//
//  FontSchemesManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FontSchemesManager: MappedPresets<FontScheme> {
    
    // The current system color scheme. It is initialized with the default scheme.
    private(set) var systemScheme: FontScheme
    
    init(persistentState: FontSchemesPersistentState?) {
        
        let systemDefinedSchemes = FontSchemePreset.allCases.map {FontScheme($0.name, $0)}
        let userDefinedSchemes = (persistentState?.userSchemes ?? []).map {FontScheme($0, false)}
        
        if let persistentSystemScheme = persistentState?.systemScheme {
            
            self.systemScheme = FontScheme(persistentSystemScheme, true)
            
        } else {
            
            self.systemScheme = systemDefinedSchemes.first(where: {$0.name == FontSchemePreset.standard.name}) ??
                FontScheme("_system_", FontSchemePreset.standard)
        }
        
        super.init(systemDefinedPresets: systemDefinedSchemes, userDefinedPresets: userDefinedSchemes)
    }
    
    func applyScheme(named name: String) {
        
        if let scheme = preset(named: name) {
            applyScheme(scheme)
        }
    }
    
    func applyScheme(_ fontScheme: FontScheme) {

        systemScheme = FontScheme("_system_", true, fontScheme)
        Messenger.publish(.applyFontScheme, payload: systemScheme)
    }
    
    // State to be persisted to disk.
    var persistentState: FontSchemesPersistentState {
        
        FontSchemesPersistentState(FontSchemePersistentState(systemScheme),
                                   userDefinedPresets.map {FontSchemePersistentState($0)})
    }
}
