import Cocoa

class ColorSchemesWindowController: NSWindowController, ModalDialogDelegate, StringInputClient {
    
    // TODO: Store history of changes for each color (to allow Undo feature)
    
    @IBOutlet weak var tabView: AuralTabView!
    @IBOutlet weak var btnSave: NSButton!

    private lazy var generalSchemeView: ColorSchemesViewProtocol = ViewFactory.generalColorSchemeView
    private lazy var playerSchemeView: ColorSchemesViewProtocol = ViewFactory.playerColorSchemeView
    private lazy var playlistSchemeView: ColorSchemesViewProtocol = ViewFactory.playlistColorSchemeView
    private lazy var effectsSchemeView: ColorSchemesViewProtocol = ViewFactory.effectsColorSchemeView
    
    private var subViews: [ColorSchemesViewProtocol] = []
    
    lazy var userSchemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    override func windowDidLoad() {
        
        self.window?.isMovableByWindowBackground = true
        
        subViews = [generalSchemeView, playerSchemeView, playlistSchemeView, effectsSchemeView]
        tabView.addViewsForTabs(subViews.map {$0.colorSchemeView})
        
        NSColorPanel.shared.showsAlpha = false
        ObjectGraph.windowManager.registerModalComponent(self)
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
    
    @IBAction func doneAction(_ sender: Any) {
        
        NSColorPanel.shared.close()
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func saveSchemeAction(_ sender: Any) {
        userSchemesPopover.show(btnSave, NSRectEdge.minY)
    }
    
    // MARK - StringInputClient functions
    // TODO: Refactor this into a ColorSchemesStringInputClient class to avoid duplication
    
    var inputPrompt: String {
        return "Enter a new color scheme name:"
    }
    
    var defaultValue: String? {
        return "<New color scheme>"
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        if ColorSchemes.schemeWithNameExists(string) {
            return (false, "Color scheme with this name already exists !")
        } else if string.trim().isEmpty {
            return (false, "Name must have at least 1 non-whitespace character.")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new color scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let newScheme: ColorScheme = ColorScheme(string, false, ColorSchemes.systemScheme)
        ColorSchemes.addUserDefinedScheme(newScheme)
    }
    
    var inputFontSize: TextSize {
        return .normal
    }
}

protocol ColorSchemesViewProtocol {
    
    var colorSchemeView: NSView {get}
    
    func resetFields(_ scheme: ColorScheme)
}
