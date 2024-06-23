//
//  CompactPlayerWindowController+EventHandling.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension CompactPlayerWindowController {
    
    private var gesturesPreferences: GesturesControlsPreferences {preferences.controlsPreferences.gestures}
    
    // Registers handlers for keyboard events and trackpad/mouse gestures (NSEvent).
    func setUpEventHandling() {
        
        eventMonitor.registerHandler(forEventType: .scrollWheel, self.handleScroll(_:))
        eventMonitor.registerHandler(forEventType: .swipe, self.handleSwipe(_:))

        eventMonitor.startMonitoring()
    }

    // Handles a single swipe event
    private func handleSwipe(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        if let swipeDirection = event.gestureDirection {
            
            if swipeDirection.isHorizontal {
                
                switch compactPlayerUIState.displayedView {
                    
                case .player:
                    handleTrackChange(swipeDirection)
                    
                case .playQueue:
                    handlePageUpDown(swipeDirection)
                    
                default:
                    return event
                }
                
            } else if compactPlayerUIState.displayedView == .playQueue {
                
                // Vertical swipe on the PQ
                handleScrollTopBottom(swipeDirection)
            }
        }

        return event
    }

    // Handles a single scroll event
    private func handleScroll(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        // Calculate the direction and magnitude of the scroll (nil if there is no direction information)
        if let scrollDirection = event.gestureDirection, compactPlayerUIState.displayedView == .player {

            // Vertical scroll = volume control, horizontal scroll = seeking
            scrollDirection.isVertical ? handleVolumeControl(event, scrollDirection) : handleSeek(event, scrollDirection)
        }

        return event
    }
    
    private func handleTrackChange(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowTrackChange.value {
            
            // Publish the command notification
            messenger.publish(swipeDirection == .left ? .Player.previousTrack : .Player.nextTrack)
        }
    }
    
    private func handleVolumeControl(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        if gesturesPreferences.allowVolumeControl.value && ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
        
            // Scroll up = increase volume, scroll down = decrease volume
            messenger.publish(scrollDirection == .up ?.Player.increaseVolume : .Player.decreaseVolume, payload: UserInputMode.continuous)
        }
    }
    
    private func handleSeek(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        guard gesturesPreferences.allowSeeking.value else {return}
        
        // If no track is playing, seeking cannot be performed
        if playbackInfoDelegate.state.isStopped {
            return
        }
        
        // Seeking forward (do not allow residual scroll)
        if scrollDirection == .right && event.isResidualScroll {
            return
        }
        
        if ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
            
            // Scroll left = seek backward, scroll right = seek forward
            messenger.publish(scrollDirection == .left ? .Player.seekBackward : .Player.seekForward, payload: UserInputMode.continuous)
        }
    }
    
    private func handleScrollTopBottom(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlayQueueScrollingTopToBottom.value {
            messenger.publish(swipeDirection == .up ? .PlayQueue.scrollToTop : .PlayQueue.scrollToBottom)
        }
    }
    
    private func handlePageUpDown(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlayQueueScrollingPageUpDown.value {
            messenger.publish(swipeDirection == .left ? .PlayQueue.pageUp : .PlayQueue.pageDown)
        }
    }
}
