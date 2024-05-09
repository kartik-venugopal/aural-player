//
//  FontSchemesManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 View controller for the manager that allows the user to manage user-defined font schemes.
 */
class FontSchemesManagerViewController: PresetsManagerViewController {
    
    // A view that gives the user a visual preview of what each font scheme looks like.
    @IBOutlet weak var previewView: FontSchemePreviewView!
    
    override var nibName: NSNib.Name? {"FontSchemesManager"}
    
    override var numberOfPresets: Int {fontSchemesManager.numberOfUserDefinedObjects}
    
    override func nameOfPreset(atIndex index: Int) -> String {fontSchemesManager.userDefinedObjects[index].name}
    
    override func presetExists(named name: String) -> Bool {
        fontSchemesManager.objectExists(named: name)
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        
        _ = fontSchemesManager.deleteObjects(atIndices: indices)
        previewView.clear()
    }
    
    // Applies the selected font scheme to the system.
    override func applyPreset(atIndex index: Int) {
        
        let selScheme = fontSchemesManager.userDefinedObjects[index]
        fontSchemesManager.applyScheme(selScheme)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        fontSchemesManager.renameObject(named: name, to: newName)
    }

    // Updates the visual preview.
    private func updatePreview() {
        
        if tableView.numberOfSelectedRows == 1 {
            previewView.scheme = fontSchemesManager.userDefinedObjects[tableView.selectedRow]
            
        } else {
            previewView.clear()
        }
    }
    
    // MARK: Table view delegate and data source functions
    
    // When the table selection changes, the button states and preview might need to change.
    override func tableViewSelectionDidChange(_ notification: Notification) {
        
        super.tableViewSelectionDidChange(notification)
        updatePreview()
    }
    
    // Returns a view for a single column
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let scheme = fontSchemesManager.userDefinedObjects[row]
        return createTextCell(tableView, tableColumn!, row, scheme.name, true)
    }
}
