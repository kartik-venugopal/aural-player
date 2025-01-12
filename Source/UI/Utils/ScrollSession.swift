//
//  ScrollSession.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

/*
    A helper class that keeps track of a "scroll session" that consists of a set of scroll events performed in rapid succession. The constraint is that, during any single scroll session, scrolling may only be performed in a single direction (left/right/up/down) ... any events with a different scroll direction will be ignored.
 
    This is useful in eliminating human error caused by inexact (diagonal) scrolling, i.e. most people cannot scroll exactly in one direction. They scroll mostly in one direction, but often also a little bit in a perpendicular direction.
 
    For example, when scrolling left, the user may scroll a little bit up as well. The result of such a scroll should be a scroll up without scrolling left.
 */
class ScrollSession {
    
    // State variables that keep track of the current session
    
    // Time when the current scroll session began (nil initially)
    // TimeInterval represents systemUpTime. See ProcessInfo.processInfo.systemUpTime.
    static var sessionStartTime: TimeInterval?
    
    // Time when last event was triggered (nil if no session currently active)
    // TimeInterval represents systemUpTime. See ProcessInfo.processInfo.systemUpTime.
    static var lastEventTime: TimeInterval?
    
    // Maximum time gap between scroll events for them to be considered as being part of the same scroll session
    static let maxTimeGapSeconds: TimeInterval = (1.0/6)
    
    // Map of counts of events in different scroll directions. Used to determine the intended scroll direction for a session.
    private static var events: [GestureDirection: Int] = [.up: 0, .down: 0, .left: 0, .right: 0]
    
    // Updates the lastEventTime field with the timestamp of a new event. This function is called when it is determined that the event is not to be processed, and the lastEventTime needs to be updated merely for comparison with future invalid events.
    static func updateLastEventTime(_ event: NSEvent) {
        lastEventTime = event.timestamp
    }
   
    // Validates a single scroll event with the given direction, within the context of the current scroll session. Returns true if the event is valid, and false otherwise.
    static func validateEvent(timestamp: TimeInterval, eventDirection: GestureDirection) -> Bool {
        
        // Check if this event belongs to the current scroll session (based on time since last event)
        if timeSinceLastEvent(timestamp) < Self.maxTimeGapSeconds {
            
            // There is an ongoing (current) scroll session. Check if the direction for this event matches the intended scroll direction.
            
            if eventDirection != intendedDirection {
                // This event is invalid because its direction differs from the intended direction for this session
                return false
            }

        } else {
            
            // This is a new scroll session, because the max. time gap between sessions has been exceeded
            reset()
        }
        
        // Mark the time for this event
        lastEventTime = timestamp
        
        // Increment the count for events with this direction
        events[eventDirection]!.increment()
        
        // Event is valid
        return true
    }
    
    /*
        Determines the intended scroll direction for this session. This is calculated by determining which direction most of the scrolling thus far has been performed in. Example - If the session has 10 scroll Up events and 2 scroll Left events, the intended scroll direction is Up.
     */
    private static var intendedDirection: GestureDirection {
        
        var maxEvents = 0
        var intendedDir: GestureDirection?
        
        for (direction, count) in events {
            
            if (count > maxEvents) {
                maxEvents = count
                intendedDir = direction
            }
        }
        
        // Value will always be set, ok to force unwrap
        return intendedDir!
    }
    
    // Resets the scroll session to mark a new session
    private static func reset() {
        
        sessionStartTime = ProcessInfo.processInfo.systemUptime
        lastEventTime = nil
        events = [.up: 0, .down: 0, .left: 0, .right: 0]
    }
    
    // Calculates the time since the last event in the current session, in seconds. If there is no current session (i.e. lastEventTime is nil), a large value is returned, so as to indicate that the max time gap between sessions has been exceeded and that a new session should be started.
    private static func timeSinceLastEvent(_ timestamp: TimeInterval) -> TimeInterval {
        return lastEventTime == nil ? 10 : (timestamp - lastEventTime!)
    }
}
