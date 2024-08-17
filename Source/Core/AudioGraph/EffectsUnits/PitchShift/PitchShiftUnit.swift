//
//  PitchShiftUnit.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// An effects unit that applies a "pitch shift" effect to an audio signal, i.e. changes the pitch of the signal.
///
/// - SeeAlso: `PitchShiftUnitProtocol`
///
class PitchShiftUnit: EffectsUnit, PitchShiftUnitProtocol {
    
    let node: AVAudioUnitTimePitch = AVAudioUnitTimePitch()
    let presets: PitchShiftPresets
    var currentPreset: PitchShiftPreset? = nil
    
    init(persistentState: PitchShiftUnitPersistentState?) {
        
        presets = PitchShiftPresets(persistentState: persistentState)
        super.init(unitType: .pitch, unitState: persistentState?.state ?? AudioGraphDefaults.pitchShiftState, renderQuality: persistentState?.renderQuality)
        
        node.pitch = persistentState?.pitch ?? AudioGraphDefaults.pitchShift
        
        if let currentPresetName = persistentState?.currentPresetName,
            let matchingPreset = presets.object(named: currentPresetName) {
            
            currentPreset = matchingPreset
        }
        
        presets.registerPresetDeletionCallback(presetsDeleted(_:))
        
        unitInitialized = true
    }
    
    override var avNodes: [AVAudioNode] {[node]}
    
    var pitch: Float {
        
        get {node.pitch}
        
        set {
            
            node.pitch = newValue
            invalidateCurrentPreset()
        }
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        node.bypass = !isActive
    }
    
    override func savePreset(named presetName: String) {
        
        let newPreset = PitchShiftPreset(name: presetName, state: .active, pitch: pitch, systemDefined: false)
        presets.addObject(newPreset)
        currentPreset = newPreset
    }

    override func applyPreset(named presetName: String) {

        if let preset = presets.object(named: presetName) {
            
            applyPreset(preset)
            currentPreset = preset
        }
    }
    
    func applyPreset(_ preset: PitchShiftPreset) {
        pitch = preset.pitch
    }
    
    var settingsAsPreset: PitchShiftPreset {
        PitchShiftPreset(name: "pitchSettings", state: state, pitch: pitch, systemDefined: false)
    }
    
    private func invalidateCurrentPreset() {
        
        guard unitInitialized else {return}
        
        currentPreset = nil
        masterUnit.currentPreset = nil
    }
    
    private func presetsDeleted(_ presetNames: [String]) {
        
        if let theCurrentPreset = currentPreset, theCurrentPreset.userDefined, presetNames.contains(theCurrentPreset.name) {
            currentPreset = nil
        }
    }
    
    func setCurrentPreset(byName presetName: String) {
        
        guard let matchingPreset = presets.object(named: presetName) else {return}
        
        if matchingPreset.equalToOtherPreset(pitch: self.pitch) {
            self.currentPreset = matchingPreset
        }
    }
    
    var persistentState: PitchShiftUnitPersistentState {
        
        PitchShiftUnitPersistentState(state: state,
                                      userPresets: presets.userDefinedObjects.map {PitchShiftPresetPersistentState(preset: $0)},
                                      currentPresetName: currentPreset?.name,
                                      renderQuality: renderQualityPersistentState,
                                      pitch: pitch)
    }
}
