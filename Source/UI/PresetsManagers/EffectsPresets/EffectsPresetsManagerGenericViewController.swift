//
//  EffectsPresetsManagerGenericViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsPresetsManagerGenericViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, Destroyable {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var previewBox: NSBox!
    
    let graph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    var effectsUnit: EffectsUnitDelegateProtocol!
    var presetsWrapper: PresetsWrapperProtocol!
    var unitType: EffectsUnitType!
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        let unitTypeFilter: (EffectsUnitType) -> Bool = {[weak self] (unit: EffectsUnitType) in unit == self?.unitType}
        
        messenger.subscribe(to: .effectsPresetsManager_reload, handler: {[weak self] (EffectsUnit) in self?.doViewDidAppear()},
                            filter: unitTypeFilter)
        
        messenger.subscribe(to: .effectsPresetsManager_apply, handler: {[weak self] (EffectsUnit) in self?.applySelectedPreset()},
                            filter: unitTypeFilter)
        
        messenger.subscribe(to: .effectsPresetsManager_rename, handler: {[weak self] (EffectsUnit) in self?.renameSelectedPreset()},
                            filter: unitTypeFilter)
        
        messenger.subscribe(to: .effectsPresetsManager_delete, handler: {[weak self] (EffectsUnit) in self?.deleteSelectedPresets()},
                            filter: unitTypeFilter)
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
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
        
        messenger.publish(.presetsManager_selectionChanged, payload: Int(0))
    }
    
    var selectedPresets: [EffectsUnitPreset] {
        tableView.selectedRowIndexes.map {presetsWrapper.userDefinedPresets[$0]}
    }
    
    var firstSelectedPreset: EffectsUnitPreset? {selectedPresets.first}
    
    func renameSelectedPreset() {
        
        let rowIndex = tableView.selectedRow
        let rowView = tableView.rowView(atRow: rowIndex, makeIfNecessary: true)
        
        if let editedTextField = (rowView?.view(atColumn: 0) as? NSTableCellView)?.textField {
            self.view.window?.makeFirstResponder(editedTextField)
        }
    }
    
    func applySelectedPreset() {
        
        if let preset = firstSelectedPreset {
            
            effectsUnit.applyPreset(named: preset.name)
            messenger.publish(.effects_updateEffectsUnitView, payload: self.unitType!)
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
        
        messenger.publish(.presetsManager_selectionChanged, payload: numRows)
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
        
        cell.isSelectedFunction = {[weak tableView] row in
            tableView?.isRowSelected(row) ?? false
        }
        
        cell.row = row
        
        cell.text = text
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
        
        editedTextField.textColor = .defaultSelectedLightTextColor
        
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
