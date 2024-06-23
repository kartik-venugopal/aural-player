//
//  UnifiedPlayerWindowController+EventHandling.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension UnifiedPlayerWindowController {
    
    // Registers handlers for keyboard events and trackpad/mouse gestures (NSEvent).
    func setUpEventHandling() {
        
        eventMonitor.registerHandler(forEventType: .keyDown, self.handleKeyDown(_:))
        eventMonitor.registerHandler(forEventType: .scrollWheel, self.handleScroll(_:))
        eventMonitor.registerHandler(forEventType: .swipe, self.handleSwipe(_:))
        
        eventMonitor.startMonitoring()
    }
    
    // Handles a single key press event. Returns nil if the event has been successfully handled (or needs to be suppressed),
    // returns the same event otherwise.
    func handleKeyDown(_ event: NSEvent) -> NSEvent? {

        // One-off special case: Without this, a space key press (for play/pause) is not sent to main window
        // Send the space key event to the main window unless a modal component is currently displayed
        if event.charactersIgnoringModifiers == " ",
           !NSApp.isShowingModalComponent {
            
            window?.makeFirstResponder(window)
            self.window?.keyDown(with: event)
            return nil
        }

        return event
    }
    
    // Handles a single scroll event
    func handleScroll(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)
        
        let loc = event.locationInWindow
        let locInPlayerView = playerViewController.view.convert(loc, from: nil)
        let hit: Bool = playerViewController.view.frame.contains(locInPlayerView)
        
        if hit, let scrollDirection = event.gestureDirection {
            
            // Calculate the direction and magnitude of the scroll (nil if there is no direction information)
            // Vertical scroll = volume control, horizontal scroll = seeking
            
            scrollDirection.isVertical ? handleVolumeControl(event, scrollDirection) : handleSeek(event, scrollDirection)
        }
        
        return event
    }
    
    func handleVolumeControl(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
        if gesturesPreferences.allowVolumeControl.value,
           ScrollSession.validateEvent(timestamp: event.timestamp, eventDirection: scrollDirection) {
        
            // Scroll up = increase volume, scroll down = decrease volume
            messenger.publish(scrollDirection == .up ?.Player.increaseVolume : .Player.decreaseVolume, payload: UserInputMode.continuous)
        }
    }
    
    func handleSeek(_ event: NSEvent, _ scrollDirection: GestureDirection) {
        
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
    
    // Handles a single swipe event
    func handleSwipe(_ event: NSEvent) -> NSEvent? {

        // If a modal dialog is open, don't do anything
        // Also, ignore any gestures that weren't triggered over the main window (they trigger other functions if performed over the playlist window)

        if event.window === self.window,
           !NSApp.isShowingModalComponent,
           let swipeDirection = event.gestureDirection, swipeDirection.isHorizontal {
            
            // TODO: Figure out where the mouse cursor is. If over player, trackChange ... if over PQ, pageUp/Down/scrollTopBottom

            handleTrackChange(swipeDirection)
        }

        return event
    }
    
    func handleTrackChange(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowTrackChange.value {
            
            // Publish the command notification
            messenger.publish(swipeDirection == .left ? .Player.previousTrack : .Player.nextTrack)
        }
    }
}
