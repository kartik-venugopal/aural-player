import Cocoa

class ColorSchemesWindowController: NSWindowController, ModalDialogDelegate {
    
    // TODO: Store history of changes for each color (to allow Undo feature)
    
    @IBOutlet weak var tabView: AuralTabView!

    private lazy var generalSchemeView: ColorSchemesViewProtocol = ViewFactory.generalColorSchemeView
    private lazy var playerSchemeView: ColorSchemesViewProtocol = ViewFactory.playerColorSchemeView
    private lazy var playlistSchemeView: ColorSchemesViewProtocol = ViewFactory.playlistColorSchemeView
//    private lazy var effectsSchemeView: NSView = ViewFactory.viewPreferencesView
    
    private var subViews: [ColorSchemesViewProtocol] = []
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    override func windowDidLoad() {
        
        subViews = [generalSchemeView, playerSchemeView, playlistSchemeView]
        tabView.addViewsForTabs(subViews.map {$0.colorSchemeView})
        
        NSColorPanel.shared.showsAlpha = true
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        // Select the first tab
        subViews.forEach({$0.resetFields(ColorSchemes.systemScheme)})
        tabView.selectTabViewItem(at: 0)
        
        UIUtils.showDialog(self.window!)
        
        return .ok
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
}

protocol ColorSchemesViewProtocol {
    
    var colorSchemeView: NSView {get}
    
    func resetFields(_ scheme: ColorScheme)
}
