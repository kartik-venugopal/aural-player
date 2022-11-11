//
//  ColorSchemesWindowController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system color scheme to be edited.
 */
class ColorSchemesWindowController: SingletonWindowController, NSMenuDelegate, ModalDialogDelegate {
    
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
    private lazy var generalSchemeView: ColorSchemesViewProtocol = GeneralColorSchemeViewController()
    private lazy var playerSchemeView: ColorSchemesViewProtocol = PlayerColorSchemeViewController()
    private lazy var playlistSchemeView: ColorSchemesViewProtocol = PlaylistColorSchemeViewController()
    private lazy var effectsSchemeView: ColorSchemesViewProtocol = EffectsColorSchemeViewController()
    
    private var subViews: [ColorSchemesViewProtocol] = []
    
    // Popover to collect user input (i.e. color scheme name) when saving new color schemes
    lazy var userSchemesPopover: StringInputPopoverViewController = .create(self)
    
    private let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    // Maintains a history of all changes made to the system color scheme since the dialog opened. Allows undo/redo.
    private var history: ColorSchemeHistory = ColorSchemeHistory()
    
    // Stores a single color copied by the user for later use.
    private var clipboard: ColorClipboard = ColorClipboard()
    
    override var windowNibName: NSNib.Name? {"ColorSchemes"}
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    override func windowDidLoad() {
        
        self.window?.isMovableByWindowBackground = true
        
        // Add the subviews to the tab group
        subViews = [generalSchemeView, playerSchemeView, playlistSchemeView, effectsSchemeView]
        tabView.addViewsForTabs(subViews.map {$0.view})
        
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
    }
    
    func showDialog() -> ModalDialogResponse {
        
        forceLoadingOfWindow()
        
        // Reset the change history and the color clipboard (every time the dialog is shown)
        history.begin()
        clipboard.clear()
        
        // Reset the subviews according to the current system color scheme, and show the first tab
        subViews.forEach {$0.resetFields(colorSchemesManager.systemScheme, history, clipboard)}
        tabView.selectTabViewItem(at: 0)
        
        // Enable/disable function buttons
        updateButtonStates()
        
        theWindow.showCenteredOnScreen()
        
        return .ok
    }
    
    // Applies an existing color scheme (either user-defined or system-defined) to the current system color scheme.
    @IBAction func applySchemeAction(_ sender: NSMenuItem) {
        
        // First, capture a snapshot of the current scheme (for potentially undoing later)
        let undoValue: ColorScheme = colorSchemesManager.systemScheme.clone()
        
        // Apply the user-selected scheme
        colorSchemesManager.applyScheme(named: sender.title)
            
        // Capture the new scheme (for potentially redoing changes later)
        let newScheme = colorSchemesManager.systemScheme
        let redoValue: ColorScheme = newScheme.clone()
        history.noteChange(ColorSchemeChange(tag: 1, undoValue: undoValue, redoValue: redoValue, changeType: .applyScheme))
            
        // Notify UI components of the scheme change
        schemeUpdated(newScheme)
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
        
        colorSchemesManager.applyScheme(scheme)
        schemeUpdated(colorSchemesManager.systemScheme)
    }
    
    // Notify UI components of a scheme update
    private func schemeUpdated(_ scheme: ColorScheme) {
        
        subViews.forEach {$0.resetFields(scheme, history, clipboard)}
        updateButtonStates()
    }
    
    // Undoes the (single) last change made to the system color scheme.
    @IBAction func undoLastChangeAction(_ sender: Any) {
        
        // Get details about the last change from the history.
        guard let lastChange = history.undoLastChange() else {return}
        
        // Color scheme application can be handled here
        if lastChange.changeType == .applyScheme {
            
            if let scheme = lastChange.undoValue as? ColorScheme {
                applyScheme(scheme)
            }
            
        } else {
            
            // Other change types (single color changes) need to be deferred to the relevant subview
            
            // Only one subview will perform the undo operation, i.e. the subview containing the
            // color field that was previously changed.
            if subViews.contains(where: {$0.undoChange(lastChange)}) {
                
                // Undo successful ... update undo/redo button states and exit the loop.
                updateButtonStates()
            }
        }
    }
    
    // Redoes the (single) last change made to the system color scheme that was undone.
    @IBAction func redoLastChangeAction(_ sender: Any) {
        
        // Get details about the last undone change from the history.
        guard let lastChange = history.redoLastChange() else {return}
        
        // Color scheme application can be handled here
        if lastChange.changeType == .applyScheme {
            
            if let scheme = lastChange.redoValue as? ColorScheme {
                applyScheme(scheme)
            }
            
        } else {
            
            // Other change types (single color changes) need to be deferred to the relevant subview
            
            // Only one subview will perform the redo operation, i.e. the subview containing the color field
            // that was previously changed and then undone.
            if subViews.contains(where: {$0.redoChange(lastChange)}) {
                
                // Redo successful ... update undo/redo button states and exit the loop.
                updateButtonStates()
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
        theWindow.close()
    }
    
    deinit {
        
        // Make sure the color panel closes before the app exits
        NSColorPanel.shared.close()
    }
    
    // MARK - MenuDelegate functions
    
    // When the menu is about to open, recreate the menu with to the currently available color schemes.
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        menu.recreateMenu(insertingItemsAt: 1, fromItems: colorSchemesManager.userDefinedObjects,
                          action: #selector(self.applySchemeAction(_:)), target: self,
                          indentationLevel: 1)
    }
}

// StringInputReceiver functions (for saving new color schemes)
extension ColorSchemesWindowController: StringInputReceiver {
    
    var inputPrompt: String {
        "Enter a new color scheme name:"
    }
    
    var defaultValue: String? {
        "<New color scheme>"
    }
    
    // Validates the name given by the user for the new color scheme that is to be saved.
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        // Name cannot match the name of an existing scheme.
        if colorSchemesManager.objectExists(named: string) {
            return (false, "Color scheme with this name already exists !")
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
        let newScheme: ColorScheme = ColorScheme(string, false, colorSchemesManager.systemScheme)
        colorSchemesManager.addObject(newScheme)
    }
}
