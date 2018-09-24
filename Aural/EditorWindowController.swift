import Cocoa

class EditorWindowController: NSWindowController {
    
    private lazy var bookmarksEditorView: NSView = ViewFactory.getBookmarksEditorView()
    
    private lazy var favoritesEditorView: NSView = ViewFactory.getFavoritesEditorView()
    
    override var windowNibName: String? {return "EditorWindow"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        
        // TODO: Need to decide which view to add: bookmarks or favorites editor view
        theWindow.contentView?.addSubview(bookmarksEditorView)
        theWindow.contentView?.addSubview(favoritesEditorView)
        
        theWindow.isMovableByWindowBackground = true
    }
    
    func showBookmarksEditor() {
        
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        favoritesEditorView.isHidden = true
        bookmarksEditorView.isHidden = false
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
    
    func showFavoritesEditor() {
        
        bookmarksEditorView.isHidden = true
        favoritesEditorView.isHidden = false
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
}
