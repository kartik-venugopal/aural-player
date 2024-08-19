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
    let presets: ReplayGainPresets
    var currentPreset: ReplayGainPreset? = nil
    
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
        
        let replayGainDB: Float?
        
        switch mode {
            
        case .preferAlbumGain:
            replayGainDB = replayGain?.albumGain ?? replayGain?.trackGain
            
        case .preferTrackGain:
            replayGainDB = replayGain?.trackGain ?? replayGain?.albumGain
            
        case .trackGainOnly:
            replayGainDB = replayGain?.trackGain
        }
        
        node.replayGain = replayGainDB ?? 0
    }
    
    var preAmp: Float {
        
        didSet {
            node.preAmp = preAmp
        }
    }
    
    var appliedGain: Float {
        node.replayGain
    }
    
    var effectiveGain: Float {
        node.globalGain
    }
    
    init(persistentState: ReplayGainUnitPersistentState?) {
        
        node = ReplayGainNode()

        mode = persistentState?.mode ?? AudioGraphDefaults.replayGainMode
        replayGain = nil
        preAmp = persistentState?.preAmp ?? AudioGraphDefaults.replayGainPreAmp
        
        presets = ReplayGainPresets(persistentState: persistentState)
        
        super.init(unitType: .replayGain, 
                   unitState: persistentState?.state ?? AudioGraphDefaults.replayGainState,
                   renderQuality: persistentState?.renderQuality)
        
        parmsChanged()
        node.preAmp = preAmp

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
    
    override var avNodes: [AVAudioNode] {[node]}
    
    override func savePreset(named presetName: String) {
        
        let newPreset = ReplayGainPreset(name: presetName, state: .active, mode: mode, preAmp: preAmp, systemDefined: false)
        presets.addObject(newPreset)
        currentPreset = newPreset
    }
    
    override func applyPreset(named presetName: String) {
        
        if let preset = presets.object(named: presetName) {
            
            applyPreset(preset)
            currentPreset = preset
        }
    }
    
    func applyPreset(_ preset: ReplayGainPreset) {
        
        self.mode = preset.mode
        self.preAmp = preset.preAmp
    }
    
    var settingsAsPreset: ReplayGainPreset {
        ReplayGainPreset(name: "replayGainSettings", state: state, mode: mode, preAmp: preAmp, systemDefined: false)
    }
    
    private func invalidateCurrentPreset() {
        
        guard unitInitialized else {return}
        
        currentPreset = nil
        masterUnit.currentPreset = nil
    }
    
    func setCurrentPreset(byName presetName: String) {
        
        guard let matchingPreset = presets.object(named: presetName) else {return}
        
        if matchingPreset.equalToOtherPreset(mode: mode, preAmp: preAmp) {
            self.currentPreset = matchingPreset
        }
    }
    
    private func presetsDeleted(_ presetNames: [String]) {
        
        // System-defined presets cannot be deleted.
        if let theCurrentPreset = currentPreset, theCurrentPreset.userDefined, presetNames.contains(theCurrentPreset.name) {
            currentPreset = nil
        }
    }
    
    var persistentState: ReplayGainUnitPersistentState {

        ReplayGainUnitPersistentState(state: state,
                                      userPresets: presets.userDefinedObjects.map {ReplayGainPresetPersistentState(preset: $0)},
                                      currentPresetName: currentPreset?.name,
                                      renderQuality: renderQualityPersistentState,
                                      mode: mode,
                                      preAmp: preAmp)
    }
}
