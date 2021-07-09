//
//  FlatPlaylistTests+AddSizeDuration.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_AddSizeDuration: FlatPlaylistTestCase {
    
    func testEmptyPlaylist() {
        assertEmptyPlaylist()
    }
    
    func test_startingFromEmptyPlaylist() {
        
        for _ in 1...100 {
            
            assertEmptyPlaylist()
            let track = createRandomTrack()
            
            let trackIndex: Int = playlist.addTrack(track)
            XCTAssertEqual(trackIndex, 0)
            
            XCTAssertEqual(playlist.size, 1)
            XCTAssertEqual(playlist.tracks.count, 1)
            
            AssertEqual(playlist.duration, track.duration, accuracy: 0.001)
            
            // Clean up after test iteration
            playlist.clear()
        }
    }
    
    func test_cumulativeAdd() {
        
        assertEmptyPlaylist()
        
        var totalDuration: Double = 0
        
        for trackIndex in 0..<10000 {
            
            let track = createRandomTrack()
            totalDuration += track.duration
            
            let newTrackIndex: Int = playlist.addTrack(track)
            XCTAssertEqual(newTrackIndex, trackIndex)
            
            XCTAssertEqual(playlist.size, trackIndex + 1)
            XCTAssertEqual(playlist.tracks.count, trackIndex + 1)

            AssertEqual(playlist.duration, totalDuration, accuracy: 0.001)
        }
    }
    
    func testClear() {
        
        assertEmptyPlaylist()
        
        let trackCounts: [Int] = (1...100).map {_ in Int.random(in: 1...10000)}
        
        for trackCount in trackCounts {
            
            addNTracks(trackCount)
            XCTAssertEqual(playlist.size, trackCount)
            
            playlist.clear()
            assertEmptyPlaylist()
        }
    }
}
