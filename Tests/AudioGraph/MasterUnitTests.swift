//
//  MasterUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class MasterUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in [EffectsUnitState.active, EffectsUnitState.bypassed] {
            
            for _ in 1...1000 {
                
                let persistentState = MasterUnitPersistentState(state: unitState,
                                                                userPresets: randomMasterPresets())
                
                let eqType = randomEQType()
                let eqState = EQUnitPersistentState(state: .randomCase(),
                                                    userPresets: randomEQPresets(unitState: .active),
                                                    type: eqType, globalGain: randomEQGain(),
                                                    bands: randomEQBands(forType: eqType))
                
                let pitchState = PitchShiftUnitPersistentState(state: .randomCase(),
                                                               userPresets: randomPitchShiftPresets(unitState: .active),
                                                               pitch: randomPitch(), overlap: randomOverlap())
                
                let timeState = TimeStretchUnitPersistentState(state: .randomCase(),
                                                               userPresets: randomTimeStretchPresets(unitState: .active),
                                                               rate: randomTimeStretchRate(),
                                                               shiftPitch: randomTimeStretchShiftPitch(),
                                                               overlap: randomOverlap())
                
                let reverbState = ReverbUnitPersistentState(state: .randomCase(),
                                                            userPresets: randomReverbPresets(unitState: .active),
                                                            space: .randomCase(),
                                                            amount: randomReverbAmount())
                
                let delayState = DelayUnitPersistentState(state: .randomCase(),
                                                          userPresets: randomDelayPresets(unitState: .active),
                                                          amount: randomDelayAmount(),
                                                          time: randomDelayTime(),
                                                          feedback: randomDelayFeedback(),
                                                          lowPassCutoff: randomDelayLowPassCutoff())
                
                let filterState = FilterUnitPersistentState(state: .randomCase(),
                                                            userPresets: randomFilterPresets(unitState: .active),
                                                            bands: randomFilterBands())
                
//                let audioUnitsState = (0..<Int.random(in: 0..<5)).map {_ in AudioUnitPersistentState(state: .randomCase(), userPresets: randomAUPresets(), componentType: randomAUOSType(), componentSubType: randomAUOSType(), params: randomAUParams())}
                
                doTestInit(persistentState: persistentState,
                           eqState: eqState,
                           pitchState: pitchState,
                           timeState: timeState,
                           reverbState: reverbState,
                           delayState: delayState,
                           filterState: filterState)
            }
        }
    }
    
    private func doTestInit(persistentState: MasterUnitPersistentState,
                            eqState: EQUnitPersistentState,
                            pitchState: PitchShiftUnitPersistentState,
                            timeState: TimeStretchUnitPersistentState,
                            reverbState: ReverbUnitPersistentState,
                            delayState: DelayUnitPersistentState,
                            filterState: FilterUnitPersistentState) {
        
        let eqUnit = EQUnit(persistentState: eqState)
        let pitchShiftUnit = PitchShiftUnit(persistentState: pitchState)
        let timeStretchUnit = TimeStretchUnit(persistentState: timeState)
        let reverbUnit = ReverbUnit(persistentState: reverbState)
        let delayUnit = DelayUnit(persistentState: delayState)
        let filterUnit = FilterUnit(persistentState: filterState)
        
        let masterUnit = MasterUnit(persistentState: persistentState,
                                    nativeSlaveUnits: [eqUnit, pitchShiftUnit, timeStretchUnit,
                                                       reverbUnit, delayUnit, filterUnit], audioUnits: [])
        
//        validate(masterUnit, persistentState: persistentState)
    }
}
