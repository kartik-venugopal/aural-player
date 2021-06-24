//
//  FXPresetsManagerGenericViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FXPresetsManagerGenericViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var previewBox: NSBox!
    
    let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    var fxUnit: FXUnitDelegateProtocol!
    var presetsWrapper: PresetsWrapperProtocol!
    var unitType: FXUnitType!
    
    override func viewDidLoad() {
        
        let unitTypeFilter: (FXUnitType) -> Bool = {[weak self] (unit: FXUnitType) in unit == self?.unitType}
        
        Messenger.subscribe(self, .fxPresetsManager_reload, {[weak self] (FXUnit) in self?.doViewDidAppear()},
                            filter: unitTypeFilter)
        
        Messenger.subscribe(self, .fxPresetsManager_apply, {[weak self] (FXUnit) in self?.applySelectedPreset()},
                            filter: unitTypeFilter)
        
        Messenger.subscribe(self, .fxPresetsManager_rename, {[weak self] (FXUnit) in self?.renameSelectedPreset()},
                            filter: unitTypeFilter)
        
        Messenger.subscribe(self, .fxPresetsManager_delete, {[weak self] (FXUnit) in self?.deleteSelectedPresets()},
                            filter: unitTypeFilter)
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func viewDidAppear() {
        doViewDidAppear()
    }
    
    private func doViewDidAppear() {
        
        tableView.reloadData()
        tableView.deselectAll(self)
        
        previewBox.hide()
    }
    
    @IBAction func tableDoubleClickAction(_ sender: AnyObject) {
        applySelectedPreset()
    }
    
    func deleteSelectedPresets() {
        
        presetsWrapper.deletePresets(atIndices: tableView.selectedRowIndexes)
        tableView.reloadData()
        
        previewBox.hide()
        
        Messenger.publish(.presetsManager_selectionChanged, payload: Int(0))
    }
    
    var selectedPresets: [FXUnitPreset] {
        tableView.selectedRowIndexes.map {presetsWrapper.userDefinedPresets[$0]}
    }
    
    var firstSelectedPreset: FXUnitPreset? {selectedPresets.first}
    
    func renameSelectedPreset() {
        
        let rowIndex = tableView.selectedRow
        let rowView = tableView.rowView(atRow: rowIndex, makeIfNecessary: true)
        
        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            self.view.window?.makeFirstResponder(editedTextField)
        }
    }
    
    func applySelectedPreset() {
        
        if let preset = firstSelectedPreset {
            
            fxUnit.applyPreset(preset.name)
            Messenger.publish(.fx_updateFXUnitView, payload: self.unitType!)
        }
    }
    
    func renderPreview(_ presetName: String) {}
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        presetsWrapper.userDefinedPresets.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows: Int = tableView.numberOfSelectedRows
        previewBox.showIf(numRows == 1)
        
        if numRows == 1, let preset = firstSelectedPreset {
            renderPreview(preset.name)
        }
        
        Messenger.publish(.presetsManager_selectionChanged, payload: numRows)
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let preset = presetsWrapper.userDefinedPresets[row]
        return createTextCell(tableView, tableColumn!, row, preset.name)
    }
    
    // Creates a cell view containing text
    func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> PresetsManagerTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? PresetsManagerTableCellView
        else {return nil}
        
        cell.isSelectedFunction = {[weak self] row in
            self?.tableView.selectedRowIndexes.contains(row) ?? false
        }
        
        cell.row = row
        
        cell.textField?.stringValue = text
        cell.textField?.delegate = self
        
        return cell
    }
    
    // MARK: Text field delegate functions
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        guard let editedTextField = obj.object as? NSTextField else {return}
        
        let rowIndex = tableView.selectedRow
        let preset = presetsWrapper.userDefinedPresets[rowIndex]
        
        let oldPresetName = preset.name
        let newPresetName = editedTextField.stringValue
        
        // No change in preset name. Nothing to be done.
        if newPresetName == oldPresetName {return}
        
        editedTextField.textColor = Colors.defaultSelectedLightTextColor
        
        // TODO: What if the string is too long ?
        
        // If new name is empty or a preset with the new name exists, revert to old value.
        if newPresetName.isEmptyAfterTrimming {
            
            editedTextField.stringValue = preset.name
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Preset name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
            
        } else if presetsWrapper.presetExists(named: newPresetName) {
            
            editedTextField.stringValue = preset.name
            
            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Another preset with that name already exists.", "Please type a unique name.").showModal()
            
        } else {
            renamePreset(named: oldPresetName, to: newPresetName)
        }
    }
    
    func renamePreset(named name: String, to newName: String) {
        
        // Update the preset name
        presetsWrapper.renamePreset(named: name, to: newName)
    }
}
