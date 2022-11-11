//
//  PersistenceTestCase.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PersistenceTestCase: AuralTestCase {
    
    lazy var persistentStateFile: URL = tempDirectory.appendingPathComponent("test-state-\(UUID().uuidString).json")
    lazy var persistenceManager: PersistenceManager = PersistenceManager(persistentStateFile: persistentStateFile)
    
    override func tearDown() {
        persistentStateFile.delete()
    }
    
    func doTestPersistence<T>(serializedState: T) where T: Codable, T: Equatable {
        
        defer {persistentStateFile.delete()}
        
        persistenceManager.save(serializedState)
        
        guard let deserializedState = persistenceManager.load(type: T.self) else {
            
            XCTFail("deserializedState is nil, deserialization of \(T.self) failed.")
            return
        }
        
        XCTAssertEqual(deserializedState, serializedState)
    }
}
