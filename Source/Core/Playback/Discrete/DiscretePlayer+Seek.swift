//
// DiscretePlayer+Seek.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    func seekBackward(by interval: TimeInterval) {
        attemptSeek(to: playerPosition - interval)
    }
    
    func seekForward(by interval: TimeInterval) {
        attemptSeek(to: playerPosition + interval)
    }
    
    func seekTo(percentage: Double) {
        
        if let track = playingTrack {
            forceSeek(to: percentage * track.duration / 100)
        }
    }
    
    func seekTo(time seconds: TimeInterval) {
        forceSeek(to: seconds)
    }
    
    // Attempts to perform a seek to a given seek position, respecting the bounds of a defined segment loop. See doSeekToTime() for more details.
    func attemptSeek(to seconds: TimeInterval) {
        
//        let seekResult = doSeek(to: seconds, canSeekOutsideLoop: false)
//        
//        if seekResult.trackPlaybackCompleted {
//            doTrackPlaybackCompleted()
//        }
    }
    
    func forceSeek(to seconds: TimeInterval) {
        
//        let seekResult = doSeek(to: seconds, canSeekOutsideLoop: true)
//        
//        if seekResult.trackPlaybackCompleted {
//            doTrackPlaybackCompleted()
//            
//        } else if seekResult.loopRemoved {
//            messenger.publish(.Player.playbackLoopChanged)
//        }
    }
    
    ///     Attempts to seek to a given track position, checking the validity of the desired seek time. Returns an object encapsulating the result of the seek operation.
    ///
    ///     - Parameter attemptedSeekTime: The desired seek time. May be invalid, i.e. < 0 or > track duration, or outside the bounds of a defined segment loop. If so, it will be adjusted accordingly.
    ///
    ///     - Parameter canSeekOutsideLoop: If set to true, the seek may result in a segment loop being removed, if one was defined prior to the seek. Determines whether or not attemptedSeekTime can be outside the bounds of a segment loop.
    ///
    ///     NOTE - If a seek reaches the end of a track, and the player is playing, track playback completion will be signaled.
    ///
    func seek(to attemptedSeekTime: Double, canSeekOutsideLoop: Bool) -> PlayerSeekResult {
        
        guard let curSession = PlaybackSession.currentSession else {
            return PlayerSeekResult(actualSeekPosition: 0, loopRemoved: false, trackPlaybackCompleted: false)
        }
        
        let track = curSession.track
        var actualSeekTime: Double = attemptedSeekTime
        var playbackCompleted: Bool
        var loopRemoved: Bool = false
        let isPlaying = self.isPlaying
        
        if let loop = self.playbackLoop, !loop.containsPosition(attemptedSeekTime) {
            
            if canSeekOutsideLoop {
                
                // Seeking outside the loop is allowed, so remove the loop.
                
                PlaybackSession.removeLoop()
                loopRemoved = true
                
            } else {
                
                // Correct the seek time to within the loop's time bounds
                
                if attemptedSeekTime < loop.startTime {
                    actualSeekTime = loop.startTime
                    
                } else if let loopEndTime = loop.endTime, attemptedSeekTime >= loopEndTime {
                    actualSeekTime = loop.startTime
                }
            }
        }
        
        // Check if playback has completed (seek time has crossed the track duration)
        playbackCompleted = isPlaying && actualSeekTime >= track.duration
        
        // Correct the seek time to within the track's time bounds
        actualSeekTime = max(0, min(actualSeekTime, track.duration))
        
        // Create a new identical session (for the track that is playing), and perform a seek within it
        if !playbackCompleted, let newSession = PlaybackSession.startNewSessionForPlayingTrack() {
            
            scheduler.seekToTime(newSession, actualSeekTime, isPlaying)
            messenger.publish(.Player.seekPerformed)
        }
        
        return PlayerSeekResult(actualSeekPosition: actualSeekTime, loopRemoved: loopRemoved, trackPlaybackCompleted: playbackCompleted)
    }
}
