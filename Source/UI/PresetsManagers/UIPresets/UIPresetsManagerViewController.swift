//
//  PresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class UIPresetsManagerViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var presetsManager: (any PresetsManagerProtocol)!
    
    // Needs to be overriden by subclasses.
    var numberOfPresets: Int {
        presetsManager.numberOfUserDefinedObjects
    }
    
    // Needs to be overriden by subclasses.
    func presetExists(named name: String) -> Bool {
        presetsManager.objectExists(named: name)
    }
    
    func renameSelectedPreset() {
        
        let rowIndex = tableView.selectedRow
        let rowView = tableView.rowView(atRow: rowIndex, makeIfNecessary: true)
        
        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            tableView.window?.makeFirstResponder(editedTextField)
        }
    }
    
    // Needs to be overriden by subclasses.
    func renamePreset(named name: String, to newName: String) {
        presetsManager.renameObject(named: name, to: newName)
    }
    
    func nameOfPreset(atIndex index: Int) -> String {
        presetsManager.userDefinedObjects[index].name
    }
    
    func deleteSelectedPresets() {
        
        deletePresets(atIndices: tableView.selectedRowIndexes)
        
        tableView.reloadData()
        tableView.deselectAll(self)
    }
    
    func deletePresets(atIndices indices: IndexSet) {
        _ = presetsManager.deleteObjects(atIndices: indices)
    }
    
    func applySelectedPreset() {
        applyPreset(atIndex: tableView.selectedRow)
    }
    
    // Needs to be overriden by subclasses.
    func applyPreset(atIndex index: Int) {}
    
    override func viewWillAppear() {
        
        super.viewWillAppear()
        
        tableView.reloadData()
        tableView.deselectAll(self)
    }
    
    // MARK: Table view delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {numberOfPresets}
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the name (first) column is used for type selection.
        if let column = tableColumn, (column.tableView?.column(withIdentifier: column.identifier) ?? -1) == 0, NSEvent.noModifiedFlagsSet {
            return nameOfPreset(atIndex: row)
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        Messenger.publish(.PresetsManager.selectionChanged, payload: tableView.numberOfSelectedRows)
    }
    
    // Needs to be overriden by subclasses.
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn else {return nil}
        
        let object = presetsManager.userDefinedObjects[row]
        return createTextCell(tableView, column, row, object.name, true)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        24
    }
    
    // Creates a cell view containing text
    func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String, _ editable: Bool) -> NSTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView,
              let textField = cell.textField else {return nil}
        
        textField.stringValue = text
        
        // Set tool tip on name/track only if text wider than column width
        updateTooltip(forCell: cell, inColumn: column)
        
        // Name column is editable
        if editable {
            textField.delegate = self
        }
        
        return cell
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
        
        // Update tool tips as some may no longer be needed or some new ones may be needed
        
        let rowCount = tableView.numberOfRows
        guard rowCount > 0, let column = notification.userInfo?["NSTableColumn", NSTableColumn.self] else {return}
        
        for index in 0..<rowCount {
            
            if let cell = tableView(tableView, viewFor: column, row: index) as? NSTableCellView {
                updateTooltip(forCell: cell, inColumn: column)
            }
        }
    }
    
    // Renames the selected preset.
    func controlTextDidEndEditing(_ obj: Notification) {
        
//        defer {btnDelete.enable()}
        
        let rowIndex = tableView.selectedRow
        let rowView = tableView.rowView(atRow: rowIndex, makeIfNecessary: true)

        guard let cell = rowView?.view(atColumn: 0) as? NSTableCellView,
              let editedTextField = cell.textField else {return}
        
        let oldPresetName = nameOfPreset(atIndex: rowIndex)
        let newPresetName = editedTextField.stringValue
        
        // No change in preset name. Nothing to be done.
        if newPresetName == oldPresetName {return}
        
        editedTextField.textColor = .defaultSelectedLightTextColor
        
        // Empty string is invalid, revert to old value
        if newPresetName.isEmptyAfterTrimming {
            
            editedTextField.stringValue = oldPresetName
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Preset name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
            
        } else if presetExists(named: newPresetName) {
            
            // Another theme with that name exists, can't rename
            editedTextField.stringValue = oldPresetName
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Another preset with that name already exists.", "Please type a unique name.").showModal()
            
        } else {
            
            // Update the preset name
            renamePreset(named: oldPresetName, to: newPresetName)
        }
        
        // Update the tool tip
        let nameColumn = tableView.tableColumns[0]
        updateTooltip(forCell: cell, inColumn: nameColumn)
    }
    
    private func updateTooltip(forCell cell: NSTableCellView, inColumn column: NSTableColumn) {
        
        guard let textField = cell.textField else {return}
        
        if let font = textField.font, textField.stringValue.numberOfLines(font: font, lineWidth: column.width) > 1 {
            cell.toolTip = textField.stringValue
        } else {
            cell.toolTip = nil
        }
    }
}
