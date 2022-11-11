//
//  FlatPlaylistTests+SearchByTitle.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_SearchByTitle: FlatPlaylistTestCase {
    
    func test_noResults() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        _ = addTrack(title: "Madonna - Fever", artist: nil, album: nil)
        _ = addTrack(fileName: "Madonna - Fever", title: "Fever", artist: nil, album: nil)
        _ = addTrack(fileName: "Fever", title: "Fever", artist: nil, album: "Madonna's Greatest Hits")

        let query = SearchQuery(text: "Eclipse", type: .contains, fields: .title, options: [])
        let results = playlist.search(query)

        XCTAssertTrue(results.results.isEmpty)
        XCTAssertEqual(results.count, 0)
        XCTAssertFalse(results.hasResults)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .contains
    
    func test_matchContainsText() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "Track04", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match2 = addTrack(fileName: "Track07", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2].compactMap {$0.title}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "dream", type: .contains, fields: .title, options: [])
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_matchContainsText_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "04 - Endless dream", title: "Endless dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match = addTrack(fileName: "Track07", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.title!]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Dream", type: .contains, fields: .title, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .beginsWith
    
    func test_matchBeginsWithText() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "04 - dreams of reality", title: "dreams of reality", artist: nil, album: "Exilarch")
        
        _ = addTrack(fileName: "Track04", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match2 = addTrack(fileName: "Track07", title: "Dream Fortress", artist: nil, album: "Visions")
        
        let expectedResultFieldValues = [match1, match2].compactMap {$0.title}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "dream", type: .beginsWith, fields: .title, options: [])
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_matchBeginsWithText_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "04 - dreams of reality", title: "dreams of reality", artist: nil, album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match = addTrack(fileName: "Track07", title: "Dream Fortress", artist: nil, album: "Visions")
        
        let expectedResultFieldValues = [match.title!]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Dream", type: .beginsWith, fields: .title, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .endsWith
    
    func test_matchEndsWithText() {
        
        assertEmptyPlaylist()
        
        let match = addTrack(fileName: "Track04", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track07", title: "Dream Fortress", artist: nil, album: "Visions")
        
        let expectedResultFieldValues = [match.title!]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "dream", type: .endsWith, fields: .title, options: [])
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_matchEndsWithText_caseSensitive() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "Track01", title: "Peace of the Forest", artist: "Dr. Sound Effects", album: "210 hours of nature sounds")
        _ = addTrack(fileName: "Track02", title: "Rainforest", artist: "Soli", album: "Fantasies of solitude")
        _ = addTrack(fileName: "Track03", title: "Wild forest", artist: "Soli", album: "Fantasies of solitude")
        let match2 = addTrack(fileName: "Track04", title: "Rain in the Forest", artist: "Dr. Sound Effects", album: "210 hours of nature sounds")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        
        let expectedResultFieldValues = [match1, match2].compactMap {$0.title}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "Forest", type: .endsWith, fields: .title, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .equals
    
    func test_matchEqualsText() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "track2", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        let match2 = addTrack(fileName: "track2_copy", title: "endless dream", artist: "conjure one", album: "Exilarch")
        let match3 = addTrack(fileName: "track2 copy2", title: "Endless dream", artist: "Conjure one", album: "Exilarch")
        
        _ = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2, match3].compactMap {$0.title}
        let expectedResultTrackIndexes = [match1, match2, match3].compactMap {playlist.indexOfTrack($0)!}

        let query = SearchQuery(text: "endless dream", type: .equals, fields: .title, options: [])
        
        doTest(query: query,
               expectedResultCount: 3,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_matchEqualsText_caseSensitive() {
        
        assertEmptyPlaylist()
        
        let match = addTrack(fileName: "track2", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        _ = addTrack(fileName: "track2_copy", title: "endless dream", artist: "conjure one", album: "Exilarch")
        
        _ = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.title!]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Endless Dream", type: .equals, fields: .title, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["title"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    private func doTest(query: SearchQuery, expectedResultCount: Int, expectedResultFieldKeys: [String],
                        expectedResultFieldValues: [String], expectedResultTrackIndexes: [Int]) {
        
        let results = playlist.search(query)

        XCTAssertEqual(results.count, expectedResultCount)
        XCTAssertEqual(results.hasResults, expectedResultCount > 0)
        
        let resultFieldKeys = results.results.map {$0.match.fieldKey}
        let resultFieldValues = results.results.map {$0.match.fieldValue}
        let resultTrackIndexes = results.results.compactMap {$0.location.trackIndex}
        
        XCTAssertEqual(Set(resultFieldKeys), Set(expectedResultFieldKeys))
        XCTAssertEqual(Set(resultFieldValues), Set(expectedResultFieldValues))
        XCTAssertEqual(Set(expectedResultTrackIndexes), Set(resultTrackIndexes))
    }
}
