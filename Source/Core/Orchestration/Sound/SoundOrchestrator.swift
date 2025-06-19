//
// SoundOrchestrator.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class SoundOrchestrator: SoundOrchestratorProtocol {
    
    let engine: AudioEngine
    let deviceManager: DeviceManager
    let soundPreferences: SoundPreferences
    
    var uis: [SoundUI] = []
    
    init(persistentState: AudioGraphPersistentState?, soundPreferences: SoundPreferences) {
        
        self.engine = AudioEngine()
        self.deviceManager = DeviceManager(outputAudioUnit: engine.outputNode.audioUnit!)
        self.soundPreferences = soundPreferences
        
//        engine.start()
    }
    
    func registerUI(ui: any SoundUI) {
        
        if !uis.contains(where: {$0.id == ui.id}) {
            uis.append(ui)
        }
    }
    
    func deregisterUI(ui: any SoundUI) {
        uis.removeAll(where: {$0.id == ui.id})
    }
    
    var volume: Float {
        
        get {engine.volume * SoundUnits.uiVolumeFactor}
        
        set {
            engine.volume = (newValue * SoundUnits.volumeFactor).clamped(to: SoundUnits.volumeRange)
            for ui in uis {ui.volumeChanged(newVolume: volume, displayedVolume: displayedVolume, muted: muted)}
        }
    }
    
    var displayedVolume: String {
        ValueFormatter.formatVolume(volume)
    }
    
    func increaseVolume(inputMode: UserInputMode) {
        
        let delta = inputMode == .discrete ? soundPreferences.volumeDelta : soundPreferences.volumeDelta_continuous
        volume += delta
    }
    
    func decreaseVolume(inputMode: UserInputMode) {
        
        let delta = inputMode == .discrete ? soundPreferences.volumeDelta : soundPreferences.volumeDelta_continuous
        volume -= delta
    }
    
    var pan: Float {
        
        get {engine.pan * SoundUnits.uiPanFactor}
        
        set {
            engine.pan = (newValue * SoundUnits.panFactor).clamped(to: SoundUnits.panRange)
            for ui in uis {ui.panChanged(newPan: pan, displayedPan: displayedPan)}
        }
    }
    
    var displayedPan: String {
        ValueFormatter.formatPan(pan)
    }
    
    func panLeft() {
        pan -= soundPreferences.panDelta
    }
    
    func panRight() {
        pan += soundPreferences.panDelta
    }
    
    var muted: Bool {
        
        get {engine.muted}
        
        set {
            engine.muted = newValue
            for ui in uis {ui.mutedChanged(newMuted: muted, volume: volume, displayedVolume: displayedVolume)}
        }
    }
    
    func toggleMuted() {
        muted.toggle()
    }
    
    func tearDown() {
        engine.stop()
    }
}
