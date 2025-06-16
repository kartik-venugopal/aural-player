//
//  GestureHandler.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class GestureHandler {
    
    private static let gesturesPreferences: GesturesControlsPreferences = preferences.controlsPreferences.gestures
    
    // MARK: Player functions --------------------------------------------------------------------------------
    
    static func handleTrackChange(_ swipeDirection: GestureDirection) {
        
        guard gesturesPreferences.allowTrackChange else {return}
        
        if swipeDirection == .left {
            playbackOrch.previousTrack()
        } else {
            playbackOrch.nextTrack()
        }
    }
    
    static func handleVolumeControl(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        guard gesturesPreferences.allowVolumeControl, ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) else {return}
        
        // Scroll up = increase volume, scroll down = decrease volume
        Messenger.publish(scrollDirection == .up ?.Player.increaseVolume : .Player.decreaseVolume, payload: UserInputMode.continuous)
    }
    
    static func handleSeek(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        guard gesturesPreferences.allowSeeking else {return}
        
        // If no track is playing, seeking cannot be performed
        if playbackOrch.state.isStopped {
            return
        }
        
        // Seeking forward (do not allow residual scroll)
        if scrollDirection == .right && event.isResidualScroll {
            return
        }
        
        if ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
            
            // Scroll left = seek backward, scroll right = seek forward
            if scrollDirection == .left {
                playbackOrch.seekBackward(userInputMode: .continuous)
            } else {
                playbackOrch.seekForward(userInputMode: .continuous)
            }
        }
    }
    
    // MARK: Play Queue functions --------------------------------------------------------------------------------
    
    static func handleScrollTopBottom(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlayQueueScrollingTopToBottom {
            Messenger.publish(swipeDirection == .up ? .PlayQueue.scrollToTop : .PlayQueue.scrollToBottom)
        }
    }
    
    static func handlePageUpDown(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlayQueueScrollingPageUpDown {
            Messenger.publish(swipeDirection == .left ? .PlayQueue.pageUp : .PlayQueue.pageDown)
        }
    }
}
