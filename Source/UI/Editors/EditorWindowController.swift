import Cocoa

class EditorWindowController: NSWindowController, ModalComponentProtocol {
    
    private lazy var bookmarksEditorView: NSView = ViewFactory.bookmarksEditorView
    
    private lazy var favoritesEditorView: NSView = ViewFactory.favoritesEditorView
    
    private lazy var layoutsEditorView: NSView = ViewFactory.layoutsEditorView
    
    private lazy var themesEditorView: NSView = ViewFactory.themesEditorView
    
    private lazy var fontSchemesEditorView: NSView = ViewFactory.fontSchemesEditorView
    
    private lazy var colorSchemesEditorView: NSView = ViewFactory.colorSchemesEditorView
    
    private lazy var effectsPresetsEditorView: NSView = ViewFactory.effectsPresetsEditorView
    
    override var windowNibName: String? {return "EditorWindow"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        
        // TODO: Use tab view ?
        
        theWindow.contentView?.addSubview(bookmarksEditorView)
        theWindow.contentView?.addSubview(favoritesEditorView)
        theWindow.contentView?.addSubview(layoutsEditorView)
        theWindow.contentView?.addSubview(themesEditorView)
        theWindow.contentView?.addSubview(fontSchemesEditorView)
        theWindow.contentView?.addSubview(colorSchemesEditorView)
        theWindow.contentView?.addSubview(effectsPresetsEditorView)
        
        theWindow.isMovableByWindowBackground = true
        
        WindowManager.registerModalComponent(self)
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showBookmarksEditor() {
        
        bookmarksEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, bookmarksEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        [themesEditorView, fontSchemesEditorView, colorSchemesEditorView, favoritesEditorView, layoutsEditorView, effectsPresetsEditorView].forEach({$0.hide()})
        
        UIUtils.showDialog(theWindow)
    }
    
    func showFavoritesEditor() {
        
        favoritesEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, favoritesEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        [themesEditorView, fontSchemesEditorView, colorSchemesEditorView, bookmarksEditorView, layoutsEditorView, effectsPresetsEditorView].forEach({$0.hide()})
        
        UIUtils.showDialog(theWindow)
    }
    
    func showLayoutsEditor() {
        
        layoutsEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, layoutsEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        [themesEditorView, fontSchemesEditorView, colorSchemesEditorView, favoritesEditorView, bookmarksEditorView, effectsPresetsEditorView].forEach({$0.hide()})
        
        UIUtils.showDialog(theWindow)
    }
    
    func showEffectsPresetsEditor() {
        
        effectsPresetsEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, effectsPresetsEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        [themesEditorView, fontSchemesEditorView, colorSchemesEditorView, favoritesEditorView, layoutsEditorView, bookmarksEditorView].forEach({$0.hide()})
        
        UIUtils.showDialog(theWindow)
    }
    
    func showThemesEditor() {
        
        themesEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, themesEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        [fontSchemesEditorView, colorSchemesEditorView, effectsPresetsEditorView, favoritesEditorView, layoutsEditorView, bookmarksEditorView].forEach({$0.hide()})
        
        UIUtils.showDialog(theWindow)
    }
    
    func showFontSchemesEditor() {
        
        fontSchemesEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, fontSchemesEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        [themesEditorView, colorSchemesEditorView, effectsPresetsEditorView, favoritesEditorView, layoutsEditorView, bookmarksEditorView].forEach({$0.hide()})
        
        UIUtils.showDialog(theWindow)
    }
    
    func showColorSchemesEditor() {
        
        colorSchemesEditorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, colorSchemesEditorView.height)
        theWindow.setFrame(frame, display: true)
        
        [themesEditorView, fontSchemesEditorView, effectsPresetsEditorView, favoritesEditorView, layoutsEditorView, bookmarksEditorView].forEach({$0.hide()})
        
        UIUtils.showDialog(theWindow)
    }
}
