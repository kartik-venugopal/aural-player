//
// PlayerViewController+Player.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

fileprivate var playbackPreferences: PlaybackPreferences {
    preferences.playbackPreferences
}

extension PlayerProtocol {
    
    func seekBackward(inputMode: UserInputMode = .discrete) {
        seekBackward(by: getPrimarySeekLength(inputMode))
    }
    
    func seekForward(inputMode: UserInputMode = .discrete) {
        seekForward(by: getPrimarySeekLength(inputMode))
    }
    
    /*
        Computes the seek length (i.e. interval/adjustment/delta) used as an increment/decrement when performing a "primary" seek, i.e.
        the seeking that can be performed through the player's seek control buttons.
     
        The "inputMode" parameter denotes whether the seeking is occurring in a discrete (using the main controls) or continuous (through a scroll gesture) mode. The amount of seeking performed
        will vary depending on the mode.
     */
    private func getPrimarySeekLength(_ inputMode: UserInputMode) -> TimeInterval {
        
        if inputMode == .discrete {
            
            if playbackPreferences.primarySeekLengthOption == .constant {
                return TimeInterval(playbackPreferences.primarySeekLengthConstant)
                
            } else if let trackDuration = playingTrack?.duration {
                
                // Percentage of track duration
                let percentage = TimeInterval(playbackPreferences.primarySeekLengthPercentage)
                return trackDuration * percentage / 100.0
            }
            
        } else {
            
            // Continuous seeking
            return playbackPreferences.seekLength_continuous
        }
        
        // Default value
        return 5
    }
    
    func seekBackwardSecondary() {
        seekBackward(by: secondarySeekLength)
    }
    
    func seekForwardSecondary() {
        seekForward(by: secondarySeekLength)
    }
    
    /*
        Computes the seek length (i.e. interval/adjustment/delta) used as an increment/decrement when performing a "secondary" seek, i.e.
        the seeking that can only be performed through the application's menu (or associated keyboard shortcuts). There are no control buttons
        to directly perform secondary seeking.
    */
    private var secondarySeekLength: TimeInterval {
        
        if playbackPreferences.secondarySeekLengthOption == .constant {
            return TimeInterval(playbackPreferences.secondarySeekLengthConstant)
            
        } else if let trackDuration = playingTrack?.duration {
            
            // Percentage of track duration
            let percentage = TimeInterval(playbackPreferences.secondarySeekLengthPercentage)
            return trackDuration * percentage / 100.0
        }
        
        // Default value
        return 30
    }
}
