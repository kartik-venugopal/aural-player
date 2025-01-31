//
//  ReplayGainUnit.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
            
            if preventClipping {
                replayGain?.applyClippingPrevention(usingMaxPeakLevel: maxPeakLevel.decibels)
            }
            
            parmsChanged()
        }
    }
    
    var preAmp: Float {
        
        get {node.preAmp}
        set {node.preAmp = newValue}
    }
    
    var preventClipping: Bool {
        
        didSet {
            parmsChanged()
        }
    }
    
    var dataSource: ReplayGainDataSource
    
    var maxPeakLevel: ReplayGainMaxPeakLevel {
        
        didSet {
            
            if preventClipping {
                replayGain?.applyClippingPrevention(usingMaxPeakLevel: maxPeakLevel.decibels)
            }
            
            parmsChanged()
        }
    }
    
    private var computedTrackGain: Float? {
        
        preventClipping ?
        replayGain?.trackGainToPreventClipping ?? replayGain?.trackGain :
        replayGain?.trackGain
    }
    
    private var computedAlbumGain: Float? {
        
        preventClipping ?
        replayGain?.albumGainToPreventClipping ?? replayGain?.albumGain :
        replayGain?.albumGain
    }
    
    private func parmsChanged() {
        
        let replayGainDB: Float?
        
        lazy var albumGain = computedAlbumGain
        lazy var trackGain = computedTrackGain
        
        switch mode {
            
        case .preferAlbumGain:
            
            replayGainDB = albumGain ?? trackGain
            appliedGainType = albumGain != nil ? .albumGain : (trackGain != nil ? .trackGain : nil)
            
        case .preferTrackGain:
            
            replayGainDB = trackGain ?? albumGain
            appliedGainType = trackGain != nil ? .trackGain : (albumGain != nil ? .albumGain : nil)
            
        case .trackGainOnly:
            
            replayGainDB = trackGain
            appliedGainType = trackGain != nil ? .trackGain : nil
        }
        
        node.replayGain = replayGainDB ?? 0
    }
    
    var appliedGain: Float? {
        self.replayGain == nil ? nil : node.replayGain
    }
    
    private(set) var appliedGainType: ReplayGainType? = nil
    
    var effectiveGain: Float {
        node.globalGain
    }
    
    init(persistentState: ReplayGainUnitPersistentState?) {
        
        node = ReplayGainNode()
        node.preAmp = persistentState?.preAmp ?? AudioGraphDefaults.replayGainPreAmp

        mode = persistentState?.mode ?? AudioGraphDefaults.replayGainMode
        replayGain = nil
        preventClipping = persistentState?.preventClipping ?? AudioGraphDefaults.replayGainPreventClipping
        
        maxPeakLevel = persistentState?.maxPeakLevel ?? AudioGraphDefaults.replayGainMaxPeakLevel
        dataSource = persistentState?.dataSource ?? AudioGraphDefaults.replayGainDataSource
        
        presets = ReplayGainPresets(persistentState: persistentState)
        
        super.init(unitType: .replayGain, 
                   unitState: persistentState?.state ?? AudioGraphDefaults.replayGainState,
                   renderQuality: persistentState?.renderQuality)
        
        parmsChanged()

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
        
        let newPreset = ReplayGainPreset(name: presetName, state: .active,
                                         mode: mode, preAmp: preAmp, preventClipping: preventClipping,
                                         systemDefined: false)
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
        ReplayGainPreset(name: "replayGainSettings", state: state,
                         mode: mode, preAmp: preAmp, preventClipping: preventClipping,
                         systemDefined: false)
    }
    
    private func invalidateCurrentPreset() {
        
        guard unitInitialized else {return}
        
        currentPreset = nil
        masterUnit.currentPreset = nil
    }
    
    func setCurrentPreset(byName presetName: String) {
        
        guard let matchingPreset = presets.object(named: presetName) else {return}
        
        if matchingPreset.equalToOtherPreset(mode: mode, preAmp: preAmp, preventClipping: preventClipping) {
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
                                      preAmp: preAmp,
                                      preventClipping: preventClipping,
                                      dataSource: dataSource,
                                      maxPeakLevel: maxPeakLevel)
    }
}
