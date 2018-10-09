/*
    Handles input events (key presses and trackpad/MagicMouse gestures) for certain playlist functions like type selection and scrolling.
*/

import Cocoa

class PlaylistInputEventHandler {
    
    // A mapping of playlist type to the corresponding view that displays it
    private static var playlistViews: [PlaylistType: NSTableView] = [:]
    
    private static let preferences: ControlsPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().controlsPreferences
    
    static func registerViewForPlaylistType(_ playlistType: PlaylistType, _ playlistView: NSTableView) {
        playlistViews[playlistType] = playlistView
    }
    
    // Handles a single event. Returns true if the event has been successfully handled (or needs to be suppressed), false otherwise
    static func handle(_ event: NSEvent) -> Bool {
        
        if (NSApp.modalWindow != nil || WindowState.showingPopover) {
            // Modal dialog open, don't do anything
            return false
        }
        
        // Delegate to an appropriate handler function based on event type
        switch event.type {
            
        case .keyDown: return handleKeyDown(event)
            
        case .swipe: handleSwipe(event)
            
        default: return false
            
        }
        
        return false
    }
    
    // Handles a single swipe event
    private static func handleSwipe(_ event: NSEvent) {
        
        // Ignore any swipe events that weren't performed over the playlist window (they trigger other functions if performed over the main window)
        if event.window != WindowState.playlistWindow {
            return
        }
        
        if let swipeDirection = UIUtils.determineSwipeDirection(event) {
            
            swipeDirection.isHorizontal() ? handlePlaylistTabToggle(event, swipeDirection) : handlePlaylistNavigation(event, swipeDirection)
        }
    }
    
    private static func handlePlaylistNavigation(_ event: NSEvent, _ swipeDirection: GestureDirection) {
        
        if preferences.allowPlaylistNavigation {
        
            // Publish the action message
            SyncMessenger.publishActionMessage(PlaylistActionMessage(swipeDirection == .up ? .scrollToTop : .scrollToBottom, nil))
        }
    }
    
    private static func handlePlaylistTabToggle(_ event: NSEvent, _ swipeDirection: GestureDirection) {
        
        if preferences.allowPlaylistTabToggle {
            
            // Publish the action message
            SyncMessenger.publishActionMessage(PlaylistActionMessage(swipeDirection == .left ? .previousPlaylistView : .nextPlaylistView, nil))
        }
    }
    
    // Handles a single key press event. Returns true if the event has been successfully handled (or needs to be suppressed), false otherwise
    private static func handleKeyDown(_ event: NSEvent) -> Bool {
        
        // Indicate whether or not Shift/Command/Option were pressed
        let isShift: Bool = event.modifierFlags.contains(NSEvent.ModifierFlags.shift)
        let isCommand: Bool = event.modifierFlags.contains(NSEvent.ModifierFlags.command)
        let isOption: Bool = event.modifierFlags.contains(NSEvent.ModifierFlags.option)
        
        let isVerticalArrow: Bool = KeyCodeConstants.verticalArrows.contains(event.keyCode)
        
        let chars = event.charactersIgnoringModifiers
        let isAlphaNumeric = chars != nil && chars!.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
        
        // ---------------------- Handlers --------------------------
        
        // Arrows enable natural playlist scrolling and group expansion/collapsing, and alphanumeric characters enable type selection by track name
        if (!isShift && !isCommand && !isOption && (isVerticalArrow || isAlphaNumeric)) {
            
            // Forward the event to the currently displayed playlist view
            playlistViews[PlaylistViewState.current]!.keyDown(with: event)
            return true
        }
        
        // NOTE - This keyboard shortcut is for debugging purposes only, not intended for the end user
        // (Shift + Command + S) Print Timer stats
        if (isShift && isCommand && (chars != nil && chars! == "S")) {
            TimerUtils.printStats()
            return false
        }
        
        return false
    }
}
