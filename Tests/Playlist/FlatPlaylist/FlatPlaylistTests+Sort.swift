//
//  FlatPlaylistTests+Sort.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_Sort: FlatPlaylistTestCase {
    
    func test_byName() {
        
        let tracks = [createTrack(fileName: "track09"),
                      createTrack(fileName: "track11"),
                      createTrack(fileName: "track08"),
                      createTrack(fileName: "04 - Endless Dream"),
                      createTrack(title: "Money", artist: "Pink Floyd"),
                      createTrack(title: "Breathe", artist: "Pink Floyd"),
                      createTrack(title: "Time", artist: "Pink Floyd"),
                      createTrack(title: "Dream Fortress", artist: "Grimes")]
        
        let sort = TracksSort().withFields(.name).withOrder(.ascending)
        let expectedOrder = [3, 7, 5, 4, 6, 2, 0, 1]
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    func test_byDuration() {
        
        let tracks = [createTrack(fileName: "track09", duration: 213.46),
                      createTrack(fileName: "track11", duration: 103.67),
                      createTrack(title: "Dream Fortress", artist: "Grimes", duration: 3789.94),
                      createTrack(fileName: "track08", duration: 63.19),
                      createTrack(title: "Time", artist: "Pink Floyd", duration: 672.143)]
        
        let sort = TracksSort().withFields(.duration).withOrder(.ascending)
        let expectedOrder = [3, 1, 0, 4, 2]
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    func test_byArtistAndName() {
        
        let tracks = [createTrack(fileName: "track09"),
                      createTrack(fileName: "track11"),
                      createTrack(fileName: "track08"),
                      createTrack(fileName: "04 - Endless Dream"),
                      createTrack(title: "Money", artist: "Pink Floyd"),
                      createTrack(title: "Breathe", artist: "Pink Floyd"),
                      createTrack(title: "Time", artist: "Pink Floyd"),
                      createTrack(title: "Dream Fortress", artist: "Grimes")]
        
        let sort = TracksSort().withFields(.artist, .name).withOrder(.ascending)
        let expectedOrder = [3, 2, 0, 1, 7, 5, 4, 6]
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    func test_byArtistAlbumDiscAndTrackNumber() {
        
        let tracks = [createTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 6),
                      createTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 2),
                      createTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 4),
                      
                      createTrack(title: "Lunaria", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 13),
                      createTrack(title: "Mycel", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 3),
                      
                      createTrack(title: "Dream Fortress", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 8),
                      createTrack(title: "Be a body", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 8),
                      createTrack(title: "Skin", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 12),
                      
                      createTrack(title: "Fever", artist: "Madonna", album: "Madonna's Greatest Hits", discNum: 1, trackNum: 1),
                      
                      createTrack(title: "Favriel", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 15),
                      
                      createTrack(title: "Dopia", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 2),
                      createTrack(title: "Piota", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 6),
                      createTrack(title: "Atropia", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 10)]
        
        let expectedOrder = [5, 9, 6, 7, 8, 1, 2, 0, 10, 11, 3, 4, 12]
        let sort = TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(.ascending)
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    // Sort should use track name (i.e. displayName) to sort tracks without artist / album metadata.
    func test_byArtistAlbumDiscAndTrackNumber_someTracksMissingArtistAlbumFields() {
        
        let tracks = [createTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 6),
                      createTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 2),
                      createTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 4),
                      
                      createTrack(fileName: "The Sushi Club - Lunaria"),
                      createTrack(fileName: "The Sushi Club - Mycel"),
                      
                      createTrack(title: "Dream Fortress", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 8),
                      createTrack(title: "Be a body", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 8),
                      createTrack(title: "Skin", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 12),
                      
                      createTrack(fileName: "Madonna - Fever"),
                      
                      createTrack(title: "Favriel", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 15),
                      
                      createTrack(title: "Dopia", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 2),
                      createTrack(title: "Piota", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 6),
                      createTrack(title: "Atropia", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 10)]
        
        let expectedOrder = [8, 3, 4, 5, 9, 6, 7, 1, 2, 0, 10, 11, 12]
        let sort = TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(.ascending)
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    func test_byArtistAlbumAndTrackName() {
        
        let tracks = [createTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 6),
                      createTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 2),
                      createTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 4),
                      
                      createTrack(title: "Lunaria", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 13),
                      createTrack(title: "Mycel", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 3),
                      
                      createTrack(title: "Dream Fortress", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 8),
                      createTrack(title: "Be a body", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 8),
                      createTrack(title: "Skin", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 12),
                      
                      createTrack(title: "Fever", artist: "Madonna", album: "Madonna's Greatest Hits", discNum: 1, trackNum: 1),
                      
                      createTrack(title: "Favriel", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 15),
                      
                      createTrack(title: "Dopia", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 2),
                      createTrack(title: "Piota", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 6),
                      createTrack(title: "Atropia", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 10)]
        
        let expectedOrder = [5, 9, 6, 7, 8, 1, 0, 2, 12, 10, 3, 4, 11]
        let sort = TracksSort().withFields(.artist, .album, .name).withOrder(.ascending)
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    func test_byAlbumDiscAndTrackNumber() {
        
        let tracks = [createTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 6),
                      createTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 2),
                      createTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 4),
                      
                      createTrack(title: "Lunaria", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 13),
                      createTrack(title: "Mycel", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 3),
                      
                      createTrack(title: "Dream Fortress", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 8),
                      createTrack(title: "Be a body", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 8),
                      createTrack(title: "Skin", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 12),
                      
                      createTrack(title: "Fever", artist: "Madonna", album: "Madonna's Greatest Hits"),
                      
                      createTrack(title: "Favriel", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 15),
                      
                      createTrack(title: "Dopia", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 2),
                      createTrack(title: "Piota", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 6),
                      createTrack(title: "Atropia", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 10)]
        
        let expectedOrder = [1, 2, 0, 5, 9, 10, 11, 3, 4, 12, 8, 6, 7]
        let sort = TracksSort().withFields(.album, .discNumberAndTrackNumber).withOrder(.ascending)
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    func test_byAlbumDiscAndTrackNumber_someTracksMissingDiscNumOrTrackNum() {
        
        let tracks = [createTrack(title: "Lunaria", artist: "The Sushi Club", album: "Lunarium", trackNum: 13),
                      createTrack(title: "Mycel", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 3),
                      createTrack(title: "Dopia", artist: "The Sushi Club", album: "Lunarium"),
                      createTrack(title: "Piota", artist: "The Sushi Club", album: "Lunarium", trackNum: 6),
                      createTrack(title: "Atropia", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 10)]
        
        let expectedOrder = [2, 3, 0, 4, 1]
        let sort = TracksSort().withFields(.album, .discNumberAndTrackNumber).withOrder(.ascending)
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    func test_byAlbumAndTrackName() {
        
        let tracks = [createTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 6),
                      createTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 2),
                      createTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon", discNum: 1, trackNum: 4),
                      
                      createTrack(title: "Lunaria", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 13),
                      createTrack(title: "Mycel", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 3),
                      
                      createTrack(title: "Dream Fortress", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 8),
                      createTrack(title: "Be a body", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 8),
                      createTrack(title: "Skin", artist: "Grimes", album: "Visions", discNum: 1, trackNum: 12),
                      
                      createTrack(title: "Fever", artist: "Madonna", album: "Madonna's Greatest Hits"),
                      
                      createTrack(title: "Favriel", artist: "Grimes", album: "Halfaxa", discNum: 1, trackNum: 15),
                      
                      createTrack(title: "Dopia", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 2),
                      createTrack(title: "Piota", artist: "The Sushi Club", album: "Lunarium", discNum: 1, trackNum: 6),
                      createTrack(title: "Atropia", artist: "The Sushi Club", album: "Lunarium", discNum: 2, trackNum: 10)]
        
        let expectedOrder = [1, 0, 2, 5, 9, 12, 10, 3, 4, 11, 8, 6, 7]
        let sort = TracksSort().withFields(.album, .name).withOrder(.ascending)
        
        doTest(tracks: tracks, sort: sort, expectedOrder: expectedOrder)
        doTest(tracks: tracks, sort: sort.withOrder(.descending), expectedOrder: expectedOrder.reversed())
    }
    
    private func doTest(tracks: [Track], sort: TracksSort, expectedOrder: [Int]) {
        
        playlist.clear()
        assertEmptyPlaylist()
        
        tracks.shuffled().forEach {_ = self.playlist.addTrack($0)}
        
        playlist.sort(Sort().withTracksSort(sort))
        
        XCTAssertTrue(playlist.tracks.elementsEqual(expectedOrder.map {tracks[$0]}))
    }
}
