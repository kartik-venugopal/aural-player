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

    private let decoder: JSONDecoder = JSONDecoder()
    
    private lazy var encoder: JSONEncoder = {
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        return encoder
    }()
    
    init(persistentStateFile: URL) {
        self.persistentStateFile = persistentStateFile
    }
    
    func save<S>(_ state: S) where S: Codable {
        
        persistentStateFile.parentDir.createDirectory()
        
        do {
            
            let data = try encoder.encode(state)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                try jsonString.write(to: persistentStateFile, atomically: true, encoding: .utf8)
            } else {
                NSLog("Error saving app state config file: Unable to create String from JSON data.")
            }
            
        } catch let error as NSError {
           NSLog("Error saving app state config file: %@", error.description)
        }
    }
    
    func load<S>(type: S.Type) -> S? where S: Codable {
        
        do {
            
            let jsonString = try String(contentsOf: persistentStateFile, encoding: .utf8)
            guard let jsonData = jsonString.data(using: .utf8) else {return nil}
            return try decoder.decode(S.self, from: jsonData)
            
        } catch let error as NSError {
            NSLog("Error loading app state config file: %@", error.description)
        }
        
        return nil
    }
}
