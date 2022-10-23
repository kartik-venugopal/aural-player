//
//  EQUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    var currentPreset: EQPreset?
    
    init(persistentState: EQUnitPersistentState?) {
        
        node = FifteenBandEQNode()
        presets = EQPresets(persistentState: persistentState)
        
        super.init(unitType: .eq, unitState: persistentState?.state ?? AudioGraphDefaults.eqState)

        bands = persistentState?.bands ?? AudioGraphDefaults.eqBands
        globalGain = persistentState?.globalGain ?? AudioGraphDefaults.eqGlobalGain
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    var globalGain: Float {
        
        get {node.globalGain}
        set {node.globalGain = newValue}
    }
    
    var bands: [Float] {
        
        get {node.bandGains}
        set(newBands) {node.bandGains = newBands}
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    subscript(_ index: Int) -> Float {
        
        get {node[index]}
        set {node[index] = newValue}
    }
    
    func increaseBass(by increment: Float) -> [Float] {
        return node.increaseBass(by: increment)
    }
    
    func decreaseBass(by decrement: Float) -> [Float] {
        return node.decreaseBass(by: decrement)
    }
    
    func increaseMids(by increment: Float) -> [Float] {
        return node.increaseMids(by: increment)
    }
    
    func decreaseMids(by decrement: Float) -> [Float] {
        return node.decreaseMids(by: decrement)
    }
    
    func increaseTreble(by increment: Float) -> [Float] {
        return node.increaseTreble(by: increment)
    }
    
    func decreaseTreble(by decrement: Float) -> [Float] {
        return node.decreaseTreble(by: decrement)
    }
    
    override func savePreset(named presetName: String) {
        presets.addObject(EQPreset(name: presetName, state: .active, bands: bands, globalGain: globalGain, systemDefined: false))
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        bands = preset.bands
        globalGain = preset.globalGain
    }
    
    var settingsAsPreset: EQPreset {
        EQPreset(name: "eqSettings", state: state, bands: bands, globalGain: globalGain, systemDefined: false)
    }
    
    var persistentState: EQUnitPersistentState {

        EQUnitPersistentState(state: state,
                              userPresets: presets.userDefinedObjects.map {EQPresetPersistentState(preset: $0)},
                              renderQuality: renderQualityPersistentState,
                              globalGain: globalGain,
                              bands: bands)
    }
}
