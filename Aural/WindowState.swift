import Cocoa

// TODO: Remove this class .. merge with LayoutManager
// Provides convenient access to the state of the main and playlist windows, across the view layer of the app
class WindowState {
    
    // Flag that indicates whether the app is displaying an input receiving popover view (used to block input from being received by other views on the window)
    static var showingPopover: Bool = false
    
    // These variables determine whether or not the app is currently in the "foreground"
//    static var appActive: Bool = true
//    static var appHidden: Bool = false
//    static var minimized: Bool = false
    
//    static func setActive(_ isActive: Bool) {
//
//        appActive = isActive
//
//        // Publish a notification indicating whether or not the app is now in the foreground
//        isInForeground() ? SyncMessenger.publishNotification(AppInForegroundNotification.instance) : SyncMessenger.publishNotification(AppInBackgroundNotification.instance)
//    }
//
//    static func setHidden(_ isHidden: Bool) {
//
//        appHidden = isHidden
//
//        // Publish a notification indicating whether or not the app is now in the foreground
//        isInForeground() ? SyncMessenger.publishNotification(AppInForegroundNotification.instance) : SyncMessenger.publishNotification(AppInBackgroundNotification.instance)
//    }
//
//    static func setMinimized(_ isMinimized: Bool) {
//
//        minimized = isMinimized
//
//        // Publish a notification indicating whether or not the app is now in the foreground
//        isInForeground() ? SyncMessenger.publishNotification(AppInForegroundNotification.instance) : SyncMessenger.publishNotification(AppInBackgroundNotification.instance)
//    }
//
//    // The app is considered to be in the foreground if it is active, it is not hidden, and it is not minimized.
//    static func isInForeground() -> Bool {
//        return appActive && !appHidden && !minimized
//    }
}
