//
//  HostedAudioUnitTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest
import AVFoundation

class HostedAudioUnitTests: AudioGraphTestCase {
    
    // TODO
    
    func testInit() {
        
        let auManager = AudioUnitsManager()
//        let audioUnits = auManager.audioUnits
        
//        for unitState in EffectsUnitState.allCases {
            
//            for _ in 1...10 {
                
            let randomAU = auManager.audioUnit(ofType: 1635083896, andSubType: 1851942257)!
                let params = randomParams(forComponent: randomAU).map {AudioUnitParameterPersistentState(address: $0, value: $1)}
        print("\nPersistent params: \(params.count)")
                
        let persistentState = AudioUnitPersistentState(state: .active, userPresets: nil,
                                                               componentType: randomAU.componentType, componentSubType: randomAU.componentSubType,
                                                               params: params)
                
                doTestInit(forComponent: randomAU, persistentState: persistentState)
//            }
//        }
    }
    
    private func randomParams(forComponent component: AVAudioUnitComponent) -> [AUParameterAddress: Float] {
        
        let node = HostedAUNode(forComponent: component)
        
        var dict: [AUParameterAddress: Float] = [:]
        
        for param in node.parameterTree?.allParameters ?? [] {
            dict[param.address] = AUValue.random(in: param.minValue...param.maxValue)
        }
        
        print("\nFound params: \(dict.count)")
        return dict
    }

    private func doTestInit(forComponent component: AVAudioUnitComponent, persistentState: AudioUnitPersistentState) {

        let audioUnit = HostedAudioUnit(forComponent: component, persistentState: persistentState)
        
        XCTAssertEqual(audioUnit.name, component.name)
        XCTAssertEqual(audioUnit.version, component.versionString)
        XCTAssertEqual(audioUnit.manufacturerName, component.manufacturerName)
        
        XCTAssertEqual(audioUnit.componentType, component.componentType)
        XCTAssertEqual(audioUnit.componentSubType, component.componentSubType)
        
//        print("AU params: \(audioUnit.params)")
        
        for param in persistentState.params ?? [] {
            AssertEqual(audioUnit.params[param.address!], param.value!, accuracy: 0.001)
            
            if audioUnit.params[param.address!] != param.value! {
                print("\nMismatch: \(audioUnit.componentType) \(audioUnit.componentSubType) \(audioUnit.params.count)")
                return
            }
        }
    }
}
