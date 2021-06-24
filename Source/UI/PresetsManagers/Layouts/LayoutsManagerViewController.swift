//
//  LayoutsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class LayoutsManagerViewController: GenericPresetsManagerViewController {
    
    @IBOutlet weak var previewView: LayoutPreviewView!
    
    // Delegate that performs CRUD on user preferences
    private lazy var preferences: Preferences = ObjectGraph.preferences
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = ObjectGraph.windowLayoutsManager
    
    override var nibName: String? {"LayoutsManager"}
    
    override var numberOfPresets: Int {windowLayoutsManager.numberOfUserDefinedPresets}
    
    override func nameOfPreset(atIndex index: Int) -> String {windowLayoutsManager.userDefinedPresets[index].name}
    
    override func presetExists(named name: String) -> Bool {
        windowLayoutsManager.presetExists(named: name)
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Clear the preview view (no theme is selected).
        previewView.clear()
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        
        windowLayoutsManager.deletePresets(atIndices: indices)
        previewView.clear()
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let selLayout = windowLayoutsManager.userDefinedPresets[index]
        WindowManager.instance.layout(selLayout)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        
        // Update the layout name.
        windowLayoutsManager.renamePreset(named: name, to: newName)
        
        // Also update the view preference, if the chosen startup layout was this edited one.
        let prefLayout = preferences.viewPreferences.layoutOnStartup.layoutName
        if prefLayout == name {
            
            preferences.viewPreferences.layoutOnStartup.layoutName = newName
            preferences.persist()
        }
    }
    
    // Updates the visual preview.
    private func updatePreview() {
        
        if tableView.numberOfSelectedRows == 1 {
            
            let layout = windowLayoutsManager.userDefinedPresets[tableView.selectedRow]
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
        
        let layout = windowLayoutsManager.userDefinedPresets[row]
        return createTextCell(tableView, tableColumn!, row, layout.name, true)
    }
}
