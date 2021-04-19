import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system color scheme to be edited.
 */
class ColorSchemesWindowController: NSWindowController, NSMenuDelegate, ModalDialogDelegate, StringInputReceiver, Destroyable {
    
    private static var _instance: ColorSchemesWindowController?
    static var instance: ColorSchemesWindowController {
        
        if _instance == nil {
            _instance = ColorSchemesWindowController()
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
    
    // UI elements that display the current clipboard color
    @IBOutlet weak var clipboardIcon: NSImageView!
    @IBOutlet weak var clipboardColorViewer: NSColorWell!

    // Subviews that handle color scheme editing for different UI components
    private lazy var generalSchemeView: ColorSchemesViewProtocol = ViewFactory.generalColorSchemeView
    private lazy var playerSchemeView: ColorSchemesViewProtocol = ViewFactory.playerColorSchemeView
    private lazy var playlistSchemeView: ColorSchemesViewProtocol = ViewFactory.playlistColorSchemeView
    private lazy var effectsSchemeView: ColorSchemesViewProtocol = ViewFactory.effectsColorSchemeView
    
    private var subViews: [ColorSchemesViewProtocol] = []
    
    // Popover to collect user input (i.e. color scheme name) when saving new color schemes
    lazy var userSchemesPopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
    
    // Maintains a history of all changes made to the system color scheme since the dialog opened. Allows undo/redo.
    private var history: ColorSchemeHistory = ColorSchemeHistory()
    
    // Stores a single color copied by the user for later use.
    private var clipboard: ColorClipboard = ColorClipboard()
    
    override var windowNibName: NSNib.Name? {return "ColorSchemes"}
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    override func windowDidLoad() {
        
        self.window?.isMovableByWindowBackground = true
        
        // Add the subviews to the tab group
        subViews = [generalSchemeView, playerSchemeView, playlistSchemeView, effectsSchemeView]
        tabView.addViewsForTabs(subViews.map {$0.colorSchemeView})
        
        // Disable color transparency in the color chooser panel (for now)
        NSColorPanel.shared.showsAlpha = false
        
        // Register an observer that updates undo/redo button states whenever the history changes.
        history.changeListener = {[weak self] in
            self?.updateButtonStates()
        }
        
        // Set up an observer that responds whenever the clipboard color is changed (so that the UI can be updated accordingly)
        clipboard.colorChangeCallback = {[weak self] in
            
            guard let nonNilSelf = self else {return}
            
            if let color = nonNilSelf.clipboard.color {
                
                nonNilSelf.clipboardColorViewer.color = color
                [nonNilSelf.clipboardIcon, nonNilSelf.clipboardColorViewer].forEach {$0?.show()}
                
            } else {
                
                [nonNilSelf.clipboardIcon, nonNilSelf.clipboardColorViewer].forEach {$0?.hide()}
            }
        }
        
        // Register self as a modal component
        WindowManager.instance.registerModalComponent(self)
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        // Reset the change history and the color clipboard (every time the dialog is shown)
        history.begin()
        clipboard.clear()
        
        // Reset the subviews according to the current system color scheme, and show the first tab
        subViews.forEach({$0.resetFields(ColorSchemes.systemScheme, history, clipboard)})
        tabView.selectTabViewItem(at: 0)
        
        // Enable/disable function buttons
        updateButtonStates()
        
        UIUtils.showDialog(self.window!)
        
        return .ok
    }
    
    // Applies an existing color scheme (either user-defined or system-defined) to the current system color scheme.
    @IBAction func applySchemeAction(_ sender: NSMenuItem) {
        
        // First, capture a snapshot of the current scheme (for potentially undoing later)
        let undoValue: ColorScheme = ColorSchemes.systemScheme.clone()
        
        // Apply the user-selected scheme
        if let scheme = ColorSchemes.applyScheme(sender.title) {
            
            // Capture the new scheme (for potentially redoing changes later)
            let redoValue: ColorScheme = scheme.clone()
            history.noteChange(1, undoValue, redoValue, .applyScheme)
            
            // Notify UI components of the scheme change
            schemeUpdated(scheme)
        }
    }
    
    @IBAction func saveSchemeAction(_ sender: Any) {
        
        // Allows the user to type in a name and save a new color scheme
        userSchemesPopover.show(btnSave, NSRectEdge.minY)
    }
    
    // Undo all changes made to the system color scheme since the dialog last opened (i.e. this editing session)
    @IBAction func undoAllChangesAction(_ sender: Any) {
        
        // Get the snapshot (or restore point) from the history, and apply it to the system scheme
        if let restorePoint = history.undoAll() {
            applyScheme(restorePoint)
        }
    }

    // Redo all changes made to the system color scheme since the dialog last opened (i.e. this editing session) that were undone.
    @IBAction func redoAllChangesAction(_ sender: Any) {
        
        // Get the snapshot (or restore point) from the history, and apply it to the system scheme
        if let restorePoint = history.redoAll() {
            applyScheme(restorePoint)
        }
    }
    
    // Apply a given color scheme to the system scheme
    private func applyScheme(_ scheme: ColorScheme) {
        schemeUpdated(ColorSchemes.applyScheme(scheme))
    }
    
    // Notify UI components of a scheme update
    private func schemeUpdated(_ systemScheme: ColorScheme) {
        
        subViews.forEach({$0.resetFields(systemScheme, history, clipboard)})
        Messenger.publish(.applyColorScheme, payload: systemScheme)
        updateButtonStates()
    }
    
    // Undoes the (single) last change made to the system color scheme.
    @IBAction func undoLastChangeAction(_ sender: Any) {
        
        // Get details about the last change from the history.
        if let lastChange = history.undoLastChange() {
            
            // Color scheme application can be handled here
            if lastChange.changeType == .applyScheme {
            
                if let scheme = lastChange.undoValue as? ColorScheme {
                    applyScheme(scheme)
                }
                
            } else {
                
                // Other change types (single color changes) need to be deferred to the relevant subview
                
                for subView in subViews {
                    
                    // Only one subview will perform the undo operation, i.e. the subview containing the color field that was previously changed.
                    if subView.undoChange(lastChange) {
                        
                        // Undo successful ... update undo/redo button states and exit the loop.
                        updateButtonStates()
                        break
                    }
                }
            }
        }
    }
    
    // Redoes the (single) last change made to the system color scheme that was undone.
    @IBAction func redoLastChangeAction(_ sender: Any) {
        
        // Get details about the last undone change from the history.
        if let lastChange = history.redoLastChange() {
            
            // Color scheme application can be handled here
            if lastChange.changeType == .applyScheme {
                
                if let scheme = lastChange.redoValue as? ColorScheme {
                    applyScheme(scheme)
                }
                
            } else {
                
                // Other change types (single color changes) need to be deferred to the relevant subview
                
                for subView in subViews {
                
                    // Only one subview will perform the redo operation, i.e. the subview containing the color field
                    // that was previously changed and then undone.
                    if subView.redoChange(lastChange) {
                        
                        // Redo successful ... update undo/redo button states and exit the loop.
                        updateButtonStates()
                        break
                    }
                }
            }
        }
    }
    
    // Updates the undo/redo function button states according to the current state of the change history,
    // i.e. depending on whether or not there are any changes to undo/redo.
    private func updateButtonStates() {
        
        btnUndo.enableIf(history.canUndo)
        btnUndoAll.enableIf(history.canUndo)
        
        btnRedo.enableIf(history.canRedo)
        btnRedoAll.enableIf(history.canRedo)
    }
    
    // Dismisses the panel when the user is done making changes
    @IBAction func doneAction(_ sender: Any) {
        
        // Close the system color chooser panel.
        NSColorPanel.shared.close()
        UIUtils.dismissDialog(self.window!)
    }
    
    deinit {
        
        // Make sure the color panel closes before the app exits
        NSColorPanel.shared.close()
    }
    
    // MARK - MenuDelegate functions
    
    // When the menu is about to open, recreate the menu with to the currently available color schemes.
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Remove all user-defined scheme items
        while let item = menu.item(at: 1), !item.isSeparatorItem {
            menu.removeItem(at: 1)
        }
        
        // Recreate the user-defined scheme items
        ColorSchemes.userDefinedSchemes.forEach({
            
            let item: NSMenuItem = NSMenuItem(title: $0.name, action: #selector(self.applySchemeAction(_:)), keyEquivalent: "")
            item.target = self
            item.indentationLevel = 1
            
            menu.insertItem(item, at: 1)
        })
    }
    
    // MARK - StringInputReceiver functions (for saving new color schemes)
    // TODO: Refactor this into a common ColorSchemesStringInputReceiver class to avoid duplication
    
    var inputPrompt: String {
        return "Enter a new color scheme name:"
    }
    
    var defaultValue: String? {
        return "<New color scheme>"
    }
    
    // Validates the name given by the user for the new color scheme that is to be saved.
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        // Name cannot match the name of an existing scheme.
        if ColorSchemes.schemeWithNameExists(string) {
            
            return (false, "Color scheme with this name already exists !")
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
        let newScheme: ColorScheme = ColorScheme(string, false, ColorSchemes.systemScheme)
        ColorSchemes.addUserDefinedScheme(newScheme)
    }
}

/*
    Contract for all subviews that alter the color scheme, to facilitate communication between the window controller and subviews.
 */
protocol ColorSchemesViewProtocol {
    
    // The view containing the color editing UI components
    var colorSchemeView: NSView {get}
    
    // Reset all UI controls every time the dialog is shown or a new color scheme is applied.
    // NOTE - the history and clipboard are shared across all views
    func resetFields(_ scheme: ColorScheme, _ history: ColorSchemeHistory, _ clipboard: ColorClipboard!)
    
    // If the last change was made to a control in this view, performs an undo operation and returns true. Otherwise, does nothing and returns false.
    func undoChange(_ lastChange: ColorSchemeChange) -> Bool

    // If the last undo was performed on a control in this view, performs a redo operation and returns true. Otherwise, does nothing and returns false.
    func redoChange(_ lastChange: ColorSchemeChange) -> Bool
}
