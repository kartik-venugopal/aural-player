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
    
    private func randomRecentlyPlayedItems() -> [HistoryItemPersistentState] {
        
        let numItems = Int.random(in: 10...100)
        
        return (1...numItems).map {_ in
            
            let file = randomAudioFile()
            let name = randomString(length: Int.random(in: 10...50))
            let time = Date.init(timeIntervalSinceNow: -randomTimeBeforeNow())
            
            return HistoryItemPersistentState(file: file, name: name, time: time.serializableString())
        }
    }
    
    private func randomRecentlyAddedItems() -> [HistoryItemPersistentState] {
        
        let numItems = Int.random(in: 10...100)
        
        return (1...numItems).map {_ in
            
            let file = randomRecentlyAddedItemFilePath()
            let name = randomString(length: Int.random(in: 10...50))
            let time = Date.init(timeIntervalSinceNow: -randomTimeBeforeNow())
            
            return HistoryItemPersistentState(file: file, name: name, time: time.serializableString())
        }
    }
    
    private func randomTimeBeforeNow() -> Double {
        
        // 1 minute to 60 days.
        Double.random(in: 65...5184000)
    }
    
    private func randomRecentlyAddedItemFilePath() -> URLPath {
        
        let randomNum = Int.random(in: 1...3)
        
        switch randomNum {
        
        case 1:     // Audio file
                    return randomAudioFile()
        
        case 2:     // Playlist file
                    return randomPlaylistFile()
        
        case 3:     // Folder
                    return randomFolder()
            
        default:    return randomAudioFile()
            
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
