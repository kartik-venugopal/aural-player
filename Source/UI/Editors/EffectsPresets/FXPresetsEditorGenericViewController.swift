import Cocoa

class FXPresetsEditorGenericViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var editorView: NSTableView!
    @IBOutlet weak var previewBox: NSBox!
    
    let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    var fxUnit: FXUnitDelegateProtocol!
    var presetsWrapper: PresetsWrapperProtocol!
    var unitType: EffectsUnit!
    
    var oldPresetName: String = ""
    
    override func viewDidLoad() {
        
        let unitTypeFilter: (EffectsUnit) -> Bool = {[weak self] (unit: EffectsUnit) in unit == self?.unitType}
        
        Messenger.subscribe(self, .fxPresetsEditor_reload, {[weak self] (EffectsUnit) in self?.doViewDidAppear()},
                            filter: unitTypeFilter)
        
        Messenger.subscribe(self, .fxPresetsEditor_apply, {[weak self] (EffectsUnit) in self?.applySelectedPreset()},
                            filter: unitTypeFilter)
        
        Messenger.subscribe(self, .fxPresetsEditor_rename, {[weak self] (EffectsUnit) in self?.renameSelectedPreset()},
                            filter: unitTypeFilter)
        
        Messenger.subscribe(self, .fxPresetsEditor_delete, {[weak self] (EffectsUnit) in self?.deleteSelectedPresets()},
                            filter: unitTypeFilter)
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func viewDidAppear() {
        doViewDidAppear()
    }
    
    private func doViewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        previewBox.hide()
    }
    
    @IBAction func tableDoubleClickAction(_ sender: AnyObject) {
        applySelectedPreset()
    }
    
    func deleteSelectedPresets() {
        
        presetsWrapper.deletePresets(selectedPresetNames)
        editorView.reloadData()
        
        previewBox.hide()
        
        Messenger.publish(.presetsEditor_selectionChanged, payload: Int(0))
    }
    
    var selectedPresetNames: [String] {
        
        editorView.selectedRowIndexes.compactMap {[weak editorView] in editorView?.view(atColumn: 0, row: $0, makeIfNecessary: true) as? NSTableCellView}
            .compactMap {$0.textField?.stringValue}
    }
    
    var firstSelectedPresetName: String {
        (editorView.view(atColumn: 0, row: editorView.selectedRow, makeIfNecessary: true) as! NSTableCellView).textField!.stringValue
    }
    
    func renameSelectedPreset() {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let editedTextField = (rowView?.view(atColumn: 0) as! NSTableCellView).textField!
        
        self.view.window?.makeFirstResponder(editedTextField)
    }
    
    func applySelectedPreset() {
        
        fxUnit.applyPreset(firstSelectedPresetName)
        Messenger.publish(.fx_updateFXUnitView, payload: self.unitType!)
    }
    
    func renderPreview(_ presetName: String) {}
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return presetsWrapper.userDefinedPresets.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows: Int = editorView.numberOfSelectedRows
        previewBox.showIf(numRows == 1)
        
        if numRows == 1 {
            
            let presetName = firstSelectedPresetName
            renderPreview(presetName)
            oldPresetName = presetName
        }
        
        Messenger.publish(.presetsEditor_selectionChanged, payload: numRows)
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
    func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView {
            
            cell.isSelectedFunction = {[weak self] (row: Int) -> Bool in
                return self?.editorView.selectedRowIndexes.contains(row) ?? false
            }
            
            cell.row = row
            
            cell.textField?.stringValue = text
            cell.textField!.delegate = self
            
            return cell
        }
        
        return nil
    }
    
    // MARK: Text field delegate functions
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let editedTextField = obj.object as! NSTextField
        let newPresetName = editedTextField.stringValue
        
        if let preset = presetsWrapper.presetByName(oldPresetName) {
            
            editedTextField.textColor = Colors.playlistSelectedTextColor
            
            // TODO: What if the string is too long ?
            
            // Empty string is invalid, revert to old value
            if String.isEmpty(newPresetName) || presetsWrapper.presetWithNameExists(newPresetName) {
                
                editedTextField.stringValue = preset.name
                
            } else {
                
                // Update the preset name
                presetsWrapper.renamePreset(oldPresetName, newPresetName)
            }
            
        } else {
            
            // IMPOSSIBLE
            editedTextField.stringValue = oldPresetName
        }
    }
}
