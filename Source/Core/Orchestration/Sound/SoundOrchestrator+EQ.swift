//
// SoundOrchestrator+EQ.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension SoundOrchestrator {
    
    func initEngine(persistentState: AudioGraphPersistentState?) {
        
//        self.engine = AVAudioEngine()
//        self.audioUnitsRegistry = AudioUnitsRegistry()
//        
//        let volume = persistentState?.volume ?? AudioGraphDefaults.volume
//        let pan = persistentState?.pan ?? AudioGraphDefaults.pan
//        playerNode = AuralPlayerNode(volume: volume, pan: pan)
//        
//        let muted = persistentState?.muted ?? AudioGraphDefaults.muted
//        auxMixer = AVAudioMixerNode(muted: muted)
//        
//        outputNode = engine.outputNode
//        mainMixerNode = engine.mainMixerNode
//        
//        eqUnit = EQUnit()
//        pitchShiftUnit = PitchShiftUnit()
//        timeStretchUnit = TimeStretchUnit()
//        reverbUnit = ReverbUnit()
//        delayUnit = DelayUnit(persistentState: persistentState?.delayUnit)
//        filterUnit = FilterUnit(persistentState: persistentState?.filterUnit)
////        replayGainUnit = ReplayGainUnit(persistentState: persistentState?.replayGainUnit)
//        
//        audioUnitPresets = AudioUnitPresetsMap(persistentState: persistentState?.audioUnitPresets)
//        audioUnits = []
//        
//        for auState in persistentState?.audioUnits ?? [] {
//            
//            guard let componentType = auState.componentType,
//                  let componentSubType = auState.componentSubType,
//                  let component = audioUnitsManager.audioUnit(ofType: componentType,
//                                                              andSubType: componentSubType) else {continue}
//            
//            let presets = audioUnitPresets.getPresetsForAU(componentType: componentType, componentSubType: componentSubType)
//            audioUnits.append(HostedAudioUnit(forComponent: component, persistentState: auState, presets: presets))
//        }
//        
////        let nativeSlaveUnits = [eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit, replayGainUnit]
//        let nativeSlaveUnits = [eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit]
//        masterUnit = MasterUnit(nativeSlaveUnits: nativeSlaveUnits.compactMap {$0 as? EffectsUnit})
//        
//        self.permanentNodes = [playerNode, auxMixer] + (nativeSlaveUnits.flatMap {$0.avNodes})
//        self.removableNodes = audioUnits.flatMap {$0.avNodes}
        
//        setUpConnections()
//        messenger.subscribe(to: .Application.launched, handler: setUpMasterUnitStateObservation)
    }
    
    func initMaster(persistentState: MasterUnitPersistentState?, nativeSlaveUnits: [EffectsUnit], audioUnits: [HostedAudioUnit]) {
        
//        self.nativeSlaveUnits = nativeSlaveUnits
//        
//        eqUnit = nativeSlaveUnits.first(where: {$0 is EQUnit}) as! EQUnit
//        pitchShiftUnit = nativeSlaveUnits.first(where: {$0 is PitchShiftUnit}) as! PitchShiftUnit
//        timeStretchUnit = nativeSlaveUnits.first(where: {$0 is TimeStretchUnit}) as! TimeStretchUnit
//        reverbUnit = nativeSlaveUnits.first(where: {$0 is ReverbUnit}) as! ReverbUnit
//        delayUnit = nativeSlaveUnits.first(where: {$0 is DelayUnit}) as! DelayUnit
//        filterUnit = nativeSlaveUnits.first(where: {$0 is FilterUnit}) as! FilterUnit
//        
//        self.audioUnits = audioUnits
//        presets = MasterPresets(persistentState: persistentState)
//        
//        super.init(unitType: .master, unitState: persistentState?.state ?? AudioGraphDefaults.masterState)
    }
    
    func initEQ(persistentState: EQUnitPersistentState?) {
        
//        node = FifteenBandEQNode()
//        
//        presets = EQPresets(persistentState: persistentState)
//        super.init(unitType: .eq, unitState: persistentState?.state ?? AudioGraphDefaults.eqState, renderQuality: persistentState?.renderQuality)
//
//        bands = persistentState?.bands ?? AudioGraphDefaults.eqBands
//        globalGain = persistentState?.globalGain ?? AudioGraphDefaults.eqGlobalGain
    }
    
    func initPitch(persistentState: PitchShiftUnitPersistentState?) {
        
//        presets = PitchShiftPresets(persistentState: persistentState)
//        super.init(unitType: .pitch, unitState: persistentState?.state ?? AudioGraphDefaults.pitchShiftState, renderQuality: persistentState?.renderQuality)
//        
//        node.pitch = persistentState?.pitch ?? AudioGraphDefaults.pitchShift
    }
    
    func initTime(persistentState: TimeStretchUnitPersistentState?) {
        
//        presets = TimeStretchPresets(persistentState: persistentState)
//        super.init(unitType: .time, unitState: persistentState?.state ?? AudioGraphDefaults.timeStretchState, renderQuality: persistentState?.renderQuality)
//        
//        rate = persistentState?.rate ?? AudioGraphDefaults.timeStretchRate
//        shiftPitch = persistentState?.shiftPitch ?? AudioGraphDefaults.timeStretchShiftPitch
    }
    
    func initReverb(persistentState: ReverbUnitPersistentState?) {
        
//        avSpace = (persistentState?.space ?? AudioGraphDefaults.reverbSpace).avPreset
//        presets = ReverbPresets(persistentState: persistentState)
//        
//        super.init(unitType: .reverb, unitState: persistentState?.state ?? AudioGraphDefaults.reverbState, renderQuality: persistentState?.renderQuality)
//        
//        amount = persistentState?.amount ?? AudioGraphDefaults.reverbAmount
    }
    
    func initDelay(persistentState: DelayUnitPersistentState?) {
        
//        presets = DelayPresets(persistentState: persistentState)
//        super.init(unitType: .delay, unitState: persistentState?.state ?? AudioGraphDefaults.delayState, renderQuality: persistentState?.renderQuality)
//        
//        time = persistentState?.time ?? AudioGraphDefaults.delayTime
//        amount = persistentState?.amount ?? AudioGraphDefaults.delayAmount
//        feedback = persistentState?.feedback ?? AudioGraphDefaults.delayFeedback
//        lowPassCutoff = persistentState?.lowPassCutoff ?? AudioGraphDefaults.delayLowPassCutoff
    }
    
    func initFilter(persistentState: FilterUnitPersistentState?) {
        
//        self.node = FlexibleFilterNode()
//        
//        presets = FilterPresets(persistentState: persistentState)
//        super.init(unitType: .filter, unitState: persistentState?.state ?? AudioGraphDefaults.filterState, renderQuality: persistentState?.renderQuality)
//        
//        node.addBands((persistentState?.bands ?? []).compactMap {FilterBand(persistentState: $0)})
    }
}
