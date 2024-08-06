//
//  Chapter.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Represents a single chapter marking within a track.
///
class Chapter: Codable {
    
    // Title may be changed / corrected after chapter object is created
    var title: String
    
    // Time bounds of this chapter
    let startTime: Double
    var endTime: Double
    var duration: Double
    
    init(title: String, startTime: Double, endTime: Double, duration: Double? = nil) {
        
        self.title = title
        
        self.startTime = startTime
        self.endTime = endTime
        
        // Use duration if provided. Otherwise, compute it from the start and end times.
        self.duration = duration ?? max(endTime - startTime, 0)
    }
    
    convenience init?(persistentState: ChapterPersistentState, index: Int) {
        
        guard let startTime = persistentState.startTime, let endTime = persistentState.endTime else {return nil}
        
        let title: String
        
        if let theTitle = persistentState.title, !theTitle.isEmptyAfterTrimming {
            title = theTitle
        } else {
            title = "Chapter \(index + 1)"
        }
        
        self.init(title: title, startTime: startTime, endTime: endTime)
    }
    
    // Convenience function to determine if a given track position lies within this chapter's time bounds
    func containsTimePosition(_ seconds: Double) -> Bool {
        seconds >= startTime && seconds <= endTime
    }
    
    func correctEndTimeAndDuration(endTime: Double) {
        
        self.endTime = endTime
        self.duration = max(endTime - startTime, 0)
    }
   
    var description: String {
        "Title: \(title), startTime: \(startTime), endTime: \(endTime), duration: \(duration)"
    }
}
