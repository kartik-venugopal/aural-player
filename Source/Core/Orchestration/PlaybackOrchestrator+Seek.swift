//
// PlaybackOrchestrator+Seek.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension PlaybackOrchestrator {
    
    func seekTo(position: TimeInterval) -> PlaybackCommandResult {
        
        let seekResult = player.seek(to: position, canSeekOutsideLoop: true)
        ui?.playbackPositionChanged(newPosition: self.playbackPosition)
        
        return currentStateAsCommandResult
    }
    
    // Seeks to a specific percentage of the track duration, within the current track
    func seekTo(percentage: Double) -> PlaybackCommandResult {
        
        if let playingTrack = self.playingTrack {
            return seekTo(position: percentage * playingTrack.duration / 100)
        }
        
        return currentStateAsCommandResult
    }
    
    func seekBackward(userInputMode: UserInputMode) -> PlaybackCommandResult {
        
        guard let curPosition = self.playbackPosition else {return currentStateAsCommandResult}
        
        let primarySeekInterval = getPrimarySeekInterval(inputMode: userInputMode)
        attemptSeek(to: max(0, curPosition.timeElapsed - primarySeekInterval))
        
        ui?.playbackPositionChanged(newPosition: self.playbackPosition)
        
        return currentStateAsCommandResult
    }
    
    func seekForward(userInputMode: UserInputMode) -> PlaybackCommandResult {
        
        guard let curPosition = self.playbackPosition else {return currentStateAsCommandResult}
        
        let primarySeekInterval = getPrimarySeekInterval(inputMode: userInputMode)
        attemptSeek(to: min(curPosition.timeElapsed + primarySeekInterval, curPosition.trackDuration))
        
        ui?.playbackPositionChanged(newPosition: self.playbackPosition)
        
        return currentStateAsCommandResult
    }
    
    func seekBackwardSecondary() -> PlaybackCommandResult {
        
        guard let curPosition = self.playbackPosition else {return currentStateAsCommandResult}
        
        attemptSeek(to: max(0, curPosition.timeElapsed - secondarySeekInterval))
        
        ui?.playbackPositionChanged(newPosition: self.playbackPosition)
        
        return currentStateAsCommandResult
    }
    
    func seekForwardSecondary() -> PlaybackCommandResult {
        
        guard let curPosition = self.playbackPosition else {return currentStateAsCommandResult}
        
        attemptSeek(to: min(curPosition.timeElapsed + secondarySeekInterval, curPosition.trackDuration))
        
        ui?.playbackPositionChanged(newPosition: self.playbackPosition)
        
        return currentStateAsCommandResult
    }
    
    // An attempted seek cannot seek outside the bounds of a segment loop (if one is defined).
    // It occurs, for instance, when seeking backward/forward.
    private func attemptSeek(to position: TimeInterval) {
        
        let result = player.seek(to: position, canSeekOutsideLoop: true)
        
//        guard let track = playingTrack else {return}
//        
//        let seekResult = player.attemptSeek(to: position)
//        
//        if seekResult.trackPlaybackCompleted {
//            
//            if isInGaplessPlaybackMode {
//                
//                changeGaplessTrack(mustStopIfNoTrack: true) {
//                    playQueue.subsequent()
//                }
//                
//            } else {
//                doTrackPlaybackCompleted()
//            }
//        }
    }
    
    /*
     Computes the seek length (i.e. interval/adjustment/delta) used as an increment/decrement when performing a "primary" seek, i.e.
     the seeking that can be performed through the player's seek control buttons.
     
     The "inputMode" parameter denotes whether the seeking is occurring in a discrete (using the main controls) or continuous (through a scroll gesture) mode. The amount of seeking performed
     will vary depending on the mode.
     */
    private func getPrimarySeekInterval(inputMode: UserInputMode) -> TimeInterval {
        
        if inputMode == .discrete {
            
            if playbackPreferences.primarySeekLengthOption == .constant {
                return TimeInterval(playbackPreferences.primarySeekLengthConstant)
                
            } else if let trackDuration = playingTrack?.duration {
                
                // Percentage of track duration
                let percentage = Double(playbackPreferences.primarySeekLengthPercentage)
                return trackDuration * percentage / 100.0
            }
            
        } else {
            
            // Continuous seeking
            return playbackPreferences.seekLength_continuous
        }
        
        // Default value
        return TimeInterval(PlaybackPreferences.Defaults.primarySeekLengthConstant)
    }
    
    /*
     Computes the seek interval (i.e. interval/adjustment/delta) used as an increment/decrement when performing a "secondary" seek, i.e.
     the seeking that can only be performed through the application's menu (or associated keyboard shortcuts). There are no control buttons
     to directly perform secondary seeking.
     */
    private var secondarySeekInterval: TimeInterval {
        
        if playbackPreferences.secondarySeekLengthOption == .constant {
            return TimeInterval(playbackPreferences.secondarySeekLengthConstant)
            
        } else if let trackDuration = playingTrack?.duration {
            
            // Percentage of track duration
            let percentage = Double(playbackPreferences.secondarySeekLengthPercentage)
            return trackDuration * percentage / 100.0
        }
        
        // Default value
        return TimeInterval(PlaybackPreferences.Defaults.secondarySeekLengthConstant)
    }
    
    //    // A forced seek can seek outside the bounds of a segment loop (if one is defined).
    //    // It occurs, for instance, when clicking on the seek bar, or using the "Jump to time" function.
    //    private func forceSeek(_ seekPosn: Double) {
    //
    ////        guard state.isPlayingOrPaused, let track = playingTrack else {return}
    ////
    ////        let seekResult = player.forceSeekToTime(track, seekPosn)
    ////
    ////        if seekResult.trackPlaybackCompleted {
    ////            doTrackPlaybackCompleted()
    ////
    ////        } else if seekResult.loopRemoved {
    ////            messenger.publish(.Player.playbackLoopChanged)
    ////        }
    //    }
}
