//
//  Track.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates all information about a single track
///
class Track: Hashable, PlayableItem {
    
    let file: URL
    var metadata: FileMetadata
    var playbackContext: PlaybackContextProtocol?
    
    init(_ file: URL, primaryMetadata: PrimaryMetadata? = nil, cueSheetMetadata: CueSheetMetadata? = nil) {

        self.file = file
        self.metadata = FileMetadata(file: file)
        
        if let primaryMetadata {
            self.metadata.updatePrimaryMetadata(with: primaryMetadata)
        }
        
        self.metadata.cueSheetMetadata = cueSheetMetadata
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
    
    deinit {
        playbackContext?.close()
    }
}

extension Track: CustomStringConvertible {
    
    var description: String {
        displayName
    }
}
