//
//  FlatPlaylistTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests: PlaylistTestCase {
    
    private let playlist = FlatPlaylist()
    
    func testEmptyPlaylist() {
        assertEmptyPlaylist()
    }
    
    func testAddTrack_startingFromEmptyPlaylist() {
        
        for _ in 1...100 {
            
            assertEmptyPlaylist()
            let track = createRandomTrack()
            
            let trackIndex: Int = playlist.addTrack(track)
            XCTAssertEqual(trackIndex, 0)
            XCTAssertEqual(playlist.indexOfTrack(track), 0)
            
            let playlistTracks = playlist.tracks
            
            XCTAssertEqual(playlist.size, 1)
            XCTAssertEqual(playlistTracks.count, 1)
            
            XCTAssertEqual(playlistTracks[0], track)
            XCTAssertEqual(playlist.trackAtIndex(0), track)
            
            AssertEqual(playlist.duration, track.duration, accuracy: 0.001)
            
            // Clean up after test iteration
            playlist.clear()
        }
    }
    
    func testAddTrack_cumulative() {
        
        assertEmptyPlaylist()
        
        var totalDuration: Double = 0
        
        for trackIndex in 0..<10000 {
            
            let track = createRandomTrack()
            totalDuration += track.duration
            
            let newTrackIndex: Int = playlist.addTrack(track)
            XCTAssertEqual(newTrackIndex, trackIndex)
            
            let playlistTracks = playlist.tracks

            XCTAssertEqual(playlist.size, trackIndex + 1)
            XCTAssertEqual(playlistTracks.count, trackIndex + 1)

            XCTAssertEqual(playlistTracks[trackIndex], track)
            XCTAssertEqual(playlist.trackAtIndex(trackIndex), track)
            
            AssertEqual(playlist.duration, totalDuration, accuracy: 0.001)
        }
    }
    
    func testTrackAtIndex_validIndices() {
        
        assertEmptyPlaylist()
        
        for trackIndex in 0..<10000 {
            
            let track = createRandomTrack()
            _ = playlist.addTrack(track)
            
            XCTAssertNotNil(playlist.trackAtIndex(trackIndex))
            XCTAssertNotNil(playlist.tracks[trackIndex])
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
    
    private func addNTracks(_ count: Int) {
        
        for _ in 1...count {
            _ = playlist.addTrack(createRandomTrack())
        }
    }
    
    private func createRandomTrack() -> Track {
        return createTrack(title: randomTitle(), duration: randomDuration())
    }
    
    private func assertEmptyPlaylist() {
        
        XCTAssertEqual(playlist.size, 0)
        XCTAssertEqual(playlist.duration, 0)
        XCTAssertTrue(playlist.tracks.isEmpty)
    }
}
