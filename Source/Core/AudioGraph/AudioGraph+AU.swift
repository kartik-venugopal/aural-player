//
// AudioGraph+AU.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension AudioGraph {
    
    var audioUnitPresets: AudioUnitPresetsMap {
        engine.audioUnitPresets
    }
    
    var audioUnitsState: EffectsUnitState {
        engine.audioUnitsState
    }
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnit, index: Int)? {
        engine.addAudioUnit(ofType: type, andSubType: subType)
    }
    
    func removeAudioUnits(at indices: IndexSet) -> [HostedAudioUnitProtocol] {
        engine.removeAudioUnits(at: indices)
    }
}
