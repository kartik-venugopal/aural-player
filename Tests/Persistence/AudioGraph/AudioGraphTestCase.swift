//
//  AudioGraphTestCase.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class AudioGraphTestCase: PersistenceTestCase {
    
    // MARK: Master unit --------------------------------------------
    
    func randomMasterPresets(count: Int? = nil) -> [MasterPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        if numPresets == 0 {return []}
        
        let eqPresets = randomEQPresets(count: numPresets).compactMap {EQPreset(persistentState: $0)}
        let pitchShiftPresets = randomPitchShiftPresets(count: numPresets).compactMap {PitchShiftPreset(persistentState: $0)}
        let timeStretchPresets = randomTimeStretchPresets(count: numPresets).compactMap {TimeStretchPreset(persistentState: $0)}
        let reverbPresets = randomReverbPresets(count: numPresets).compactMap {ReverbPreset(persistentState: $0)}
        let delayPresets = randomDelayPresets(count: numPresets).compactMap {DelayPreset(persistentState: $0)}
        let filterPresets = randomFilterPresets(count: numPresets).compactMap {FilterPreset(persistentState: $0)}
        
        return (0..<numPresets).map {index in
            
            let preset = MasterPreset(name: "preset-\(index + 1)", eq: eqPresets[index],
                                      pitch: pitchShiftPresets[index],
                                      time: timeStretchPresets[index],
                                      reverb: reverbPresets[index],
                                      delay: delayPresets[index],
                                      filter: filterPresets[index],
                                      systemDefined: false)
            
            return MasterPresetPersistentState(preset: preset)
        }
    }
    
    // MARK: EQ unit --------------------------------------------
    
    func validate(_ eqUnit: EQUnit, persistentState: EQUnitPersistentState) {
        
        XCTAssertEqual(eqUnit.state, persistentState.state)
        XCTAssertEqual(eqUnit.node.bypass, eqUnit.state != .active)
        XCTAssertEqual(eqUnit.node.activeNode.bypass, eqUnit.state != .active)
        
        XCTAssertEqual(eqUnit.node.type, persistentState.type!)
        XCTAssertEqual(eqUnit.type, persistentState.type!)
        
        XCTAssertEqual(eqUnit.node.activeNode.numberOfBands, persistentState.type! == .tenBand ? 10 : 15)
        
        XCTAssertEqual(eqUnit.globalGain, persistentState.globalGain!, accuracy: 0.001)
        XCTAssertEqual(eqUnit.node.activeNode.globalGain, persistentState.globalGain!, accuracy: 0.001)
        
        AssertEqual(eqUnit.bands, persistentState.bands!, accuracy: 0.001)
        AssertEqual(eqUnit.node.activeNode.bandGains, persistentState.bands!, accuracy: 0.001)
        
        let expectedPresets = Set(persistentState.userPresets!.map {EQPreset(persistentState: $0)})
        XCTAssertEqual(Set(eqUnit.presets.userDefinedPresets), expectedPresets)
    }
    
    func randomNillableEQPresets(unitState: EffectsUnitState? = nil) -> [EQPresetPersistentState]? {
        randomNillableValue {self.randomEQPresets(unitState: unitState)}
    }
    
    func randomEQPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [EQPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            EQPresetPersistentState(preset: EQPreset(name: "preset-\(index)", state: unitState ?? randomUnitState(),
                                                     bands: randomEQ15Bands(), globalGain: randomEQGlobalGain(),
                                                     systemDefined: false))
        }
    }
    
    func randomEQType() -> EQType {EQType.randomCase()}
    
    func randomNillableEQType() -> EQType? {
        randomNillableValue {self.randomEQType()}
    }
    
    func randomNillableEQGlobalGain() -> Float? {
        randomNillableValue {self.randomEQGlobalGain()}
    }
    
    func randomNillableEQ10Bands() -> [Float]? {
        randomNillableValue {self.randomEQ10Bands()}
    }
    
    func randomNillableEQ15Bands() -> [Float]? {
        randomNillableValue {self.randomEQ15Bands()}
    }
    
    let validEQGainRange: ClosedRange<Float> = -20...20
    
    func randomEQGlobalGain() -> Float {Float.random(in: validEQGainRange)}
    
    func randomEQ10Bands() -> [Float] {
        (0..<10).map {_ in Float.random(in: validEQGainRange)}
    }
    
    func randomEQ15Bands() -> [Float] {
        (0..<15).map {_ in Float.random(in: validEQGainRange)}
    }
    
    // MARK: Pitch Shift unit --------------------------------------------
    
    func validate(_ pitchShiftUnit: PitchShiftUnit, persistentState: PitchShiftUnitPersistentState) {
        
        XCTAssertEqual(pitchShiftUnit.state, persistentState.state)
        XCTAssertEqual(pitchShiftUnit.node.bypass, pitchShiftUnit.state != .active)
        
        XCTAssertEqual(pitchShiftUnit.pitch, persistentState.pitch!, accuracy: 0.001)
        XCTAssertEqual(pitchShiftUnit.node.pitch, persistentState.pitch!, accuracy: 0.001)
        
        XCTAssertEqual(pitchShiftUnit.overlap, persistentState.overlap!, accuracy: 0.001)
        XCTAssertEqual(pitchShiftUnit.node.overlap, persistentState.overlap!, accuracy: 0.001)
        
        let expectedPresets = Set(persistentState.userPresets!.map {PitchShiftPreset(persistentState: $0)})
        XCTAssertEqual(Set(pitchShiftUnit.presets.userDefinedPresets), expectedPresets)
    }
    
    func randomNillablePitchShiftPresets(unitState: EffectsUnitState? = nil) -> [PitchShiftPresetPersistentState]? {
        randomNillableValue {self.randomPitchShiftPresets(unitState: unitState)}
    }
    
    func randomPitchShiftPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [PitchShiftPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            PitchShiftPresetPersistentState(preset: PitchShiftPreset(name: "preset-\(index)", state: unitState ?? randomUnitState(),
                                                                     pitch: randomPitch(), overlap: randomOverlap(),
                                                                     systemDefined: false))
        }
    }
    
    func randomPitch() -> Float {Float.random(in: -2400...2400)}
    
    func randomNillablePitch() -> Float? {
        randomNillableValue {self.randomPitch()}
    }
    
    func randomPositivePitch() -> Float {Float.random(in: 0...2400)}
    
    func randomNegativePitch() -> Float {Float.random(in: -2400..<0)}
    
    func randomOverlap() -> Float {Float.random(in: 3...32)}
    
    func randomNillableOverlap() -> Float? {
        randomNillableValue {self.randomOverlap()}
    }
    
    // MARK: Time Stretch unit --------------------------------------------
    
    func validate(_ timeStretchUnit: TimeStretchUnit, persistentState: TimeStretchUnitPersistentState) {
        
        XCTAssertEqual(timeStretchUnit.state, persistentState.state)
        XCTAssertEqual(timeStretchUnit.node.bypass, timeStretchUnit.state != .active)
        
        XCTAssertEqual(timeStretchUnit.shiftPitch, persistentState.shiftPitch!)
        
        XCTAssertEqual(timeStretchUnit.node.varispeedNode.bypass, timeStretchUnit.state != .active || (!timeStretchUnit.shiftPitch))
        XCTAssertEqual(timeStretchUnit.node.timePitchNode.bypass, timeStretchUnit.state != .active || timeStretchUnit.shiftPitch)
        
        XCTAssertEqual(timeStretchUnit.rate, persistentState.rate!, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.rate, persistentState.rate!, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.varispeedNode.rate, persistentState.rate!, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.timePitchNode.rate, persistentState.rate!, accuracy: 0.001)
        
        XCTAssertEqual(timeStretchUnit.overlap, persistentState.overlap!, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.overlap, persistentState.overlap!, accuracy: 0.001)
        XCTAssertEqual(timeStretchUnit.node.timePitchNode.overlap, persistentState.overlap!, accuracy: 0.001)

        let expectedPresets = Set(persistentState.userPresets!.map {TimeStretchPreset(persistentState: $0)})
        XCTAssertEqual(Set(timeStretchUnit.presets.userDefinedPresets), expectedPresets)
    }
    
    func randomNillableTimeStretchPresets(unitState: EffectsUnitState? = nil) -> [TimeStretchPresetPersistentState]? {
        randomNillableValue {self.randomTimeStretchPresets(unitState: unitState)}
    }
    
    func randomTimeStretchPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [TimeStretchPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            TimeStretchPresetPersistentState(preset: TimeStretchPreset(name: "preset-\(index)", state: unitState ?? randomUnitState(),
                                                                       rate: randomTimeStretchRate(), overlap: randomOverlap(),
                                                                       shiftPitch: .random(), systemDefined: false))
        }
    }
    
    func randomTimeStretchRate() -> Float {Float.random(in: 0.25...4)}
    
    func randomNillableTimeStretchRate() -> Float? {
        randomNillableValue {self.randomTimeStretchRate()}
    }
    
    func randomTimeStretchShiftPitch() -> Bool {
        .random()
    }
    
    func randomNillableTimeStretchShiftPitch() -> Bool? {
        randomNillableValue {self.randomTimeStretchShiftPitch()}
    }
    
    // MARK: Reverb unit --------------------------------------------
    
    func validate(_ reverbUnit: ReverbUnit, persistentState: ReverbUnitPersistentState) {
        
        XCTAssertEqual(reverbUnit.state, persistentState.state)
        XCTAssertEqual(reverbUnit.node.bypass, reverbUnit.state != .active)
        
        XCTAssertEqual(reverbUnit.amount, persistentState.amount!, accuracy: 0.001)
        XCTAssertEqual(reverbUnit.node.wetDryMix, persistentState.amount!, accuracy: 0.001)
        
        XCTAssertEqual(reverbUnit.space, persistentState.space!)
        XCTAssertEqual(reverbUnit.avSpace, persistentState.space!.avPreset)

        let expectedPresets = Set(persistentState.userPresets!.map {ReverbPreset(persistentState: $0)})
        XCTAssertEqual(Set(reverbUnit.presets.userDefinedPresets), expectedPresets)
    }
    
    func randomNillableReverbPresets(unitState: EffectsUnitState? = nil) -> [ReverbPresetPersistentState]? {
        randomNillableValue {self.randomReverbPresets(unitState: unitState)}
    }
    
    func randomReverbPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [ReverbPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            ReverbPresetPersistentState(preset: ReverbPreset(name: "preset-\(index)", state: unitState ?? randomUnitState(),
                                                             space: randomReverbSpace(), amount: randomReverbAmount(),
                                                             systemDefined: false))
        }
    }
    
    func randomReverbSpace() -> ReverbSpaces {ReverbSpaces.randomCase()}
    
    func randomNillableReverbSpace() -> ReverbSpaces? {
        randomNillableValue {self.randomReverbSpace()}
    }
    
    func randomReverbAmount() -> Float {Float.random(in: 0...100)}
    
    func randomNillableReverbAmount() -> Float? {
        randomNillableValue {self.randomReverbAmount()}
    }
    
    // MARK: Delay unit --------------------------------------------
    
    func validate(_ delayUnit: DelayUnit, persistentState: DelayUnitPersistentState) {
        
        XCTAssertEqual(delayUnit.state, persistentState.state)
        XCTAssertEqual(delayUnit.node.bypass, delayUnit.state != .active)
        
        XCTAssertEqual(delayUnit.amount, persistentState.amount!, accuracy: 0.001)
        XCTAssertEqual(delayUnit.node.wetDryMix, persistentState.amount!, accuracy: 0.001)
        
        XCTAssertEqual(delayUnit.time, persistentState.time!, accuracy: 0.001)
        XCTAssertEqual(delayUnit.node.delayTime, persistentState.time!, accuracy: 0.001)
        
        XCTAssertEqual(delayUnit.feedback, persistentState.feedback!, accuracy: 0.001)
        XCTAssertEqual(delayUnit.node.feedback, persistentState.feedback!, accuracy: 0.001)
        
        XCTAssertEqual(delayUnit.lowPassCutoff, persistentState.lowPassCutoff!, accuracy: 0.001)
        XCTAssertEqual(delayUnit.node.lowPassCutoff, persistentState.lowPassCutoff!, accuracy: 0.001)

        let expectedPresets = Set(persistentState.userPresets!.map {DelayPreset(persistentState: $0)})
        XCTAssertEqual(Set(delayUnit.presets.userDefinedPresets), expectedPresets)
    }
    
    func randomNillableDelayPresets(unitState: EffectsUnitState? = nil) -> [DelayPresetPersistentState]? {
        randomNillableValue {self.randomDelayPresets(unitState: unitState)}
    }
    
    func randomDelayPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [DelayPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            DelayPresetPersistentState(preset: DelayPreset(name: "preset-\(index)", state: unitState ?? randomUnitState(),
                                                           amount: randomDelayAmount(), time: randomDelayTime(),
                                                           feedback: randomDelayFeedback(), cutoff: randomDelayLowPassCutoff(),
                                                           systemDefined: false))
        }
    }
    
    func randomDelayAmount() -> Float {Float.random(in: 0...100)}
    
    func randomNillableDelayAmount() -> Float? {
        randomNillableValue {self.randomDelayAmount()}
    }
    
    func randomDelayTime() -> Double {Double.random(in: 0...2)}
    
    func randomNillableDelayTime() -> Double? {
        randomNillableValue {self.randomDelayTime()}
    }
    
    func randomDelayFeedback() -> Float {Float.random(in: -100...100)}
    
    func randomNillableDelayFeedback() -> Float? {
        randomNillableValue {self.randomDelayFeedback()}
    }
    
    func randomDelayLowPassCutoff() -> Float {Float.random(in: 10...20000)}
    
    func randomNillableDelayLowPassCutoff() -> Float? {
        randomNillableValue {self.randomDelayLowPassCutoff()}
    }
    
    // MARK: Filter unit --------------------------------------------
    
    func validate(_ filterUnit: FilterUnit, persistentState: FilterUnitPersistentState) {
        
        XCTAssertEqual(filterUnit.state, persistentState.state)
        XCTAssertEqual(filterUnit.node.bypass, filterUnit.state != .active)
        
        let expectedBands: [FilterBand] = persistentState.bands!.compactMap {FilterBand(persistentState: $0)}
        
        XCTAssertEqual(filterUnit.bands, expectedBands)
        XCTAssertEqual(filterUnit.node.activeBands, expectedBands)
        
        for band in filterUnit.node.activeBands {
            
            let params = band.params!
            
            XCTAssertFalse(params.bypass)
            XCTAssertEqual(params.filterType, band.type.toAVFilterType())
            
            if params.filterType == .parametric {
                XCTAssertEqual(params.gain, FlexibleFilterNode.bandStopGain, accuracy: 0.001)
            }
            
            switch band.type {
            
            case .bandPass, .bandStop:
                
                let minFreq = band.minFreq!
                let maxFreq = band.maxFreq!
                
                // Frequency at the center of the band is the geometric mean of the min and max frequencies
                let centerFrequency = sqrt(minFreq * maxFreq)
                
                // Bandwidth in octaves is the log of the ratio of max to min
                // Ex: If min=200 and max=800, bandwidth = 2 octaves (200 to 400, and 400 to 800)
                let bandwidth = log2(maxFreq / minFreq)
                
                XCTAssertEqual(params.frequency, centerFrequency, accuracy: 0.001)
                XCTAssertEqual(params.bandwidth, bandwidth, accuracy: 0.001)
                
            case .lowPass:
                
                XCTAssertEqual(params.frequency, band.maxFreq!, accuracy: 0.001)
                
            case .highPass:
                
                XCTAssertEqual(params.frequency, band.minFreq!, accuracy: 0.001)
            }
        }

        let expectedPresets = Set(persistentState.userPresets!.map {FilterPreset(persistentState: $0)})
        XCTAssertEqual(Set(filterUnit.presets.userDefinedPresets), expectedPresets)
    }
    
    func randomFilterBandType() -> FilterBandType {FilterBandType.randomCase()}
    
    func randomFilterFrequency() -> Float {
        Float.random(in: SoundConstants.audibleRangeMin...SoundConstants.audibleRangeMax)
    }
    
    func randomFilterBands() -> [FilterBandPersistentState] {
        
        let numBands = Int.random(in: 1...10)
        return (0..<numBands).map {_ in
            
            let type = randomFilterBandType()
            
            switch type {
            
            case .bandStop:
                
                let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                
                return FilterBandPersistentState(band: FilterBand.bandStopBand(minFreq: minFreq, maxFreq: maxFreq))
                
            case .bandPass:
                
                let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                
                return FilterBandPersistentState(band: FilterBand.bandPassBand(minFreq: minFreq, maxFreq: maxFreq))
                
            case .lowPass:
                
                return FilterBandPersistentState(band: FilterBand.lowPassBand(maxFreq: randomFilterFrequency()))
                
            case .highPass:
                
                return FilterBandPersistentState(band: FilterBand.highPassBand(minFreq: randomFilterFrequency()))
            }
        }
    }
    
    func randomNillableFilterBands() -> [FilterBandPersistentState]? {
        randomNillableValue {self.randomFilterBands()}
    }
    
    func randomFilterPresets(count: Int? = nil, unitState: EffectsUnitState? = nil) -> [FilterPresetPersistentState] {
        
        let numPresets = count ?? Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in
            
            let numBands = Int.random(in: 1...10)
            let bands = (0..<numBands).map {(_: Int) -> FilterBand in
                
                let type = self.randomFilterBandType()
                
                switch type {
                
                case .bandStop:
                    
                    let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                    let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                    
                    return FilterBand.bandStopBand(minFreq: minFreq, maxFreq: maxFreq)
                    
                case .bandPass:
                    
                    let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                    let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                    
                    return FilterBand.bandPassBand(minFreq: minFreq, maxFreq: maxFreq)
                    
                case .lowPass:
                    
                    return FilterBand.lowPassBand(maxFreq: randomFilterFrequency())
                    
                case .highPass:
                    
                    return FilterBand.highPassBand(minFreq: randomFilterFrequency())
                }
            }
            
            return FilterPresetPersistentState(preset: FilterPreset(name: "preset-\(index)", state: unitState ?? randomUnitState(), bands: bands, systemDefined: false))
        }
    }
    
    func randomNillableFilterPresets(unitState: EffectsUnitState? = nil) -> [FilterPresetPersistentState]? {
        randomNillableValue {self.randomFilterPresets(unitState: unitState)}
    }
    
    // MARK: Audio Unit -------------------------------------------
    
    func randomNillableAUParams() -> [AudioUnitParameterPersistentState]? {
        randomNillableValue {self.randomAUParams()}
    }
    
    func randomAUParams() -> [AudioUnitParameterPersistentState] {
        
        let numParams = Int.random(in: 1...100)
        
        return (1...numParams).map {_ in
            AudioUnitParameterPersistentState(address: randomAUParamAddress(), value: randomAUParamValue())
        }
    }
    
    func randomAUParamAddress() -> UInt64 {
        UInt64.random(in: 1...UInt64.max)
    }
    
    func randomAUParamValue() -> Float {
        Float.random(in: -100000...100000)
    }

    func randomNillableAUOSType() -> OSType? {
        randomNillableValue {self.randomAUOSType()}
    }
    
    func randomAUOSType() -> OSType {
        OSType.random(in: OSType.min...OSType.max)
    }
    
    func randomAUPresetNumber() -> Int {
        Int.random(in: 0...Int.max)
    }
    
    func randomNillableAUPresets() -> [AudioUnitPresetPersistentState]? {
        randomNillableValue {self.randomAUPresets()}
    }
    
    func randomAUPresets() -> [AudioUnitPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (1...numPresets).map {index in

            AudioUnitPresetPersistentState(preset: AudioUnitPreset(name: "preset-\(index)", state: .active, systemDefined: false,
                                                                 componentType: randomAUOSType(),
                                                                 componentSubType: randomAUOSType(),
                                                                 number: randomAUPresetNumber()))
        }
    }
    
    // MARK: Audio Device -----------------------------------------
    
    func randomDeviceName() -> String {
        randomString(length: Int.random(in: 10...30))
    }
    
    func randomDeviceUID() -> String {
        UUID().uuidString
    }
    
    // MARK: Sound Profile ----------------------------------------
    
    func randomVolume() -> Float {
        Float.random(in: 0...1)
    }
    
    func randomBalance() -> Float {
        Float.random(in: -1...1)
    }
}
