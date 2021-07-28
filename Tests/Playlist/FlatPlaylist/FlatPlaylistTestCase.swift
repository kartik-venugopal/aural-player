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
    
    func addTrack(title: String, artist: String?, album: String) -> Track {
        
        let playlistSizeBeforeAdd = playlist.size

        let fileName = artist == nil ? title : "\(artist!) - \(title)"
        let fileExt = randomAudioFileExtension()
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Users/MyUsername/Music/%@.%@", fileName, fileExt)))
        
        let metadata = fileMetadata(title, artist, album, nil, randomDuration())
        track.setPlaylistMetadata(from: metadata)
        
        _ = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.size, playlistSizeBeforeAdd + 1)
        
        return track
    }
    
    func addTrack(fileName: String, title: String, artist: String?, album: String) -> Track {
        
        let playlistSizeBeforeAdd = playlist.size
        
        let fileExt = randomAudioFileExtension()
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Users/MyUsername/Music/%@.%@", fileName, fileExt)))
        
        let metadata = fileMetadata(title, artist, album, nil, randomDuration())
        track.setPlaylistMetadata(from: metadata)
        
        _ = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.size, playlistSizeBeforeAdd + 1)
        
        return track
    }
    
    func addTrack(fileName: String) -> Track {
        
        let playlistSizeBeforeAdd = playlist.size
        
        let fileExt = randomAudioFileExtension()
        
        let track = MockTrack(URL(fileURLWithPath: String(format: "/Users/MyUsername/Music/%@.%@", fileName, fileExt)))
        
        let metadata = fileMetadata(nil, nil, nil, nil, randomDuration())
        track.setPlaylistMetadata(from: metadata)
        
        _ = playlist.addTrack(track)
        
        XCTAssertEqual(playlist.size, playlistSizeBeforeAdd + 1)
        
        return track
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

extension SearchQuery {
    
    convenience init(text: String, type: SearchType = .contains, fields: SearchFields = .all, options: SearchOptions = .none) {
        
        self.init()
        
        self.text = text
        self.type = type
        self.fields = fields
        self.options = options
    }

    func withText(_ text: String) -> SearchQuery {
        
        self.text = text
        return self
    }
    
    func withFields(_ fields: SearchFields) -> SearchQuery {
        
        self.fields = fields
        return self
    }
    
    func withType(_ type: SearchType) -> SearchQuery {
        
        self.type = type
        return self
    }
    
    func withOptions(_ options: SearchOptions) -> SearchQuery {
        
        self.options = options
        return self
    }
}
