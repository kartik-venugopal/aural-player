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
    
    init(persistentStateFile: URL) {
        self.persistentStateFile = persistentStateFile
    }
    
    func save<S>(_ state: S) where S: PersistentStateProtocol {
        
        FilesAndPaths.baseDir.createDirectory()
        
        let jsonObject = JSONMapper.map(state)
        
        do {
            
            try JSONSerialization.writeObject(jsonObject, toFile: persistentStateFile, failSilently: true)
            
        } catch let error as NSError {
           NSLog("Error saving app state config file: %@", error.description)
        }
    }
    
    func load<S>(type: S.Type) -> S? where S: PersistentStateProtocol {
        
        guard let inputStream = InputStream(url: persistentStateFile) else {return nil}
            
        inputStream.open()
        defer {inputStream.close()}
        
        do {
            
            let data = try JSONSerialization.jsonObject(with: inputStream, options: JSONSerialization.ReadingOptions())
            
            if let dictionary = data as? NSDictionary {
                return S.init(dictionary)
            }
            
        } catch let error as NSError {
            NSLog("Error loading app state config file: %@", error.description)
        }
        
        return nil
    }
}
