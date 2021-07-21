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
    
    let node: ParametricEQ
    let presets: EQPresets
    
    init(persistentState: EQUnitPersistentState?) {
        
        node = ParametricEQ(type: persistentState?.type ?? AudioGraphDefaults.eqType)
        presets = EQPresets(persistentState: persistentState)
        super.init(unitType: .eq, unitState: persistentState?.state ?? AudioGraphDefaults.eqState)

        // TODO: Validate persistent bands array ... if not 10 or 15 values, fix it.
        bands = persistentState?.bands ?? AudioGraphDefaults.eqBands
        globalGain = persistentState?.globalGain ?? AudioGraphDefaults.eqGlobalGain
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    var type: EQType {
        
        get {node.type}
        
        set(newType) {
            
            if newType != node.type {
                node.type = newType
            }
        }
    }
    
    var globalGain: Float {
        
        get {node.globalGain}
        set {node.globalGain = newValue}
    }
    
    var bands: [Float] {
        
        get {node.bands}
        set(newBands) {node.bands = newBands}
    }
    
    override var avNodes: [AVAudioNode] {node.allNodes}
    
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
        presets.addPreset(EQPreset(presetName, .active, bands, globalGain, false))
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.preset(named: presetName) {
            applyPreset(preset)
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
        bands = preset.bands
        globalGain = preset.globalGain
    }
    
    var settingsAsPreset: EQPreset {
        EQPreset("eqSettings", state, bands, globalGain, false)
    }
    
    var persistentState: EQUnitPersistentState {

        EQUnitPersistentState(state: state,
                              userPresets: presets.userDefinedPresets.map {EQPresetPersistentState(preset: $0)},
                              type: type,
                              globalGain: globalGain,
                              bands: bands)
    }
}
