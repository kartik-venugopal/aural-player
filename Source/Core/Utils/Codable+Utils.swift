//
//  Codable+Utils.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension Encodable {
    
    func save(toFile file: URL) {
        
        file.parentDir.createDirectory()
        
        do {
            
            let data = try jsonEncoder.encode(self)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                try jsonString.write(to: file, atomically: true, encoding: .utf8)
            } else {
                NSLog("Error saving Encodable: Unable to create String from JSON data.")
            }
            
        } catch let error as NSError {
            NSLog("Error saving Encodable \(self) to file \(file.path). Error: \(error.description)")
        }
    }
}

extension Decodable where Self: Decodable {
    
    static func load(fromFile file: URL) -> Self? {
        
        do {
            
            let jsonString = try String(contentsOf: file, encoding: .utf8)
            guard let jsonData = jsonString.data(using: .utf8) else {return nil}
            return try jsonDecoder.decode(Self.self, from: jsonData)
            
        } catch let error as NSError {
            NSLog("Error loading Decodable of type \(Self.self) from file \(file.path). Error: \(error.description)")
        }
        
        return nil
    }
}
