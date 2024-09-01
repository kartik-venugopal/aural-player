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
class FileMetadata {

    let fileSystemInfo: FileSystemInfo
    
    var primary: PrimaryMetadata?
    var cueSheet: CueSheetMetadata?
    var audioInfo: AudioInfo?
    
    var isPlayable: Bool {validationError == nil}
    var validationError: DisplayableError?
    
    var preparationFailed: Bool = false
    var preparationError: DisplayableError?
    
    init(file: URL) {
        self.fileSystemInfo = FileSystemInfo(file: file)
    }
}
