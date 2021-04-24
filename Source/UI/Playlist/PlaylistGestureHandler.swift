/*
    Handles trackpad/MagicMouse gestures for certain playlist functions like scrolling and tab group tab switching.
*/
import Cocoa

class PlaylistGestureHandler {
    
    private static let preferences: ControlsPreferences = ObjectGraph.preferences.controlsPreferences
    
    // Handles a single event. Returns true if the event has been successfully handled (or needs to be suppressed), false otherwise
    static func handle(_ event: NSEvent) {
        
        // If a modal dialog is open, don't do anything
        // Also, ignore any swipe events that weren't performed over the playlist window
        // (they trigger other functions if performed over the main window)
        
        // TODO: Enable top/bottom gestures for chapters list window too !!!
        
        if event.type == .swipe, !WindowManager.instance.isShowingModalComponent && event.window === WindowManager.instance.playlistWindow,
            let swipeDirection = UIUtils.determineSwipeDirection(event) {
            
            swipeDirection.isHorizontal ? handleTabToggle(swipeDirection) : handleScrolling(swipeDirection)
        }
    }
    
    private static func handleScrolling(_ swipeDirection: GestureDirection) {
        
        if preferences.allowPlaylistNavigation {
        
            Messenger.publish(swipeDirection == .up ? .playlist_scrollToTop : .playlist_scrollToBottom,
                              payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
        }
    }
    
    private static func handleTabToggle(_ swipeDirection: GestureDirection) {
        
        if preferences.allowPlaylistTabToggle {
            Messenger.publish(swipeDirection == .left ? .playlist_previousView : .playlist_nextView)
        }
    }
}
