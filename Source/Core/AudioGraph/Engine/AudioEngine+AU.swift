//
// AudioEngine+AU.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension AudioEngine {
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnit, index: Int)? {
        
        guard let auComponent = audioUnitsManager.audioUnit(ofType: type, andSubType: subType) else {return nil}
        
        let newUnit: HostedAudioUnit = HostedAudioUnit(forComponent: auComponent,
                                                       presets: audioUnitPresets.getPresetsForAU(componentType: type, componentSubType: subType))
        
        audioUnits.append(newUnit)
        masterUnit.addAudioUnit(newUnit)
        
        let context = AudioGraphChangeContext()
        messenger.publish(PreAudioGraphChangeNotification(context: context))
        insertNode(newUnit.avNodes[0])
        messenger.publish(AudioGraphChangedNotification(context: context))
        
        return (audioUnit: newUnit, index: audioUnits.lastIndex)
    }
    
    func removeAudioUnits(at indices: IndexSet) {
        
        let descendingIndices = indices.sortedDescending()
        descendingIndices.forEach {audioUnits.remove(at: $0)}
        
        masterUnit.removeAudioUnits(at: descendingIndices)
        
        let context = AudioGraphChangeContext()
        messenger.publish(PreAudioGraphChangeNotification(context: context))
        removeNodes(at: descendingIndices)
        messenger.publish(AudioGraphChangedNotification(context: context))
    }
    
    var audioUnitsState: EffectsUnitState {
        
        for unit in audioUnits {
        
            if unit.state == .active {
                return .active
            }
            
            if unit.state == .suppressed {
                return .suppressed
            }
        }
        
        return .bypassed
    }
}
