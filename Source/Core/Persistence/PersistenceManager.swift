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

fileprivate let logger: Logger = .init()

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
    
    var persistentStateJSONData: Data? {
        
        do {
            return try String(contentsOf: persistentStateFile, encoding: .utf8).data(using: .utf8)
            
        } catch {
            
            logger.error("Error loading app state config file: \(error)")
            return nil
        }
    }
    
    func load<S>(objectOfType type: S.Type) -> S? where S: Decodable {
        type.load(fromFile: persistentStateFile)
    }
    
    func load<S>(objectOfType type: S.Type, fromJSONData data: Data) -> S? where S: Decodable {
        type.load(fromJSONData: data)
    }
    
    func loadMetadata() -> MetadataPersistentState? {
        MetadataPersistentState.load(fromFile: metadataStateFile)
    }
}
