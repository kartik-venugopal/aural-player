//
// AudioGraph+Engine.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AVFoundation

extension AudioGraph {
    
    var masterUnit: MasterUnitProtocol {
        engine.masterUnit
    }
    
    var eqUnit: EQUnitProtocol {
        engine.eqUnit
    }
    
    var pitchShiftUnit: PitchShiftUnitProtocol {
        engine.pitchShiftUnit
    }
    
    var timeStretchUnit: TimeStretchUnitProtocol {
        engine.timeStretchUnit
    }
    
    var reverbUnit: ReverbUnitProtocol {
        engine.reverbUnit
    }
    
    var delayUnit: DelayUnitProtocol {
        engine.delayUnit
    }
    
    var filterUnit: FilterUnitProtocol {
        engine.filterUnit
    }
    
//    var replayGainUnit: ReplayGainUnitProtocol {
//        engine.replayGainUnit
//    }
    
    var audioUnits: [HostedAudioUnitProtocol] {
        engine.audioUnits
    }
    
    var allUnits: [any EffectsUnitProtocol] {
        engine.allUnits
    }
    
    var playerNode: AuralPlayerNode {
        engine.playerNode
    }
    
    var auxMixer: AVAudioMixerNode {
        engine.auxMixer
    }
    
    var outputNode: AVAudioOutputNode {
        engine.outputNode
    }
    
    var playerOutputFormat: AVAudioFormat {
        engine.playerOutputFormat
    }
    
    func reconnectPlayerNode(withFormat format: AVAudioFormat) {
        engine.reconnectPlayerNode(withFormat: format)
    }
    
    func clearSoundTails() {
        engine.clearSoundTails()
    }
    
    func startEngine() {
        engine.start()
    }
    
    func stopEngine() {
        engine.stop()
    }
}
