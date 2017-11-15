import Cocoa

/*
    Handles trackpad/MagicMouse gestures performed over the main window, for convenient access to essential player functions
 */
class GestureHandler {
 
    // Handles a single event
    func handle(_ event: NSEvent) {
        
        if (NSApp.modalWindow != nil) {
            // Modal dialog open, don't do anything
            return
        }
        
        // Delegate to an appropriate handler function based on event type
        switch event.type {
            
        case .swipe: handleSwipe(event)
            
        case .scrollWheel: handleScroll(event)
            
        default: return
            
        }
    }
    
    // Handles a single (three finger) swipe event
    private func handleSwipe(_ event: NSEvent) {
        
        // Ignore any swipe events that weren't triggered over the main window (they trigger other functions if performed over the playlist window)
        if event.window != WindowState.window {
            return
        }
        
        // Used to indicate a playback action triggered by the swipe
        var actionType: ActionType
        
        if let swipeDirection = UIUtils.determineSwipeDirection(event) {
            
            switch swipeDirection {
                
            case .left: actionType = .previousTrack
                
            case .right: actionType = .nextTrack
                
            default: return
                
            }
            
            // Publish the action message
            SyncMessenger.publishActionMessage(PlaybackActionMessage(actionType))
        }
    }
    
    // Handles a single (two finger) scroll event
    private func handleScroll(_ event: NSEvent) {
        
        // Ignore any scroll events that weren't triggered over the main window (they trigger other functions if performed over the playlist window)
        if event.window != WindowState.window {
            return
        }
        
        // TODO: Detect scroll "sessions", and don't allow different scroll direction during session. Ex - If scrolling left, and a scroll up comes along, ignore it. Use time between events to bound session.
        
        // Used to indicate a player action triggered by the swipe
        var actionType: ActionType
        
        if let scrollVector = UIUtils.determineScrollVector(event) {
            
            if (ScrollSession.validateEvent(scrollVector.direction)) {
            
                switch scrollVector.direction {
                    
                case .up: actionType = .increaseVolume
                    
                case .down: actionType = .decreaseVolume
                    
                case .left: actionType = .seekBackward
                    
                case .right: actionType = .seekForward
                    
                }
                
                // Publish the action message
                
                if (actionType == .seekBackward || actionType == .seekForward) {
                    SyncMessenger.publishActionMessage(PlaybackActionMessage(actionType, .continuous))
                } else {
                    SyncMessenger.publishActionMessage(AudioGraphActionMessage(actionType, .continuous, Float(scrollVector.movement)))
                }
            }
        }
    }
}

/*
    A helper class that keeps track of a "scroll session" that consists of a set of scroll events performed in rapid succession. The constraint is that, during any single scroll session, scrolling may only be performed in a single direction (left/right/up/down) ... any events with a different scroll direction will be ignored.
 
    This is useful in eliminating human error caused by inexact (diagonal) scrolling, i.e. most people cannot scroll exactly in one direction. They scroll mostly in one direction, but often also a little bit in a perpendicular direction. 
 
    For example, when scrolling left, the user may scroll a little bit up as well. The result of such a scroll should be a scroll up without scrolling left.
 */
fileprivate class ScrollSession {
    
    // State variables that keep track of the current session
    
    // Time when last event was triggered (nil if no session currently active)
    private static var lastEventTime: Date?
    
    // Map of counts of events in different scroll directions. Used to determine the intended scroll direction for a session.
    private static var events: [GestureDirection: Int] = [.up: 0, .down: 0, .left: 0, .right: 0]
   
    // Validates a single scroll event with the given direction, within the context of the current scroll session. Returns true if the event is valid, and false otherwise.
    static func validateEvent(_ eventDir: GestureDirection) -> Bool {
        
        let now = Date()
        
        // Check if this event belongs to the current scroll session (based on time since last event)
        if timeSinceLastEvent() < UIConstants.scrollSessionMaxTimeGapSeconds {
            
            // There is an ongoing (current) scroll session. Check if the direction for this event matches the intended scroll direction.
            
            if eventDir != getIntendedDirection() {
                // This event is invalid because its direction differs from the intended direction for this session
                return false
            }

        } else {
            
            // This is a new scroll session, because the max. time gap between sessions has been exceeded
            reset()
        }
        
        // Mark the time for this event
        lastEventTime = now
        
        // Increment the count for events with this direction
        events[eventDir] = events[eventDir]! + 1
        
        // Event is valid
        return true
    }
    
    /*
        Determines the intended scroll direction for this session. This is calculated by determining which direction most of the scrolling thus far has been performed in. Example - If the session has 10 scroll Up events and 2 scroll Left events, the intended scroll direction is Up.
     */
    private static func getIntendedDirection() -> GestureDirection {
        
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
        
        lastEventTime = nil
        events = [.up: 0, .down: 0, .left: 0, .right: 0]
    }
    
    // Calculates the time since the last event in the current session, in seconds. If there is no current session (i.e. lastEventTime is nil), a large value is returned, so as to indicate that the max time gap between sessions has been exceeded and that a new session should be started.
    private static func timeSinceLastEvent() -> TimeInterval {
        return lastEventTime == nil ? 10 : Date().timeIntervalSince(lastEventTime!)
    }
}

// Enumerates all possible directions of a trackpad/MagicMouse swipe/scroll gesture
enum GestureDirection: String {
    
    case left
    case right
    case down
    case up
}
