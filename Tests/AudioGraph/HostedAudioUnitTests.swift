//
//  HostedAudioUnitTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest
import AVFoundation

class HostedAudioUnitTests: AudioGraphTestCase {
    
    func testInit() {
        
        let auManager = AudioUnitsManager()
        let audioUnits = auManager.audioUnits
        
        for unitState in EffectsUnitState.allCases {
            
            for _ in 1...1000 {
                
                let randomAU = audioUnits.randomElement()
                
                let persistentState = AudioUnitPersistentState(state: unitState, userPresets: nil,
                                                               componentType: randomAU.componentType,
                                                               componentSubType: randomAU.componentSubType,
                                                               params: nil)
                
                doTestInit(forComponent: randomAU, persistentState: persistentState)
            }
        }
    }

    private func doTestInit(forComponent component: AVAudioUnitComponent, persistentState: AudioUnitPersistentState) {

        let audioUnit = HostedAudioUnit(forComponent: component, persistentState: persistentState)
        
        XCTAssertEqual(audioUnit.componentType, component.componentType)
        XCTAssertEqual(audioUnit.componentSubType, component.componentSubType)
        
        XCTAssertEqual(audioUnit.state, persistentState.state)
        XCTAssertEqual(audioUnit.isActive, audioUnit.state == .active)
        XCTAssertEqual(audioUnit.node.bypass, !audioUnit.isActive)
        
        XCTAssertEqual(audioUnit.name, component.name)
        XCTAssertEqual(audioUnit.version, component.versionString)
        XCTAssertEqual(audioUnit.manufacturerName, component.manufacturerName)
    }
}
