import Cocoa

// Provides convenient access to the state of the main and playlist windows, across the view layer of the app
class WindowState {
    
    static var window: NSWindow!
    static var playlistWindow: NSWindow!
    
    static var showingPlaylist: Bool = AppDefaults.showPlaylist
    static var showingEffects: Bool = AppDefaults.showEffects
    static var playlistLocation: PlaylistLocations = AppDefaults.playlistLocation
    
    // These variables determine whether or not the app is currently in the "foreground"
    static var appActive: Bool = true
    static var appHidden: Bool = false
    static var minimized: Bool = false
    
    // Flag that indicates whether the app is displaying an input receiving popover view (used to block input from being received by other views on the window)
    static var showingPopover: Bool = false
    
    static func setActive(_ isActive: Bool) {
        
        appActive = isActive
        
        // Publish a notification indicating whether or not the app is now in the foreground
        isInForeground() ? SyncMessenger.publishNotification(AppInForegroundNotification.instance) : SyncMessenger.publishNotification(AppInBackgroundNotification.instance)
    }
    
    static func setHidden(_ isHidden: Bool) {
        
        appHidden = isHidden
        
        // Publish a notification indicating whether or not the app is now in the foreground
        isInForeground() ? SyncMessenger.publishNotification(AppInForegroundNotification.instance) : SyncMessenger.publishNotification(AppInBackgroundNotification.instance)
    }
    
    static func setMinimized(_ isMinimized: Bool) {
        
        minimized = isMinimized
        
        // Publish a notification indicating whether or not the app is now in the foreground
        isInForeground() ? SyncMessenger.publishNotification(AppInForegroundNotification.instance) : SyncMessenger.publishNotification(AppInBackgroundNotification.instance)
    }
    
    static func location() -> NSPoint {
        return window.frame.origin
    }
    
    // The app is considered to be in the foreground if it is active, it is not hidden, and it is not minimized.
    static func isInForeground() -> Bool {
        return appActive && !appHidden && !minimized
    }
    
    static func persistentState() -> UIState {
        
        let uiState = UIState()
        
//        uiState.windowLocationX = Float(window.x)
//        uiState.windowLocationY = Float(window.y)
        
        uiState.showEffects = showingEffects
        uiState.showPlaylist = showingPlaylist
        
        uiState.playlistLocation = playlistLocation
        
        return uiState
    }
}

// Enumerates all possible dock states of the playlist window, in relation to the main window
enum PlaylistDockState: String {
    
    // Playlist has been docked on the bottom of the main window
    case bottom
    
    // Playlist has been docked on the right side of the main window
    case right
    
    // Playlist has been docked on the left side of the main window
    case left
    
    // Playlist is not docked
    case none
}

// Accessors for convenience/conciseness
extension NSWindow {
    
    var origin: NSPoint {
        return self.frame.origin
    }
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    // X co-ordinate of location
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    // Y co-ordinate of location
    var y: CGFloat {
        return self.frame.origin.y
    }
    
    var maxX: CGFloat {
        return self.frame.maxX
    }
    
    var maxY: CGFloat {
        return self.frame.maxY
    }
    
    // Screen (visible) width - this window's width
    var remainingWidth: CGFloat {
        return (NSScreen.main()!.visibleFrame.width - self.width)
    }
    
    // Screen (visible) height - this window's height
    var remainingHeight: CGFloat {
        return (NSScreen.main()!.visibleFrame.height - self.height)
    }
}

// Type mapping extension
extension PlaylistLocations {
    
    func toPlaylistDockState() -> PlaylistDockState {
        
        switch self {
            
        case .left: return .left
            
        case .right: return .right
            
        case .bottom: return .bottom
            
        }
    }
}
