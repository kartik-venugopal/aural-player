/*
    Handles input events (key presses and trackpad/MagicMouse gestures) for certain playlist functions like type selection and scrolling.
*/

import Cocoa

class PlaylistInputEventHandler {
    
    // A mapping of playlist type to the corresponding view that displays it
    private static var playlistViews: [PlaylistType: NSTableView] = [:]
    
    private static let preferences: ControlsPreferences = ObjectGraph.preferencesDelegate.preferences.controlsPreferences
    
    static func registerViewForPlaylistType(_ playlistType: PlaylistType, _ playlistView: NSTableView) {
        playlistViews[playlistType] = playlistView
    }
    
    // Handles a single event. Returns true if the event has been successfully handled (or needs to be suppressed), false otherwise
    static func handle(_ event: NSEvent) {
        
        // If a modal dialog is open, don't do anything
        // Also, ignore any swipe events that weren't performed over the playlist window
        // (they trigger other functions if performed over the main window)
        
        // TODO: Enable top/bottom gestures for chapters list window too !!!
        
        if event.type == .swipe, !WindowManager.isShowingModalComponent && event.window === WindowManager.playlistWindow,
            let swipeDirection = UIUtils.determineSwipeDirection(event) {
            
            swipeDirection.isHorizontal ? handlePlaylistTabToggle(event, swipeDirection) : handlePlaylistNavigation(event, swipeDirection)
        }
    }
    
    private static func handlePlaylistNavigation(_ event: NSEvent, _ swipeDirection: GestureDirection) {
        
        if preferences.allowPlaylistNavigation {
        
            // Publish the command notification
            Messenger.publish(swipeDirection == .up ? .playlist_scrollToTop : .playlist_scrollToBottom, payload: PlaylistViewSelector.allViews)
        }
    }
    
    private static func handlePlaylistTabToggle(_ event: NSEvent, _ swipeDirection: GestureDirection) {
        
        if preferences.allowPlaylistTabToggle {
            
            // Publish the command notification
            Messenger.publish(swipeDirection == .left ? .playlist_previousView : .playlist_nextView)
        }
    }
}
