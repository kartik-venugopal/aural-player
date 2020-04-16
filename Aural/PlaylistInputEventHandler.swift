/*
    Handles input events (key presses and trackpad/MagicMouse gestures) for certain playlist functions like type selection and scrolling.
*/

import Cocoa

class PlaylistInputEventHandler {
    
    // A mapping of playlist type to the corresponding view that displays it
    private static var playlistViews: [PlaylistType: NSTableView] = [:]
    
    private static let preferences: ControlsPreferences = ObjectGraph.preferencesDelegate.preferences.controlsPreferences
    
    private static let layoutManager: LayoutManagerProtocol = ObjectGraph.layoutManager
    
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
        if event.window != layoutManager.playlistWindow {
            return
        }
        
        if let swipeDirection = UIUtils.determineSwipeDirection(event) {
            
            swipeDirection.isHorizontal ? handlePlaylistTabToggle(event, swipeDirection) : handlePlaylistNavigation(event, swipeDirection)
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
        
        // One-off special case: Without this, space key press (for play/pause) is not sent to main window
        // Send space to main window unless chapters list window is key (space is used for type selection and chapter search)
        if event.charactersIgnoringModifiers == " " && layoutManager.chaptersListWindow != NSApp.keyWindow {
            layoutManager.mainWindow.keyDown(with: event)
            return true
        }
        
        return false
    }
}
