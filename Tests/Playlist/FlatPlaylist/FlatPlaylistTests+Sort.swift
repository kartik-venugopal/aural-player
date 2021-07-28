//
//  FlatPlaylistTests+Sort.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_Sort: FlatPlaylistTestCase {
    
    func test_byName_ascending() {
        
        assertEmptyPlaylist()
        
        let tracks = [createTrack(fileName: "track09"),
                      createTrack(fileName: "track11"),
                      createTrack(fileName: "track08"),
                      createTrack(fileName: "04 - Endless Dream"),
                      createTrack(title: "Money", artist: "Pink Floyd"),
                      createTrack(title: "Breathe", artist: "Pink Floyd"),
                      createTrack(title: "Time", artist: "Pink Floyd"),
                      createTrack(title: "Dream Fortress", artist: "Grimes")]
        
        tracks.shuffled().forEach {_ = self.playlist.addTrack($0)}
        
        let tracksSort = TracksSort().withFields(.name).withOrder(.ascending)
        let sort = Sort().withTracksSort(tracksSort)
        
        playlist.sort(sort)
        
        XCTAssertTrue(playlist.tracks.elementsEqual([tracks[3], tracks[7], tracks[5], tracks[4], tracks[6], tracks[2], tracks[0], tracks[1]]))
    }
    
    func test_byName_descending() {
        
        assertEmptyPlaylist()
        
        let tracks = [createTrack(fileName: "track09"),
                      createTrack(fileName: "track11"),
                      createTrack(fileName: "track08"),
                      createTrack(fileName: "04 - Endless Dream"),
                      createTrack(title: "Money", artist: "Pink Floyd"),
                      createTrack(title: "Breathe", artist: "Pink Floyd"),
                      createTrack(title: "Time", artist: "Pink Floyd"),
                      createTrack(title: "Dream Fortress", artist: "Grimes")]
        
        tracks.shuffled().forEach {_ = self.playlist.addTrack($0)}
        
        let tracksSort = TracksSort().withFields(.name).withOrder(.descending)
        let sort = Sort().withTracksSort(tracksSort)
        
        playlist.sort(sort)
        
        XCTAssertTrue(playlist.tracks.elementsEqual([tracks[3], tracks[7], tracks[5], tracks[4], tracks[6], tracks[2], tracks[0], tracks[1]].reversed()))
    }
    
    func test_byDuration_ascending() {
        
        assertEmptyPlaylist()
        
        let tracks = [createTrack(fileName: "track09", duration: 213.46),
                      createTrack(fileName: "track11", duration: 103.67),
                      createTrack(title: "Dream Fortress", artist: "Grimes", duration: 3789.94),
                      createTrack(fileName: "track08", duration: 63.19),
                      createTrack(title: "Time", artist: "Pink Floyd", duration: 672.143)]
        
        tracks.shuffled().forEach {_ = self.playlist.addTrack($0)}
        
        let tracksSort = TracksSort().withFields(.duration).withOrder(.ascending)
        let sort = Sort().withTracksSort(tracksSort)
        
        playlist.sort(sort)
        
        XCTAssertTrue(playlist.tracks.elementsEqual([tracks[3], tracks[1], tracks[0], tracks[4], tracks[2]]))
    }
    
    func test_byDuration_descending() {
        
        assertEmptyPlaylist()
        
        let tracks = [createTrack(fileName: "track09", duration: 213.46),
                      createTrack(fileName: "track11", duration: 103.67),
                      createTrack(title: "Dream Fortress", artist: "Grimes", duration: 3789.94),
                      createTrack(fileName: "track08", duration: 63.19),
                      createTrack(title: "Time", artist: "Pink Floyd", duration: 672.143)]
        
        tracks.shuffled().forEach {_ = self.playlist.addTrack($0)}
        
        let tracksSort = TracksSort().withFields(.duration).withOrder(.descending)
        let sort = Sort().withTracksSort(tracksSort)
        
        playlist.sort(sort)
        
        XCTAssertTrue(playlist.tracks.elementsEqual([tracks[3], tracks[1], tracks[0], tracks[4], tracks[2]].reversed()))
    }
    
    func test_byArtistAndName_ascending() {
        
        assertEmptyPlaylist()
        
        let tracks = [createTrack(fileName: "track09"),
                      createTrack(fileName: "track11"),
                      createTrack(fileName: "track08"),
                      createTrack(fileName: "04 - Endless Dream"),
                      createTrack(title: "Money", artist: "Pink Floyd"),
                      createTrack(title: "Breathe", artist: "Pink Floyd"),
                      createTrack(title: "Time", artist: "Pink Floyd"),
                      createTrack(title: "Dream Fortress", artist: "Grimes")]
        
        tracks.shuffled().forEach {_ = self.playlist.addTrack($0)}
        
        let tracksSort = TracksSort().withFields(.artist, .name).withOrder(.ascending)
        let sort = Sort().withTracksSort(tracksSort)
        
        playlist.sort(sort)
        
        XCTAssertTrue(playlist.tracks.elementsEqual([tracks[3], tracks[2], tracks[0], tracks[1], tracks[7], tracks[5], tracks[4], tracks[6]]))
    }
    
    func test_byArtistAndName_descending() {
        
        assertEmptyPlaylist()
        
        let tracks = [createTrack(fileName: "track09"),
                      createTrack(fileName: "track11"),
                      createTrack(fileName: "track08"),
                      createTrack(fileName: "04 - Endless Dream"),
                      createTrack(title: "Money", artist: "Pink Floyd"),
                      createTrack(title: "Breathe", artist: "Pink Floyd"),
                      createTrack(title: "Time", artist: "Pink Floyd"),
                      createTrack(title: "Dream Fortress", artist: "Grimes")]
        
        tracks.shuffled().forEach {_ = self.playlist.addTrack($0)}
        
        let tracksSort = TracksSort().withFields(.artist, .name).withOrder(.descending)
        let sort = Sort().withTracksSort(tracksSort)
        
        playlist.sort(sort)
        
        XCTAssertTrue(playlist.tracks.elementsEqual([tracks[3], tracks[2], tracks[0], tracks[1], tracks[7], tracks[5], tracks[4], tracks[6]].reversed()))
    }
}
