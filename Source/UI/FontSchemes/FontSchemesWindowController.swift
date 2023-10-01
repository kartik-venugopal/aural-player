//
//  FontSchemesWindowController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system font scheme to be edited.
 */
class FontSchemesWindowController: SingletonWindowController, ModalDialogDelegate {
    
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
    
    private let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    
    // Popover to collect user input (i.e. color scheme name) when saving new color schemes
    lazy var userSchemesPopover: StringInputPopoverViewController = .create(self)
    
    private var subViews: [FontSchemesViewProtocol] = []
    
    // Maintains a history of all changes made to the system color scheme since the dialog opened. Allows undo/redo.
    private var history: FontSchemeHistory = FontSchemeHistory()
    
    override var windowNibName: NSNib.Name? {"FontSchemes"}
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    override func windowDidLoad() {

        self.window?.isMovableByWindowBackground = true

        // Add the subviews to the tab group
        subViews = [generalView, playerView, playlistView, effectsView]
        tabView.addViewsForTabs(subViews.map {$0.view})
        
        // Register an observer that updates undo/redo button states whenever the history changes.
        history.changeListener = {[weak self] in
            self?.updateButtonStates()
        }
    }
    
    func showDialog() -> ModalDialogResponse {
        
        forceLoadingOfWindow()
        subViews.forEach {$0.resetFields(fontSchemesManager.systemScheme)}
        
        // Reset the change history (every time the dialog is shown)
        history.begin()
        updateButtonStates()
        
        // Reset the subviews according to the current system color scheme, and show the first tab
        tabView.selectTabViewItem(at: 0)
        
        theWindow.showCenteredOnScreen()
        
        return .ok
    }
    
    @IBAction func applyChangesAction(_ sender: Any) {
        
        let undoValue: FontScheme = fontSchemesManager.systemScheme.clone()
        
        let context = FontSchemeChangeContext()
        let newScheme = FontScheme("_temp", FontSchemePreset.standard)
        
        generalView.applyFontScheme(context, to: newScheme)
        
        [playerView, playlistView, effectsView].forEach {$0.applyFontScheme(context, to: newScheme)}
        fontSchemesManager.applyScheme(newScheme)
        
        let redoValue: FontScheme = fontSchemesManager.systemScheme.clone()
        history.noteChange(FontSchemeChange(undoValue: undoValue, redoValue: redoValue))
    }
    
    @IBAction func saveSchemeAction(_ sender: Any) {
        
        // Allows the user to type in a name and save a new color scheme
        userSchemesPopover.show(btnSave, NSRectEdge.minY)
    }
    
    @IBAction func loadSchemeAction(_ sender: NSMenuItem) {
        
        if let scheme = fontSchemesManager.object(named: sender.title) {
            subViews.forEach {$0.loadFontScheme(scheme)}
        }
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        
        fontSchemesManager.applyScheme(fontScheme)
        let systemFontScheme = fontSchemesManager.systemScheme
        
        subViews.forEach {$0.resetFields(systemFontScheme)}
        
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
            applyFontScheme(lastChange.undoValue)
        }
    }
    
    // Redoes the (single) last change made to the system color scheme that was undone.
    @IBAction func redoLastChangeAction(_ sender: Any) {
        
        if let lastChange = history.redoLastChange() {
            applyFontScheme(lastChange.redoValue)
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
}

// MARK: MenuDelegate functions
extension FontSchemesWindowController: NSMenuDelegate {
    
    // When the menu is about to open, recreate the menu with to the currently available color schemes.
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.recreateMenu(insertingItemsAt: 1, fromItems: fontSchemesManager.userDefinedObjects,
                          action: #selector(self.loadSchemeAction(_:)), target: self,
                          indentationLevel: 1)
    }
}

// StringInputReceiver functions (for saving new font schemes).
extension FontSchemesWindowController: StringInputReceiver {
    
    var inputPrompt: String {
        "Enter a new font scheme name:"
    }
    
    var defaultValue: String? {
        "<New font scheme>"
    }
    
    // Validates the name given by the user for the new font scheme that is to be saved.
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        // Name cannot match the name of an existing scheme.
        if fontSchemesManager.objectExists(named: string) {
            
            return (false, "Font scheme with this name already exists !")
        }
        // Name cannot be empty
        else if string.isEmptyAfterTrimming {
            
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
        let newScheme: FontScheme = FontScheme(string, false, fontSchemesManager.systemScheme)
        fontSchemesManager.addObject(newScheme)
    }
}
