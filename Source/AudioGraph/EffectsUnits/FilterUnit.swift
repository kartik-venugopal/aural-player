//
//  FilterUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that eliminates certain frequencies from the input audio signal.
///
/// - SeeAlso: `FilterUnitProtocol`
///
class FilterUnit: EffectsUnit, FilterUnitProtocol {
    
    let node: FlexibleFilterNode = FlexibleFilterNode()
    let presets: FilterPresets
    
    override var avNodes: [AVAudioNode] {[node]}
    
    init(persistentState: FilterUnitPersistentState?) {
        
        presets = FilterPresets(persistentState: persistentState)
        super.init(unitType: .filter, unitState: persistentState?.state ?? AudioGraphDefaults.filterState)
        
        node.addBands((persistentState?.bands ?? []).compactMap {FilterBand(persistentState: $0)})
    }
    
    var bands: [FilterBand] {
        
        get {node.activeBands}
        set(newBands) {node.activeBands = newBands}
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    subscript(_ index: Int) -> FilterBand {
        
        get {node[index]}
        set(newBand) {node[index] = newBand}
    }
    
    func addBand(_ band: FilterBand) -> Int {
        return node.addBand(band)
    }
    
    func removeBand(at index: Int) {
        node.removeBands(atIndices: IndexSet([index]))
    }
    
    override func savePreset(named presetName: String) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        let presetBands: [FilterBand] = bands.map {$0.clone()}
        presets.addPreset(FilterPreset(name: presetName, state: .active, bands: presetBands, systemDefined: false))
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: FilterPreset) {
        
        // Need to clone the preset's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        bands = preset.bands.map {$0.clone()}
    }
    
    var settingsAsPreset: FilterPreset {
        FilterPreset(name: "filterSettings", state: state, bands: bands, systemDefined: false)
    }
    
    var persistentState: FilterUnitPersistentState {
        
        FilterUnitPersistentState(state: state,
                                  userPresets: presets.userDefinedPresets.map {FilterPresetPersistentState(preset: $0)},
                                  bands: bands.map {FilterBandPersistentState(band: $0)})
    }
}
