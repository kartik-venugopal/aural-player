import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system color scheme to be edited.
 */
class FontSetsWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var tabView: AuralTabView!
    
    @IBOutlet weak var btnSave: NSButton!
    
    @IBOutlet weak var btnUndo: NSButton!
    @IBOutlet weak var btnUndoAll: NSButton!
    
    @IBOutlet weak var btnRedo: NSButton!
    @IBOutlet weak var btnRedoAll: NSButton!
    
    private lazy var generalView: FontSetsViewProtocol = GeneralFontSetViewController()
    private lazy var playerView: FontSetsViewProtocol = PlayerFontSetViewController()
    private lazy var playlistView: FontSetsViewProtocol = PlaylistFontSetViewController()
    private lazy var effectsView: FontSetsViewProtocol = EffectsFontSetViewController()
    
    private var subViews: [FontSetsViewProtocol] = []
    
    // Maintains a history of all changes made to the system color scheme since the dialog opened. Allows undo/redo.
    private var history: FontSetHistory = FontSetHistory()
    
    override var windowNibName: NSNib.Name? {return "FontSets"}
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    override func windowDidLoad() {

        self.window?.isMovableByWindowBackground = true

        // Add the subviews to the tab group
        subViews = [generalView, playerView, playlistView, effectsView]
        tabView.addViewsForTabs(subViews.map {$0.fontSetsView})
        
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
        
        subViews.forEach {$0.resetFields(FontSets.systemFontSet)}
        
        // Reset the change history (every time the dialog is shown)
        history.begin()
        updateButtonStates()
        
        // Reset the subviews according to the current system color scheme, and show the first tab
        tabView.selectTabViewItem(at: 0)
        
        UIUtils.showDialog(self.window!)
        
        return .ok
    }
    
    @IBAction func applyChangesAction(_ sender: Any) {
        
        let undoValue: FontSet = FontSets.systemFontSet.clone()
        
        let context = FontSetChangeContext()
        generalView.applyFontSet(context, to: FontSets.systemFontSet)
        
        [playerView, playlistView, effectsView].forEach {$0.applyFontSet(context, to: FontSets.systemFontSet)}
        Messenger.publish(.applyFontSet, payload: FontSets.systemFontSet)
        
        let redoValue: FontSet = FontSets.systemFontSet.clone()
        history.noteChange(undoValue, redoValue)
    }
    
    private func applyFontSet(_ fontSet: FontSet) {
        
        let systemFontSet = FontSets.applyFontSet(fontSet)
        subViews.forEach {$0.resetFields(systemFontSet)}
        Messenger.publish(.applyFontSet, payload: systemFontSet)
        
        updateButtonStates()
    }
    
    // Undo all changes made to the system color scheme since the dialog last opened (i.e. this editing session)
    @IBAction func undoAllChangesAction(_ sender: Any) {
        
        // Get the snapshot (or restore point) from the history, and apply it to the system scheme
        if let restorePoint = history.undoAll() {
            applyFontSet(restorePoint)
        }
    }

    // Redo all changes made to the system color scheme since the dialog last opened (i.e. this editing session) that were undone.
    @IBAction func redoAllChangesAction(_ sender: Any) {
        
        // Get the snapshot (or restore point) from the history, and apply it to the system scheme
        if let restorePoint = history.redoAll() {
            applyFontSet(restorePoint)
        }
    }
    
    // Undoes the (single) last change made to the system color scheme.
    @IBAction func undoLastChangeAction(_ sender: Any) {
        
        // Get details about the last change from the history.
        if let lastChange = history.undoLastChange() {
            applyFontSet(lastChange)
        }
    }
    
    // Redoes the (single) last change made to the system color scheme that was undone.
    @IBAction func redoLastChangeAction(_ sender: Any) {
        
        if let lastChange = history.redoLastChange() {
            applyFontSet(lastChange)
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
protocol FontSetsViewProtocol {
    
    // The view containing the color editing UI components
    var fontSetsView: NSView {get}
    
    // Reset all UI controls every time the dialog is shown or a new color scheme is applied.
    // NOTE - the history and clipboard are shared across all views
    func resetFields(_ fontSet: FontSet)
    
    func applyFontSet(_ context: FontSetChangeContext, to fontSet: FontSet)
}
