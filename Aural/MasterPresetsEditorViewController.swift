import Cocoa

class MasterPresetsEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, ActionMessageSubscriber {
    
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var previewBox: NSBox!
    @IBOutlet weak var subPreviewBox: NSBox!
    @IBOutlet weak var subPreviewMenu: NSPopUpButton!
    private var subPreviewViews: [NSView] = []
    
    @IBOutlet weak var masterSubPreview: MasterView!
    @IBOutlet weak var eqSubPreview: EQView!
    @IBOutlet weak var pitchSubPreview: PitchView!
    @IBOutlet weak var timeSubPreview: TimeView!
    @IBOutlet weak var reverbSubPreview: ReverbView!
    @IBOutlet weak var delaySubPreview: DelayView!
    
    @IBOutlet weak var filterSubPreview: FilterView!
    private var bandsDataSource: PresetFilterBandsDataSource = PresetFilterBandsDataSource()
    
    // --------------------------------
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private lazy var preferencesDelegate: PreferencesDelegateProtocol = ObjectGraph.getPreferencesDelegate()
    private lazy var preferences: Preferences = ObjectGraph.getPreferencesDelegate().getPreferences()
    
//    private let masterPresets: MasterPresets = ObjectGraph.getAudioGraphDelegate().masterPresets
    
    private var oldPresetName: String?
    
    override var nibName: String? {return "MasterPresetsEditor"}
    
    override func viewDidLoad() {
        
        subPreviewViews = [masterSubPreview, eqSubPreview, pitchSubPreview, timeSubPreview, reverbSubPreview, delaySubPreview, filterSubPreview]
        subPreviewViews.forEach({subPreviewBox.addSubview($0)})
        
        eqSubPreview.chooseType(.tenBand)
        
        let bandsDataFunction = {() -> [FilterBand] in return self.getFilterChartBands()}
        filterSubPreview.initialize({() -> EffectsUnitState in return self.getPresetFilterUnitState()}, bandsDataFunction, bandsDataSource, false)
        
        SyncMessenger.subscribe(actionTypes: [.reloadPresets, .applyEffectsPreset, .renameEffectsPreset, .deleteEffectsPresets], subscriber: self)
    }
    
    private func getFilterChartBands() -> [FilterBand] {
        
        let selection = getSelectedPresetNames()
        
        if !selection.isEmpty {
            
            // TODO: Write a simple function to get selection[0]
            
//            let preset = masterPresets.presetByName(selection[0])!
//            return preset.filter.bands
        }
        
        return []
    }
    
    private func getPresetFilterUnitState() -> EffectsUnitState {
        
        let selection = getSelectedPresetNames()
        
        if !selection.isEmpty {
        
//            let preset = masterPresets.presetByName(selection[0])!
//            return preset.filter.state
        }
        
        return .active
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        previewBox.hide()
        
        // Show EQ sub preview by default
        subPreviewViews.forEach({$0.hide()})
        masterSubPreview.show()
        subPreviewMenu.selectItem(withTitle: "Master")
    }
    
    @IBAction func tableDoubleClickAction(_ sender: AnyObject) {
        applyPresetAction()
    }
    
    private func deleteSelectedPresetsAction() {
        
        let selection = getSelectedPresetNames()
//        masterPresets.deletePresets(selection)
        editorView.reloadData()
        
        previewBox.hide()
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
//        graph.applyMasterPreset(selection[0])
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.updateEffectsView, .master))
    }
    
    @IBAction func subPreviewMenuAction(_ sender: AnyObject) {
        
        subPreviewViews.forEach({$0.hide()})
        
        let selItem = subPreviewMenu.titleOfSelectedItem
        
        switch selItem {
            
        case "Master": masterSubPreview.show()
            
        case "EQ": eqSubPreview.show()
            
        case "Pitch": pitchSubPreview.show()
            
        case "Time": timeSubPreview.show()
            
        case "Reverb": reverbSubPreview.show()
            
        case "Delay": delaySubPreview.show()
            
        case "Filter": filterSubPreview.show()
            
        default: return
            
        }
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        let presetName = getSelectedPresetNames()[0]
//        let preset = masterPresets.presetByName(presetName)!.eq
//
//        eqSubPreview.setUnitState(preset.state)
//        eqSubPreview.typeChanged(preset.bands, preset.globalGain)
    }
    
    private func renderPreview(_ preset: MasterPreset) {
        
        masterSubPreview.applyPreset(preset)
        eqSubPreview.applyPreset(preset.eq)
        pitchSubPreview.applyPreset(preset.pitch)
        timeSubPreview.applyPreset(preset.time)
        reverbSubPreview.applyPreset(preset.reverb)
        delaySubPreview.applyPreset(preset.delay)
        
        // TODO: Implement applyPreset() in FilterView
        filterSubPreview.refresh()
        
        previewBox.show()
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
//        return masterPresets.userDefinedPresets.count
        return 0
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows = editorView.numberOfSelectedRows
        
        previewBox.hideIf_elseShow(numRows != 1)
        
        if numRows == 1 {
            
            let presetName = getSelectedPresetNames()[0]
//            let masterPreset = masterPresets.presetByName(presetName)!
//
//            bandsDataSource.preset = masterPreset.filter
//            renderPreview(masterPreset)
//            oldPresetName = presetName
        }
        
        SyncMessenger.publishNotification(EditorSelectionChangedNotification(numRows))
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
//        let preset = masterPresets.userDefinedPresets[row]
        return createTextCell(tableView, tableColumn!, row, "preset.name")
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
        
//        if let preset = masterPresets.presetByName(oldName) {
//
//            let newPresetName = editedTextField.stringValue
//
//            editedTextField.textColor = Colors.playlistSelectedTextColor
//
//            // TODO: What if the string is too long ?
//
//            // Empty string is invalid, revert to old value
//            if (StringUtils.isStringEmpty(newPresetName)) {
//
//                editedTextField.stringValue = preset.name
//
//            } else if masterPresets.presetWithNameExists(newPresetName) {
//
//                // Another preset with that name exists, can't rename
//                editedTextField.stringValue = preset.name
//
//            } else {
//
//                // Update the preset name
//                masterPresets.renamePreset(oldName, newPresetName)
//
//                // Also update the sound preference, if the chosen preset was this edited one
//                let presetOnStartup = preferences.soundPreferences.masterPresetOnStartup_name
//                if presetOnStartup == oldName {
//
//                    preferences.soundPreferences.masterPresetOnStartup_name = newPresetName
//                    preferencesDelegate.savePreferences(preferences)
//                }
//            }
//        }
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }

    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? EffectsPresetsEditorActionMessage {
            
            if msg.effectsPresetsUnit == .master {
                
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
