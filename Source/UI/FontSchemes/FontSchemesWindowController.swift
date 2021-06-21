import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system color scheme to be edited.
 */
class FontSchemesWindowController: NSWindowController, NSMenuDelegate, ModalDialogDelegate, StringInputReceiver, Destroyable {
    
    private static var _instance: FontSchemesWindowController?
    static var instance: FontSchemesWindowController {
        
        if _instance == nil {
            _instance = FontSchemesWindowController()
        }
        
        return _instance!
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var btnSave: NSButton!
    
    @IBOutlet weak var btnUndo: NSButton!
    @IBOutlet weak var btnUndoAll: NSButton!
    
    @IBOutlet weak var btnRedo: NSButton!
    @IBOutlet weak var btnRedoAll: NSButton!
    
    private lazy var generalView: FontSchemesViewProtocol = GeneralFontSchemeViewController()
    private lazy var playerView: FontSchemesViewProtocol = PlayerFontSchemeViewController()
    private lazy var playlistView: FontSchemesViewProtocol = PlaylistFontSchemeViewController()
    private lazy var effectsView: FontSchemesViewProtocol = EffectsFontSchemeViewController()
    
    // Popover to collect user input (i.e. color scheme name) when saving new color schemes
    lazy var userSchemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    private var subViews: [FontSchemesViewProtocol] = []
    
    // Maintains a history of all changes made to the system color scheme since the dialog opened. Allows undo/redo.
    private var history: FontSchemeHistory = FontSchemeHistory()
    
    override var windowNibName: NSNib.Name? {return "FontSchemes"}
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    override func windowDidLoad() {

        self.window?.isMovableByWindowBackground = true

        // Add the subviews to the tab group
        subViews = [generalView, playerView, playlistView, effectsView]
        tabView.addViewsForTabs(subViews.map {$0.fontSchemesView})
        
        // Register an observer that updates undo/redo button states whenever the history changes.
        history.changeListener = {[weak self] in
            self?.updateButtonStates()
        }

        // Register self as a modal component
        WindowManager.instance.registerModalComponent(self)
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = theWindow
        }
        
        subViews.forEach {$0.resetFields(FontSchemes.systemScheme)}
        
        // Reset the change history (every time the dialog is shown)
        history.begin()
        updateButtonStates()
        
        // Reset the subviews according to the current system color scheme, and show the first tab
        tabView.selectTabViewItem(at: 0)
        
        theWindow.showCenteredOnScreen()
        
        return .ok
    }
    
    @IBAction func applyChangesAction(_ sender: Any) {
        
        let undoValue: FontScheme = FontSchemes.systemScheme.clone()
        
        let context = FontSchemeChangeContext()
        generalView.applyFontScheme(context, to: FontSchemes.systemScheme)
        
        [playerView, playlistView, effectsView].forEach {$0.applyFontScheme(context, to: FontSchemes.systemScheme)}
        Messenger.publish(.applyFontScheme, payload: FontSchemes.systemScheme)
        
        let redoValue: FontScheme = FontSchemes.systemScheme.clone()
        history.noteChange(undoValue, redoValue)
    }
    
    @IBAction func saveSchemeAction(_ sender: Any) {
        
        // Allows the user to type in a name and save a new color scheme
        userSchemesPopover.show(btnSave, NSRectEdge.minY)
    }
    
    @IBAction func loadSchemeAction(_ sender: NSMenuItem) {
        
        if let scheme = FontSchemes.schemeByName(sender.title) {
            subViews.forEach {$0.loadFontScheme(scheme)}
        }
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        
        let systemFontScheme = FontSchemes.applyScheme(fontScheme)
        subViews.forEach {$0.resetFields(systemFontScheme)}
        Messenger.publish(.applyFontScheme, payload: systemFontScheme)
        
        updateButtonStates()
    }
    
    // Undo all changes made to the system color scheme since the dialog last opened (i.e. this editing session)
    @IBAction func undoAllChangesAction(_ sender: Any) {
        
        // Get the snapshot (or restore point) from the history, and apply it to the system scheme
        if let restorePoint = history.undoAll() {
            applyFontScheme(restorePoint)
        }
    }

    // Redo all changes made to the system color scheme since the dialog last opened (i.e. this editing session) that were undone.
    @IBAction func redoAllChangesAction(_ sender: Any) {
        
        // Get the snapshot (or restore point) from the history, and apply it to the system scheme
        if let restorePoint = history.redoAll() {
            applyFontScheme(restorePoint)
        }
    }
    
    // Undoes the (single) last change made to the system color scheme.
    @IBAction func undoLastChangeAction(_ sender: Any) {
        
        // Get details about the last change from the history.
        if let lastChange = history.undoLastChange() {
            applyFontScheme(lastChange)
        }
    }
    
    // Redoes the (single) last change made to the system color scheme that was undone.
    @IBAction func redoLastChangeAction(_ sender: Any) {
        
        if let lastChange = history.redoLastChange() {
            applyFontScheme(lastChange)
        }
    }
    
    // Dismisses the panel when the user is done making changes
    @IBAction func doneAction(_ sender: Any) {
        
        // Close the system color chooser panel.
        NSColorPanel.shared.close()
        theWindow.close()
    }
    
    // Updates the undo/redo function button states according to the current state of the change history,
    // i.e. depending on whether or not there are any changes to undo/redo.
    private func updateButtonStates() {
        
        btnUndo.enableIf(history.canUndo)
        btnUndoAll.enableIf(history.canUndo)
        
        btnRedo.enableIf(history.canRedo)
        btnRedoAll.enableIf(history.canRedo)
    }
    
    // MARK - MenuDelegate functions
    
    // When the menu is about to open, recreate the menu with to the currently available color schemes.
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all user-defined scheme items
        while let item = menu.item(at: 1), !item.isSeparatorItem {
            menu.removeItem(at: 1)
        }
        
        // Recreate the user-defined scheme items
        FontSchemes.userDefinedSchemes.forEach({
            
            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.loadSchemeAction(_:)),
                                              keyEquivalent: "")
            item.target = self
            item.indentationLevel = 1
            
            menu.insertItem(item, at: 1)
        })
    }
    
    // MARK - StringInputReceiver functions (for saving new color schemes)
    // TODO: Refactor this into a common FontSchemesStringInputReceiver class to avoid duplication
    
    var inputPrompt: String {
        return "Enter a new font scheme name:"
    }
    
    var defaultValue: String? {
        return "<New font scheme>"
    }
    
    // Validates the name given by the user for the new font scheme that is to be saved.
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        // Name cannot match the name of an existing scheme.
        if FontSchemes.schemeWithNameExists(string) {
            
            return (false, "Font scheme with this name already exists !")
        }
        // Name cannot be empty
        else if string.trim().isEmpty {
            
            return (false, "Name must have at least 1 character.")
        }
        // Valid name
        else {
            return (true, nil)
        }
    }
    
    // Receives a new color scheme name and saves the new scheme
    func acceptInput(_ string: String) {
        
        // Copy the current system scheme into the new scheme, and name it with the user's given scheme name
        let newScheme: FontScheme = FontScheme(string, false, FontSchemes.systemScheme)
        FontSchemes.addUserDefinedScheme(newScheme)
    }
}

/*
    Contract for all subviews that alter the color scheme, to facilitate communication between the window controller and subviews.
 */
protocol FontSchemesViewProtocol {
    
    // The view containing the color editing UI components
    var fontSchemesView: NSView {get}
    
    // Reset all UI controls every time the dialog is shown or a new color scheme is applied.
    // NOTE - the history and clipboard are shared across all views
    func resetFields(_ fontScheme: FontScheme)
    
    // Load values from a font scheme into the UI fields
    func loadFontScheme(_ fontScheme: FontScheme)
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme)
}
