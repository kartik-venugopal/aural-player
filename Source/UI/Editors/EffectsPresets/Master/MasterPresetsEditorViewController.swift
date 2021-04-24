import Cocoa

class MasterPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
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
    @IBOutlet weak var bandsTable: NSTableView!
    @IBOutlet weak var tableViewDelegate: FilterBandsViewDelegate!
    
    private lazy var preferences: Preferences = ObjectGraph.preferences
    
    private let masterPresets: MasterPresets = ObjectGraph.audioGraphDelegate.masterUnit.presets
    
    override var nibName: String? {"MasterPresetsEditor"}
    
    var masterUnit: MasterUnitDelegateProtocol {graph.masterUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .master
        fxUnit = masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(masterPresets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        subPreviewViews = [masterSubPreview, eqSubPreview, pitchSubPreview, timeSubPreview, reverbSubPreview, delaySubPreview, filterSubPreview]
        subPreviewViews.forEach({subPreviewBox.addSubview($0)})
        
        eqSubPreview.chooseType(.tenBand)
        
        let bandsDataFunction = {[weak self] () -> [FilterBand] in self?.filterChartBands ?? []}
        filterSubPreview.initialize({[weak self] () -> EffectsUnitState in self?.presetFilterUnitState ?? .active}, bandsDataFunction, bandsDataSource, false)
        
        tableViewDelegate.dataSource = bandsDataSource
        tableViewDelegate.allowSelection = false
    }
    
    private var filterChartBands: [FilterBand] {
        
        let selection = selectedPresetNames
        return selection.isEmpty ? [] : masterPresets.presetByName(selection[0])?.filter.bands ?? []
    }
    
    private var presetFilterUnitState: EffectsUnitState {
        
        let selection = selectedPresetNames
        return selection.isEmpty ? .active : masterPresets.presetByName(selection[0])?.filter.state ?? .active
    }
    
    override func viewDidAppear() {
        
        super.viewDidAppear()
        
        // Show EQ sub preview by default
        subPreviewViews.forEach {$0.hide()}
        masterSubPreview.show()
        subPreviewMenu.selectItem(withTitle: "Master")
    }
    
    @IBAction func subPreviewMenuAction(_ sender: AnyObject) {
        
        subPreviewViews.forEach {$0.hide()}
        
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
        
        if let preset = masterPresets.presetByName(firstSelectedPresetName)?.eq {
            
            eqSubPreview.setUnitState(preset.state)
            eqSubPreview.typeChanged(preset.bands, preset.globalGain)
        }
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
        bandsTable.reloadData()
    }
    
    // MARK: View delegate functions
    
    override func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows: Int = editorView.numberOfSelectedRows
        previewBox.showIf(numRows == 1)
        
        if numRows == 1 {
            
            let presetName = firstSelectedPresetName
            if let masterPreset = masterPresets.presetByName(presetName) {

                bandsDataSource.preset = masterPreset.filter
                renderPreview(masterPreset)
            }
            
            oldPresetName = presetName
        }
        
        Messenger.publish(.presetsEditor_selectionChanged, payload: numRows)
    }
    
    // MARK: Text field delegate functions
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        
        super.controlTextDidEndEditing(obj)
        
        let newPresetName = (obj.object as! NSTextField).stringValue
        
        if masterPresets.presetWithNameExists(oldPresetName) {

            if StringUtils.isStringEmpty(newPresetName) {
            } else if masterPresets.presetWithNameExists(newPresetName) {
            } else {

                // Also update the sound preference, if the chosen preset was this edited one
                if preferences.soundPreferences.masterPresetOnStartup_name == oldPresetName {

                    preferences.soundPreferences.masterPresetOnStartup_name = newPresetName
                    preferences.persist()
                }
            }
        }
    }
}
