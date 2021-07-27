//
//  FilterUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FilterUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let persistentState = FilterUnitPersistentState(state: unitState,
                                                                userPresets: randomFilterPresets(unitState: .active),
                                                                bands: randomFilterBands())
                
                doTestInit(persistentState: persistentState)
            }
        }
    }
    
    private func doTestInit(persistentState: FilterUnitPersistentState) {
        
        let filterUnit = FilterUnit(persistentState: persistentState)
        validate(filterUnit, persistentState: persistentState)
    }
    
    private func randomBand() -> FilterBand {
        
        let type = randomFilterBandType()
        
        switch type {
        
        case .bandStop:
            
            let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
            let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
            
            return .bandStopBand(minFreq: minFreq, maxFreq: maxFreq)
            
        case .bandPass:
            
            let minFreq = Float.random(in: SoundConstants.audibleRangeMin...(SoundConstants.audibleRangeMax / 2))
            let maxFreq = Float.random(in: minFreq...SoundConstants.audibleRangeMax)
            
            return .bandPassBand(minFreq: minFreq, maxFreq: maxFreq)
            
        case .lowPass:
            
            return .lowPassBand(maxFreq: randomFilterFrequency())
            
        case .highPass:
            
            return .highPassBand(minFreq: randomFilterFrequency())
        }
    }
    
    private func randomBands(allowZeroBands: Bool = true) -> [FilterBand] {
        
        let numBands = allowZeroBands ? Int.random(in: 0...31) : Int.random(in: 1...31)
        return (0..<numBands).map {_ in randomBand()}
    }
    
    func testToggleState() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = FilterUnitPersistentState(state: startingState, userPresets: nil, bands: nil)
            
            let filterUnit = FilterUnit(persistentState: persistentState)
            
            XCTAssertEqual(filterUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = filterUnit.state == .active ? .bypassed : .active
                let newState = filterUnit.toggleState()
                
                XCTAssertEqual(filterUnit.state, expectedState)
                XCTAssertEqual(newState, expectedState)
                
                XCTAssertEqual(filterUnit.node.bypass, filterUnit.state != .active)
            }
        }
    }
    
    func testIsActive() {
        
        for startingState in EffectsUnitState.allCases {
                
            let persistentState = FilterUnitPersistentState(state: startingState, userPresets: nil, bands: nil)
            
            let filterUnit = FilterUnit(persistentState: persistentState)
            
            XCTAssertEqual(filterUnit.state, startingState)
            
            for _ in 1...1000 {
                
                let expectedState: EffectsUnitState = filterUnit.state == .active ? .bypassed : .active
                _ = filterUnit.toggleState()
                
                XCTAssertEqual(filterUnit.state, expectedState)
                XCTAssertEqual(filterUnit.isActive, expectedState == .active)
                
                XCTAssertEqual(filterUnit.node.bypass, !filterUnit.isActive)
            }
        }
    }
    
    func testSuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = FilterUnitPersistentState(state: startingState, userPresets: nil, bands: nil)
                
                let filterUnit = FilterUnit(persistentState: persistentState)
                
                XCTAssertEqual(filterUnit.state, startingState)
                
                let expectedState: EffectsUnitState = filterUnit.state == .active ? .suppressed : filterUnit.state
                filterUnit.suppress()
                
                XCTAssertEqual(filterUnit.state, expectedState)
                XCTAssertEqual(filterUnit.isActive, expectedState == .active)
                
                if filterUnit.state == .suppressed {
                    XCTAssertTrue(filterUnit.node.bypass)
                }
            }
        }
    }
    
    func testUnsuppress() {
        
        for _ in 1...1000 {
            
            for startingState in EffectsUnitState.allCases {
                
                let persistentState = FilterUnitPersistentState(state: startingState, userPresets: nil, bands: nil)
                
                let filterUnit = FilterUnit(persistentState: persistentState)
                
                XCTAssertEqual(filterUnit.state, startingState)
                
                let expectedState: EffectsUnitState = filterUnit.state == .suppressed ? .active : filterUnit.state
                filterUnit.unsuppress()
                
                XCTAssertEqual(filterUnit.state, expectedState)
                XCTAssertEqual(filterUnit.isActive, expectedState == .active)
                
                if filterUnit.state == .active {
                    XCTAssertFalse(filterUnit.node.bypass)
                }
            }
        }
    }
    
    func testSavePreset() {

        for _ in 1...1000 {

            let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)

            let filterUnit = FilterUnit(persistentState: persistentState)
            XCTAssertEqual(filterUnit.state, .active)
            
            filterUnit.bands = randomBands()

            let presetName = "TestFilterPreset-1"
            filterUnit.savePreset(named: presetName)

            guard let savedPreset = filterUnit.presets.userDefinedPreset(named: presetName) else {

                XCTFail("Failed to save Filter preset named \(presetName)")
                continue
            }

            XCTAssertEqual(savedPreset.name, presetName)
            compareBands(filterUnit.bands, with: savedPreset.bands)
        }
    }
    
    private func compareBands(_ bands: [FilterBand], with other: [FilterBand]) {
        
        XCTAssertEqual(bands.count, other.count)
        
        for index in bands.indices {
            compareBand(bands[index], with: other[index])
        }
    }
    
    private func compareBand(_ band: FilterBand, with other: FilterBand) {
        
        AssertEqual(band.minFreq, other.minFreq, accuracy: 0.001)
        AssertEqual(band.maxFreq, other.maxFreq, accuracy: 0.001)
    }
    
    private func AssertNotEqual(_ bands: [FilterBand], _ other: [FilterBand]) {
        
        if bands.count != other.count {
            return
        }
        
        if bands.isEmpty {return}
        
        for index in bands.indices {
            
            let b1 = bands[index]
            let b2 = other[index]
            
            // Only one mismatch is required to pass
            if !(Float.approxEquals(b1.minFreq, b2.minFreq, accuracy: 0.001) &&
                    Float.approxEquals(b1.maxFreq, b2.maxFreq, accuracy: 0.001)) {
                
                return
            }
        }
        
        XCTFail("All bands elements are equal.")
    }

    func testApplyNamedPreset() {

        for _ in 1...1000 {

            let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)

            let filterUnit = FilterUnit(persistentState: persistentState)
            XCTAssertEqual(filterUnit.state, .active)

            filterUnit.bands = randomBands()

            let presetName = "TestFilterPreset-1"
            filterUnit.savePreset(named: presetName)

            guard let savedPreset = filterUnit.presets.userDefinedPreset(named: presetName) else {

                XCTFail("Failed to save Filter preset named \(presetName)")
                continue
            }

            filterUnit.bands = randomBands()

            AssertNotEqual(filterUnit.bands, savedPreset.bands)

            filterUnit.applyPreset(named: presetName)

            compareBands(filterUnit.bands, with: savedPreset.bands)
        }
    }

    func testApplyNamedPreset_persistentPreset() {

        for _ in 1...1000 {

            let persistentPresets = randomFilterPresets(count: 3, unitState: .active)

            let persistentState = FilterUnitPersistentState(state: .active, userPresets: persistentPresets, bands: nil)

            let filterUnit = FilterUnit(persistentState: persistentState)
            XCTAssertEqual(filterUnit.state, .active)
            XCTAssertEqual(filterUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)

            filterUnit.bands = randomBands()

            let presetToApply = filterUnit.presets.userDefinedPresets.randomElement()
            let presetName = presetToApply.name

            AssertNotEqual(filterUnit.bands, presetToApply.bands)

            filterUnit.applyPreset(named: presetName)

            compareBands(filterUnit.bands, with: presetToApply.bands)
        }
    }

    func testApplyPreset() {

        for _ in 1...1000 {

            let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)

            let filterUnit = FilterUnit(persistentState: persistentState)
            XCTAssertEqual(filterUnit.state, .active)

            filterUnit.bands = randomBands()

            let presetName = "TestFilterPreset-1"
            filterUnit.savePreset(named: presetName)

            guard let savedPreset = filterUnit.presets.userDefinedPreset(named: presetName) else {

                XCTFail("Failed to save Filter preset named \(presetName)")
                continue
            }

            filterUnit.bands = randomBands()

            AssertNotEqual(filterUnit.bands, savedPreset.bands)

            filterUnit.applyPreset(savedPreset)

            compareBands(filterUnit.bands, with: savedPreset.bands)
        }
    }

    func testApplyPreset_persistentPreset() {

        for _ in 1...1000 {

            let persistentPresets = randomFilterPresets(count: 3, unitState: .active)

            let persistentState = FilterUnitPersistentState(state: .active, userPresets: persistentPresets, bands: nil)

            let filterUnit = FilterUnit(persistentState: persistentState)
            XCTAssertEqual(filterUnit.state, .active)
            XCTAssertEqual(filterUnit.presets.numberOfUserDefinedPresets, persistentPresets.count)

            filterUnit.bands = randomBands()

            let presetToApply = filterUnit.presets.userDefinedPresets.randomElement()

            AssertNotEqual(filterUnit.bands, presetToApply.bands)

            filterUnit.applyPreset(presetToApply)

            compareBands(filterUnit.bands, with: presetToApply.bands)
        }
    }

    func testSettingsAsPreset() {

        for _ in 1...1000 {

            let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)

            let filterUnit = FilterUnit(persistentState: persistentState)
            XCTAssertEqual(filterUnit.state, .active)

            filterUnit.bands = randomBands()

            let settingsAsPreset: FilterPreset = filterUnit.settingsAsPreset

            compareBands(settingsAsPreset.bands, with: filterUnit.bands)
        }
    }
    
    func testBands() {
        
        let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)
        let filterUnit = FilterUnit(persistentState: persistentState)
        
        for _ in 1...1000 {

            let bands = randomBands()
            filterUnit.bands = bands
            
            compareBands(filterUnit.bands, with: bands)
        }
    }
    
    func testSubscript() {
        
        let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)
        let filterUnit = FilterUnit(persistentState: persistentState)
        
        for _ in 1...1000 {

            let bands = randomBands()
            filterUnit.bands = bands
            
            compareBands(filterUnit.bands, with: bands)
            
            for index in bands.indices {
                
                let testBand: FilterBand = filterUnit[index]
                let comparisonBand: FilterBand = bands[index]
                
                AssertEqual(testBand.minFreq, comparisonBand.minFreq, accuracy: 0.001)
                AssertEqual(testBand.maxFreq, comparisonBand.maxFreq, accuracy: 0.001)
            }
        }
    }
    
    func testAddBand() {
        
        let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)
        let filterUnit = FilterUnit(persistentState: persistentState)
        
        for _ in 1...1000 {
            
            let numBands = Int.random(in: 1...31)
            for index in 0..<numBands {
                
                let newBand = randomBand()
                let newIndex = filterUnit.addBand(newBand)
                
                XCTAssertEqual(newIndex, index)
                compareBand(filterUnit[index], with: newBand)
            }
            
            // Clear the bands for the next test iteration.
            filterUnit.bands = []
        }
    }
    
    func testRemoveBand() {
        
        let persistentState = FilterUnitPersistentState(state: .active, userPresets: nil, bands: nil)
        let filterUnit = FilterUnit(persistentState: persistentState)
        
        for _ in 1...10 {
            
            let bands = randomBands(allowZeroBands: false)
            filterUnit.bands = bands
            
            for _ in 1...Int.random(in: 1...filterUnit.bands.count) {
                
                let bandsBeforeRemove = filterUnit.bands
                let removedIndex = Int.random(in: filterUnit.bands.indices)
                filterUnit.removeBand(at: removedIndex)
                
                if removedIndex > 0 {
                    
                    for index in 0..<removedIndex {
                        compareBand(filterUnit[index], with: bandsBeforeRemove[index])
                    }
                }
                
                if removedIndex < filterUnit.bands.count {
                    
                    for index in removedIndex..<filterUnit.bands.count {
                        compareBand(filterUnit[index], with: bandsBeforeRemove[index + 1])
                    }
                }
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FilterPreset: Equatable, Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    static func == (lhs: FilterPreset, rhs: FilterPreset) -> Bool {
        lhs.name == rhs.name && lhs.state == rhs.state && lhs.bands == rhs.bands
    }
}

extension FilterBand: Equatable {
    
    static func == (lhs: FilterBand, rhs: FilterBand) -> Bool {
        
        lhs.type == rhs.type &&
            Float.approxEquals(lhs.minFreq, rhs.minFreq, accuracy: 0.001) &&
            Float.approxEquals(lhs.maxFreq, rhs.maxFreq, accuracy: 0.001)
    }
}
