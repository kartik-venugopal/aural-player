import Cocoa

/*
    Factory for instantiating windows/dialogs from XIBs
 */
class WindowFactory {
    
    static var editorWindowController: EditorWindowController = EditorWindowController()
    
    private static var preferencesWindowController: PreferencesWindowController = PreferencesWindowController()
    
    private static var playlistSearchWindowController: PlaylistSearchWindowController = PlaylistSearchWindowController()
    
    private static var playlistSortWindowController : PlaylistSortWindowController = PlaylistSortWindowController()
    
    private static var jumpToTimeEditorWindowController: JumpToTimeEditorWindowController = JumpToTimeEditorWindowController()
    
    private static var colorSchemesWindowController: ColorSchemesWindowController = ColorSchemesWindowController()
    
    private static var fontSchemesWindowController: FontSchemesWindowController = FontSchemesWindowController()
    
    private static var createThemeDialogController: CreateThemeDialogController = CreateThemeDialogController()
    
    static var alertWindowController: AlertWindowController = AlertWindowController()
    
    // MARK: Accessor functions for the different windows/dialogs
    
    // Returns the preferences modal dialog
    static var preferencesDialog: ModalDialogDelegate {
        return preferencesWindowController
    }
    
    // Returns the playlist search dialog
    static var playlistSearchDialog: ModalDialogDelegate {
        return playlistSearchWindowController
    }
    
    // Returns the playlist sort dialog
    static var playlistSortDialog: ModalDialogDelegate {
        return playlistSortWindowController
    }

    static var jumpToTimeEditorDialog: ModalDialogDelegate {
        return jumpToTimeEditorWindowController
    }
    
    static var colorSchemesDialog: ModalDialogDelegate {
        return colorSchemesWindowController
    }
    
    static var fontSchemesDialog: ModalDialogDelegate {
        return fontSchemesWindowController
    }
    
    static var createThemeDialog: ModalDialogDelegate {
        return createThemeDialogController
    }
}
