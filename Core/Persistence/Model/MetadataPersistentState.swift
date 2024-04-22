//
//  MetadataPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct MetadataPersistentState: Codable {
    
    let metadata: [URL: PrimaryMetadataPersistentState]
}

struct PrimaryMetadataPersistentState: Codable {
    
    let title: String?
    let artist: String?
    let albumArtist: String?
    let album: String?
    let genre: String?
    let year: Int?
    
    let trackNumber: Int?
    let totalTracks: Int?
    
    let discNumber: Int?
    let totalDiscs: Int?
    
    let duration: Double?
    let isProtected: Bool?
    
    let chapters: [ChapterPersistentState]?
    
    init(metadata: PrimaryMetadata) {
        
        self.title = metadata.title
        self.artist = metadata.artist
        self.album = metadata.album
        self.albumArtist = metadata.albumArtist
        self.genre = metadata.genre
        self.year = metadata.year
        
        self.trackNumber = metadata.trackNumber
        self.totalTracks = metadata.totalTracks
        
        self.discNumber = metadata.discNumber
        self.totalDiscs = metadata.totalDiscs
        
        self.duration = metadata.duration
        self.isProtected = metadata.isProtected
        
        self.chapters = metadata.chapters.map {ChapterPersistentState(chapter: $0)}
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
