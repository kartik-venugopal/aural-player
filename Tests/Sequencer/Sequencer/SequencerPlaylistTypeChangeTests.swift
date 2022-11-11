//
//  SequencerPlaylistTypeChangeTests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerPlaylistTypeChangeTests: SequencerTests {

    func testPlaylistTypeChange() {
        
        for playlistType in PlaylistType.allCases {
            
            sequencer.playlistTypeChanged(playlistType)
            XCTAssertEqual(sequencer.playlistType, playlistType)
        }
    }
}
