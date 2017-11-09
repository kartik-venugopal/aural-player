import Cocoa

/*
    Handles instantiation of all application windows and exposes them through protocols so as to provide abstraction
 */
class WindowFactory {
    
    // Preferences dialog
    private static var preferencesWindowController : PreferencesWindowController = PreferencesWindowController()
    
    // Playlist sort dialog
    private static var playlistSortWindowController : PlaylistSortWindowController = PlaylistSortWindowController()
    
    static func getPreferencesDialog() -> ModalDialogDelegate {
        return preferencesWindowController
    }
    
    static func getPlaylistSortDialog() -> ModalDialogDelegate {
        return playlistSortWindowController
    }
}
