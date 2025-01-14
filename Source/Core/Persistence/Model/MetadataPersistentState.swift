//
//  MetadataPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

struct MetadataPersistentState: Codable {
    
    let metadata: [URL: FileMetadataPersistentState]?
    let coverArt: [URL: MD5String]?
}

struct FileMetadataPersistentState: Codable {
    
    let playbackFormat: PlaybackFormatPersistentState?
    let audioInfo: AudioInfoPersistentState?
    
    let title: String?
    let artist: String?
    let albumArtist: String?
    let album: String?
    let genre: String?
    let year: Int?
    
    let composer: String?
    let conductor: String?
    let performer: String?
    let lyricist: String?
    
    let trackNumber: Int?
    let totalTracks: Int?
    
    let discNumber: Int?
    let totalDiscs: Int?
    
    let duration: Double?
    let durationIsAccurate: Bool?
    let isProtected: Bool?
    
    let bpm: Int?
    
    let lyrics: String?
    
    let timedLyrics: TimedLyricsPersistentState?
    
    let externalLyricsFile: URL?
    let lyricsDownloaded: Bool?
    
    let nonEssentialMetadata: [String: MetadataEntry]
    
    let chapters: [ChapterPersistentState]?
    
    let replayGain: ReplayGain?
    
    init(metadata: FileMetadata) {
        
        if let playbackFormat = metadata.playbackFormat {
            self.playbackFormat = .init(format: playbackFormat)
        } else {
            self.playbackFormat = nil
        }
        
        self.audioInfo = .init(audioInfo: metadata.audioInfo)
        
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
        
        if let timedLyrics = metadata.timedLyrics {
            self.timedLyrics = .init(lyrics: timedLyrics)
        } else {
            self.timedLyrics = nil
        }
        
        self.externalLyricsFile = metadata.externalLyricsFile
        self.lyricsDownloaded = metadata.lyricsDownloaded
        
        self.nonEssentialMetadata = metadata.nonEssentialMetadata
        
        self.chapters = metadata.chapters.map {ChapterPersistentState(chapter: $0)}
        
        self.replayGain = metadata.replayGain
    }
}

struct AudioInfoPersistentState: Codable {
    
    // The total number of frames in the track
    let frames: AVAudioFramePosition?
    
    // The sample rate of the track (in Hz)
    let sampleRate: Int32?
    
    // eg. "32-bit Floating point planar" or "Signed 16-bit Integer interleaved".
    let sampleFormat: String?
    
    // Number of audio channels
    let numChannels: Int?
    
    // Bit rate (in kbps)
    let bitRate: Int?
    
    // Audio format (e.g. "mp3", "aac", or "lpcm")
    let format: String?
    
    // The codec that was used to decode the track.
    let codec: String?
    
    // A description of the channel layout, eg. "5.1 Surround".
    let channelLayout: String?
    
    let replayGainFromMetadata: ReplayGain?
    let replayGainFromAnalysis: ReplayGain?
    
    init(audioInfo: AudioInfo) {
        
        self.frames = audioInfo.frames
        self.sampleRate = audioInfo.sampleRate
        self.sampleFormat = audioInfo.sampleFormat
        self.numChannels = audioInfo.numChannels
        self.bitRate = audioInfo.bitRate
        self.format = audioInfo.format
        self.codec = audioInfo.codec
        self.channelLayout = audioInfo.channelLayout
        self.replayGainFromMetadata = audioInfo.replayGainFromMetadata
        self.replayGainFromAnalysis = audioInfo.replayGainFromAnalysis
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

struct TimedLyricsPersistentState: Codable {
    
    let lines: [TimedLyricsLinePersistentState]?
    
    init(lyrics: TimedLyrics) {
        self.lines = lyrics.lines.map {.init(lyricsLine: $0)}
    }
}

struct TimedLyricsLinePersistentState: Codable {
    
    let content: String?
 
    let position: TimeInterval?
    let maxPosition: TimeInterval?
    
    let segments: [TimedLyricsLineSegmentPersistentState]?
    
    init(lyricsLine: TimedLyricsLine) {
        
        self.content = lyricsLine.content
        self.position = lyricsLine.position
        self.maxPosition = lyricsLine.maxPosition
        self.segments = lyricsLine.segments.map {.init(segment: $0)}
    }
}

struct TimedLyricsLineSegmentPersistentState: Codable {
    
    let startPos: TimeInterval?
    let endPos: TimeInterval?
    let range: NSRange?
    
    init(segment: TimedLyricsLineSegment) {
        
        self.startPos = segment.startPos
        self.endPos = segment.endPos
        self.range = segment.range
    }
}
