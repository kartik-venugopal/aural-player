//
// TimedLyrics.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import LyricsCore

struct TimedLyrics {
    
    let lines: [TimedLyricsLine]
    
    init(from lyrics: LyricsCore.Lyrics, trackDuration: TimeInterval) {
        
        let offset = lyrics.offset
        let maxPossiblePosition = trackDuration - 0.001
        
        // TODO: Validate duration vs time/duration of last lyrics line ?
        
        self.lines = lyrics.lines.enumerated().map {index, line in
            
            let position = max(0, line.position - offset)
            let maxPosition = min(lyrics.maxPosition(ofLineAtIndex: index, maxPossiblePosition: maxPossiblePosition) - offset, trackDuration)
            
            return TimedLyricsLine(content: line.content, position: position, maxPosition: maxPosition)
        }
    }
    
    init?(persistentState: TimedLyricsPersistentState) {
        
        self.lines = persistentState.lines?.compactMap {TimedLyricsLine.init(persistentState: $0)} ?? []
        guard lines.isNonEmpty else {return nil}
    }
    
    func currentLine(at position: TimeInterval) -> Int? {
        
        var left = 0
        var right = lines.count - 1

        while left <= right {
            
            let mid = (left + right) / 2
            let line = lines[mid]
            
            switch line.relativePosition(to: position) {
                
            case .match:
                return mid
                
            case .left:
                left = mid + 1
                
            case .right:
                right = mid - 1
            }
        }
        
        return nil
    }
}

struct TimedLyricsLine {
    
    let content: String
    let position: TimeInterval
    var maxPosition: TimeInterval
    
    init(content: String, position: TimeInterval, maxPosition: TimeInterval) {
        
        self.content = content
        self.position = position
        self.maxPosition = maxPosition
    }
    
    init?(persistentState: TimedLyricsLinePersistentState) {
        
        guard let content = persistentState.content,
              let position = persistentState.position,
        let maxPosition = persistentState.maxPosition else {return nil}
        
        self.content = content
        self.position = position
        self.maxPosition = maxPosition
    }
    
    fileprivate func relativePosition(to target: TimeInterval) -> LyricsLineRelativePosition {
        
        if target < position {
            return .right
        }
        
        if target > maxPosition {
            return .left
        }
        
        return .match
    }
    
    func isCurrent(atPosition target: TimeInterval) -> Bool {
        target >= position && target <= maxPosition
    }
}
