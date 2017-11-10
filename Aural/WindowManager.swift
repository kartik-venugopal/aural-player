import Cocoa

/*
    Handles instantiation of all application windows and exposes them through protocols so as to provide abstraction
 */
class WindowManager {
    
    private static var mainWindowController: MainWindowController = MainWindowController()
    
    private static var playlistWindowController: PlaylistWindowController = PlaylistWindowController()
    
    // Preferences dialog
    private static var preferencesWindowController: PreferencesWindowController = PreferencesWindowController()
    
    // Playlist search dialog
    private static var playlistSearchWindowController: PlaylistSearchWindowController = PlaylistSearchWindowController()
    
    // Playlist sort dialog
    private static var playlistSortWindowController : PlaylistSortWindowController = PlaylistSortWindowController()
    
    static func showMainWindow() {
        mainWindowController.showWindow(NSApplication.shared().delegate)
    }
    
    static func getMainWindow() -> NSWindow {
        return mainWindowController.window!
    }
    
    static func getPlaylistWindow() -> NSWindow {
        return playlistWindowController.window!
    }
    
    static func getPreferencesDialog() -> ModalDialogDelegate {
        return preferencesWindowController
    }
    
    static func getPlaylistSearchDialog() -> ModalDialogDelegate {
        return playlistSearchWindowController
    }
    
    static func getPlaylistSortDialog() -> ModalDialogDelegate {
        return playlistSortWindowController
    }
}
