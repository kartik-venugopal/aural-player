//
//  MusicBrainzCachePersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class MusicBrainzCachePersistenceTests: PersistenceTestCase {
    
    func testPersistence_noCacheEntries() {
        
        let state = MusicBrainzCachePersistentState(releases: [], recordings: [])
        doTestPersistence(serializedState: state)
    }
    
    func testPersistence() {
        
        for _ in 1...100 {
            
            let numReleases = Int.random(in: 5...500)
            let numRecordings = Int.random(in: 5...500)
            
            let releases: [MusicBrainzCacheEntryPersistentState] = (1...numReleases).map {_ in
                
                MusicBrainzCacheEntryPersistentState(artist: randomArtist(),
                                                     title: randomTitle(),
                                                     file: randomImageFile())
            }
            
            let recordings: [MusicBrainzCacheEntryPersistentState] = (1...numRecordings).map {_ in
                
                MusicBrainzCacheEntryPersistentState(artist: randomArtist(),
                                                     title: randomTitle(),
                                                     file: randomImageFile())
            }
            
            let state = MusicBrainzCachePersistentState(releases: releases, recordings: recordings)
            doTestPersistence(serializedState: state)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension MusicBrainzCachePersistentState: Equatable {
    
    static func == (lhs: MusicBrainzCachePersistentState, rhs: MusicBrainzCachePersistentState) -> Bool {
        lhs.releases == rhs.releases && lhs.recordings == rhs.recordings
    }
}

extension MusicBrainzCacheEntryPersistentState: Equatable {
    
    static func == (lhs: MusicBrainzCacheEntryPersistentState, rhs: MusicBrainzCacheEntryPersistentState) -> Bool {
        lhs.artist == rhs.artist && lhs.title == rhs.title && lhs.file == rhs.file
    }
}
