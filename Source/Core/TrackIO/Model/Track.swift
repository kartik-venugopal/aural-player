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
    
    init(_ file: URL, cueSheetMetadata: CueSheetMetadata? = nil, primaryMetadata: PrimaryMetadata? = nil) {

        self.file = file
        self.metadata = FileMetadata(file: file)
        self.metadata.primary = primaryMetadata
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
}

extension Track: CustomStringConvertible {
    
    var description: String {
        displayName
    }
}
