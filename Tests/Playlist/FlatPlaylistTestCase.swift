//
//  FlatPlaylistTestCase.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTestCase: PlaylistTestCase {
    
    let playlist = FlatPlaylist()
    
    func addNTracks(_ count: Int) {
        
        for _ in 1...count {
            _ = playlist.addTrack(createRandomTrack())
        }
        
        XCTAssertEqual(playlist.size, count)
    }
    
    func assertEmptyPlaylist() {
        
        XCTAssertEqual(playlist.size, 0)
        XCTAssertEqual(playlist.duration, 0)
        XCTAssertTrue(playlist.tracks.isEmpty)
    }
}
