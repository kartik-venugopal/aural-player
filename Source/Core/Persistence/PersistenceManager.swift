//
//  PersistenceManager.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    let metadataStateFile: URL
    
    var persistentStateFileExists: Bool {
        persistentStateFile.exists
    }

    init(persistentStateFile: URL, metadataStateFile: URL) {
        
        self.persistentStateFile = persistentStateFile
        self.metadataStateFile = metadataStateFile
    }
    
    func save(metadataState: MetadataPersistentState) {
        
        metadataStateFile.parentDir.createDirectory()
        metadataState.save(toFile: metadataStateFile)
    }
    
    func save(persistentState: AppPersistentState) {
        
        persistentStateFile.parentDir.createDirectory()
        persistentState.save(toFile: persistentStateFile)
    }
    
    func load<S>(objectOfType type: S.Type) -> S? where S: Decodable {
        type.load(fromFile: persistentStateFile)
    }
    
    func loadMetadata() -> MetadataPersistentState? {
        MetadataPersistentState.load(fromFile: metadataStateFile)
    }
}
