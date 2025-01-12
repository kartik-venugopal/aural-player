//
//  EffectsPresetsManagerGenericViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class EffectsPresetsManagerGenericViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var effectsUnit: EffectsUnitDelegateProtocol!
    var presetsWrapper: PresetsWrapperProtocol!
    var unitType: EffectsUnitType!
    
    private lazy var messenger = Messenger(for: self)
    
    override func viewDidLoad() {
        
        let unitTypeFilter: (EffectsUnitType) -> Bool = {[weak self] unit in unit == self?.unitType}
        
        messenger.subscribe(to: .PresetsManager.Effects.reload, handler: {[weak self] in self?.doViewDidAppear()},
                            filter: unitTypeFilter)
    }
    
    override func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        doViewDidAppear()
    }
    
    private func doViewDidAppear() {
        
        tableView.reloadData()
        tableView.deselectAll(self)
    }
    
    @IBAction func tableDoubleClickAction(_ sender: AnyObject) {
        applySelectedPreset()
    }
    
    func deleteSelectedPresets() {
        
        presetsWrapper.deletePresets(atIndices: tableView.selectedRowIndexes)
        tableView.reloadData()
        
        messenger.publish(.PresetsManager.selectionChanged, payload: Int(0))
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
            messenger.publish(.Effects.updateEffectsUnitView, payload: self.unitType!)
        }
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        presetsWrapper.userDefinedPresets.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        messenger.publish(.PresetsManager.selectionChanged, payload: tableView.numberOfSelectedRows)
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn,
              let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? NSTableCellView else {return nil}
        
        let preset = presetsWrapper.userDefinedPresets[row]
        
        cell.text = preset.name
        cell.textField?.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        24
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
