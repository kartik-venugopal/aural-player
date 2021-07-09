//
//  FlatPlaylistTests+TrackAccessByIndex.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import XCTest

class FlatPlaylistTests_TrackAccessByIndex: FlatPlaylistTestCase {
    
    func testTrackAtIndex_validIndices() {
        
        assertEmptyPlaylist()
        
        for trackIndex in 0..<10000 {
            
            let track = createRandomTrack()
            _ = playlist.addTrack(track)
            
            XCTAssertEqual(playlist.trackAtIndex(trackIndex), track)
            XCTAssertEqual(playlist.tracks[trackIndex], track)
        }
        
        // For any random index in the playlist, verify that trackAtIndex() returns a non-nil value.
        let randomValidIndices: [Int] = (1...100).map {_ in
            Int.random(in: 0..<playlist.size)
        }
        
        for index in randomValidIndices {
            
            XCTAssertNotNil(playlist.trackAtIndex(index))
            XCTAssertNotNil(playlist.tracks[index])
        }
    }
    
    func testTrackAtIndex_invalidIndices() {
        
        assertEmptyPlaylist()
        
        for invalidIndex in -100...100 {
            XCTAssertNil(playlist.trackAtIndex(invalidIndex))
        }
        
        for trackIndex in 0..<10000 {
            
            let track = createRandomTrack()
            let newTrackIndex: Int = playlist.addTrack(track)
            
            XCTAssertEqual(newTrackIndex, trackIndex)
            
            for invalidIndex in -100..<0 {
                XCTAssertNil(playlist.trackAtIndex(invalidIndex))
            }
            
            for invalidIndex in (trackIndex + 1)..<(trackIndex + 100) {
                XCTAssertNil(playlist.trackAtIndex(invalidIndex))
            }
        }
    }
    
    func testIndexOfTrack() {
        
        assertEmptyPlaylist()
        
        for trackIndex in 0..<10000 {
            
            let track = createRandomTrack()
            _ = playlist.addTrack(track)
            
            XCTAssertEqual(playlist.indexOfTrack(track), trackIndex)
        }
    }
}
