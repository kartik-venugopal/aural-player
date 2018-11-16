import Cocoa

// TODO: Remove this class .. merge with LayoutManager
// Provides convenient access to the state of the main and playlist windows, across the view layer of the app
class WindowState {
    
    static var mainWindow: NSWindow!
    static var playlistWindow: NSWindow!
    static var effectsWindow: NSWindow!
    
    static var showingPlaylist: Bool = true
    static var showingEffects: Bool = true
    
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
        return mainWindow.frame.origin
    }
    
    // The app is considered to be in the foreground if it is active, it is not hidden, and it is not minimized.
    static func isInForeground() -> Bool {
        return appActive && !appHidden && !minimized
    }
    
    static func persistentState() -> WindowLayoutState {
        
        let uiState = WindowLayoutState()
        
        uiState.showEffects = showingEffects
        uiState.showPlaylist = showingPlaylist
        
        uiState.mainWindowOrigin = location()
        
        if showingEffects {
            uiState.effectsWindowOrigin = effectsWindow.origin
        }
        
        if showingPlaylist {
            uiState.playlistWindowFrame = playlistWindow.frame
        }
        
        return uiState
    }
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
        return (NSScreen.main!.visibleFrame.width - self.width)
    }
    
    // Screen (visible) height - this window's height
    var remainingHeight: CGFloat {
        return (NSScreen.main!.visibleFrame.height - self.height)
    }
}
