//
//  FileMetadata.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// A container for all possible metadata for a file / track.
///
struct FileMetadata {
    
    var playlist: PlaylistMetadata?
    var playback: PlaybackContextProtocol?
    
    var isPlayable: Bool {validationError == nil}
    var validationError: DisplayableError?
    
    var auxiliary: AuxiliaryMetadata?
    
    var coverArt: NSImage?
}
