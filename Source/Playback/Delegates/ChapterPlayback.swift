import Foundation

// Chapter playback functions
extension PlaybackDelegate {
    
    func playChapter(_ index: Int) {
        
        // Validate track and index by checking the bounds of the chapters array
        if let track = playingTrack?.track, track.hasChapters, index >= 0 && index < track.chapters.count {
            
            // Find the chapter with the given index and seek to its start time.
            // HACK: Add a little margin to the chapter start time to avoid overlap in chapters (except if the start time is zero).
            let startTime = track.chapters[index].startTime
            seekToTime(startTime + (startTime > 0 ? chapterPlaybackStartTimeMargin : 0))
            
            // Resume playback if paused
            resumeIfPaused()
        }
    }
    
    func previousChapter() {
        
        if let chapters = playingTrack?.track.chapters, !chapters.isEmpty {
            
            let elapsed = player.seekPosition
            
            for index in 0..<chapters.count {
                
                let chapter = chapters[index]
                
                // We have either reached a chapter containing the elapsed time or
                // we have passed the elapsed time (i.e. within a gap between chapters).
                if chapter.containsTimePosition(elapsed) || (elapsed < chapter.startTime) {
                    
                    // If there is a previous chapter, play it
                    if index > 0 {
                        playChapter(index - 1)
                    }
                    
                    // No previous chapter
                    return
                }
            }
            
            // Elapsed time > all chapter times ... it's a gap at the end
            // i.e. need to play the last chapter
            playChapter(chapters.count - 1)
        }
    }
    
    func nextChapter() {
        
        if let chapters = playingTrack?.track.chapters, !chapters.isEmpty {
                
            let elapsed = player.seekPosition
            
            for index in 0..<chapters.count {
                
                let chapter = chapters[index]
                
                if chapter.containsTimePosition(elapsed) {
                
                    // Play the next chapter if there is one
                    if index < (chapters.count - 1) {
                        playChapter(index + 1)
                    }
                    
                    return
                    
                } else if elapsed < chapter.startTime {
                    
                    // Elapsed time is less than this chapter's lower time bound,
                    // i.e. this chapter is the next chapter
                    
                    playChapter(index)
                    return
                }
            }
        }
    }
    
    func replayChapter() {
        
        if let startTime = playingChapter?.chapter.startTime {
        
            // Seek to current chapter's start time
            seekToTime(startTime + (startTime > 0 ? chapterPlaybackStartTimeMargin : 0))
            
            // Resume playback if paused
            resumeIfPaused()
        }
    }
    
    func loopChapter() {
        
        if let chapter = playingChapter?.chapter {
            player.defineLoop(chapter.startTime, chapter.endTime)
        }
    }
    
    var chapterCount: Int {
        return playingTrack?.track.chapters.count ?? 0
    }
    
    // NOTE - This function needs to be efficient because it is repeatedly called to keep track of the current chapter
    // TODO: One possible optimization - keep track of which chapter is playing (in a variable), and in this function, check
    // against it first. In most cases, that check will produce a quick result. Or, implement a binary search. Or both.
    var playingChapter: IndexedChapter? {
        
        if let track = playingTrack?.track, track.hasChapters {
            
            let elapsed = player.seekPosition
            
            var index: Int = 0
            for chapter in track.chapters {
                
                if chapter.containsTimePosition(elapsed) {
                    
                    // Elapsed time is within this chapter's lower and upper time bounds ... found the chapter.
                    return IndexedChapter(track, chapter, index)
                    
                } else if elapsed < chapter.startTime {
                    
                    // Elapsed time is less than this chapter's lower time bound,
                    // i.e. we have already looked at all chapters up to the elapsed time and not found a match.
                    // Since chapters are sorted, we can assume that this indicates a gap between chapters.
                    return nil
                }
                
                index += 1
            }
        }
        
        return nil
    }
}
