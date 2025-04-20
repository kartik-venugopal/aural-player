//
// DiscretePlayer+Chapters.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    ///
    /// A small margin of time that is added to the start time of a chapter to prevent an
    /// "overlap" with the previous chapter.
    ///
    private static let chapterPlaybackStartTimeMargin: TimeInterval = 0.001
    
    var chapterCount: Int {
        playingTrack?.chapters.count ?? 0
    }
    
    var playingChapter: IndexedChapter? {
        
        if let track = playingTrack, let index = currentChapterIndex {
            return IndexedChapter(track: track, chapter: track.chapters[index], index: index)
        }
        
        return nil
    }
    
    func playChapter(_ index: Int) {
        
        // Validate track and index by checking the bounds of the chapters array
        guard let track = playingTrack, track.hasChapters, index >= 0 && index < track.chapters.count else {
            return
        }
        
        // Find the chapter with the given index and seek to its start time.
        // HACK: Add a little margin to the chapter start time to avoid overlap in chapters (except if the start time is zero).
        let startTime = track.chapters[index].startTime
        seekTo(time: startTime + (startTime > 0 ? Self.chapterPlaybackStartTimeMargin : 0))
        
        // Resume playback if paused
        resumeIfPaused()
    }
    
    func previousChapter() {
        
        if let index = previousChapterIndex {
            playChapter(index)
        }
    }
    
    func nextChapter() {
        
        if let index = nextChapterIndex {
            playChapter(index)
        }
    }
    
    func replayChapter() {
        
        guard let startTime = playingChapter?.chapter.startTime else {return}
        
        // Seek to current chapter's start time
        seekTo(time: startTime + (startTime > 0 ? Self.chapterPlaybackStartTimeMargin : 0))
        
        // Resume playback if paused
        resumeIfPaused()
    }
    
    func toggleChapterLoop() -> Bool {
        
        guard let chapter = playingChapter?.chapter else {
            return false
        }
        
        if !chapterLoopExists {
            
            // Apply margins to both start/end time to avoid overlap with adjacent chapters.
            let startTime = chapter.startTime + (chapter.startTime > 0 ? Self.chapterPlaybackStartTimeMargin : 0)
            let endTime = chapter.endTime - Self.chapterPlaybackStartTimeMargin
            
            defineLoop(startPosition: startTime, endPosition: endTime, isChapterLoop: true)
            return true
            
        } else {
            
            // Remove chapter loop
            toggleLoop()
            return false
        }
    }
    
    var chapterLoopExists: Bool {
        playbackLoop?.isChapterLoop ?? false
    }
    
    var currentChapterIndex: Int? {
        
        guard let chapters = playingTrack?.chapters, chapters.isNonEmpty else {
            return nil
        }
        
        // Binary search algorithm (assumes chapters are chronologically arranged and non-overlapping).
        // Able to handle gaps around chapters.

        let seekTime = playerPosition
        var first = 0
        var last = chapters.lastIndex
        var center = (first + last) / 2
        var centerChapter = chapters[center]
        
        while first <= last {

            // Found a matching chapter
            if centerChapter.containsTimePosition(seekTime) {
                return center
                
            } else if seekTime < centerChapter.startTime {
                last = center - 1
                
            } else if seekTime > centerChapter.endTime {
                first = center + 1
            }
            
            center = (first + last) / 2
            centerChapter = chapters[center]
        }
        
        return nil
    }
    
    var previousChapterIndex: Int? {
        
        guard let chapters = playingTrack?.chapters, chapters.isNonEmpty else {
            return nil
        }
        
        guard let currentChapterIndex = self.currentChapterIndex else {
            return nil
        }
        
        let curChapter = chapters[currentChapterIndex]
        
        // If no matching chapter was found for the current seek position, try to determine a previous chapter.
        if playerPosition < curChapter.startTime {
            return currentChapterIndex - 1 < 0 ? nil : currentChapterIndex - 1
            
        } else {
            return currentChapterIndex
        }
    }

    var nextChapterIndex: Int? {
        
        guard let chapters = playingTrack?.chapters, chapters.isNonEmpty else {
            return nil
        }
        
        guard let currentChapterIndex = self.currentChapterIndex else {
            return nil
        }
        
        let curChapter = chapters[currentChapterIndex]
        
        // If no matching chapter was found for the current seek position, try to determine a previous chapter.
        if playerPosition < curChapter.startTime {
            return currentChapterIndex
            
        } else {
            return currentChapterIndex + 1 >= chapters.count ? nil : currentChapterIndex + 1
        }
    }
}
