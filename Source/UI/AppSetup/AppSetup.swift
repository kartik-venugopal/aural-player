//
//  AppSetup.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class AppSetup {
    
    // TODO: Take into account data migrated from v3 - color scheme / font scheme, app mode, window layout, etc
    
    private init() {}
    
    /// Singleton
    static var shared: AppSetup = .init()
    
    private(set) lazy var setupRequired: Bool = {
        
        if persistenceManager.persistentStateFileExists, 
            let appVersion = appPersistentState.appVersion,
            appVersion.hasPrefix("4") {
            
            return false
        }
        
        return true
    }()
    
    var setupCompleted: Bool = false
    
    var presentationMode: AppMode = .defaultMode
    var windowLayoutPreset: WindowLayoutPresets = .defaultLayout
    var colorSchemePreset: ColorSchemePreset = .defaultScheme
    var fontSchemePreset: FontSchemePreset = .defaultScheme
//    var librarySourceFolder: URL = FilesAndPaths.musicDir
}
