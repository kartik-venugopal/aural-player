//
//  TimeStretchUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that applies a "time stretch" effect to an audio signal,
/// i.e. changes the playback rate of the signal. Optionally, the pitch of the input signal can also be
/// adjusted, thus syncing the pitch and playback rate.
///
/// - SeeAlso: `TimeUnitProtocol`
///
class TimeStretchUnit: EffectsUnit, TimeStretchUnitProtocol {
    
    let node: VariableRateNode = VariableRateNode()
    let presets: TimeStretchPresets
    var currentPreset: TimeStretchPreset? = nil
    
    init(persistentState: TimeStretchUnitPersistentState?) {
        
        presets = TimeStretchPresets(persistentState: persistentState)
        super.init(unitType: .time, unitState: persistentState?.state ?? AudioGraphDefaults.timeStretchState, renderQuality: persistentState?.renderQuality)
        
        rate = persistentState?.rate ?? AudioGraphDefaults.timeStretchRate
        shiftPitch = persistentState?.shiftPitch ?? AudioGraphDefaults.timeStretchShiftPitch
        
        if let currentPresetName = persistentState?.currentPresetName,
            let matchingPreset = presets.object(named: currentPresetName) {
            
            currentPreset = matchingPreset
        }
        
        presets.registerPresetDeletionCallback(presetsDeleted(_:))
        
        unitInitialized = true
    }
    
    override var avNodes: [AVAudioNode] {node.avNodes}

    var rate: Float {
        
        get {node.rate}
        
        set {
            
            node.rate = newValue
            invalidateCurrentPreset()
        }
    }
    
    var shiftPitch: Bool {
        
        get {node.shiftPitch}
        
        set {
            
            node.shiftPitch = newValue
            invalidateCurrentPreset()
        }
    }
    
    var pitch: Float {
        node.pitch
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(named presetName: String) {
        
        let newPreset = TimeStretchPreset(name: presetName, state: .active, rate: node.rate,
                                          shiftPitch: node.shiftPitch, systemDefined: false)
        presets.addObject(newPreset)
        currentPreset = newPreset
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            
            applyPreset(preset)
            currentPreset = preset
        }
    }
    
    func applyPreset(_ preset: TimeStretchPreset) {
        
        rate = preset.rate
        shiftPitch = preset.shiftPitch
    }
    
    var settingsAsPreset: TimeStretchPreset {
        
        TimeStretchPreset(name: "timeSettings", state: state, rate: rate,
                          shiftPitch: shiftPitch, systemDefined: false)
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
    
    var persistentState: TimeStretchUnitPersistentState {

        TimeStretchUnitPersistentState(state: state,
                                       userPresets: presets.userDefinedObjects.map {TimeStretchPresetPersistentState(preset: $0)},
                                       currentPresetName: currentPreset?.name,
                                       renderQuality: renderQualityPersistentState,
                                       rate: rate,
                                       shiftPitch: shiftPitch)
    }
}
