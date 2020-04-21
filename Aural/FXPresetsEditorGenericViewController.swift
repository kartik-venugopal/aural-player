import Cocoa

class FXPresetsEditorGenericViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, ActionMessageSubscriber {
    
    @IBOutlet weak var editorView: NSTableView!
    @IBOutlet weak var previewBox: NSBox!
    
    let graph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    var fxUnit: FXUnitDelegateProtocol!
    var presetsWrapper: PresetsWrapperProtocol!
    var unitType: EffectsUnit!
    
    var oldPresetName: String = ""
    
    override func viewDidLoad() {
        SyncMessenger.subscribe(actionTypes: [.reloadPresets, .applyEffectsPreset, .renameEffectsPreset, .deleteEffectsPresets], subscriber: self)
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        previewBox.hide()
    }
    
    @IBAction func tableDoubleClickAction(_ sender: AnyObject) {
        applyPresetAction()
    }
    
    func deleteSelectedPresetsAction() {
        
        presetsWrapper.deletePresets(selectedPresetNames)
        editorView.reloadData()
        
        previewBox.hide()
        
        SyncMessenger.publishNotification(EditorSelectionChangedNotification(0))
    }
    
    var selectedPresetNames: [String] {
        
        var names = [String]()
        
        editorView.selectedRowIndexes.forEach({
            
            let cell = editorView.view(atColumn: 0, row: $0, makeIfNecessary: true) as! NSTableCellView
            names.append(cell.textField!.stringValue)
        })
        
        return names
    }
    
    var firstSelectedPresetName: String {
        return (editorView.view(atColumn: 0, row: editorView.selectedRow, makeIfNecessary: true) as! NSTableCellView).textField!.stringValue
    }
    
    func renamePresetAction() {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let editedTextField = (rowView?.view(atColumn: 0) as! NSTableCellView).textField!
        
        self.view.window?.makeFirstResponder(editedTextField)
    }
    
    func applyPresetAction() {
        
        fxUnit.applyPreset(firstSelectedPresetName)
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, self.unitType))
    }
    
    func renderPreview(_ presetName: String) {}
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return presetsWrapper.userDefinedPresets.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows = editorView.numberOfSelectedRows
        previewBox.showIf_elseHide(numRows == 1)
        
        if numRows == 1 {
            
            let presetName = firstSelectedPresetName
            renderPreview(presetName)
            oldPresetName = presetName
        }
        
        SyncMessenger.publishNotification(EditorSelectionChangedNotification(numRows))
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
            
            cell.isSelectedFunction = {
                
                (row: Int) -> Bool in
                
                return self.editorView.selectedRowIndexes.contains(row)
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
            if (StringUtils.isStringEmpty(newPresetName) || presetsWrapper.presetWithNameExists(newPresetName)) {
                
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
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? EffectsPresetsEditorActionMessage {
            
            if msg.effectsPresetsUnit == self.unitType {
                
                switch msg.actionType {
                    
                case .reloadPresets:
                    viewDidAppear()
                    
                case .renameEffectsPreset:
                    renamePresetAction()
                    
                case .deleteEffectsPresets:
                    deleteSelectedPresetsAction()
                    
                case .applyEffectsPreset:
                    applyPresetAction()
                    
                default: return
                    
                }
            }
        }
    }
}
