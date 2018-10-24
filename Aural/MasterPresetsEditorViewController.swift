import Cocoa

class MasterPresetsEditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, ActionMessageSubscriber {
    
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    @IBOutlet weak var previewBox: NSBox!
    
    @IBOutlet weak var subPreviewMenu: NSPopUpButton!
    
    // EQ
    
    @IBOutlet weak var eqSubPreview: NSView!
    
    @IBOutlet weak var eqGlobalGainSlider: EffectsUnitSlider!
    @IBOutlet weak var eqSlider1k: EffectsUnitSlider!
    @IBOutlet weak var eqSlider64: EffectsUnitSlider!
    @IBOutlet weak var eqSlider16k: EffectsUnitSlider!
    @IBOutlet weak var eqSlider8k: EffectsUnitSlider!
    @IBOutlet weak var eqSlider4k: EffectsUnitSlider!
    @IBOutlet weak var eqSlider2k: EffectsUnitSlider!
    @IBOutlet weak var eqSlider32: EffectsUnitSlider!
    @IBOutlet weak var eqSlider512: EffectsUnitSlider!
    @IBOutlet weak var eqSlider256: EffectsUnitSlider!
    @IBOutlet weak var eqSlider128: EffectsUnitSlider!
    
    private var eqSliders: [EffectsUnitSlider] = []
    
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
    
    @IBOutlet weak var filterBassSlider: RangeSlider!
    @IBOutlet weak var filterMidSlider: RangeSlider!
    @IBOutlet weak var filterTrebleSlider: RangeSlider!
    
    @IBOutlet weak var lblFilterBassRange: NSTextField!
    @IBOutlet weak var lblFilterMidRange: NSTextField!
    @IBOutlet weak var lblFilterTrebleRange: NSTextField!
    
    // --------------------------------
    
    private var subPreviewViews: [NSView] = []
    
    @IBOutlet weak var subPreviewBox: NSBox!
    
    private var graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private lazy var preferencesDelegate: PreferencesDelegateProtocol = ObjectGraph.getPreferencesDelegate()
    private lazy var preferences: Preferences = ObjectGraph.getPreferencesDelegate().getPreferences()
    
    private var oldPresetName: String?
    
    override var nibName: String? {return "MasterPresetsEditor"}
    
    override func viewDidLoad() {
        
        subPreviewViews = [eqSubPreview, pitchSubPreview, timeSubPreview, reverbSubPreview, delaySubPreview, filterSubPreview]
        subPreviewViews.forEach({subPreviewBox.addSubview($0)})
        
        eqSliders = [eqSlider32, eqSlider64, eqSlider128, eqSlider256, eqSlider512, eqSlider1k, eqSlider2k, eqSlider4k, eqSlider8k, eqSlider16k]
        
        filterBassSlider.initialize(AppConstants.bass_min, AppConstants.bass_max, {
            (slider: RangeSlider) -> Void in
            // Do nothing
        })
        
        filterMidSlider.initialize(AppConstants.mid_min, AppConstants.mid_max, {
            (slider: RangeSlider) -> Void in
            // Do nothing
        })
        
        filterTrebleSlider.initialize(AppConstants.treble_min, AppConstants.treble_max, {
            (slider: RangeSlider) -> Void in
            // Do nothing
        })
        
        SyncMessenger.subscribe(actionTypes: [.reloadPresets, .applyEffectsPreset, .renameEffectsPreset, .deleteEffectsPresets], subscriber: self)
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        previewBox.isHidden = true
        
        // Show EQ sub preview by default
        subPreviewViews.forEach({$0.isHidden = true})
        eqSubPreview.isHidden = false
        subPreviewMenu.selectItem(withTitle: "EQ")
    }
    
    @IBAction func tableDoubleClickAction(_ sender: AnyObject) {
        applyPresetAction()
    }
    
    private func deleteSelectedPresetsAction() {
        
        let selection = getSelectedPresetNames()
        MasterPresets.deletePresets(selection)
        editorView.reloadData()
        
        previewBox.isHidden = true
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
        
        subPreviewViews.forEach({$0.isHidden = true})
        
        let selItem = subPreviewMenu.titleOfSelectedItem
        
        switch selItem {
            
        case "EQ": eqSubPreview.isHidden = false
            
        case "Pitch": pitchSubPreview.isHidden = false
            
        case "Time": timeSubPreview.isHidden = false
            
        case "Reverb": reverbSubPreview.isHidden = false
            
        case "Delay": delaySubPreview.isHidden = false
            
        case "Filter": filterSubPreview.isHidden = false
            
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
        
        previewBox.isHidden = false
    }
    
    private func renderEQPreview(_ preset: EQPreset) {
        
        let eqBands: [Int: Float] = preset.bands
        let globalGain: Float = preset.globalGain
        
        // Slider tag = index. Default gain value, if bands array doesn't contain gain for index, is 0
        eqSliders.forEach({
            $0.floatValue = eqBands[$0.tag] ?? 0
            $0.setUnitState(preset.state)
        })
        
        eqGlobalGainSlider.floatValue = globalGain
        eqGlobalGainSlider.setUnitState(preset.state)
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
        
        let bassBand = preset.bassBand
        filterBassSlider.start = Double(bassBand.lowerBound)
        filterBassSlider.end = Double(bassBand.upperBound)
        lblFilterBassRange.stringValue = ValueFormatter.formatFilterFrequencyRange(bassBand.lowerBound, bassBand.upperBound)
        
        let midBand = preset.midBand
        filterMidSlider.start = Double(midBand.lowerBound)
        filterMidSlider.end = Double(midBand.upperBound)
        lblFilterMidRange.stringValue = ValueFormatter.formatFilterFrequencyRange(midBand.lowerBound, midBand.upperBound)
        
        let trebleBand = preset.trebleBand
        filterTrebleSlider.start = Double(trebleBand.lowerBound)
        filterTrebleSlider.end = Double(trebleBand.upperBound)
        lblFilterTrebleRange.stringValue = ValueFormatter.formatFilterFrequencyRange(trebleBand.lowerBound, trebleBand.upperBound)
        
        [filterBassSlider, filterMidSlider, filterTrebleSlider].forEach({$0?.unitState = preset.state})
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return MasterPresets.countUserDefinedPresets()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows = editorView.numberOfSelectedRows
        
        previewBox.isHidden = numRows != 1
        
        if numRows == 1 {
            
            let presetName = getSelectedPresetNames()[0]
            renderPreview(MasterPresets.presetByName(presetName)!)
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
