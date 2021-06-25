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
    
    private let node: FlexibleFilterNode = FlexibleFilterNode()
    let presets: FilterPresets
    
    override var avNodes: [AVAudioNode] {return [node]}
    
    init(persistentState: FilterUnitPersistentState?) {
        
        presets = FilterPresets(persistentState: persistentState)
        super.init(.filter, persistentState?.state ?? AudioGraphDefaults.filterState)
        
        node.addBands((persistentState?.bands ?? []).map {FilterBand(persistentState: $0)})
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
    
    func removeBands(_ indexSet: IndexSet) {
        node.removeBands(indexSet)
    }
    
    func removeAllBands() {
        node.removeAllBands()
    }
    
    override func savePreset(_ presetName: String) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        var presetBands: [FilterBand] = []
        bands.forEach({presetBands.append($0.clone())})
        
        presets.addPreset(FilterPreset(presetName, .active, presetBands, false))
    }
    
    override func applyPreset(_ presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: FilterPreset) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        var filterBands: [FilterBand] = []
        preset.bands.forEach({filterBands.append($0.clone())})
        
        bands = filterBands
    }
    
    var settingsAsPreset: FilterPreset {
        FilterPreset("filterSettings", state, bands, false)
    }
    
    var persistentState: FilterUnitPersistentState {
        
        let filterState = FilterUnitPersistentState()
        
        filterState.state = state
        filterState.bands = bands.map {FilterBandPersistentState(band: $0)}
        filterState.userPresets = presets.userDefinedPresets.map {FilterPresetState(preset: $0)}
        
        return filterState
    }
}
