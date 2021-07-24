//
//  FlatPlaylistTests+Search.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_Search: FlatPlaylistTestCase {
    
    private var library: Library = Library()
    
    func test_noFieldsSpecified() {
        
        assertEmptyPlaylist()
        
        addNTracks(10)
        
        let query = SearchQuery().withText("Madonna").withFields(.none)
        let results = playlist.search(query)
        
        XCTAssertTrue(results.results.isEmpty)
        XCTAssertEqual(results.count, 0)
        XCTAssertFalse(results.hasResults)
    }
    
    private func populatePlaylist(size: Int) {
        
        playlist.clear()
        assertEmptyPlaylist()
        
        func randomIndex() -> Int {
            Int.random(in: 0..<library.size)
        }
        
        var libraryIndices: Set<Int> = Set((0..<size).map {_ in randomIndex()})
        
        while libraryIndices.count < size {
            libraryIndices.insert(randomIndex())
        }
        
        for index in libraryIndices {
            _ = playlist.addTrack(library.tracks[index])
        }
    }
    
    // Returns the number of matching tracks added.
    private func populatePlaylistByName(size: Int, queryText: String, matchType: SearchType, caseSensitive: Bool) -> Int {
        
        playlist.clear()
        assertEmptyPlaylist()
        
        var matchingTracks: [Track] = []
        
        switch matchType {
        
        case .contains:
            
            matchingTracks = library.tracksWithNameContaining(queryText, caseSensitive: caseSensitive)
            
        case .equals:
            
            matchingTracks = library.tracksWithNameEqualing(queryText, caseSensitive: caseSensitive)
            
        case .beginsWith:
            
            matchingTracks = library.tracksWithNameStartingWith(queryText, caseSensitive: caseSensitive)
            
        case .endsWith:
            
            matchingTracks = library.tracksWithNameEndingWith(queryText, caseSensitive: caseSensitive)
        }
            
            
        var addedTracks: Set<Track> = Set()
        
        // If we found more matches than we need, use a subarray instead of the whole array.
        if matchingTracks.count > size {
            matchingTracks = Array(matchingTracks[0..<size])
        }
        
        let numberOfMatches = matchingTracks.count
        
        addedTracks = Set(matchingTracks)
        
        // Add the matching tracks to ensure that a subsequent playlist search
        // by name succeeds.
        for track in matchingTracks {
            _ = playlist.addTrack(track)
        }
        
        while playlist.size < size {
            
            let randomIndex = Int.random(in: 0..<library.size)
            let track = library.tracks[randomIndex]
            
            // Avoid duplicates.
            if !addedTracks.contains(track) {
                
                _ = playlist.addTrack(track)
                addedTracks.insert(track)
            }
        }
        
        return numberOfMatches
    }
    
    func test_byName_noResults() {
        
        let query: SearchQuery = SearchQuery().withText("_RandomABCDText1298Here_").withFields(.name).withType(.contains)
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let playlistSize = Int.random(in: 10...library.size)
            populatePlaylist(size: playlistSize)
            
            let results = playlist.search(query)
                
            XCTAssertTrue(results.results.isEmpty)
            XCTAssertEqual(results.count, 0)
            XCTAssertFalse(results.hasResults)
        }
    }
    
    private func randomArtists(count: Int) -> Set<String> {
        
        let artists = Array(library.uniqueArtists())
        
        let correctedCount = min(artists.count, count)
        return Set((0..<correctedCount).map {_ in artists[Int.random(in: artists.indices)]})
    }
    
    func test_byName_partialTextMatch() {
        
        // Artist names might appear as partial text in multiple track names (Artist - Title.mp3).
        doTestByName(type: .contains, caseSensitive: false, searchTexts: randomArtists(count: 25))
    }
    
    func test_byName_wholeTextMatch() {
        
        doTestByName(type: .contains, caseSensitive: false, searchTexts: library.randomTrackNames(count: 25))
    }
    
    private func doTestByName(type: SearchType, caseSensitive: Bool, searchTexts: Set<String>) {
        
        let nameSearchField: SearchFields = .name
        
        for searchText in searchTexts {
            
            let query = SearchQuery().withText(searchText).withFields(nameSearchField).withType(type)
            
            let playlistSize = Int.random(in: 100...library.size)
            let expectedResultsCount = populatePlaylistByName(size: playlistSize, queryText: searchText,
                                                              matchType: type,
                                                              caseSensitive: false)
            
            let results = playlist.search(query)
            
            XCTAssertEqual(results.count, expectedResultsCount)
            
            if expectedResultsCount > 0 {
                XCTAssertTrue(results.hasResults)
            } else {
                XCTAssertFalse(results.hasResults)
            }
        }
    }
}

extension SearchQuery {

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
}
