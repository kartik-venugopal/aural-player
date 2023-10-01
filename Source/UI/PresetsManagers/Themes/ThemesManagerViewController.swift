//
//  ThemesManagerViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 View controller for the manager that allows the user to manage user-defined themes.
 */
class ThemesManagerViewController: PresetsManagerViewController {
    
    // A view that gives the user a visual preview of what each theme looks like.
    @IBOutlet weak var previewView: ThemePreviewView!
    
    private lazy var themesManager: ThemesManager = objectGraph.themesManager
    
    override var nibName: String? {"ThemesManager"}
    
    override var numberOfPresets: Int {themesManager.numberOfUserDefinedObjects}
    
    override func nameOfPreset(atIndex index: Int) -> String {themesManager.userDefinedObjects[index].name}
    
    override func presetExists(named name: String) -> Bool {
        themesManager.objectExists(named: name)
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        
        _ = themesManager.deleteObjects(atIndices: indices)
        previewView.clear()
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let selTheme = themesManager.userDefinedObjects[index]
        themesManager.applyTheme(selTheme)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        themesManager.renameObject(named: name, to: newName)
    }
    
    // Updates the visual preview.
    private func updatePreview() {
        
        if tableView.numberOfSelectedRows == 1 {
            previewView.theme = themesManager.userDefinedObjects[tableView.selectedRow]
            
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
        
        let theme = themesManager.userDefinedObjects[row]
        return createTextCell(tableView, tableColumn!, row, theme.name, true)
    }
}
