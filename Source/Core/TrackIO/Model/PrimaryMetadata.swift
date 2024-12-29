//
//  PrimaryMetadata.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A container for all metadata required for a track to be displayed within the playlist.
///
/// This is considered the most essential type of metadata and is loaded immediately when a track is added to the playlist.
///
/// The artist / album / genre fields help the playlist categorize tracks into groups also participate in searching and sorting.
///
class PrimaryMetadata {
    
    let playbackFormat: PlaybackFormat
    
    var title: String?
    var artist: String?
    var albumArtist: String?
    var album: String?
    var genre: String?
    
    var year: Int? {
        
        didSet {
            
            guard let year = self.year else {

                self.decade = nil
                return
            }
            
            let firstYearOfDecade = year - (year % 10)
            self.decade = "\(firstYearOfDecade)'s"
        }
    }
    
    private(set) var decade: String?
    
    var composer: String?
    var conductor: String?
    var performer: String?
    var lyricist: String?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var duration: Double = 0
    var durationIsAccurate: Bool = false
    
    var isProtected: Bool?
    
    var chapters: [Chapter] = []
    
    var bpm: Int?
    
    var lyrics: String?
    
    var nonEssentialMetadata: [String: MetadataEntry] = [:]
    
    var art: CoverArt?
    
    // Used by the metadata cache to determine whether or not to look for art
    var hasArt: Bool = false
    
    var replayGain: ReplayGain?
    
    var audioInfo: AudioInfo?
    
    init(audioFormat: AVAudioFormat) {
        self.playbackFormat = .init(audioFormat: audioFormat)
    }
}
