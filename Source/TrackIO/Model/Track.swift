//
//  Track.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

/*
    Encapsulates all information about a single track
 */
class Track: Hashable, PlaylistItem {
    
    let file: URL
    let isNativelySupported: Bool
    
    var playbackContext: PlaybackContextProtocol?
    
    var isPlayable: Bool = true
    var validationError: DisplayableError?
    
    var preparationFailed: Bool = false
    var preparationError: DisplayableError?
    
    let defaultDisplayName: String
    
    var displayName: String {
        artistTitleString ?? defaultDisplayName
    }
    
    var duration: Double = 0
    var durationIsAccurate: Bool = false

    var title: String?
    
    private var theArtist: String?
    
    var artist: String? {
        theArtist ?? albumArtist ?? performer
    }
    
    var artistTitleString: String? {
        
        if let theArtist = artist, let theTitle = title {
            return "\(theArtist) - \(theTitle)"
        }
        
        return title
    }
    
    var albumArtist: String?
    var album: String?
    var genre: String?
    
    var composer: String?
    var conductor: String?
    var performer: String?
    var lyricist: String?
    
    var art: CoverArt?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var year: Int?
    
    var bpm: Int?
    
    var lyrics: String?
    
    // Non-essential metadata
    var auxiliaryMetadata: [String: MetadataEntry] = [:]
    
    var chapters: [Chapter] = []
    var hasChapters: Bool {!chapters.isEmpty}
    
    var fileSystemInfo: FileSystemInfo
    var audioInfo: AudioInfo?
    
    init(_ file: URL, fileMetadata: FileMetadata? = nil) {

        self.file = file
        self.fileSystemInfo = FileSystemInfo(file)
        
        self.defaultDisplayName = file.deletingPathExtension().lastPathComponent
        
        self.isNativelySupported = file.isNativelySupported
        
        if let theFileMetadata = fileMetadata {
            setPlaylistMetadata(from: theFileMetadata)
        }
    }
    
    func setPlaylistMetadata(from allMetadata: FileMetadata) {
        
        self.isPlayable = allMetadata.isPlayable
        self.validationError = allMetadata.validationError
        
        guard let metadata: PlaylistMetadata = allMetadata.playlist else {return}
        
        self.title = metadata.title
        
        self.theArtist = metadata.artist
        self.albumArtist = metadata.albumArtist
        self.performer = metadata.performer
        
        self.album = metadata.album
        self.genre = metadata.genre

        self.trackNumber = metadata.trackNumber
        self.totalTracks = metadata.totalTracks
        
        self.discNumber = metadata.discNumber
        self.totalDiscs = metadata.totalDiscs
        
        self.duration = metadata.duration
        self.durationIsAccurate = metadata.durationIsAccurate
        
        self.chapters = metadata.chapters
    }
    
    func setAuxiliaryMetadata(_ metadata: AuxiliaryMetadata) {
        
        self.composer = metadata.composer
        self.conductor = metadata.conductor
        self.lyricist = metadata.lyricist
        
        self.bpm = metadata.bpm
        self.year = metadata.year

        self.lyrics = metadata.lyrics
        self.auxiliaryMetadata = metadata.auxiliaryMetadata
        
        self.fileSystemInfo = metadata.fileSystemInfo ?? self.fileSystemInfo
        self.audioInfo = metadata.audioInfo
        
        self.auxMetadataLoaded = true
    }
    
    var auxMetadataLoaded: Bool = false
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.file == rhs.file
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(file.path)
    }
}

// Wrapper around Track that includes its location within a group in a hierarchical playlist
struct GroupedTrack {
    
    let track: Track
    let group: Group
    
    let trackIndex: Int
    let groupIndex: Int
    
    init(_ track: Track, _ group: Group, _ trackIndex: Int, _ groupIndex: Int) {
        
        self.track = track
        self.group = group
        self.trackIndex = trackIndex
        self.groupIndex = groupIndex
    }
}
