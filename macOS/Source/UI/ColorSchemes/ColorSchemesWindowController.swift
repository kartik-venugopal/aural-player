//
//  ColorSchemesWindowController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Controller for the color scheme editor panel that allows the current system color scheme to be edited.
 */
class ColorSchemesWindowController: SingletonWindowController, ModalDialogDelegate {
    
    override var windowNibName: NSNib.Name? {"ColorSchemes"}
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var btnSave: NSButton!
    
    @IBOutlet weak var btnUndo: NSToolbarItem!
    @IBOutlet weak var btnUndoAll: NSToolbarItem!
    
    @IBOutlet weak var btnRedo: NSToolbarItem!
    @IBOutlet weak var btnRedoAll: NSToolbarItem!
    
    // UI elements that display the current clipboard color
    @IBOutlet weak var clipboardIcon: NSImageView!
    @IBOutlet weak var clipboardColorViewer: NSColorWell!

    // Subviews that handle color scheme editing for different UI components
    private lazy var generalSchemeView: ColorSchemesViewProtocol = GeneralColorSchemeViewController()
    private lazy var textSchemeView: ColorSchemesViewProtocol = TextColorSchemeViewController()
    private lazy var controlStatesSchemeView: ColorSchemesViewProtocol = ControlStatesColorSchemeViewController()
    
    private var subViews: [ColorSchemesViewProtocol] = []
    
    // Maintains a history of all changes made to the system color scheme since the dialog opened. Allows undo/redo.
    private var history: ColorSchemeHistory = ColorSchemeHistory()
    
    // Stores a single color copied by the user for later use.
    private var clipboard: ColorClipboard = ColorClipboard()
    
    var isModal: Bool {
        window?.isVisible ?? false
    }
    
    override func windowDidLoad() {
        
        window?.isMovableByWindowBackground = true
        
        // Add the subviews to the tab group
        subViews = [generalSchemeView, textSchemeView, controlStatesSchemeView]
        
        for (index, subView) in subViews.enumerated() {
            
            tabView.tabViewItem(at: index).view?.addSubview(subView.view)
            subView.view.anchorToSuperview()
        }
        
        // Disable color transparency in the color chooser panel (for now)
        NSColorPanel.shared.showsAlpha = false
        
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
        subViews.forEach {$0.resetFields(systemColorScheme, history, clipboard)}
        tabView.selectTabViewItem(at: 0)
        
        theWindow.showCenteredOnScreen()
        
        return .ok
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
        schemeUpdated(systemColorScheme)
    }
    
    // Notify UI components of a scheme update
    private func schemeUpdated(_ scheme: ColorScheme) {
        subViews.forEach {$0.resetFields(scheme, history, clipboard)}
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
            for subView in subViews {
                
                if subView.undoChange(lastChange) {
                    break
                }
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
            for subView in subViews {
                
                if subView.redoChange(lastChange) {
                    break
                }
            }
        }
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
}

extension ColorSchemesWindowController: NSToolbarItemValidation {
    
    // Updates the undo/redo function button states according to the current state of the change history,
    // i.e. depending on whether or not there are any changes to undo/redo.
    func validateToolbarItem(_ item: NSToolbarItem) -> Bool {
        item.itemIdentifier.rawValue.hasPrefix("undo") ? history.canUndo : history.canRedo
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
        let newScheme: ColorScheme = ColorScheme(string, false, systemColorScheme)
        colorSchemesManager.addObject(newScheme)
    }
}

extension NSToolbarItem {
    
    var isDisabled: Bool {!isEnabled}
    
    @objc func enable() {
        self.isEnabled = true
    }
    
    @objc func disable() {
        self.isEnabled = false
    }
    
    @objc func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    @objc func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
}
