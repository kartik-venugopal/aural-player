//
//  PersistenceManager.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Handles persistence of application state to / from disk.
///
class PersistenceManager {
    
    let persistentStateFile: URL
    
    var persistentStateFileExists: Bool {
        persistentStateFile.exists
    }

    init(persistentStateFile: URL) {
        self.persistentStateFile = persistentStateFile
    }
    
    func save(persistentState: AppPersistentState) {
        
        persistentStateFile.parentDir.createDirectory()
        persistentState.save(toFile: persistentStateFile)
    }
    
    func load<S>(objectOfType type: S.Type) -> S? where S: Decodable {
        type.load(fromFile: persistentStateFile)
    }
}
