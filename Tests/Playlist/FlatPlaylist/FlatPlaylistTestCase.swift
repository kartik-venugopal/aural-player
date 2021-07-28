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
        
        let playlistSizeBeforeAdd = playlist.size
        
        for _ in 1...count {
            _ = playlist.addTrack(createRandomTrack())
        }
        
        XCTAssertEqual(playlist.size, playlistSizeBeforeAdd + count)
    }
    
    func addTrack(withFilename name: String) {
        
        let playlistSizeBeforeAdd = playlist.size
        
        let fileExt = randomAudioFileExtension()
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Users/MyUsername/Music/%@.%@", name, fileExt)))
        
        let metadata = fileMetadata(nil, nil, nil, nil, randomDuration())
        track.setPlaylistMetadata(from: metadata)
        
        _ = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.size, playlistSizeBeforeAdd + 1)
    }
    
    func addTrack(title: String) {
        
        let playlistSizeBeforeAdd = playlist.size
        
        let fileExt = randomAudioFileExtension()
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Users/MyUsername/Music/%@.%@", title, fileExt)))
        
        let metadata = fileMetadata(title, nil, nil, nil, randomDuration())
        track.setPlaylistMetadata(from: metadata)
        
        _ = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.size, playlistSizeBeforeAdd + 1)
    }
    
    func addTrack(title: String, artist: String) {
        
        let playlistSizeBeforeAdd = playlist.size
        
        let fileExt = randomAudioFileExtension()
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Users/MyUsername/Music/%@ - %@.%@", artist, title, fileExt)))
        
        let metadata = fileMetadata(title, artist, nil, nil, randomDuration())
        track.setPlaylistMetadata(from: metadata)
        
        _ = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.size, playlistSizeBeforeAdd + 1)
    }
    
    func assertEmptyPlaylist() {
        
        XCTAssertEqual(playlist.size, 0)
        XCTAssertEqual(playlist.duration, 0)
        XCTAssertTrue(playlist.tracks.isEmpty)
    }
    
//    func randomPlaylistSize() -> Int {
//        .random(in: 10...10000)
//    }
}
