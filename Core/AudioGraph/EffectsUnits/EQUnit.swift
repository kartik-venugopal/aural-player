//
//  EQUnit.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An Equalizer effects unit that controls the volume of sound in
/// different frequency bands. So, it can emphasize or suppress bass (low frequencies),
/// vocals (mid frequencies), or treble (high frequencies).
///
/// - SeeAlso: `EQUnitProtocol`
///
class EQUnit: EffectsUnit, EQUnitProtocol {
    
    let node: ParametricEQNode
    let presets: EQPresets
    var currentPreset: EQPreset? = nil
    
    init(persistentState: EQUnitPersistentState?) {
        
        #if os(macOS)
        node = FifteenBandEQNode()
        #elseif os(iOS)
        node = TenBandEQNode()
        #endif
        
        presets = EQPresets(persistentState: persistentState)
        super.init(unitType: .eq, unitState: persistentState?.state ?? AudioGraphDefaults.eqState, renderQuality: persistentState?.renderQuality)

        // TODO: Validate persistent bands array ... if not 10 or 15 values, fix it.
        bands = persistentState?.bands ?? AudioGraphDefaults.eqBands
        globalGain = persistentState?.globalGain ?? AudioGraphDefaults.eqGlobalGain
        
        if let currentPresetName = persistentState?.currentPresetName,
            let matchingPreset = presets.object(named: currentPresetName) {
            
            currentPreset = matchingPreset
        }
        
        presets.registerPresetDeletionCallback(presetsDeleted(_:))
        
        unitInitialized = true
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    var globalGain: Float {
        
        get {node.globalGain}
        
        set {
            node.globalGain = newValue
            invalidateCurrentPreset()
        }
    }
    
    var bands: [Float] {
        
        get {node.bandGains}
        
        set(newBands) {
            node.bandGains = newBands
            invalidateCurrentPreset()
        }
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    subscript(_ index: Int) -> Float {
        
        get {node[index]}
        
        set {
            node[index] = newValue
            invalidateCurrentPreset()
        }
    }
    
    func increaseBass(by increment: Float) -> [Float] {
        
        invalidateCurrentPreset()
        return node.increaseBass(by: increment)
    }
    
    func decreaseBass(by decrement: Float) -> [Float] {
        
        invalidateCurrentPreset()
        return node.decreaseBass(by: decrement)
    }
    
    func increaseMids(by increment: Float) -> [Float] {
        
        invalidateCurrentPreset()
        return node.increaseMids(by: increment)
    }
    
    func decreaseMids(by decrement: Float) -> [Float] {
        
        invalidateCurrentPreset()
        return node.decreaseMids(by: decrement)
    }
    
    func increaseTreble(by increment: Float) -> [Float] {
        
        invalidateCurrentPreset()
        return node.increaseTreble(by: increment)
    }
    
    func decreaseTreble(by decrement: Float) -> [Float] {
        
        invalidateCurrentPreset()
        return node.decreaseTreble(by: decrement)
    }
    
    override func savePreset(named presetName: String) {
        
        let newPreset = EQPreset(name: presetName, state: .active, bands: bands, globalGain: globalGain, systemDefined: false)
        presets.addObject(newPreset)
        currentPreset = newPreset
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            
            applyPreset(preset)
            currentPreset = preset
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        bands = preset.bands
        globalGain = preset.globalGain
    }
    
    var settingsAsPreset: EQPreset {
        EQPreset(name: "eqSettings", state: state, bands: bands, globalGain: globalGain, systemDefined: false)
    }
    
    private func invalidateCurrentPreset() {
        
        guard unitInitialized else {return}
        
        currentPreset = nil
        masterUnit.currentPreset = nil
    }
    
    func setCurrentPreset(byName presetName: String) {
        
        guard let matchingPreset = presets.object(named: presetName) else {return}
        
        if matchingPreset.equalToOtherPreset(globalGain: self.globalGain, bands: self.bands) {
            self.currentPreset = matchingPreset
        }
    }
    
    private func presetsDeleted(_ presetNames: [String]) {
        
        // System-defined presets cannot be deleted.
        if let theCurrentPreset = currentPreset, theCurrentPreset.userDefined, presetNames.contains(theCurrentPreset.name) {
            currentPreset = nil
        }
    }
    
    var persistentState: EQUnitPersistentState {

        EQUnitPersistentState(state: state,
                              userPresets: presets.userDefinedObjects.map {EQPresetPersistentState(preset: $0)},
                              currentPresetName: currentPreset?.name,
                              renderQuality: renderQualityPersistentState,
                              globalGain: globalGain,
                              bands: bands)
    }
}
