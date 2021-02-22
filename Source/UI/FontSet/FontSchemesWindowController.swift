import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system color scheme to be edited.
 */
class FontSchemesWindowController: NSWindowController, ModalDialogDelegate {
    
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
        history.changeListener = {
            self.updateButtonStates()
        }

        // Register self as a modal component
        WindowManager.registerModalComponent(self)
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        subViews.forEach {$0.resetFields(FontSchemes.systemFontScheme)}
        
        // Reset the change history (every time the dialog is shown)
        history.begin()
        updateButtonStates()
        
        // Reset the subviews according to the current system color scheme, and show the first tab
        tabView.selectTabViewItem(at: 0)
        
        UIUtils.showDialog(self.window!)
        
        return .ok
    }
    
    @IBAction func applyChangesAction(_ sender: Any) {
        
        let undoValue: FontScheme = FontSchemes.systemFontScheme.clone()
        
        let context = FontSchemeChangeContext()
        generalView.applyFontScheme(context, to: FontSchemes.systemFontScheme)
        
        [playerView, playlistView, effectsView].forEach {$0.applyFontScheme(context, to: FontSchemes.systemFontScheme)}
        Messenger.publish(.applyFontScheme, payload: FontSchemes.systemFontScheme)
        
        let redoValue: FontScheme = FontSchemes.systemFontScheme.clone()
        history.noteChange(undoValue, redoValue)
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        
        let systemFontScheme = FontSchemes.applyFontScheme(fontScheme)
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
        UIUtils.dismissDialog(self.window!)
    }
    
    // Updates the undo/redo function button states according to the current state of the change history,
    // i.e. depending on whether or not there are any changes to undo/redo.
    private func updateButtonStates() {
        
        btnUndo.enableIf(history.canUndo)
        btnUndoAll.enableIf(history.canUndo)
        
        btnRedo.enableIf(history.canRedo)
        btnRedoAll.enableIf(history.canRedo)
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
    
    func applyFontScheme(_ context: FontSchemeChangeContext, to fontScheme: FontScheme)
}
