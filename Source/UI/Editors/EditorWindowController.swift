import Cocoa

class EditorWindowController: NSWindowController, ModalComponentProtocol, Destroyable {
    
    private static var _instance: EditorWindowController?
    static var instance: EditorWindowController {
        
        if _instance == nil {
            _instance = EditorWindowController()
        }
        
        return _instance!
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    private lazy var bookmarksEditorView: NSView = BookmarksEditorViewController().view
    private lazy var favoritesEditorView: NSView = FavoritesEditorViewController().view
    private lazy var layoutsEditorView: NSView = LayoutsEditorViewController().view
    private lazy var themesEditorView: NSView = ThemesEditorViewController().view
    private lazy var fontSchemesEditorView: NSView = FontSchemesEditorViewController().view
    private lazy var colorSchemesEditorView: NSView = ColorSchemesEditorViewController().view
    
    private lazy var effectsPresetsEditorViewLoader: LazyViewLoader<EffectsPresetsEditorViewController> = LazyViewLoader()
    private lazy var effectsPresetsEditorView: NSView = effectsPresetsEditorViewLoader.view
    
    override var windowNibName: String? {"EditorWindow"}
    
    private var theWindow: NSWindow {self.window!}
    
    private var addedViews: Set<NSView> = Set()
    
    override func windowDidLoad() {
        
        // TODO: Use tab view ?
        theWindow.isMovableByWindowBackground = true
        WindowManager.instance.registerModalComponent(self)
    }
    
    func destroy() {
        
        addedViews.removeAll()
        effectsPresetsEditorViewLoader.destroy()
    }
    
    var isModal: Bool {self.window?.isVisible ?? false}
    
    func showEditor(_ editorView: NSView) {
        
        if !addedViews.contains(editorView) {
            
            theWindow.contentView?.addSubview(editorView)
            addedViews.insert(editorView)
        }
        
        addedViews.forEach {$0.hide()}
        editorView.show()
        
        var frame = theWindow.frame
        frame.size = NSMakeSize(frame.width, editorView.height)
        theWindow.setFrame(frame, display: true)
        
        UIUtils.showDialog(theWindow)
    }
    
    func showBookmarksEditor() {
        showEditor(bookmarksEditorView)
    }
    
    func showFavoritesEditor() {
        showEditor(favoritesEditorView)
    }
    
    func showLayoutsEditor() {
        showEditor(layoutsEditorView)
    }
    
    func showEffectsPresetsEditor() {
        showEditor(effectsPresetsEditorView)
    }
    
    func showThemesEditor() {
        showEditor(themesEditorView)
    }
    
    func showFontSchemesEditor() {
        showEditor(fontSchemesEditorView)
    }
    
    func showColorSchemesEditor() {
        showEditor(colorSchemesEditorView)
    }
}
