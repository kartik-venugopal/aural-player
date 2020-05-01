import Cocoa

class ColorSchemesWindowController: NSWindowController, NSMenuDelegate, ModalDialogDelegate, StringInputClient, NSWindowDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    @IBOutlet weak var btnSave: NSButton!
    
    @IBOutlet weak var btnUndo: NSButton!
    @IBOutlet weak var btnUndoAll: NSButton!
    
    @IBOutlet weak var btnRedo: NSButton!
    @IBOutlet weak var btnRedoAll: NSButton!
    
    @IBOutlet weak var clipboardIcon: NSImageView!
    @IBOutlet weak var clipboardColorViewer: NSColorWell!

    private lazy var generalSchemeView: ColorSchemesViewProtocol = ViewFactory.generalColorSchemeView
    private lazy var playerSchemeView: ColorSchemesViewProtocol = ViewFactory.playerColorSchemeView
    private lazy var playlistSchemeView: ColorSchemesViewProtocol = ViewFactory.playlistColorSchemeView
    private lazy var effectsSchemeView: ColorSchemesViewProtocol = ViewFactory.effectsColorSchemeView
    
    private var subViews: [ColorSchemesViewProtocol] = []
    
    lazy var userSchemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private var history: ColorSchemeHistory = ColorSchemeHistory()
    private var clipboard: ColorClipboard = ColorClipboard()
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    override func windowDidLoad() {
        
        self.window?.isMovableByWindowBackground = true
        
        subViews = [generalSchemeView, playerSchemeView, playlistSchemeView, effectsSchemeView]
        tabView.addViewsForTabs(subViews.map {$0.colorSchemeView})
        
        NSColorPanel.shared.showsAlpha = false
        NSColorPanel.shared.delegate = self
        
        clipboard.colorChangeCallback = {
            
            if let color = self.clipboard.color {
                
                self.clipboardColorViewer.color = color
                [self.clipboardIcon, self.clipboardColorViewer].forEach({$0?.show()})
                
            } else {
                
                [self.clipboardIcon, self.clipboardColorViewer].forEach({$0?.hide()})
            }
        }
        
        ObjectGraph.windowManager.registerModalComponent(self)
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        history.begin()
        history.changeListener = {
            self.updateButtonStates()
        }
        
        clipboard.clear()
//        [clipboardIcon, clipboardColorViewer].forEach({$0?.hide()})
        
        // Select the first tab
        subViews.forEach({$0.resetFields(ColorSchemes.systemScheme, history, clipboard)})
        tabView.selectTabViewItem(at: 0)
        
        updateButtonStates()
        
        UIUtils.showDialog(self.window!)
        
        return .ok
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    @IBAction func applySchemeAction(_ sender: NSMenuItem) {
        
        let undoValue: ColorScheme = ColorSchemes.systemScheme.clone()
        
        if let scheme = ColorSchemes.applyScheme(sender.title) {
            
            let redoValue: ColorScheme = scheme.clone()
            history.noteChange(1, undoValue, redoValue, .applyScheme)
            
            schemeUpdated(scheme)
        }
    }
    
    @IBAction func saveSchemeAction(_ sender: Any) {
        userSchemesPopover.show(btnSave, NSRectEdge.minY)
    }
    
    @IBAction func undoAllChangesAction(_ sender: Any) {
        
        if let restorePoint = history.undoAll() {
            applyScheme(restorePoint)
        }
    }
    
    @IBAction func redoAllChangesAction(_ sender: Any) {
        
        if let restorePoint = history.redoAll() {
            applyScheme(restorePoint)
        }
    }
    
    private func applyScheme(_ scheme: ColorScheme) {
        schemeUpdated(ColorSchemes.applyScheme(scheme))
    }
    
    private func schemeUpdated(_ systemScheme: ColorScheme) {
        
        subViews.forEach({$0.resetFields(systemScheme, history, clipboard)})
        SyncMessenger.publishActionMessage(ColorSchemeActionMessage(systemScheme))
        updateButtonStates()
    }
    
    @IBAction func undoLastChangeAction(_ sender: Any) {
        
        if let lastChange = history.undoLastChange() {
            
            // Color scheme application can be handled here
            if lastChange.changeType == .applyScheme {
            
                if let scheme = lastChange.undoValue as? ColorScheme {
                    applyScheme(scheme)
                }
                
            } else {
                
                // Other change types (single field changes) need to be deferred to subviews
                
                for subView in subViews {
                    
                    if subView.undoChange(lastChange) {
                        
                        updateButtonStates()
                        break
                    }
                }
            }
        }
    }
    
    @IBAction func redoLastChangeAction(_ sender: Any) {
        
        if let lastChange = history.redoLastChange() {
            
            // Color scheme application can be handled here
            if lastChange.changeType == .applyScheme {
                
                if let scheme = lastChange.redoValue as? ColorScheme {
                    applyScheme(scheme)
                }
                
            } else {
                
                // Other change types (single field changes) need to be deferred to subviews
                
                for subView in subViews {
                    
                    if subView.redoChange(lastChange) {
                        
                        updateButtonStates()
                        break
                    }
                }
            }
        }
    }
    
    private func updateButtonStates() {
        
        btnUndo.enableIf(history.canUndo)
        btnUndoAll.enableIf(history.canUndo)
        
        btnRedo.enableIf(history.canRedo)
        btnRedoAll.enableIf(history.canRedo)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        
        NSColorPanel.shared.close()
        UIUtils.dismissDialog(self.window!)
    }
    
    deinit {
        
        // Make sure the color panel closes before the app exits
        NSColorPanel.shared.close()
    }
    
    // MARK - MenuDelegate functions
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        while let item = menu.item(at: 1), !item.isSeparatorItem {
            menu.removeItem(at: 1)
        }
        
        // Recreate the custom scheme items
        ColorSchemes.userDefinedSchemes.forEach({
            
            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.applySchemeAction(_:)), keyEquivalent: "")
            item.target = self
            item.indentationLevel = 1
            
            menu.insertItem(item, at: 1)
        })
    }
    
    // MARK - StringInputClient functions (for saving new color schemes)
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

/*
    Contract for all subviews that alter the color scheme, to facilitate communication between the window controller and subviews.
 */
protocol ColorSchemesViewProtocol {
    
    var colorSchemeView: NSView {get}
    
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!)
    
    func undoChange(_ lastChange: ColorSchemeChange) -> Bool
    
    func redoChange(_ lastChange: ColorSchemeChange) -> Bool
}
