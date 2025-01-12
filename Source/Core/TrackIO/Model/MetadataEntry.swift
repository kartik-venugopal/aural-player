//
//  MetadataEntry.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates a single generic metadata key-value pair.
///
struct MetadataEntry: Codable {
    
    // Type: e.g. ID3 or iTunes
    let format: MetadataFormat
    
    // Key or "tag"
    let key: String
    
    let value: String
}
