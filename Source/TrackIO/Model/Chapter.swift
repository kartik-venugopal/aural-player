//
//  Chapter.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Represents a single chapter marking within a track.
///
class Chapter: CustomStringConvertible {
    
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
        self.duration = duration == nil ? max(endTime - startTime, 0) : duration!
    }
    
    // Convenience function to determine if a given track position lies within this chapter's time bounds
    func containsTimePosition(_ seconds: Double) -> Bool {
        return seconds >= startTime && seconds <= endTime
    }
    
    func correctEndTimeAndDuration(endTime: Double) {
        
        self.endTime = endTime
        self.duration = max(endTime - startTime, 0)
    }
   
    var description: String {
        "Title: \(title), startTime: \(startTime), endTime: \(endTime), duration: \(duration)"
    }
}
