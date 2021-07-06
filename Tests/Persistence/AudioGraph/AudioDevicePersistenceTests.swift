//
//  AudioDevicePersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class AudioDevicePersistenceTests: AudioGraphPersistenceTestCase {
    
    func testPersistence() {
        
        for _ in 1...100 {
            
            doTestPersistence(serializedState: AudioDevicePersistentState(name: randomDeviceName(),
                                                                           uid: randomDeviceUID()))
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension AudioDevicePersistentState: Equatable {
    
    static func == (lhs: AudioDevicePersistentState, rhs: AudioDevicePersistentState) -> Bool {
        lhs.name == rhs.name && lhs.uid == rhs.uid
    }
}
