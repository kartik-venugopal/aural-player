import Cocoa

class MasterPresetsEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, ActionMessageSubscriber {
    
    @IBOutlet weak var editorView: NSTableView!
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private lazy var preferencesDelegate: PreferencesDelegateProtocol = ObjectGraph.getPreferencesDelegate()
    private lazy var preferences: Preferences = ObjectGraph.getPreferencesDelegate().getPreferences()
    
    private var oldPresetName: String?
    
    override var nibName: String? {return "MasterPresetsEditor"}
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        SyncMessenger.subscribe(actionTypes: [.applyEffectsPreset, .renameEffectsPreset, .deleteEffectsPresets], subscriber: self)
    }
    
    private func deleteSelectedPresetsAction() {
        
        let selection = getSelectedPresetNames()
        MasterPresets.deletePresets(selection)
        editorView.reloadData()
    }
    
    private func getSelectedPresetNames() -> [String] {
        
        var names = [String]()
        
        let selection = editorView.selectedRowIndexes

        selection.forEach({

            let cell = editorView.view(atColumn: 0, row: $0, makeIfNecessary: true) as! NSTableCellView

            let name = cell.textField!.stringValue
            names.append(name)
        })
        
        return names
    }
    
    private func renamePresetAction() {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let editedTextField = (rowView?.view(atColumn: 0) as! NSTableCellView).textField!

        self.view.window?.makeFirstResponder(editedTextField)
    }
    
    private func applyPresetAction() {
        
        let selection = getSelectedPresetNames()
        graph.applyMasterPreset(selection[0])
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return MasterPresets.countUserDefinedPresets()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        SyncMessenger.publishNotification(EditorSelectionChangedNotification(editorView.selectedRowIndexes.count))
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let preset = MasterPresets.userDefinedPresets[row]
        return createTextCell(tableView, tableColumn!, row, preset.name)
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
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
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        
        // Note down the existing preset name
        oldPresetName = fieldEditor.string
        
        return true
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let cell = rowView?.view(atColumn: 0) as! NSTableCellView
        let editedTextField = cell.textField!
        
        // Access the old value from the temp storage variable
        let oldName = oldPresetName!
        
        if let preset = MasterPresets.presetByName(oldName) {
            
            let newPresetName = editedTextField.stringValue

            editedTextField.textColor = Colors.playlistSelectedTextColor

            // TODO: What if the string is too long ?

            // Empty string is invalid, revert to old value
            if (StringUtils.isStringEmpty(newPresetName)) {
                
                editedTextField.stringValue = preset.name

            } else if MasterPresets.presetWithNameExists(newPresetName) {

                // Another preset with that name exists, can't rename
                editedTextField.stringValue = preset.name

            } else {

                // Update the preset name
                MasterPresets.renamePreset(oldName, newPresetName)
                
                // Also update the sound preference, if the chosen preset was this edited one
                let presetOnStartup = preferences.soundPreferences.masterPresetOnStartup_name
                if presetOnStartup == oldName {
                    
                    preferences.soundPreferences.masterPresetOnStartup_name = newPresetName
                    preferencesDelegate.savePreferences(preferences)
                }
            }
        }
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }

    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? EffectsPresetsEditorActionMessage {
            
            if msg.effectsPresetsUnit == .master {
                
                switch msg.actionType {
                    
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
