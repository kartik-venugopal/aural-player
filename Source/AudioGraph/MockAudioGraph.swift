//
//  MockAudioGraph.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
//import Cocoa
//import AVFoundation
//
///
/// Mock for **AudioGraph** to be used when debugging the application without actually starting an audio engine.
///
//class MockAudioGraph: AudioGraphProtocol, PersistentModelObject {
//
//    var _state: AudioGraphState
//    
//    // Effects units
//    var masterUnit: MasterUnit
//    var eqUnit: EQUnit
//    var pitchShiftUnit: PitchUnit
//    var timeStretchUnit: TimeUnit
//    var reverbUnit: ReverbUnit
//    var delayUnit: DelayUnit
//    var filterUnit: FilterUnit
//    
//    var availableDevices: [AudioDevice] {
//        return []
//    }
//    
//    var systemDevice: AudioDevice {
//        return AudioDevice(deviceID: AudioDeviceID(0))
//    }
//    
//    var outputDevice: AudioDevice {
//        
//        get {AudioDevice(deviceID: AudioDeviceID(0))}
//        set {}
//    }
//    
//    var playerNode: AuralPlayerNode
//    
//    var soundProfiles: SoundProfiles
//    
//    // Sound setting value holders
//    private var playerVolume: Float
//    
//    // Sets up the audio engine
//    init(_ state: AudioGraphState) {
//        
//        playerNode = AuralPlayerNode(useLegacyAPI: true)
//        
//        soundProfiles = SoundProfiles()
//        _state = state
//        
//        playerVolume = state.volume
//        muted = state.muted
//        playerNode.volume = muted ? 0 : playerVolume
//        playerNode.pan = state.pan
//        
//        eqUnit = EQUnit(state)
//        pitchShiftUnit = PitchUnit(state)
//        timeStretchUnit = TimeUnit(state)
//        reverbUnit = ReverbUnit(state)
//        delayUnit = DelayUnit(state)
//        filterUnit = FilterUnit(state)
//        
//        let slaveUnits = [eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit]
//        masterUnit = MasterUnit(state, slaveUnits)
//        
//        state.soundProfiles.forEach {
//            soundProfiles.add($0.file, $0)
//        }
//    }
//    
//    var volume: Float {
//        
//        get {playerVolume}
//        
//        set {
//            playerVolume = newValue
//            if !muted {playerNode.volume = newValue}
//        }
//    }
//    
//    var pan: Float {
//        
//        get {playerNode.pan}
//        set {playerNode.pan = newValue}
//    }
//    
//    var muted: Bool {
//        didSet {playerNode.volume = muted ? 0 : playerVolume}
//    }
//    
//    var settingsAsMasterPreset: MasterPreset {
//        return MasterUnit(_state, []).settingsAsPreset
//    }
//
//    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
//    }
//    
//    // MARK: Miscellaneous functions
//    
//    func clearSoundTails() {
//    }
//    
//    var persistentState: PersistentState {
//        
//        let state: AudioGraphState = AudioGraphState()
//        
//        // Volume and pan
//        state.volume = playerVolume
//        state.muted = muted
//        state.pan = playerNode.pan
//        
//        state.masterUnit = masterUnit.persistentState
//        state.eqUnit = eqUnit.persistentState
//        state.pitchShiftUnit = pitchShiftUnit.persistentState
//        state.timeStretchUnit = timeStretchUnit.persistentState
//        state.reverbUnit = reverbUnit.persistentState
//        state.delayUnit = delayUnit.persistentState
//        state.filterUnit = filterUnit.persistentState
//        
//        state.soundProfiles.append(contentsOf: soundProfiles.all())
//        
//        return state
//    }
//    
//    func restartAudioEngine() {
//    }
//    
//    func tearDown() {
//    }
//}
