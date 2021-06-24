//
//  FilesAndPaths.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct FilesAndPaths {
    
    // Default user's music directory (default place to look in, when opening/saving files)
    static let musicDir: URL = URL(fileURLWithPath: NSHomeDirectory() + "/Music").resolvedURL
    static let baseDir: URL = musicDir.appendingPathComponent("aural", isDirectory: true)
    
    // App state/log files
    static let persistentStateFileName = "state.json"
    static let persistentStateFile: URL = baseDir.appendingPathComponent(persistentStateFileName)
    
    static let logFileName = "aural.log"
    static let logFile: URL = baseDir.appendingPathComponent(logFileName)
    
    // Directory where recordings are temporarily stored, till the user defines the location
    static let recordingsDir: URL = baseDir.appendingPathComponent("recordings", isDirectory: true)
}
