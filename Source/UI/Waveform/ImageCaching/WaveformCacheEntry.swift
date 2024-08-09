//
//  WaveformImageCacheEntry.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import Foundation
import CoreGraphics

protocol WaveformImageCacheable {
    
    var imageSize: CGSize {get}
}

struct WaveformCacheLookup {
    
    let entry: WaveformCacheEntry
    let data: WaveformCacheData
}

///
/// Represents a single waveform image cache entry.
///
/// **Notes**
///
/// * Instances of this class will *not* contain any image data
/// (i.e. NSImage / UIImage). But they will contain info (a mapping
/// of audio file -> image file) that can be used to create an
/// NSImage / UIImage from an image file on disk.
///
/// * Entries of this kind will be stored in ``UserDefaults``, so they
/// must conform to ``Codable``.
///
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
    
    ///
    /// Updates the "last opened" timestamp to the current time.
    ///
    func updateLastOpenedTimestamp() {
        lastOpenedTimestamp = CFAbsoluteTimeGetCurrent()
    }
}

struct WaveformCacheData: Codable {
    
    let samples: [[Float]]
}
