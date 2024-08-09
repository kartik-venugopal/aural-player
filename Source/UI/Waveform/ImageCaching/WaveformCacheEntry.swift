//
//  WaveformImageCacheEntry.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import Foundation
import CoreGraphics

struct WaveformCacheLookup {
    
    let entry: WaveformCacheEntry
    let data: WaveformCacheData
}

struct WaveformPersistentState: Codable {
    
    let entries: [WaveformCacheEntryPersistentState]?
    
    init(entries: [WaveformCacheEntry]) {
        self.entries = entries.map {.init(entry: $0)}
    }
}

class WaveformCacheEntry: Codable, CustomStringConvertible {
    
    /// Unique identifier.
    let uuid: String
    
    /// Conformance to ``CustomStringConvertible``.
    var description: String {
        "WaveformImageCacheEntry - UUID: \(uuid). AudioFile: \(audioFile.lastPathComponent), imageSize: \(imageSize), lastOpenedTimestamp: \(lastOpenedTimestamp)"
    }
    
    let audioFile: URL
    let imageSize: CGSize
    
    ///
    /// Time when this file was rendered or last opened.
    ///
    /// This is used in LRU comparisons during cache culling.
    ///
    var lastOpenedTimestamp: CFAbsoluteTime
    
    init(audioFile: URL, imageSize: CGSize) {
        
        self.uuid = UUID().uuidString
        self.audioFile = audioFile
        self.imageSize = imageSize
        self.lastOpenedTimestamp = CFAbsoluteTimeGetCurrent()
    }
    
    init?(persistentState: WaveformCacheEntryPersistentState) {
        
        guard let uuid = persistentState.uuid,
              let audioFile = persistentState.audioFile,
              let imageSize = persistentState.imageSize else {
            
            return nil
        }
            
        self.uuid = uuid
        self.audioFile = audioFile
        self.imageSize = imageSize
        self.lastOpenedTimestamp = persistentState.lastOpenedTimestamp ?? CFAbsoluteTimeGetCurrent()
    }
    
    ///
    /// Updates the "last opened" timestamp to the current time.
    ///
    func updateLastOpenedTimestamp() {
        lastOpenedTimestamp = CFAbsoluteTimeGetCurrent()
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

struct WaveformCacheData: Codable {
    
    let samples: [[Float]]
}
