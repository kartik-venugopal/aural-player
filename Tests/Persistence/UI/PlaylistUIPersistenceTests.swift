//
//  PlaylistUIPersistenceTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class PlaylistUIPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for playlistView in PlaylistType.allCases {
            doTestPersistence(serializedState: PlaylistUIPersistentState(view: playlistView.rawValue))
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PlaylistUIPersistentState: Equatable {
    
    static func == (lhs: PlaylistUIPersistentState, rhs: PlaylistUIPersistentState) -> Bool {
        lhs.view == rhs.view
    }
}
