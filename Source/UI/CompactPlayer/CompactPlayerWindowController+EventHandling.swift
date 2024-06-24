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
        
        guard let swipeDirection = event.gestureDirection else {return event}
        
        if swipeDirection.isHorizontal {
            
            switch compactPlayerUIState.displayedView {
                
            case .player:
                GestureHandler.handleTrackChange(swipeDirection)
                
            case .playQueue:
                GestureHandler.handlePageUpDown(swipeDirection)
                
            default:
                return event
            }
            
        } else if compactPlayerUIState.displayedView == .playQueue {
            
            // Vertical swipe on the PQ
            GestureHandler.handleScrollTopBottom(swipeDirection)
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
            scrollDirection.isVertical ? GestureHandler.handleVolumeControl(event, scrollDirection) : GestureHandler.handleSeek(event, scrollDirection)
        }

        return event
    }
}
