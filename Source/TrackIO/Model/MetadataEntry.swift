//
//  MetadataEntry.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// Encapsulates a single metadata entry
class MetadataEntry {
    
    // Type: e.g. ID3 or iTunes
    var format: MetadataFormat
    
    // Key or "tag"
    let key: String
    
    let value: String
    
    init(_ format: MetadataFormat, _ key: String, _ value: String) {
        
        self.format = format
        self.key = key
        self.value = value
    }
}
