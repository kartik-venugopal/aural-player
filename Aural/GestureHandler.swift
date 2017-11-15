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
        
        // Ignore any swipe events that weren't performed over the main window (they trigger other functions if performed over the playlist window)
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
        
        // Ignore any swipe events that weren't performed over the main window (they trigger other functions if performed over the playlist window)
        if event.window != WindowState.window {
            return
        }
        
        // Used to indicate a player action triggered by the swipe
        var actionType: ActionType
        
        if let scrollVector = UIUtils.determineScrollVector(event) {
            
            switch scrollVector.direction {
                
            case .up: actionType = .increaseVolume
                
            case .down: actionType = .decreaseVolume
                
            case .left: actionType = .seekBackward
                
            case .right: actionType = .seekForward
                
            }
            
            // Publish the action message
            
            if (actionType == .seekBackward || actionType == .seekForward) {
                SyncMessenger.publishActionMessage(PlaybackActionMessage(actionType))
            } else {
                SyncMessenger.publishActionMessage(AudioGraphActionMessage(actionType, Float(scrollVector.movement)))
            }
        }
    }
}

// Enumerates all possible directions of a trackpad/MagicMouse swipe/scroll gesture
enum GestureDirection: String {
    
    case left
    case right
    case down
    case up
}
