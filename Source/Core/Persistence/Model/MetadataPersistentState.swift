//
//  MetadataPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

struct MetadataPersistentState: Codable {
    
    let metadata: [URL: PrimaryMetadataPersistentState]?
    let coverArt: [URL: MD5String]?
}

struct PrimaryMetadataPersistentState: Codable {
    
    let playbackFormat: PlaybackFormatPersistentState?
    
    let title: String?
    let artist: String?
    let albumArtist: String?
    let album: String?
    let genre: String?
    let year: Int?
    
    var composer: String?
    var conductor: String?
    var performer: String?
    var lyricist: String?
    
    let trackNumber: Int?
    let totalTracks: Int?
    
    let discNumber: Int?
    let totalDiscs: Int?
    
    let duration: Double?
    let durationIsAccurate: Bool?
    let isProtected: Bool?
    
    var bpm: Int?
    
    var lyrics: String?
    
    var nonEssentialMetadata: [String: MetadataEntry] = [:]
    
    let chapters: [ChapterPersistentState]?
    
    var replayGain: ReplayGain?
    
    init(metadata: PrimaryMetadata) {
        
        self.playbackFormat = .init(format: metadata.playbackFormat)
        
        self.title = metadata.title
        self.artist = metadata.artist
        self.album = metadata.album
        self.albumArtist = metadata.albumArtist
        self.genre = metadata.genre
        self.year = metadata.year
        
        self.composer = metadata.composer
        self.conductor = metadata.conductor
        self.performer = metadata.performer
        self.lyricist = metadata.lyricist
        
        self.trackNumber = metadata.trackNumber
        self.totalTracks = metadata.totalTracks
        
        self.discNumber = metadata.discNumber
        self.totalDiscs = metadata.totalDiscs
        
        self.duration = metadata.duration
        self.durationIsAccurate = metadata.durationIsAccurate
        
        self.isProtected = metadata.isProtected
        
        self.bpm = metadata.bpm
        self.lyrics = metadata.lyrics
        self.nonEssentialMetadata = metadata.nonEssentialMetadata
        
        self.chapters = metadata.chapters.map {ChapterPersistentState(chapter: $0)}
        
        self.replayGain = metadata.replayGain
    }
}

struct PlaybackFormatPersistentState: Codable {
    
    let sampleRate: Double?
    let channelCount: AVAudioChannelCount?
    
    let layoutTag: AudioChannelLayoutTag?
    let channelBitmapRawValue: UInt32?
    
    init(format: PlaybackFormat) {
        
        self.sampleRate = format.sampleRate
        self.channelCount = format.channelCount
        self.layoutTag = format.layoutTag
        self.channelBitmapRawValue = format.channelBitmapRawValue
    }
}

struct ChapterPersistentState: Codable {
    
    let title: String?
    
    // Time bounds of this chapter
    let startTime: Double?
    let endTime: Double?
    let duration: Double?
    
    init(chapter: Chapter) {
        
        self.title = chapter.title
        
        self.startTime = chapter.startTime
        self.endTime = chapter.endTime
        self.duration = chapter.duration
    }
}
