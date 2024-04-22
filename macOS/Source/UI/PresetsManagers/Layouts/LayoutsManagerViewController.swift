//
//  LayoutsManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class LayoutsManagerViewController: PresetsManagerViewController {
    
    @IBOutlet weak var previewView: LayoutPreviewView!
    
    override var nibName: String? {"LayoutsManager"}
    
    override var numberOfPresets: Int {windowLayoutsManager.numberOfUserDefinedObjects}
    
    override func nameOfPreset(atIndex index: Int) -> String {windowLayoutsManager.userDefinedObjects[index].name}
    
    override func presetExists(named name: String) -> Bool {
        windowLayoutsManager.objectExists(named: name)
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        
        _ = windowLayoutsManager.deleteObjects(atIndices: indices)
        previewView.clear()
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let selLayout = windowLayoutsManager.userDefinedObjects[index]
        windowLayoutsManager.applyLayout(selLayout)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        
        // Update the layout name.
        windowLayoutsManager.renameObject(named: name, to: newName)
        
        // Also update the view preference, if the chosen startup layout was this edited one.
        let prefLayout = preferences.viewPreferences.layoutOnStartup.layoutName
        if prefLayout == name {
            
            preferences.viewPreferences.layoutOnStartup.layoutName = newName
//            preferences.persist()
        }
    }
    
    // Updates the visual preview.
    private func updatePreview() {
        
        if tableView.numberOfSelectedRows == 1 {
            
            let layout = windowLayoutsManager.userDefinedObjects[tableView.selectedRow]
            previewView.drawPreviewForLayout(layout)
            
        } else {
            previewView.clear()
        }
    }
    
    // MARK: Table view delegate functions
    
    // When the table selection changes, the button states and preview might need to change.
    override func tableViewSelectionDidChange(_ notification: Notification) {
        
        super.tableViewSelectionDidChange(notification)
        updatePreview()
    }
    
    // Returns a view for a single column
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let layout = windowLayoutsManager.userDefinedObjects[row]
        return createTextCell(tableView, tableColumn!, row, layout.name, true)
    }
}
