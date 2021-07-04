//
//  FilterUnitPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FilterUnitPersistenceTests: PersistenceTestCase {
    
    // MARK: init() tests -------------------------------------------
    
    func testInit_defaultSettings() {
        
        doTestInit(unitState: AudioGraphDefaults.filterState, userPresets: [],
                   bands: [])
    }
    
    func testInit_noValuesAvailable() {
        doTestInit(unitState: nil, userPresets: nil, bands: nil)
    }
    
    func testInit_someValuesAvailable() {
        
        for state in EffectsUnitState.allCases {
            
            doTestInit(unitState: state, userPresets: randomNillablePresets(),
                       bands: randomNillableBands())
        }
        
        for _ in 0..<100 {
            
            doTestInit(unitState: randomNillableUnitState(), userPresets: randomNillablePresets(),
                       bands: randomNillableBands())
        }
    }
    
    func testInit() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestInit(unitState: state, userPresets: randomPresets(),
                           bands: randomBands())
            }
        }
    }
    
    private func doTestInit(unitState: EffectsUnitState?, userPresets: [FilterPresetPersistentState]?,
                            bands: [FilterBandPersistentState]?) {
        
        let dict = NSMutableDictionary()
        
        dict["state"] = unitState?.rawValue
        dict["userPresets"] = userPresets == nil ? nil : NSArray(array: userPresets!.map {JSONMapper.map($0)})
        
        dict["bands"] = bands == nil ? nil : NSArray(array: bands!.map {JSONMapper.map($0)})
        
        let optionalPersistentState = FilterUnitPersistentState(dict)
        
        guard let persistentState = optionalPersistentState else {
            
            XCTFail("persistentState is nil, deserialization of FilterUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: persistentState, unitState: unitState,
                                userPresets: userPresets, bands: bands)
    }
    
    // MARK: Persistence tests -------------------------------------------
    
    func testPersistence() {
        
        for state in EffectsUnitState.allCases {
            
            for _ in 0..<100 {
                
                doTestPersistence(unitState: state, userPresets: randomPresets(),
                           bands: randomBands())
            }
        }
    }
    
    private func doTestPersistence(unitState: EffectsUnitState, userPresets: [FilterPresetPersistentState],
                            bands: [FilterBandPersistentState]) {
        
        defer {persistentStateFile.delete()}
        
        let serializedState = FilterUnitPersistentState()
        
        serializedState.state = unitState
        serializedState.userPresets = userPresets
        
        serializedState.bands = bands
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: FilterUnitPersistentState.self) else {
            
            XCTFail("persistentState is nil, deserialization of FilterUnit state failed.")
            return
        }
        
        validatePersistentState(persistentState: deserializedState, unitState: unitState, userPresets: userPresets,
                                bands: bands)
    }
    
    // MARK: Helper functions --------------------------------------------
    
    private func randomBandType() -> FilterBandType {FilterBandType.randomCase()}
    
    private func randomFrequency() -> Float {
        Float.random(in: SoundConstants.audibleRangeMin...SoundConstants.audibleRangeMax)
    }
    
    private func randomBands() -> [FilterBandPersistentState] {
        
        let numBands = Int.random(in: 1...10)
        return (0..<numBands).map {_ in
            
            let type = randomBandType()
            
            switch type {
            
            case .bandStop:
                
                let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                
                return FilterBandPersistentState(band: FilterBand.bandStopBand(minFreq, maxFreq))
                
            case .bandPass:
                
                let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                
                return FilterBandPersistentState(band: FilterBand.bandPassBand(minFreq, maxFreq))
                
            case .lowPass:
                
                return FilterBandPersistentState(band: FilterBand.lowPassBand(randomFrequency()))
                
            case .highPass:
                
                return FilterBandPersistentState(band: FilterBand.highPassBand(randomFrequency()))
            }
        }
    }
    
    private func randomNillableBands() -> [FilterBandPersistentState]? {
        randomNillableValue {self.randomBands()}
    }
    
    private func randomPresets() -> [FilterPresetPersistentState] {
        
        let numPresets = Int.random(in: 0...10)
        
        return numPresets == 0 ? [] : (0..<numPresets).map {index in
            
            let numBands = Int.random(in: 1...10)
            let bands = (0..<numBands).map {(_: Int) -> FilterBand in
                
                let type = self.randomBandType()
                
                switch type {
                
                case .bandStop:
                    
                    let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                    let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                    
                    return FilterBand.bandStopBand(minFreq, maxFreq)
                    
                case .bandPass:
                    
                    let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
                    let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
                    
                    return FilterBand.bandPassBand(minFreq, maxFreq)
                    
                case .lowPass:
                    
                    return FilterBand.lowPassBand(randomFrequency())
                    
                case .highPass:
                    
                    return FilterBand.highPassBand(randomFrequency())
                }
            }
            
            return FilterPresetPersistentState(preset: FilterPreset("preset-\(index)", .active, bands, false))
        }
    }
    
    private func randomNillablePresets() -> [FilterPresetPersistentState]? {
        randomNillableValue {self.randomPresets()}
    }
    
    private func validatePersistentState(persistentState: FilterUnitPersistentState,
                                         unitState: EffectsUnitState?, userPresets: [FilterPresetPersistentState]?,
                                         bands: [FilterBandPersistentState]?) {
        
        XCTAssertEqual(persistentState.state, unitState)
        
        if let theUserPresets = userPresets {
            
            guard let persistedUserPresets = persistentState.userPresets else {
                
                XCTFail("persisted user presets is nil, deserialization of FilterUnit state failed.")
                return
            }
            
            XCTAssertTrue(persistedUserPresets.count == theUserPresets.count)
            XCTAssertEqual(persistedUserPresets, theUserPresets)
            
        } else {
            
            XCTAssertNil(persistentState.userPresets)
        }
        
        XCTAssertEqual(persistentState.bands, bands)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FilterPresetPersistentState: Equatable {
    
    static func == (lhs: FilterPresetPersistentState, rhs: FilterPresetPersistentState) -> Bool {
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.bands == rhs.bands
    }
}

extension FilterBandPersistentState: Equatable {
    
    static func == (lhs: FilterBandPersistentState, rhs: FilterBandPersistentState) -> Bool {
        
        lhs.type == rhs.type &&
            Float.approxEquals(lhs.minFreq, rhs.minFreq, accuracy: 0.001) &&
            Float.approxEquals(lhs.maxFreq, rhs.maxFreq, accuracy: 0.001)
    }
}
