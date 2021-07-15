//
//  AuxiliaryMetadata.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A container for all non-essential metadata for a file / track.
///
/// This metadata will be loaded only when the user requests detailed track information.
///
struct AuxiliaryMetadata {
    
    var composer: String?
    var conductor: String?
    var lyricist: String?
    
    var year: Int?
    
    var bpm: Int?
    
    var lyrics: String?
    
    var auxiliaryMetadata: [String: MetadataEntry] = [:]
    
    var fileSystemInfo: FileSystemInfo?
    var audioInfo: AudioInfo?
}
