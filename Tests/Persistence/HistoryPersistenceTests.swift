//
//  HistoryPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class HistoryPersistenceTests: PersistenceTestCase {
    
    func testPersistence_noHistory() {
        
        let state = HistoryPersistentState(recentlyAdded: [], recentlyPlayed: [])
        doTestPersistence(serializedState: state)
    }
    
    func testPersistence() {
        
        for _ in 1...100 {
            
            let addedItems = randomRecentlyAddedItems()
            let playedItems = randomRecentlyPlayedItems()
            
            let state = HistoryPersistentState(recentlyAdded: addedItems, recentlyPlayed: playedItems)
            doTestPersistence(serializedState: state)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension HistoryPersistentState: Equatable {
    
    static func == (lhs: HistoryPersistentState, rhs: HistoryPersistentState) -> Bool {
        lhs.recentlyAdded == rhs.recentlyAdded && lhs.recentlyPlayed == rhs.recentlyPlayed
    }
}

extension HistoryItemPersistentState: Equatable {
    
    init(file: URLPath?, name: String?, time: DateString?) {
        
        self.file = file
        self.name = name
        self.time = time
    }
    
    static func == (lhs: HistoryItemPersistentState, rhs: HistoryItemPersistentState) -> Bool {
        lhs.file == rhs.file && lhs.name == rhs.name && lhs.time == rhs.time
    }
}
