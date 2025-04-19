//
//  FileMetadata.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A container for all possible metadata for a file / track.
///
class FileMetadata {

    var audioInfo: AudioInfo
    
    // ------------------------------------------------
    
    var playbackFormat: PlaybackFormat?
    
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
    
    var duration: TimeInterval = 0
    var durationIsAccurate: Bool = false
    
    var isProtected: Bool?
    
    var chapters: [Chapter] = []
    
    var bpm: Int?
    
    var lyrics: String?
    
    var timedLyrics: TimedLyrics?
    
    var externalLyricsFile: URL?
    var externalTimedLyrics: TimedLyrics?
    var lyricsDownloaded: Bool = false
    
    var nonEssentialMetadata: [String: MetadataEntry] = [:]
    
    var art: CoverArt?
    
    // Used by the metadata cache to determine whether or not to look for art
    var hasArt: Bool {art != nil}
    
    var replayGain: ReplayGain?
    
    var cueSheetMetadata: CueSheetMetadata?
    
    // ----------------------------------------------------
    
    var isPlayable: Bool {validationError == nil}
    var validationError: DisplayableError?
    
    var preparationFailed: Bool = false
    var preparationError: DisplayableError?
    
    init() {
        self.audioInfo = .init()
    }
    
    init?(persistentState: FileMetadataPersistentState, persistentCoverArt: CoverArt?) {
        
        if let audioInfo = persistentState.audioInfo {
            self.audioInfo = .init(persistentState: audioInfo)
        } else {
            self.audioInfo = .init()
        }
        
        guard let playbackFormatState = persistentState.playbackFormat,
              let playbackFormat = PlaybackFormat(persistentState: playbackFormatState) else {return nil}
        
        self.playbackFormat = playbackFormat
        
        self.title = persistentState.title
        self.artist = persistentState.artist
        self.album = persistentState.album
        self.albumArtist = persistentState.albumArtist
        self.genre = persistentState.genre
        self.year = persistentState.year
        
        self.composer = persistentState.composer
        self.conductor = persistentState.conductor
        self.performer = persistentState.performer
        self.lyricist = persistentState.lyricist
        
        self.trackNumber = persistentState.trackNumber
        self.totalTracks = persistentState.totalTracks
        
        self.discNumber = persistentState.discNumber
        self.totalDiscs = persistentState.totalDiscs
        
        self.duration = persistentState.duration ?? 0
        self.durationIsAccurate = persistentState.durationIsAccurate ?? true
        
        self.isProtected = persistentState.isProtected
        
        self.chapters = (persistentState.chapters ?? []).enumerated().compactMap {Chapter.init(persistentState: $1, index: $0)}
        
        self.bpm = persistentState.bpm
        self.lyrics = persistentState.lyrics
        
        if let timedLyrics = persistentState.timedLyrics {
            self.timedLyrics = .init(persistentState: timedLyrics)
        }
        
        self.externalLyricsFile = persistentState.externalLyricsFile
        
        if let lyricsDownloaded = persistentState.lyricsDownloaded {
            self.lyricsDownloaded = lyricsDownloaded
        }
        
        self.nonEssentialMetadata = persistentState.nonEssentialMetadata
        
        self.art = persistentCoverArt
    }
    
    func updatePrimaryMetadata(with metadata: PrimaryMetadata) {
        
        self.playbackFormat = metadata.playbackFormat
        
        self.title = metadata.title
        self.artist = metadata.artist
        self.album = metadata.album
        self.albumArtist = metadata.albumArtist
        self.genre = metadata.genre
        
        self.year = metadata.year
        
        self.trackNumber = metadata.trackNumber
        self.discNumber = metadata.discNumber
        
        self.totalTracks = metadata.totalTracks
        self.totalDiscs = metadata.totalDiscs
        
        self.composer = metadata.composer
        self.conductor = metadata.conductor
        self.performer = metadata.performer
        self.lyricist = metadata.lyricist
        
        self.duration = metadata.duration
        self.durationIsAccurate = metadata.durationIsAccurate
        
        self.isProtected = metadata.isProtected
        
        self.chapters = metadata.chapters
        
        self.bpm = metadata.bpm
        self.lyrics = metadata.lyrics
        self.timedLyrics = metadata.timedLyrics
        self.nonEssentialMetadata = metadata.nonEssentialMetadata
        
        self.art = metadata.art
        
        if let audioInfo = metadata.audioInfo {
            self.audioInfo = audioInfo
        }
    }
}
