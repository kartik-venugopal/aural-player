//
//  Chapter.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Represents a single chapter marking within a track
 */
class Chapter {
    
    // Title may be changed / corrected after chapter object is created
    var title: String
    
    // Time bounds of this chapter
    let startTime: Double
    let endTime: Double
    let duration: Double
    
    init(_ title: String, _ startTime: Double, _ endTime: Double, _ duration: Double? = nil) {
        
        self.title = title
        
        self.startTime = startTime
        self.endTime = endTime
        
        // Use duration if provided. Otherwise, compute it from the start and end times.
        self.duration = duration == nil ? max(endTime - startTime, 0) : duration!
    }
    
    init(_ ffmpegChapter: FFmpegChapter) {
        
        self.title = ffmpegChapter.title
        
        self.startTime = ffmpegChapter.startTime
        self.endTime = ffmpegChapter.endTime
        
        self.duration = max(endTime - startTime, 0)
    }
    
    // Convenience function to determine if a given track position lies within this chapter's time bounds
    func containsTimePosition(_ seconds: Double) -> Bool {
        return seconds >= startTime && seconds <= endTime
    }
}

// Wrapper around Chapter that includes its parent track and chronological index
class IndexedChapter: Equatable {
    
    // The track to which this chapter belongs
    let track: Track
    
    // The chapter this object represents
    let chapter: Chapter
    
    // The chronological index of this chapter within the track
    let index: Int
    
    init(_ track: Track, _ chapter: Chapter, _ index: Int) {
        
        self.track = track
        self.chapter = chapter
        self.index = index
    }
    
    static func == (lhs: IndexedChapter, rhs: IndexedChapter) -> Bool {
        return lhs.track == rhs.track && lhs.index == rhs.index
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(track.file.path)
        hasher.combine(index)
    }
}
