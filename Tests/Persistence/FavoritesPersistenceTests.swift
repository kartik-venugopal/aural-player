//
//  FavoritesPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FavoritesPersistenceTests: PersistenceTestCase {
    
    func testPersistence_noFavorites() {
        doTestPersistence(serializedState: [FavoritePersistentState]())
    }
    
    func testPersistence() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let numFavorites = Int.random(in: 10...100)
            
            let favorites = (1...numFavorites).map {_ in
                
                FavoritePersistentState(file: randomAudioFile(),
                                        name: randomString(length: Int.random(in: 10...50)))
            }
            
            doTestPersistence(serializedState: favorites)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension FavoritePersistentState: Equatable {
    
    init(file: URLPath?, name: String?) {
        
        self.file = file
        self.name = name
    }
    
    static func == (lhs: FavoritePersistentState, rhs: FavoritePersistentState) -> Bool {
        lhs.file == rhs.file && lhs.name == rhs.name
    }
}
