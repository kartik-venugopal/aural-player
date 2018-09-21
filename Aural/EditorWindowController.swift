import Cocoa

class EditorWindowController: NSWindowController {
    
    private lazy var bookmarksEditorView: NSView = ViewFactory.getBookmarksEditorView()
    
    override var windowNibName: String? {return "EditorWindow"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        
        // TODO: Need to decide which view to add: bookmarks or favorites editor view
        theWindow.contentView?.addSubview(bookmarksEditorView)
    }
}
