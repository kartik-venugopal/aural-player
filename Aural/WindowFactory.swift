import Cocoa

/*
    Factory for instantiating windows/dialogs from XIBs
 */
class WindowFactory {
    
    private static var mainWindowController: MainWindowController = MainWindowController()
    
    private static var effectsWindowController: EffectsWindowController = EffectsWindowController()
    
    private static var playlistWindowController: PlaylistWindowController = PlaylistWindowController()
    
    private static var editorWindowController: EditorWindowController = EditorWindowController()
    
    private static var barModeWindowController: BarModeWindowController = BarModeWindowController()
    
    private static var preferencesWindowController: PreferencesWindowController = PreferencesWindowController()
    
    private static var playlistSearchWindowController: PlaylistSearchWindowController = PlaylistSearchWindowController()
    
    private static var playlistSortWindowController : PlaylistSortWindowController = PlaylistSortWindowController()
    
    private static var gapsEditorWindowController: GapsEditorWindowController = GapsEditorWindowController()
    
    private static var delayedPlaybackEditorWindowController: DelayedPlaybackEditorWindowController = DelayedPlaybackEditorWindowController()
    
    private static var jumptToTimeEditorWindowController: JumpToTimeEditorWindowController = JumpToTimeEditorWindowController()
    
    // MARK: Accessor functions for the different windows/dialogs
    
    static func getMainWindow() -> NSWindow {
        return mainWindowController.window!
    }
    
    static func getMainWindowController() -> MainWindowController {
        return mainWindowController
    }
    
    static func getEffectsWindow() -> NSWindow {
        return effectsWindowController.window!
    }
    
    // Returns the playlist window
    static func getPlaylistWindow() -> NSWindow {
        return playlistWindowController.window!
    }
    
    static func getPlaylistContextMenu() -> NSMenu {
        return playlistWindowController.contextMenu
    }
    
    static func getEditorWindowController() -> EditorWindowController {
        return editorWindowController
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
    
    static func getGapsEditorDialog() -> ModalDialogDelegate {
        return gapsEditorWindowController
    }
    
    static func getDelayedPlaybackEditorDialog() -> ModalDialogDelegate {
        return delayedPlaybackEditorWindowController
    }
    
    static func getJumpToTimeEditorDialog() -> ModalDialogDelegate {
        return jumptToTimeEditorWindowController
    }
}

/*
    Protocol to be implemented by all NSWindowController classes that control modal dialogs. This is intended to provide abstraction, so that NSWindowController classes are not entirely exposed to callers unnecessarily.
 */
protocol ModalDialogDelegate {
    
    // Initialize and present the dialog modally
    func showDialog() -> ModalDialogResponse
    
    func setDataForKey(_ key: String, _ value: Any?)
}

enum ModalDialogResponse {
    
    case ok
    case cancel
}

extension ModalDialogDelegate {
    
    func setDataForKey(_ key: String, _ value: Any?) {
        // Dummy implementation
    }
}
