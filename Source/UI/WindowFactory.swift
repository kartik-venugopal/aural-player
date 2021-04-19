import Cocoa

/*
    Factory for instantiating windows/dialogs from XIBs
 */
class WindowFactory {
    
    static var editorWindowController: EditorWindowController = EditorWindowController()
    
    private static var colorSchemesWindowController: ColorSchemesWindowController = ColorSchemesWindowController()
    
    private static var fontSchemesWindowController: FontSchemesWindowController = FontSchemesWindowController()
    
    private static var createThemeDialogController: CreateThemeDialogController = CreateThemeDialogController()
    
    static var alertWindowController: AlertWindowController = AlertWindowController()
    
    // MARK: Accessor functions for the different windows/dialogs
    
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
