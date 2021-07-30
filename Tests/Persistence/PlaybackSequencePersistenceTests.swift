//
//  PlaybackSequencePersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PlaybackSequencePersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for repeatMode in RepeatMode.allCases {
            
            for shuffleMode in ShuffleMode.allCases {
                
                let state = PlaybackSequencePersistentState(repeatMode: repeatMode,
                                                            shuffleMode: shuffleMode)
                
                doTestPersistence(serializedState: state)
            }
        }
        
        for _ in 1...1000 {
            
            let state = PlaybackSequencePersistentState(repeatMode: .randomCase(),
                                                        shuffleMode: .randomCase())
            
            doTestPersistence(serializedState: state)
        }
    }
    
    func testPersistentState() {
        
        let flatPlaylist = FlatPlaylist()
        let artistsPlaylist = GroupingPlaylist(.artists)
        let albumsPlaylist = GroupingPlaylist(.albums)
        let genresPlaylist = GroupingPlaylist(.genres)
        
        let playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
        
        let persistentState = PlaybackSequencePersistentState(repeatMode: .off, shuffleMode: .off)
        let sequencer = Sequencer(persistentState: persistentState, playlist, .tracks)
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            _ = sequencer.setRepeatMode(repeatMode)
            _ = sequencer.setShuffleMode(shuffleMode)
            
            let modes = sequencer.repeatAndShuffleModes
            XCTAssertEqual(modes.repeatMode, repeatMode)
            XCTAssertEqual(modes.shuffleMode, shuffleMode)
            
            let persistentState = sequencer.persistentState
            XCTAssertEqual(persistentState.repeatMode, modes.repeatMode)
            XCTAssertEqual(persistentState.shuffleMode, modes.shuffleMode)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PlaybackSequencePersistentState: Equatable {
    
    static func == (lhs: PlaybackSequencePersistentState, rhs: PlaybackSequencePersistentState) -> Bool {
        lhs.repeatMode == rhs.repeatMode && lhs.shuffleMode == rhs.shuffleMode
    }
}
