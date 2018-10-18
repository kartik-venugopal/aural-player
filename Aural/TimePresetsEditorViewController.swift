import Cocoa

class TimePresetsEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, ActionMessageSubscriber {
    
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var btnShiftPitch: NSButton!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var timeOverlapSlider: NSSlider!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    @IBOutlet weak var previewBox: NSBox!
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private var oldPresetName: String?
    
    override var nibName: String? {return "TimePresetsEditor"}
    
    override func viewDidLoad() {
        SyncMessenger.subscribe(actionTypes: [.applyEffectsPreset, .renameEffectsPreset, .deleteEffectsPresets], subscriber: self)
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        previewBox.isHidden = true
    }
    
    @IBAction func tableDoubleClickAction(_ sender: AnyObject) {
        applyPresetAction()
    }
    
    private func deleteSelectedPresetsAction() {
        
        let selection = getSelectedPresetNames()
        TimePresets.deletePresets(selection)
        editorView.reloadData()
        
        previewBox.isHidden = true
        
        SyncMessenger.publishNotification(EditorSelectionChangedNotification(0))
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
        graph.applyTimePreset(selection[0])
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .time))
    }
    
    private func renderPreview(_ preset: TimePreset) {
        
        btnShiftPitch.state = NSControl.StateValue(rawValue: preset.pitchShift ? 1 : 0)
        let pitchShift = (preset.pitchShift ? 1200 * log2(preset.rate) : 0) * AppConstants.pitchConversion_audioGraphToUI
        lblPitchShiftValue.stringValue = ValueFormatter.formatPitch(pitchShift)
        
        timeSlider.floatValue = preset.rate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
        
        timeOverlapSlider.floatValue = preset.overlap
        lblTimeOverlapValue.stringValue = ValueFormatter.formatOverlap(preset.overlap)
        
        previewBox.isHidden = false
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return TimePresets.countUserDefinedPresets()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows = editorView.numberOfSelectedRows
        
        previewBox.isHidden = numRows != 1
        
        if numRows == 1 {
            renderPreview(TimePresets.presetByName(getSelectedPresetNames()[0]))
        }
        
        SyncMessenger.publishNotification(EditorSelectionChangedNotification(numRows))
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let preset = TimePresets.userDefinedPresets[row]
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
        
        if TimePresets.presetWithNameExists(oldName) {
            
            let preset = TimePresets.presetByName(oldName)
            
            let newPresetName = editedTextField.stringValue
            
            editedTextField.textColor = Colors.playlistSelectedTextColor
            
            // TODO: What if the string is too long ?
            
            // Empty string is invalid, revert to old value
            if (StringUtils.isStringEmpty(newPresetName)) {
                
                editedTextField.stringValue = preset.name
                
            } else if TimePresets.presetWithNameExists(newPresetName) {
                
                // Another preset with that name exists, can't rename
                editedTextField.stringValue = preset.name
                
            } else {
                
                // Update the preset name
                TimePresets.renamePreset(oldName, newPresetName)
            }
            
        } else {
            
            // IMPOSSIBLE
            editedTextField.stringValue = oldName
        }
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? EffectsPresetsEditorActionMessage {
            
            if msg.effectsPresetsUnit == .time {
                
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

