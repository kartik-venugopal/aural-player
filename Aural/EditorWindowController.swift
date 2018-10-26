import Cocoa

class EditorWindowController: NSWindowController {
    
    private lazy var bookmarksEditorView: NSView = ViewFactory.getBookmarksEditorView()
    
    private lazy var favoritesEditorView: NSView = ViewFactory.getFavoritesEditorView()
    
    private lazy var layoutsEditorView: NSView = ViewFactory.getLayoutsEditorView()
    
    private lazy var effectsPresetsEditorView: NSView = ViewFactory.getEffectsPresetsEditorView()
    
    override var windowNibName: String? {return "EditorWindow"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        
        theWindow.contentView?.addSubview(bookmarksEditorView)
        theWindow.contentView?.addSubview(favoritesEditorView)
        theWindow.contentView?.addSubview(layoutsEditorView)
        theWindow.contentView?.addSubview(effectsPresetsEditorView)
        
        theWindow.isMovableByWindowBackground = true
    }
    
    func showBookmarksEditor() {
        
        bookmarksEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, bookmarksEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        favoritesEditorView.hide()
        layoutsEditorView.hide()
        effectsPresetsEditorView.hide()
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
    
    func showFavoritesEditor() {
        
        favoritesEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, favoritesEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        bookmarksEditorView.hide()
        layoutsEditorView.hide()
        effectsPresetsEditorView.hide()
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
    
    func showLayoutsEditor() {
        
        layoutsEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, layoutsEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        favoritesEditorView.hide()
        bookmarksEditorView.hide()
        effectsPresetsEditorView.hide()
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
    
    func showEffectsPresetsEditor() {
        
        effectsPresetsEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, effectsPresetsEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        layoutsEditorView.hide()
        favoritesEditorView.hide()
        bookmarksEditorView.hide()
        
        WindowState.showingPopover = true
        UIUtils.showModalDialog(theWindow)
    }
}
