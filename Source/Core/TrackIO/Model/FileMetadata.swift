//
//  FileMetadata.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A container for all possible metadata for a file / track.
///
struct FileMetadata {
   
    var primary: PrimaryMetadata?
    var audioInfo: AudioInfo?
    
    var isPlayable: Bool {validationError == nil}
    var validationError: DisplayableError?
    
    init(primary: PrimaryMetadata? = nil, audioInfo: AudioInfo? = nil) {
        
        self.primary = primary
        self.audioInfo = audioInfo
    }
}
