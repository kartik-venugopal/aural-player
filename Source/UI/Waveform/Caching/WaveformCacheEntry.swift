//
//  WaveformCacheEntry.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import CoreGraphics

class WaveformCacheEntry: Codable {
    
    /// Unique identifier.
    let uuid: String
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

extension WaveformCacheEntry: CustomStringConvertible {
    
    var description: String {
        "WaveformImageCacheEntry - UUID: \(uuid). AudioFile: \(audioFile.lastPathComponent), imageSize: \(imageSize), lastOpenedTimestamp: \(lastOpenedTimestamp)"
    }
}

///
/// Downsampled data to be cached for a single waveform render.
///
struct WaveformCacheData: Codable {
    
    let samples: [[Float]]
}

///
/// Container type to hold the result of a successful cache lookup.
///
struct WaveformCacheLookup {
    
    let entry: WaveformCacheEntry
    let data: WaveformCacheData
}
