//
//  AudioGraph.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// The Audio Graph is one of the core components of the app and is responsible for all audio output. It serves as the infrastructure for playback,
/// effects, and visualization.
///
/// It encapsulates an audio engine implemented using the **AVAudioEngine** framework and manages a "graph" of nodes attached to that
/// engine. Each node in the graph performs a distinct function, such as playback, mixing, or an effect such as equalization or reverb. Each
/// node exposes configurable properties, eg. volume, playback rate, or equalizer band gain, that determine how the node manipulates audio.
/// For instance, when the user manipulates the volume slider in the player window, it modifies the volume property of the player node in the audio graph.
///
/// The nodes in the graph are connected so as to form a signal processing chain where audio is processed by a node and then
/// passed as input to the next node, which itself processes the audio, then passes it on to the next node, and so on, till the engine's output
/// node sends the audio to the audio output hardware device. So, the audio that is output by the app is a function of the cumulative audio
/// processing performed sequentially by each node in in the chain.
///
/// - SeeAlso: `AudioGraphProtocol`
///
class AudioGraph: AudioGraphProtocol, PersistentModelObject {
    
    let engine: AudioEngine
    let deviceManager: DeviceManager
    var soundProfiles: SoundProfiles
    
    lazy var messenger = Messenger(for: self)
    
    // Sets up the audio engine
    init(persistentState: AppPersistentState, audioUnitsManager: AudioUnitsManager) {
        
        let persistentState: AudioGraphPersistentState? = persistentState.audioGraph
        
        self.engine = AudioEngine(persistentState: persistentState, audioUnitsManager: audioUnitsManager)
        self.deviceManager = DeviceManager(outputAudioUnit: engine.outputNode.audioUnit!)
        self.soundProfiles = SoundProfiles(persistentState: persistentState?.soundProfiles)
        
        // Register self as an observer for notifications when the audio output device has changed (e.g. headphones)
        messenger.subscribe(to: .AVAudioEngineConfigurationChange, handler: outputDeviceChanged)
        startEngine()
        setInitialOutputDevice(persistentState: persistentState)
        
        captureSystemSoundProfile()
    }
    
    func tearDown() {
        stopEngine()
    }
    
    // MARK: Miscellaneous properties / functions ------------------------
    
    var settingsAsMasterPreset: MasterPreset {
        masterUnit.settingsAsPreset
    }

    var persistentState: AudioGraphPersistentState {
        
        AudioGraphPersistentState(outputDevice: AudioDevicePersistentState(name: outputDevice.name,
                                                                           uid: outputDevice.uid),
                                  volume: volume,
                                  muted: muted,
                                  pan: pan,
                                  masterUnit: (masterUnit as! MasterUnit).persistentState,
                                  eqUnit: (eqUnit as! EQUnit).persistentState,
                                  pitchShiftUnit: (pitchShiftUnit as! PitchShiftUnit).persistentState,
                                  timeStretchUnit: (timeStretchUnit as! TimeStretchUnit).persistentState,
                                  reverbUnit: (reverbUnit as! ReverbUnit).persistentState,
                                  delayUnit: (delayUnit as! DelayUnit).persistentState,
                                  filterUnit: (filterUnit as! FilterUnit).persistentState,
                                  replayGainUnit: (replayGainUnit as! ReplayGainUnit).persistentState,
                                  audioUnits: audioUnits.compactMap {($0 as? HostedAudioUnit)?.persistentState},
                                  audioUnitPresets: audioUnitPresets.persistentState,
                                  soundProfiles: soundProfiles.persistentState,
                                  replayGainAnalysisCache: replayGainScanner.persistentState)
        
    }
}
