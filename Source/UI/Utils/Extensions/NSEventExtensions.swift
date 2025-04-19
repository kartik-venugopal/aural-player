//
//  NSEventExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSEvent {
    
    // Computes the direction of a swipe gesture.
    var gestureDirection: GestureDirection? {
        
        // No offset, no direction
        if deltaX == 0 && deltaY == 0 {
            return nil
        }
        
        // Determine absolute offset values along both axes.
        let absX = abs(deltaX), absY = abs(deltaY)
        
        // Check along which axis greater movement occurred.
        if absX > absY {
            
            // This is a horizontal gesture (left/right).
            return deltaX < 0 ? .right : .left
            
        } else {
            
            // This is a vertical gesture (up/down).
            return deltaY < 0 ? .down : .up
        }
    }
    
    // MARK: Media keys handling ------------------------
    
    var isKeyEvent: Bool {subtype.rawValue == 8}

    var keycode: Keycode {Keycode((data1 & 0xffff0000) >> 16)}

    var keyEvent: KeyEvent {
        
        let keyFlags = KeyFlags(data1 & 0x0000ffff)
        let keyPressed = ((keyFlags & 0xff00) >> 8) == 0xa
        let keyRepeat = (keyFlags & 0x1) == 0x1

        return KeyEvent(keycode: keycode, keyFlags: keyFlags, keyPressed: keyPressed, keyRepeat: keyRepeat, timestamp: Date())
    }

    var isMediaKeyEvent: Bool {
        
        let mediaKeys = [NX_KEYTYPE_PLAY, NX_KEYTYPE_PREVIOUS, NX_KEYTYPE_NEXT, NX_KEYTYPE_FAST, NX_KEYTYPE_REWIND]
        return isKeyEvent && mediaKeys.contains(keycode)
    }
    
    static var optionFlagSet: Bool {
        modifierFlags.contains(.option)
    }
    
    static var noModifiedFlagsSet: Bool {
        modifierFlags.isEmpty
    }
    
    /*
        "Residual scrolling" occurs when seeking forward to the end of a playing track (scrolling right), resulting in the next track playing while the scroll is still occurring. Inertia (i.e. the momentum phase of the scroll) can cause scrolling, and hence seeking, to continue after the new track has begun playing. This is undesirable behavior. The scrolling should stop when the new track begins playing.
     
        To prevent residual scrolling, we need to take into account the following variables:
        - the time when the scroll session began
        - the time when the new track began playing
        - the time interval between this event and the last event
     
        Returns a value indicating whether or not this event constitutes residual scroll.
     */
    var isResidualScroll: Bool {
        
        // If the scroll session began before the currently playing track began playing, then it is now invalid and all its future events should be ignored.
        guard let playingTrackStartTime = player.playingTrackStartTime,
              let scrollSessionStartTime = ScrollSession.sessionStartTime,
              scrollSessionStartTime < playingTrackStartTime else {return false}
        
        // If the time interval between this event and the last one in the scroll session is within the maximum allowed gap between events, it is a part of the previous scroll session
        let lastEventTime = ScrollSession.lastEventTime ?? 0
        
        // If the session is invalid and this event is part of that invalid session, that indicates residual scroll, and the event should not be processed
        if (self.timestamp - lastEventTime) < ScrollSession.maxTimeGapSeconds {
            
            // Mark the timestamp of this event (for future events), but do not process it
            ScrollSession.updateLastEventTime(self)
            return true
        }
        
        return false
    }
}

