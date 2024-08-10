//
//  WaveformPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct WaveformPersistentState: Codable {
    
    let cacheEntries: [WaveformCacheEntryPersistentState]?
    
    init(cacheEntries: [WaveformCacheEntry]) {
        self.cacheEntries = cacheEntries.map {.init(entry: $0)}
    }
}

struct WaveformCacheEntryPersistentState: Codable {
    
    let uuid: String?
    let audioFile: URL?
    let imageSize: CGSize?
    let lastOpenedTimestamp: CFAbsoluteTime?
    
    init(entry: WaveformCacheEntry) {
        
        self.uuid = entry.uuid
        self.audioFile = entry.audioFile
        self.imageSize = entry.imageSize
        self.lastOpenedTimestamp = entry.lastOpenedTimestamp
    }
}
