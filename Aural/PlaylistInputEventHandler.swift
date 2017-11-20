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
    
    // Handles a single event
    static func handle(_ event: NSEvent) {
        
        if (NSApp.modalWindow != nil) {
            // Modal dialog open, don't do anything
            return
        }
        
        // Delegate to an appropriate handler function based on event type
        switch event.type {
            
        case .keyDown: handleKeyDown(event)
            
        case .swipe: handleSwipe(event)
            
        default: return
            
        }
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
    
    // Handles a single key press event
    private static func handleKeyDown(_ event: NSEvent) {
        
        // Indicate whether or not Shift/Command/Option were pressed
        let isShift: Bool = event.modifierFlags.contains(NSEventModifierFlags.shift)
        let isCommand: Bool = event.modifierFlags.contains(NSEventModifierFlags.command)
        let isOption: Bool = event.modifierFlags.contains(NSEventModifierFlags.option)
        
        let isArrow: Bool = KeyCodeConstants.arrows.contains(event.keyCode)
        
        let chars = event.charactersIgnoringModifiers
        let isAlphaNumeric = chars != nil && chars!.rangeOfCharacter(from: CharacterSet.alphanumerics) != nil
        
        // ---------------------- Handlers --------------------------
        
        // Arrows enable natural playlist scrolling and group expansion/collapsing, and alphanumeric characters enable type selection by track name
        if (!isShift && !isCommand && !isOption && (isArrow || isAlphaNumeric)) {
            
            // Forward the event to the currently displayed playlist view
            playlistViews[PlaylistViewState.current]!.keyDown(with: event)
            return
        }
        
        // NOTE - This keyboard shortcut is for debugging purposes only, not intended for the end user
        // (Shift + Command + S) Print Timer stats
        if (isShift && isCommand && (chars != nil && chars! == "S")) {
            TimerUtils.printStats()
            return
        }
    }
}

fileprivate class KeyCodeConstants {

    // TODO: Are these system-independent ???
    static let UP_ARROW: UInt16 = 126
    static let DOWN_ARROW: UInt16 = 125
    
    static let LEFT_ARROW: UInt16 = 123
    static let RIGHT_ARROW: UInt16 = 124
    
    static let arrows = [UP_ARROW, DOWN_ARROW, LEFT_ARROW, RIGHT_ARROW]
}
