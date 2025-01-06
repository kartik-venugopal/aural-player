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

class TimedLyrics {
    
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

class TimedLyricsLine {
    
    let content: String
    
    let position: TimeInterval
    let maxPosition: TimeInterval

    let segments: [TimedLyricsLineSegment]
    let numSegments: Int
    
    subscript(segmentsContent range: Range<Int>) -> String {
        
        let indices = segments.indices
        guard let min = range.min(), let max = range.max(), indices.contains(min), indices.contains(max) else {return ""}
        
        var str = ""
        
        for index in range {
            str += segments[index].content
        }

        return str
    }
    
    init(content: String, position: TimeInterval, maxPosition: TimeInterval,
         timeTags: [LyricsCore.LyricsLine.Attachments.InlineTimeTag.Tag]) {
        
        self.content = content
        self.position = position
        self.maxPosition = maxPosition
        
        var segments: [TimedLyricsLineSegment] = []
        
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
                    
                    let segmentContent = content.substring(range: range.intRange)
                    segments.append(.init(startPos: position + tag.time, endPos: position + nextTag.time, range: range, content: segmentContent))
                }
            }
        }
        
        self.segments = segments
        self.numSegments = segments.count
        
        updatePreAndPostSegmentContent()
    }
    
    private func updatePreAndPostSegmentContent() {
        
        for (index, segment) in segments.enumerated() {
            
            let preSegmentContent = index > 0 ? self[segmentsContent: 0..<index] : ""
            let postSegmentContent = (index + 1) < numSegments ? self[segmentsContent: (index + 1)..<numSegments] : ""
            
            segment.preSegmentContent = preSegmentContent
            segment.postSegmentContent = postSegmentContent
        }
    }
    
    init?(persistentState: TimedLyricsLinePersistentState) {
        
        guard let content = persistentState.content,
              let position = persistentState.position,
        let maxPosition = persistentState.maxPosition else {return nil}
        
        self.content = content
        self.position = position
        self.maxPosition = maxPosition
        
        self.segments = persistentState.segments?.compactMap {
            TimedLyricsLineSegment(persistentState: $0, lineContent: content)
        } ?? []
        
        self.numSegments = segments.count
        updatePreAndPostSegmentContent()
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

class TimedLyricsLineSegment {
    
    let startPos: TimeInterval
    let endPos: TimeInterval
    
    let range: NSRange
    
    let content: String
    var preSegmentContent: String = ""
    var postSegmentContent: String = ""
    
    init(startPos: TimeInterval, endPos: TimeInterval, range: NSRange, content: String) {
        
        self.startPos = startPos
        self.endPos = endPos
        self.range = range
        self.content = content
    }
    
    init?(persistentState: TimedLyricsLineSegmentPersistentState, lineContent: String) {
        
        guard let startPos = persistentState.startPos,
              let endPos = persistentState.endPos,
              let range = persistentState.range else {return nil}
        
        self.startPos = startPos
        self.endPos = endPos
        self.range = range
        self.content = lineContent.substring(range: range.intRange)
    }
    
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
