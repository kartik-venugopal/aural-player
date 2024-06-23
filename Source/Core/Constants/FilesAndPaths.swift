//
//  FilesAndPaths.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// An enumeration of file and directory paths (URL constants) used by the application.
///
struct FilesAndPaths {
    
    static let homeDir: URL = URL(fileURLWithPath: NSHomeDirectory())
    
    // Default user's music directory (default place to look in, when opening/saving files)
    static let musicDir: URL = homeDir.appendingPathComponent("/Music", isDirectory: true).resolvedURL
//    static let musicDir: URL = URL(fileURLWithPath: "/Volumes/MBP-Ext-4TB/Projects/Aural-Test/Aural-Music")
    
    static let baseDir: URL = musicDir.appendingPathComponent("aural", isDirectory: true)
    
    static let userDocumentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // App state/log files
    static let persistentStateFileName = "state.json"
    static let persistentStateFile: URL = baseDir.appendingPathComponent(persistentStateFileName, isDirectory: false)
    
    static let logFileName = "aural.log"
    static let logFile: URL = baseDir.appendingPathComponent(logFileName, isDirectory: false)
    
    static func subDirectory(named name: String) -> URL {
        baseDir.appendingPathComponent(name, isDirectory: true)
    }
}
