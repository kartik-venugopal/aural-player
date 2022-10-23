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
    var currentPreset: FilterPreset? = nil
    
    override var avNodes: [AVAudioNode] {[node]}
    
    init(persistentState: FilterUnitPersistentState?) {
        
        presets = FilterPresets(persistentState: persistentState)
        super.init(unitType: .filter, unitState: persistentState?.state ?? AudioGraphDefaults.filterState, renderQuality: persistentState?.renderQuality)
        
        node.addBands((persistentState?.bands ?? []).compactMap {FilterBand(persistentState: $0)})
        
        if let currentPresetName = persistentState?.currentPresetName,
            let matchingPreset = presets.object(named: currentPresetName) {
            
            currentPreset = matchingPreset
        }
        
        presets.registerPresetDeletionCallback(presetsDeleted(_:))
        
        unitInitialized = true
    }
    
    var bands: [FilterBand] {
        
        get {node.activeBands}
        
        set(newBands) {
            
            node.activeBands = newBands
            invalidateCurrentPreset()
        }
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    subscript(_ index: Int) -> FilterBand {
        
        get {node[index]}
        
        set(newBand) {
            
            node[index] = newBand
            invalidateCurrentPreset()
        }
    }
    
    func addBand(_ band: FilterBand) -> Int {
        
        invalidateCurrentPreset()
        return node.addBand(band)
    }
    
    func removeBand(at index: Int) {
        
        node.removeBands(atIndices: IndexSet([index]))
        invalidateCurrentPreset()
    }
    
    override func savePreset(named presetName: String) {
        
        // Need to clone the filter's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        let presetBands: [FilterBand] = bands.map {$0.clone()}
        let newPreset = FilterPreset(name: presetName, state: .active, bands: presetBands, systemDefined: false)
        presets.addObject(newPreset)
        currentPreset = newPreset
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            
            applyPreset(preset)
            currentPreset = preset
        }
    }
    
    func applyPreset(_ preset: FilterPreset) {
        
        // Need to clone the preset's bands to create separate identical copies so that changes to the current filter bands don't modify the preset's bands
        bands = preset.bands.map {$0.clone()}
        invalidateCurrentPreset()
    }
    
    var settingsAsPreset: FilterPreset {
        FilterPreset(name: "filterSettings", state: state, bands: bands, systemDefined: false)
    }
    
    private func invalidateCurrentPreset() {
        
        guard unitInitialized else {return}
        
        currentPreset = nil
        masterUnit.currentPreset = nil
    }
    
    private func presetsDeleted(_ presetNames: [String]) {
        
        if let theCurrentPreset = currentPreset, presetNames.contains(theCurrentPreset.name) {
            print("Preset '\(theCurrentPreset.name)' got deleted, invalidating current preset ...")
            currentPreset = nil
        }
    }
    
    var persistentState: FilterUnitPersistentState {
        
        FilterUnitPersistentState(state: state,
                                  userPresets: presets.userDefinedObjects.map {FilterPresetPersistentState(preset: $0)},
                                  currentPresetName: currentPreset?.name,
                                  renderQuality: renderQualityPersistentState,
                                  bands: bands.map {FilterBandPersistentState(band: $0)})
    }
}
