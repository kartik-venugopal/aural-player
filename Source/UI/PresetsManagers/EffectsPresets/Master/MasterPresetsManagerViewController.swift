//
//  MasterPresetsManagerViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MasterPresetsManagerViewController: EffectsPresetsManagerGenericViewController {
    
    @IBOutlet weak var subPreviewBox: NSBox!
    @IBOutlet weak var subPreviewMenu: NSPopUpButton!
    private var subPreviewViews: [NSView] = []
    
    @IBOutlet weak var masterSubPreview: MasterUnitView!
    @IBOutlet weak var eqSubPreview: EQUnitView!
    @IBOutlet weak var pitchSubPreview: PitchShiftUnitView!
    @IBOutlet weak var timeSubPreview: TimeStretchUnitView!
    @IBOutlet weak var reverbSubPreview: ReverbUnitView!
    @IBOutlet weak var delaySubPreview: DelayUnitView!

    @IBOutlet weak var filterSubPreview: FilterUnitView!
    private var bandsDataSource: PresetFilterBandsDataSource = PresetFilterBandsDataSource()
    @IBOutlet weak var bandsTable: NSTableView!
    @IBOutlet weak var tableViewDelegate: FilterBandsViewDelegate!
    
    private lazy var preferences: Preferences = objectGraph.preferences
    
    private let masterPresets: MasterPresets = objectGraph.audioGraphDelegate.masterUnit.presets
    
    private lazy var messenger = Messenger(for: self)
    
    override var nibName: String? {"MasterPresetsManager"}
    
    var masterUnit: MasterUnitDelegateProtocol {graph.masterUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .master
        effectsUnit = masterUnit
        presetsWrapper = PresetsWrapper<MasterPreset, MasterPresets>(masterPresets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        subPreviewViews = [masterSubPreview, eqSubPreview, pitchSubPreview, timeSubPreview, reverbSubPreview, delaySubPreview, filterSubPreview]
        subPreviewViews.forEach {subPreviewBox.addSubview($0)}
        
        eqSubPreview.chooseType(.tenBand)
        
        let bandsDataFunction = {[weak self] () -> [FilterBand] in self?.filterChartBands ?? []}
        filterSubPreview.initialize(stateFunction: {[weak self] in self?.presetFilterUnitState ?? .active}, bandsDataFunction: bandsDataFunction)
        
        tableViewDelegate.dataSource = bandsDataSource
        tableViewDelegate.allowSelection = false
    }
    
    private var filterChartBands: [FilterBand] {
        
        if let preset = firstSelectedPreset as? MasterPreset {
            return preset.filter.bands
        }
        
        return []
    }
    
    private var presetFilterUnitState: EffectsUnitState {
        
        if let preset = firstSelectedPreset {
            return masterPresets.preset(named: preset.name)?.state ?? .active
        }
        
        return .active
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
        
        if let firstSelectedPreset = self.firstSelectedPreset as? MasterPreset {
            
            let eqPreset = firstSelectedPreset.eq
            
            eqSubPreview.setUnitState(eqPreset.state)
            eqSubPreview.typeChanged(bands: eqPreset.bands, globalGain: eqPreset.globalGain)
        }
    }
    
    private func renderPreview(_ preset: MasterPreset) {
        
        masterSubPreview.applyPreset(preset)
        eqSubPreview.applyPreset(preset.eq)
        pitchSubPreview.applyPreset(preset.pitch)
        timeSubPreview.applyPreset(preset.time)
        reverbSubPreview.applyPreset(preset.reverb)
        delaySubPreview.applyPreset(preset.delay)
        
        filterSubPreview.refresh()
        bandsTable.reloadData()
    }
    
    override func deleteSelectedPresets() {
        
        // If there is a user-chosen master preset to be applied on app startup, and that preset
        // is being deleted, reset the user preference value.
        if let startupPreset = preferences.soundPreferences.masterPresetOnStartup_name {
            
            let selectedPresetNames = selectedPresets.map {$0.name}
            
            if selectedPresetNames.contains(startupPreset) {
                preferences.soundPreferences.masterPresetOnStartup_name = nil
            }
        }
        
        super.deleteSelectedPresets()
    }
    
    // MARK: View delegate functions
    
    override func tableViewSelectionDidChange(_ notification: Notification) {
        
        let numRows: Int = tableView.numberOfSelectedRows
        previewBox.showIf(numRows == 1)
        
        if numRows == 1, let masterPreset = firstSelectedPreset as? MasterPreset {
            
            bandsDataSource.preset = masterPreset.filter
            renderPreview(masterPreset)
        }
        
        messenger.publish(.presetsManager_selectionChanged, payload: numRows)
    }
    
    override func renamePreset(named name: String, to newName: String) {
        
        super.renamePreset(named: name, to: newName)
        
        // Also update the sound preference, if the chosen preset was this edited one
        if preferences.soundPreferences.masterPresetOnStartup_name == name {
            
            preferences.soundPreferences.masterPresetOnStartup_name = newName
            preferences.persist()
        }
    }
}
