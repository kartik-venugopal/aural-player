//
//  PersistenceManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Handles persistence to/from disk for application state.
*/
class PersistenceManager {
    
    let persistentStateFile: URL

    private let decoder = JSONDecoder()
    private lazy var encoder = JSONEncoder()
    
    init(persistentStateFile: URL) {
        self.persistentStateFile = persistentStateFile
    }
    
    func save<S>(_ state: S) where S: Codable {
        
        persistentStateFile.parentDir.createDirectory()
        
        do {
            
            guard let outputStream = OutputStream(url: persistentStateFile, append: false) else {
                
                NSLog("Error saving app state config file: Unable to open output file.")
                return
            }
            
            outputStream.open()
            defer {outputStream.close()}
            
            let data = try encoder.encode(state)
            
            JSONSerialization.writeJSONObject(data, to: outputStream, options: .prettyPrinted, error: nil)
            
        } catch let error as NSError {
           NSLog("Error saving app state config file: %@", error.description)
        }
    }
    
    func load<S>(type: S.Type) -> S? where S: Codable {
        
        do {
            
            guard let json = try String(contentsOf: persistentStateFile, encoding: .utf8).data(using: .utf8) else {
                
                NSLog("Error loading app state config file.")
                return nil
            }
            
            return try decoder.decode(S.self, from: json)
            
        } catch let error as NSError {
            NSLog("Error loading app state config file: %@", error.description)
        }
        
        return nil
    }
}
