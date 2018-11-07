import Cocoa

class DelayPresetsEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, ActionMessageSubscriber {
    
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var delayTimeSlider: EffectsUnitSlider!
    @IBOutlet weak var delayAmountSlider: EffectsUnitSlider!
    @IBOutlet weak var delayCutoffSlider: EffectsUnitSlider!
    @IBOutlet weak var delayFeedbackSlider: EffectsUnitSlider!
    
    @IBOutlet weak var lblDelayTimeValue: NSTextField!
    @IBOutlet weak var lblDelayAmountValue: NSTextField!
    @IBOutlet weak var lblDelayFeedbackValue: NSTextField!
    @IBOutlet weak var lblDelayLowPassCutoffValue: NSTextField!
    
    @IBOutlet weak var previewBox: NSBox!
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    private let delayPresets: DelayPresets = ObjectGraph.getAudioGraphDelegate().delayPresets
    
    private var oldPresetName: String?
    
    override var nibName: String? {return "DelayPresetsEditor"}
    
    override func viewDidLoad() {
        
        let unitStateFunction = {
            () -> EffectsUnitState in
            return .active
        }
        
        [delayTimeSlider, delayAmountSlider, delayCutoffSlider, delayFeedbackSlider].forEach({
            $0?.stateFunction = unitStateFunction
            $0?.updateState()
        })
        
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
    
    private func deleteSelectedPresetsAction() {
        
        let selection = getSelectedPresetNames()
        delayPresets.deletePresets(selection)
        editorView.reloadData()
        
        previewBox.hide()
        
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
        graph.applyDelayPreset(selection[0])
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .delay))
    }
    
    private func renderPreview(_ preset: DelayPreset) {
        
        delayAmountSlider.floatValue = preset.amount
        lblDelayAmountValue.stringValue = ValueFormatter.formatDelayAmount(preset.amount)
        
        delayTimeSlider.doubleValue = preset.time
        lblDelayTimeValue.stringValue = ValueFormatter.formatDelayTime(preset.time)
        
        delayFeedbackSlider.floatValue = preset.feedback
        lblDelayFeedbackValue.stringValue = ValueFormatter.formatDelayFeedback(preset.feedback)
        
        delayCutoffSlider.floatValue = preset.cutoff
        lblDelayLowPassCutoffValue.stringValue = ValueFormatter.formatDelayLowPassCutoff(preset.cutoff)
        
        previewBox.show()
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return delayPresets.userDefinedPresets.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows = editorView.numberOfSelectedRows
        
        previewBox.hideIf_elseShow(numRows != 1)
        
        if numRows == 1 {
            
            let presetName = getSelectedPresetNames()[0]
            renderPreview(delayPresets.presetByName(presetName)!)
            oldPresetName = presetName
        }
        
        SyncMessenger.publishNotification(EditorSelectionChangedNotification(numRows))
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let preset = delayPresets.userDefinedPresets[row]
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
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let cell = rowView?.view(atColumn: 0) as! NSTableCellView
        let editedTextField = cell.textField!
        
        // Access the old value from the temp storage variable
        let oldName = oldPresetName ?? editedTextField.stringValue
        
        if let preset = delayPresets.presetByName(oldName) {
            
            let newPresetName = editedTextField.stringValue
            
            editedTextField.textColor = Colors.playlistSelectedTextColor
            
            // TODO: What if the string is too long ?
            
            // Empty string is invalid, revert to old value
            if (StringUtils.isStringEmpty(newPresetName)) {
                
                editedTextField.stringValue = preset.name
                
            } else if delayPresets.presetWithNameExists(newPresetName) {
                
                // Another preset with that name exists, can't rename
                editedTextField.stringValue = preset.name
                
            } else {
                
                // Update the preset name
                delayPresets.renamePreset(oldName, newPresetName)
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
            
            if msg.effectsPresetsUnit == .delay {
                
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

