//
//  ReplayGainUnit.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

class ReplayGainUnit: EffectsUnit, ReplayGainUnitProtocol {
    
    let node: ReplayGainNode
    let presets: EQPresets
    var currentPreset: EQPreset? = nil
    
    var mode: ReplayGainMode {
        
        didSet {
            parmsChanged()
        }
    }
    
    var replayGain: ReplayGain? {
        
        didSet {
            parmsChanged()
        }
    }
    
    private func parmsChanged() {
        
        let replayGainDB = mode == .trackGain ?
        (replayGain?.trackGain ?? replayGain?.albumGain) :
        (replayGain?.albumGain ?? replayGain?.trackGain)
        
        node.replayGain = replayGainDB ?? 0
    }
    
    var preAmp: Float {
        
        didSet {
            node.preAmp = preAmp
        }
    }
    
    init(persistentState: EQUnitPersistentState?) {
        
        node = ReplayGainNode()
        presets = EQPresets(persistentState: persistentState)
        mode = .trackGain
        preAmp = 0
        
        super.init(unitType: .replayGain, 
                   unitState: persistentState?.state ?? AudioGraphDefaults.replayGainState,
                   renderQuality: persistentState?.renderQuality)

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
    
    override var avNodes: [AVAudioNode] {[node]}
    
    override func savePreset(named presetName: String) {
        
//        let newPreset = EQPreset(name: presetName, state: .active, bands: bands, globalGain: globalGain, systemDefined: false)
//        presets.addObject(newPreset)
//        currentPreset = newPreset
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            
            applyPreset(preset)
            currentPreset = preset
        }
    }
    
    func applyPreset(_ preset: EQPreset) {
        
//        bands = preset.bands
//        globalGain = preset.globalGain
    }
    
    var settingsAsPreset: EQPreset {
        EQPreset(name: "eqSettings", state: state, bands: [], globalGain: globalGain, systemDefined: false)
    }
    
    private func invalidateCurrentPreset() {
        
        guard unitInitialized else {return}
        
        currentPreset = nil
        masterUnit.currentPreset = nil
    }
    
    func setCurrentPreset(byName presetName: String) {
        
        guard let matchingPreset = presets.object(named: presetName) else {return}
        
//        if matchingPreset.equalToOtherPreset(globalGain: self.globalGain, bands: self.bands) {
//            self.currentPreset = matchingPreset
//        }
    }
    
    private func presetsDeleted(_ presetNames: [String]) {
        
        // System-defined presets cannot be deleted.
        if let theCurrentPreset = currentPreset, theCurrentPreset.userDefined, presetNames.contains(theCurrentPreset.name) {
            currentPreset = nil
        }
    }
    
//    var persistentState: EQUnitPersistentState {
//
//        EQUnitPersistentState(state: state,
//                              userPresets: presets.userDefinedObjects.map {EQPresetPersistentState(preset: $0)},
//                              currentPresetName: currentPreset?.name,
//                              renderQuality: renderQualityPersistentState,
//                              globalGain: globalGain,
//                              bands: bands)
//    }
}
