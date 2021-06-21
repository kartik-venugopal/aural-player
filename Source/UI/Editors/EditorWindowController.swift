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
    
    private lazy var bookmarksEditorViewController: NSViewController = BookmarksEditorViewController()
    private lazy var bookmarksEditorView: NSView = bookmarksEditorViewController.view
    
    private lazy var favoritesEditorViewController: NSViewController = FavoritesEditorViewController()
    private lazy var favoritesEditorView: NSView = favoritesEditorViewController.view
    
    private lazy var layoutsEditorViewController: NSViewController = LayoutsEditorViewController()
    private lazy var layoutsEditorView: NSView = layoutsEditorViewController.view
    
    private lazy var themesEditorViewController: NSViewController = ThemesEditorViewController()
    private lazy var themesEditorView: NSView = themesEditorViewController.view
    
    private lazy var fontSchemesEditorViewController: NSViewController = FontSchemesEditorViewController()
    private lazy var fontSchemesEditorView: NSView = fontSchemesEditorViewController.view
    
    private lazy var colorSchemesEditorViewController: NSViewController = ColorSchemesEditorViewController()
    private lazy var colorSchemesEditorView: NSView = colorSchemesEditorViewController.view
    
    private lazy var effectsPresetsEditorViewLoader: LazyViewLoader<EffectsPresetsEditorViewController> = LazyViewLoader()
    private lazy var effectsPresetsEditorView: NSView = effectsPresetsEditorViewLoader.view
    
    override var windowNibName: String? {"EditorWindow"}
    
    private var addedViews: Set<NSView> = Set()
    
    override func windowDidLoad() {
        
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
        
        theWindow.showCenteredOnScreen()
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
