import Cocoa

// TODO: Encapsulate individual views
class MasterPresetsEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, ActionMessageSubscriber {
    
    @IBOutlet weak var editorView: NSTableView!
    @IBOutlet weak var previewBox: NSBox!
    @IBOutlet weak var subPreviewMenu: NSPopUpButton!
    
    // Master
    
    @IBOutlet weak var masterSubPreview: NSView!
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    // EQ
    
    @IBOutlet weak var eqSubPreview: EQView!
    private var curEQPreset: EQPreset?
    
    // Pitch
    
    @IBOutlet weak var pitchSubPreview: NSView!
    
    @IBOutlet weak var pitchSlider: EffectsUnitSlider!
    @IBOutlet weak var pitchOverlapSlider: EffectsUnitSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    // Time
    
    @IBOutlet weak var timeSubPreview: NSView!
    
    @IBOutlet weak var btnShiftPitch: NSButton!
    @IBOutlet weak var timeSlider: EffectsUnitSlider!
    @IBOutlet weak var timeOverlapSlider: EffectsUnitSlider!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    // Reverb
    
    @IBOutlet weak var reverbSubPreview: NSView!
    
    @IBOutlet weak var reverbSpaceMenu: NSPopUpButton!
    @IBOutlet weak var reverbAmountSlider: EffectsUnitSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // Delay
    
    @IBOutlet weak var delaySubPreview: NSView!
    
    @IBOutlet weak var delayTimeSlider: EffectsUnitSlider!
    @IBOutlet weak var delayAmountSlider: EffectsUnitSlider!
    @IBOutlet weak var delayCutoffSlider: EffectsUnitSlider!
    @IBOutlet weak var delayFeedbackSlider: EffectsUnitSlider!
    
    @IBOutlet weak var lblDelayTimeValue: NSTextField!
    @IBOutlet weak var lblDelayAmountValue: NSTextField!
    @IBOutlet weak var lblDelayFeedbackValue: NSTextField!
    @IBOutlet weak var lblDelayLowPassCutoffValue: NSTextField!
    
    // Filter
    
    @IBOutlet weak var filterSubPreview: NSView!
    
    @IBOutlet weak var bandsTable: NSTableView!
    @IBOutlet weak var tableViewDelegate: FilterBandsViewDelegate!
    private var bandsDataSource: PresetFilterBandsDataSource = PresetFilterBandsDataSource()
    
    @IBOutlet weak var chart: FilterChart!
    
    // --------------------------------
    
    private var subPreviewViews: [NSView] = []
    
    @IBOutlet weak var subPreviewBox: NSBox!
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private lazy var preferencesDelegate: PreferencesDelegateProtocol = ObjectGraph.getPreferencesDelegate()
    private lazy var preferences: Preferences = ObjectGraph.getPreferencesDelegate().getPreferences()
    
    private var oldPresetName: String?
    
    override var nibName: String? {return "MasterPresetsEditor"}
    
    override func viewDidLoad() {
        
        subPreviewViews = [masterSubPreview, eqSubPreview, pitchSubPreview, timeSubPreview, reverbSubPreview, delaySubPreview, filterSubPreview]
        subPreviewViews.forEach({subPreviewBox.addSubview($0)})
        
        let eqStateFunction = {
            () -> EffectsUnitState in
            return self.curEQPreset == nil ? .active : self.curEQPreset!.state
        }
        
        eqSubPreview.initialize(nil, nil, eqStateFunction)
        eqSubPreview.chooseType(.tenBand)
        
        chart.bandsDataFunction = {() -> [FilterBand] in
            return self.getFilterChartBands()
        }
        
        tableViewDelegate.dataSource = bandsDataSource
        tableViewDelegate.allowSelection = false
        
        SyncMessenger.subscribe(actionTypes: [.reloadPresets, .applyEffectsPreset, .renameEffectsPreset, .deleteEffectsPresets], subscriber: self)
    }
    
    private func getFilterChartBands() -> [FilterBand] {
        
        let selection = getSelectedPresetNames()
        
        if !selection.isEmpty {
            
            let preset = MasterPresets.presetByName(selection[0])!
            return preset.filter.bands
        }
        
        return []
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
        MasterPresets.deletePresets(selection)
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
        graph.applyMasterPreset(selection[0])
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
    
    private func renderPreview(_ preset: MasterPreset) {
        
        btnEQBypass.onIf(preset.eq.state == .active)
        btnPitchBypass.onIf(preset.pitch.state == .active)
        btnTimeBypass.onIf(preset.time.state == .active)
        btnReverbBypass.onIf(preset.reverb.state == .active)
        btnDelayBypass.onIf(preset.delay.state == .active)
        btnFilterBypass.onIf(preset.filter.state == .active)
        
        // Set up EQ
        renderEQPreview(preset.eq)
        renderPitchPreview(preset.pitch)
        renderTimePreview(preset.time)
        renderReverbPreview(preset.reverb)
        renderDelayPreview(preset.delay)
        renderFilterPreview(preset.filter)
        
        previewBox.show()
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        if let preset = curEQPreset {
            eqSubPreview.typeChanged(preset.bands, preset.globalGain)
        }
    }
    
    private func renderEQPreview(_ preset: EQPreset) {
        
        curEQPreset = preset

        eqSubPreview.stateChanged()
        eqSubPreview.bandsUpdated(preset.bands, preset.globalGain)
    }
    
    private func renderPitchPreview(_ preset: PitchPreset) {
        
        let pitch = preset.pitch * AppConstants.pitchConversion_audioGraphToUI
        pitchSlider.floatValue = pitch
        pitchSlider.setUnitState(preset.state)
        lblPitchValue.stringValue = ValueFormatter.formatPitch(pitch)
        
        pitchOverlapSlider.floatValue = preset.overlap
        pitchOverlapSlider.setUnitState(preset.state)
        lblPitchOverlapValue.stringValue = ValueFormatter.formatOverlap(preset.overlap)
    }
    
    private func renderTimePreview(_ preset: TimePreset) {
        
        btnShiftPitch.onIf(preset.pitchShift)
        let pitchShift = (preset.pitchShift ? 1200 * log2(preset.rate) : 0) * AppConstants.pitchConversion_audioGraphToUI
        lblPitchShiftValue.stringValue = ValueFormatter.formatPitch(pitchShift)
        
        timeSlider.floatValue = preset.rate
        timeSlider.setUnitState(preset.state)
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(preset.rate)
        
        timeOverlapSlider.floatValue = preset.overlap
        timeOverlapSlider.setUnitState(preset.state)
        lblTimeOverlapValue.stringValue = ValueFormatter.formatOverlap(preset.overlap)
    }
    
    private func renderReverbPreview(_ preset: ReverbPreset) {
        
        reverbSpaceMenu.select(reverbSpaceMenu.item(withTitle: preset.space.description))
        
        reverbAmountSlider.floatValue = preset.amount
        reverbAmountSlider.setUnitState(preset.state)
        lblReverbAmountValue.stringValue = ValueFormatter.formatReverbAmount(preset.amount)
    }
    
    private func renderDelayPreview(_ preset: DelayPreset) {
        
        delayAmountSlider.floatValue = preset.amount
        lblDelayAmountValue.stringValue = ValueFormatter.formatDelayAmount(preset.amount)
        
        delayTimeSlider.doubleValue = preset.time
        lblDelayTimeValue.stringValue = ValueFormatter.formatDelayTime(preset.time)
        
        delayFeedbackSlider.floatValue = preset.feedback
        lblDelayFeedbackValue.stringValue = ValueFormatter.formatDelayFeedback(preset.feedback)
        
        delayCutoffSlider.floatValue = preset.cutoff
        lblDelayLowPassCutoffValue.stringValue = ValueFormatter.formatDelayLowPassCutoff(preset.cutoff)
        
        [delayTimeSlider, delayAmountSlider, delayCutoffSlider, delayFeedbackSlider].forEach({$0?.setUnitState(preset.state)})
    }
    
    private func renderFilterPreview(_ preset: FilterPreset) {
        
        chart.redraw()
        bandsTable.reloadData()
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return MasterPresets.countUserDefinedPresets()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows = editorView.numberOfSelectedRows
        
        previewBox.hideIf_elseShow(numRows != 1)
        
        if numRows == 1 {
            
            let presetName = getSelectedPresetNames()[0]
            let masterPreset = MasterPresets.presetByName(presetName)!
            
            bandsDataSource.preset = masterPreset.filter
            renderPreview(masterPreset)
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
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let cell = rowView?.view(atColumn: 0) as! NSTableCellView
        let editedTextField = cell.textField!
        
        // Access the old value from the temp storage variable
        let oldName = oldPresetName ?? editedTextField.stringValue
        
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
