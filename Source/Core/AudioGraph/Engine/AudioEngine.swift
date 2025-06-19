//
//  AudioEngine.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Encapsulates an **AVAudioEngine** and provides convenient audio engine lifecycle functions.
/// It also provides functions to add or remove audio processing nodes and manage their connections
/// to each other.
///
class AudioEngine {
    
    let engine: AVAudioEngine
    let audioUnitsRegistry: AudioUnitsRegistry
    
    let playerNode: AuralPlayerNode
    let auxMixer: AVAudioMixerNode  // Used for conversions of sample rates / channel counts
    let outputNode: AVAudioOutputNode
    let mainMixerNode: AVAudioMixerNode
    
    // Effects units
    var masterUnit: MasterUnitProtocol
    var eqUnit: EQUnitProtocol
    var pitchShiftUnit: PitchShiftUnitProtocol
    var timeStretchUnit: TimeStretchUnitProtocol
    var reverbUnit: ReverbUnitProtocol
    var delayUnit: DelayUnitProtocol
    var filterUnit: FilterUnitProtocol
//    var replayGainUnit: ReplayGainUnitProtocol
    var audioUnits: [HostedAudioUnitProtocol]
    
    var allUnits: [any EffectsUnitProtocol] {
//        [masterUnit, eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit, replayGainUnit] + audioUnits
        [masterUnit, eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit] + audioUnits
    }
    
    var allNodes: [AVAudioNode] {
        permanentNodes + removableNodes
    }
    
    var audioUnitPresets: AudioUnitPresetsMap
    
    var permanentNodes: [AVAudioNode] = []
    var removableNodes: [AVAudioNode] = []
    
    lazy var messenger = Messenger(for: self)
    
    init(persistentState: AudioGraphPersistentState?) {
        
        self.engine = AVAudioEngine()
        self.audioUnitsRegistry = AudioUnitsRegistry()
        
        let volume = persistentState?.volume ?? AudioGraphDefaults.volume
        let pan = persistentState?.pan ?? AudioGraphDefaults.pan
        playerNode = AuralPlayerNode(volume: volume, pan: pan)
        
        let muted = persistentState?.muted ?? AudioGraphDefaults.muted
        auxMixer = AVAudioMixerNode(muted: muted)
        
        outputNode = engine.outputNode
        mainMixerNode = engine.mainMixerNode
        
        eqUnit = EQUnit(persistentState: persistentState?.eqUnit)
        pitchShiftUnit = PitchShiftUnit(persistentState: persistentState?.pitchShiftUnit)
        timeStretchUnit = TimeStretchUnit(persistentState: persistentState?.timeStretchUnit)
        reverbUnit = ReverbUnit(persistentState: persistentState?.reverbUnit)
        delayUnit = DelayUnit(persistentState: persistentState?.delayUnit)
        filterUnit = FilterUnit(persistentState: persistentState?.filterUnit)
//        replayGainUnit = ReplayGainUnit(persistentState: persistentState?.replayGainUnit)
        
        audioUnitPresets = AudioUnitPresetsMap(persistentState: persistentState?.audioUnitPresets)
        audioUnits = []
        
        for auState in persistentState?.audioUnits ?? [] {
            
            guard let componentType = auState.componentType,
                  let componentSubType = auState.componentSubType,
                  let component = audioUnitsManager.audioUnit(ofType: componentType,
                                                              andSubType: componentSubType) else {continue}
            
            let presets = audioUnitPresets.getPresetsForAU(componentType: componentType, componentSubType: componentSubType)
            audioUnits.append(HostedAudioUnit(forComponent: component, persistentState: auState, presets: presets))
        }
        
//        let nativeSlaveUnits = [eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit, replayGainUnit]
        let nativeSlaveUnits = [eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit]
        masterUnit = MasterUnit(persistentState: persistentState?.masterUnit,
                                nativeSlaveUnits: nativeSlaveUnits.compactMap {$0 as? EffectsUnit},
                                audioUnits: audioUnits.compactMap {$0 as? HostedAudioUnit})
        
        self.permanentNodes = [playerNode, auxMixer] + (nativeSlaveUnits.flatMap {$0.avNodes})
        self.removableNodes = audioUnits.flatMap {$0.avNodes}
        
        setUpConnections()
        messenger.subscribe(to: .Application.launched, handler: setUpMasterUnitStateObservation)
    }
    
    // Connects all nodes in sequence.
    private func setUpConnections() {
        
        let allNodes = self.allNodes
        
        // Attach and connect the nodes, forming a chain.
        
        allNodes.forEach {engine.attach($0)}
        
        var input: AVAudioNode, output: AVAudioNode
        
        for i in 0...(allNodes.count - 2) {
            
            input = allNodes[i]
            output = allNodes[i + 1]
            
            engine.connect(input, to: output, format: nil)
        }
        
        // Connect last node to main mixer
        engine.connect(allNodes.last!, to: mainMixerNode, format: nil)
    }
    
    private func setUpMasterUnitStateObservation() {
        
        let masterUnit = self.masterUnit as! MasterUnit
        
        for unit in masterUnit.nativeSlaveUnits {
            fxUnitStateObserverRegistry.registerObserver(masterUnit, forFXUnit: unit, setInitialValue: false)
        }
    }
}
