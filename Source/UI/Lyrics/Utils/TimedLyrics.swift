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
import LyricsXCore

struct TimedLyrics {
    
    let lines: [TimedLyricsLine]
    
    init(from lyrics: LyricsCore.Lyrics, trackDuration: TimeInterval) {
        
        let offset = lyrics.offset
        let maxPossiblePosition = trackDuration - 0.001
        
        // TODO: Validate duration vs time/duration of last lyrics line ?
        
        self.lines = lyrics.lines.enumerated().map {index, line in
            
            let position = max(0, line.position - offset)
            let maxPosition = min(lyrics.maxPosition(ofLineAtIndex: index, maxPossiblePosition: maxPossiblePosition) - offset, trackDuration)
            
            return TimedLyricsLine(content: line.content, position: position, maxPosition: maxPosition, timeTags: line.timeTags)
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
    let segments: [TimedLyricsLineSegment]
    
    var contentLength: Int {
        content.count
    }
    
    init(content: String, position: TimeInterval, maxPosition: TimeInterval,
         timeTags: [LyricsCore.LyricsLine.Attachments.InlineTimeTag.Tag]) {
        
        self.content = content
        self.position = position
        self.maxPosition = maxPosition
        
        var segments: [TimedLyricsLineSegment] = []
        
//        print("\n---------------------------------------------")
//        print("For line: \(content)\n")
        
        for (index, tag) in timeTags.enumerated() {
            
            if index < timeTags.lastIndex {
                
                let nextTag = timeTags[index + 1]
                let startPos = position + tag.time
                let endPos = position + nextTag.time
                var range: NSRange? = nil
                
                if tag.index < content.count, nextTag.index <= content.count, nextTag.index > tag.index {
                    range = NSMakeRange(tag.index, nextTag.index - tag.index)
                }
                
                if startPos >= position, endPos <= maxPosition, startPos < endPos, let range {
                    segments.append(.init(startPos: position + tag.time, endPos: position + nextTag.time, range: range))
//                    print("Segment \(segments.count): \(startPos), \(endPos), \(range)")
                }
            }
        }
        
        self.segments = segments
    }
    
    init?(persistentState: TimedLyricsLinePersistentState) {
        
        guard let content = persistentState.content,
              let position = persistentState.position,
        let maxPosition = persistentState.maxPosition else {return nil}
        
        self.content = content
        self.position = position
        self.maxPosition = maxPosition
        
        // TODO: Implement this!
        self.segments = []
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
    
    func findCurrentSegment(at position: TimeInterval) -> Int? {
        
        var left = 0
        var right = segments.count - 1

        while left <= right {
            
            let mid = (left + right) / 2
            let segment = segments[mid]
            
            switch segment.relativePosition(to: position) {
                
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

struct TimedLyricsLineSegment {
    
    let startPos: TimeInterval
    let endPos: TimeInterval
    let range: NSRange
    
    func isCurrent(atPosition target: TimeInterval) -> Bool {
        target >= startPos && target <= endPos
    }
    
    fileprivate func relativePosition(to target: TimeInterval) -> LyricsLineRelativePosition {
        
        if target < startPos {
            return .right
        }
        
        if target > endPos {
            return .left
        }
        
        return .match
    }
}
