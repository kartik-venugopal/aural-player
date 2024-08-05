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
class Track: Hashable, PlaylistItem, PlayableItem {
    
    private static let minDurationForScrobblingOnLastFM: Double = 30      // 30 seconds
    
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
    
    var titleOrDefaultDisplayName: String {
        title ?? defaultDisplayName
    }
    
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
    
    var canBeScrobbledOnLastFM: Bool {
        artist != nil && title != nil && duration > Self.minDurationForScrobblingOnLastFM
    }
    
    var titleAndArtist: (title: String, artist: String?) {
        (title ?? defaultDisplayName, artist)
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
    
    var decade: String? {
        
        guard let year = self.year else {return nil}
        let firstYearOfDecade = year - (year % 10)
        return "\(firstYearOfDecade)'s"
    }
    
    var bpm: Int?
    
    var lyrics: String?
    
    // Non-essential metadata
    var auxiliaryMetadata: [String: MetadataEntry] = [:]
    
    var cueSheetMetadata: CueSheetMetadata?
    
    var chapters: [Chapter] = []
    var hasChapters: Bool {!chapters.isEmpty}
    
    var fileSystemInfo: FileSystemInfo
    var audioInfo: AudioInfo?
    
    init(_ file: URL, cueSheetMetadata: CueSheetMetadata? = nil, fileMetadata: FileMetadata? = nil) {

        self.file = file
        self.defaultDisplayName = file.nameWithoutExtension
        self.fileSystemInfo = FileSystemInfo(file: file, fileName: self.defaultDisplayName)
        
        self.isNativelySupported = file.isNativelySupported
        
        self.cueSheetMetadata = cueSheetMetadata
        
        if let theFileMetadata = fileMetadata {
            setPrimaryMetadata(from: theFileMetadata)
        }
    }
    
    func setPrimaryMetadata(from allMetadata: FileMetadata) {
        
        self.isPlayable = allMetadata.isPlayable
        self.validationError = allMetadata.validationError
        
        guard let metadata: PrimaryMetadata = allMetadata.primary else {return}
        
        self.title = metadata.title ?? cueSheetMetadata?.title
        
        self.theArtist = metadata.artist ?? cueSheetMetadata?.performer
        self.albumArtist = metadata.albumArtist ?? cueSheetMetadata?.albumPerformer
        self.performer = metadata.performer
        
        // If Cue sheet performer has not been used, and it's available, use it
        if metadata.artist != nil, self.performer == nil, cueSheetMetadata?.performer != metadata.artist {
            self.performer = cueSheetMetadata?.performer
        }
        
        self.album = metadata.album ?? cueSheetMetadata?.album
        self.genre = metadata.genre ?? cueSheetMetadata?.genre
        self.year = metadata.year
        
        if self.year == nil, let cueSheetDate = cueSheetMetadata?.date {
            self.year = Int(cueSheetDate)
        }
        
        self.composer = metadata.composer
        self.conductor = metadata.conductor
        self.lyricist = metadata.lyricist
        
        self.auxiliaryMetadata = metadata.auxiliaryMetadata
        
        self.bpm = metadata.bpm
        self.year = metadata.year

        self.lyrics = metadata.lyrics

        self.trackNumber = metadata.trackNumber
        self.totalTracks = metadata.totalTracks
        
        self.discNumber = metadata.discNumber
        self.totalDiscs = metadata.totalDiscs
        
        self.duration = metadata.duration
        self.durationIsAccurate = metadata.durationIsAccurate
        
        if metadata.chapters.isNonEmpty {
            self.chapters = metadata.chapters
            
        } else if let cueSheetChapters = cueSheetMetadata?.chapters, cueSheetChapters.isNonEmpty {
            self.chapters = cueSheetChapters
        }
        
        if let lastChapter = self.chapters.last, lastChapter.duration == 0 {
            
            // Correct the end time of the last chapter, if necessary.
            lastChapter.correctEndTimeAndDuration(endTime: metadata.duration)
        }
        
        self.art = metadata.art
        
        // Cue sheet metadata
        
        if let cueSheetDiscID = cueSheetMetadata?.discID {
            auxiliaryMetadata["DiscID"] = MetadataEntry(format: .other, key: "DiscID", value: cueSheetDiscID)
        }
        
        if let cueSheetComment = cueSheetMetadata?.comment {
            
            let hasExistingCommentField = auxiliaryMetadata.contains(where: {$1.key == "Comment"})
            let key = hasExistingCommentField ? "Additional Comment" : "Comment"
            
            auxiliaryMetadata[key] = MetadataEntry(format: .other, key: key, value: cueSheetComment)
        }
    }
    
    func setAuxiliaryMetadata(_ metadata: AuxiliaryMetadata) {
        
//        self.auxiliaryMetadata = metadata
        self.audioInfo = metadata.audioInfo
        self.auxMetadataLoaded = true
    }
    
    var auxMetadataLoaded: Bool = false
    
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
