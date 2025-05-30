//
// Track+Metadata.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension Track {
    
    private static let minDurationForScrobblingOnLastFM: Double = 30      // 30 seconds
    
    var fileName: String {
        fileSystemInfo.fileNameWithExtension
    }
    
    var isNativelySupported: Bool {
        fileSystemInfo.isNativelySupported
    }
    
    var isPlayable: Bool {
        metadata.isPlayable
    }
    
    var playbackFormat: PlaybackFormat? {
        metadata.playbackFormat
    }
    
    var displayName: String {
        artistTitleString ?? defaultDisplayName
    }
    
    var defaultDisplayName: String {
        fileSystemInfo.defaultDisplayName
    }
    
    var duration: TimeInterval {
        metadata.duration
    }
    
    var durationIsAccurate: Bool {
        metadata.durationIsAccurate
    }
    
    var title: String? {
        metadata.title ?? metadata.cueSheetMetadata?.title
    }
    
    var titleOrDefaultDisplayName: String {
        title ?? defaultDisplayName
    }
    
    var artist: String? {
        metadata.artist ?? metadata.albumArtist ?? metadata.performer ?? cueSheetMetadata?.artist
    }
    
    var artistTitleString: String? {
        
        if let theArtist = artist, let theTitle = title {
            return "\(theArtist) - \(theTitle)"
        }
        
        return title
    }
    
    var titleAndArtist: (title: String, artist: String?) {
        (titleOrDefaultDisplayName, artist)
    }
    
    var album: String? {
        metadata.album
    }
    
    var genre: String? {
        metadata.genre
    }
    
    var albumArtist: String? {
        metadata.albumArtist
    }
    
    var canBeScrobbledOnLastFM: Bool {
        artist != nil && title != nil && duration > Self.minDurationForScrobblingOnLastFM
    }
    
    var composer: String? {
        metadata.composer
    }
    
    var conductor: String? {
        metadata.conductor
    }
    
    var performer: String? {
        metadata.performer
    }
    
    var lyricist: String? {
        metadata.lyricist
    }
    
    var art: CoverArt? {
        metadata.art
    }
    
    var trackNumber: Int? {
        metadata.trackNumber
    }
    
    var totalTracks: Int? {
        metadata.totalTracks
    }
    
    var discNumber: Int? {
        metadata.discNumber
    }
    
    var totalDiscs: Int? {
        metadata.totalDiscs
    }
    
    var year: Int? {
        metadata.year
    }
    
    var decade: String? {
        metadata.decade
    }

    var bpm: Int? {
        metadata.bpm
    }

    var lyrics: String? {
        metadata.lyrics
    }
    
    var timedLyrics: TimedLyrics? {
        metadata.timedLyrics
    }
    
    var externalTimedLyrics: TimedLyrics? {
        metadata.externalTimedLyrics
    }
    
    var externalOrEmbeddedTimedLyrics: TimedLyrics? {
        metadata.externalTimedLyrics ?? metadata.timedLyrics
    }
    
    var hasLyrics: Bool {
        metadata.lyrics != nil || metadata.timedLyrics != nil || metadata.externalTimedLyrics != nil
    }
    
    var hasExternalLyrics: Bool {
        metadata.externalTimedLyrics != nil
    }
    
    // Non-essential metadata
    var nonEssentialMetadata: [String: MetadataEntry] {
        metadata.nonEssentialMetadata
    }

    var cueSheetMetadata: CueSheetMetadata? {
        metadata.cueSheetMetadata
    }

    var chapters: [Chapter] {
        metadata.chapters
    }
    
    var hasChapters: Bool {
        !chapters.isEmpty
    }
    
    var replayGain: ReplayGain? {
        metadata.replayGain
    }
    
    var audioInfo: AudioInfo {
        metadata.audioInfo
    }
    
//    func setPrimaryMetadata(from allMetadata: FileMetadata) {
//        
//        self.isPlayable = allMetadata.isPlayable
//        self.validationError = allMetadata.validationError
//        
//        guard let metadata: PrimaryMetadata = allMetadata.primary else {return}
//        
//        self.title = metadata.title ?? cueSheetMetadata?.title
//        
//        self.theArtist = metadata.artist ?? cueSheetMetadata?.artist
//        self.albumArtist = metadata.albumArtist ?? cueSheetMetadata?.albumArtist
//        self.performer = metadata.performer
//        
//        // If Cue sheet performer has not been used, and it's available, use it
//        if metadata.artist != nil, self.performer == nil, cueSheetMetadata?.artist != metadata.artist {
//            self.performer = cueSheetMetadata?.artist
//        }
//        
//        self.album = metadata.album ?? cueSheetMetadata?.album
//        self.genre = metadata.genre ?? cueSheetMetadata?.genre
//        self.year = metadata.year
//        
//        if self.year == nil, let cueSheetDate = cueSheetMetadata?.date {
//            self.year = Int(cueSheetDate)
//        }
//        
//        self.composer = metadata.composer ?? cueSheetMetadata?.composer
//        self.conductor = metadata.conductor
//        self.lyricist = metadata.lyricist
//        
//        self.nonEssentialMetadata = metadata.nonEssentialMetadata
//        
//        self.bpm = metadata.bpm
//        self.year = metadata.year
//
//        self.lyrics = metadata.lyrics
//
//        self.trackNumber = metadata.trackNumber
//        self.totalTracks = metadata.totalTracks
//        
//        self.discNumber = metadata.discNumber
//        self.totalDiscs = metadata.totalDiscs
//        
//        self.duration = metadata.duration
//        self.durationIsAccurate = metadata.durationIsAccurate
//        
//        if metadata.chapters.isNonEmpty {
//            self.chapters = metadata.chapters
//            
//        } else if let cueSheetChapters = cueSheetMetadata?.chapters, cueSheetChapters.isNonEmpty {
//            self.chapters = cueSheetChapters
//        }
//        
//        correctChapterTimes()
//        
//        self.art = metadata.art
//        
//        // Cue sheet metadata
//        
//        if let cueSheetDiscID = cueSheetMetadata?.discID {
//            nonEssentialMetadata["DiscID"] = MetadataEntry(format: .other, key: "DiscID", value: cueSheetDiscID)
//        }
//        
//        if let cueSheetComment = cueSheetMetadata?.comment {
//            
//            let hasExistingCommentField = nonEssentialMetadata.contains(where: {$1.key == "Comment"})
//            let key = hasExistingCommentField ? "Additional Comment" : "Comment"
//            
//            nonEssentialMetadata[key] = MetadataEntry(format: .other, key: key, value: cueSheetComment)
//        }
//        
//        for (key, value) in cueSheetMetadata?.auxiliaryMetadata ?? [:] {
//            
//            let hasExistingKey = nonEssentialMetadata.contains(where: {$1.key == key})
//            let theKey = hasExistingKey ? "(Cue sheet) \(key)" : key
//            
//            nonEssentialMetadata[theKey] = MetadataEntry(format: .other, key: theKey, value: value)
//        }
//        
//        self.replayGain = metadata.replayGain ?? cueSheetMetadata?.replayGain
//    }
    
//    private func correctChapterTimes() {
//        
//        if let lastChapter = self.chapters.last, lastChapter.endTime == 0 || lastChapter.duration == 0 {
//            
//            // Correct the end time of the last chapter, if necessary.
//            lastChapter.correctEndTimeAndDuration(endTime: self.duration)
//        }
//        
//        guard chapters.count > 1 else {return}
//        
//        var previousChapter = chapters[0]
//        
//        for index in 1..<chapters.count {
//            
//            let chapter = chapters[index]
//            
//            if chapter.startTime == 0 {
//                chapter.correctStartTimeAndDuration(startTime: previousChapter.endTime)
//            }
//            
//            previousChapter = chapter
//        }
//        
//        var nextChapter = chapters[1]
//        
//        for index in 0..<(chapters.lastIndex) {
//            
//            nextChapter = chapters[index + 1]
//            
//            let chapter = chapters[index]
//            
//            if chapter.endTime == 0 {
//                chapter.correctEndTimeAndDuration(endTime: nextChapter.startTime)
//            }
//        }
//    }
}
