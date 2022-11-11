//
//  BookmarksPersistenceTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class BookmarksPersistenceTests: PersistenceTestCase {
    
    func testPersistence_noBookmarks() {
        doTestPersistence(serializedState: [BookmarkPersistentState]())
    }
    
    func testPersistence() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let numBookmarks = Int.random(in: 3...100)
            
            let bookmarks: [BookmarkPersistentState] = (1...numBookmarks).map {_ in
                
                // 20% probability.
                let hasEndPosition: Bool = Int.random(in: 1...10) > 8
                
                let startPosition = randomPlaybackPosition()
                let endPosition = hasEndPosition ? startPosition + (Double.random(in: 60...600)) : nil
                
                return BookmarkPersistentState(name: randomString(length: Int.random(in: 10...50)),
                                               file: randomAudioFile(),
                                               startPosition: startPosition,
                                               endPosition: endPosition)
            }
            
            doTestPersistence(serializedState: bookmarks)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension BookmarkPersistentState: Equatable {
    
    init(name: String?, file: URLPath?, startPosition: Double?, endPosition: Double?) {
        
        self.name = name
        self.file = file
        self.startPosition = startPosition
        self.endPosition = endPosition
    }
    
    static func == (lhs: BookmarkPersistentState, rhs: BookmarkPersistentState) -> Bool {
        
        lhs.file == rhs.file && lhs.name == rhs.name &&
            Double.approxEquals(lhs.startPosition, rhs.startPosition, accuracy: 0.001) &&
            Double.approxEquals(lhs.endPosition, rhs.endPosition, accuracy: 0.001)
    }
}
