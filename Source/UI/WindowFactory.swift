import Cocoa

/*
    Factory for instantiating windows/dialogs from XIBs
 */
class WindowFactory {
    
    static var editorWindowController: EditorWindowController = EditorWindowController()
    
    static var alertWindowController: AlertWindowController = AlertWindowController()
}
