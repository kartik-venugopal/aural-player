//
//  PlayerUIPersistenceTests.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class PlayerUIPersistenceTests: PersistenceTestCase {
    
    func testPersistence_typicalSettings() {
        
        for viewType in PlayerViewType.allCases {
            
            let state = PlayerUIPersistentState(viewType: viewType,
                                                showAlbumArt: true,
                                                showArtist: true,
                                                showAlbum: true,
                                                showCurrentChapter: true,
                                                showTrackInfo: true,
                                                showPlayingTrackFunctions: true,
                                                showControls: true,
                                                showTimeElapsedRemaining: true,
                                                timeElapsedDisplayType: .formatted,
                                                timeRemainingDisplayType: .formatted)
            
            doTestPersistence(serializedState: state)
        }
    }
    
    func testPersistence() {
        
        for viewType in PlayerViewType.allCases {
            
            for _ in 1...1000 {
                
                let state = PlayerUIPersistentState(viewType: viewType,
                                                    showAlbumArt: .random(),
                                                    showArtist: .random(),
                                                    showAlbum: .random(),
                                                    showCurrentChapter: .random(),
                                                    showTrackInfo: .random(),
                                                    showPlayingTrackFunctions: .random(),
                                                    showControls: .random(),
                                                    showTimeElapsedRemaining: .random(),
                                                    timeElapsedDisplayType: .randomCase(),
                                                    timeRemainingDisplayType: .randomCase())
                
                doTestPersistence(serializedState: state)
            }
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PlayerUIPersistentState: Equatable {
    
    static func == (lhs: PlayerUIPersistentState, rhs: PlayerUIPersistentState) -> Bool {
        
        lhs.showAlbum == rhs.showAlbum &&
            lhs.showAlbumArt == rhs.showAlbumArt &&
            lhs.showArtist == rhs.showArtist &&
            lhs.showControls == rhs.showControls &&
            lhs.showCurrentChapter == rhs.showCurrentChapter &&
            lhs.showPlayingTrackFunctions == rhs.showPlayingTrackFunctions &&
            lhs.showTimeElapsedRemaining == rhs.showTimeElapsedRemaining &&
            lhs.showTrackInfo == rhs.showTrackInfo &&
            lhs.timeElapsedDisplayType == rhs.timeElapsedDisplayType &&
            lhs.timeRemainingDisplayType == rhs.timeRemainingDisplayType
    }
}
