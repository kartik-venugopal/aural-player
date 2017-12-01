import Cocoa

/*
    Factory for instantiating windows/dialogs from XIBs
 */
class WindowFactory {
    
    private static var mainWindowController: MainWindowController = MainWindowController()
    
    private static var playlistWindowController: PlaylistWindowController = PlaylistWindowController()
    
    private static var barModeWindowController: BarModeWindowController = BarModeWindowController()
    
    private static var preferencesWindowController: PreferencesWindowController = PreferencesWindowController()
    
    private static var playlistSearchWindowController: PlaylistSearchWindowController = PlaylistSearchWindowController()
    
    private static var playlistSortWindowController : PlaylistSortWindowController = PlaylistSortWindowController()
    
    // MARK: Accessor functions for the different windows/dialogs
    
    static func getMainWindow() -> NSWindow {
        return mainWindowController.window!
    }
    
    static func getMainWindowController() -> MainWindowController {
        return mainWindowController
    }
    
    // Returns the playlist window
    static func getPlaylistWindow() -> NSWindow {
        return playlistWindowController.window!
    }
    
    static func getPlaylistContextMenu() -> NSMenu {
        return playlistWindowController.contextMenu
    }
    
    // Returns the preferences modal dialog
    static func getPreferencesDialog() -> ModalDialogDelegate {
        return preferencesWindowController
    }
    
    // Returns the playlist search dialog
    static func getPlaylistSearchDialog() -> ModalDialogDelegate {
        return playlistSearchWindowController
    }
    
    // Returns the playlist sort dialog
    static func getPlaylistSortDialog() -> ModalDialogDelegate {
        return playlistSortWindowController
    }
}

/*
    Protocol to be implemented by all NSWindowController classes that control modal dialogs. This is intended to provide abstraction, so that NSWindowController classes are not entirely exposed to callers unnecessarily.
 */
protocol ModalDialogDelegate {
    
    // Initialize and present the dialog modally
    func showDialog()
}
