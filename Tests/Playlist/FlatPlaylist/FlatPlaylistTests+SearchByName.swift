//
//  FlatPlaylistTests+SearchByName.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class FlatPlaylistTests_SearchByName: FlatPlaylistTestCase {
    
    func test_noFieldsSpecified() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")

        let query = SearchQuery(text: "Pink", type: .contains, fields: [], options: [])
        let results = playlist.search(query)

        XCTAssertTrue(results.results.isEmpty)
        XCTAssertEqual(results.count, 0)
        XCTAssertFalse(results.hasResults)
    }
    
    func test_byName_noResults() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")

        let query = SearchQuery(text: "Dream", type: .contains, fields: .name, options: [])
        let results = playlist.search(query)

        XCTAssertTrue(results.results.isEmpty)
        XCTAssertEqual(results.count, 0)
        XCTAssertFalse(results.hasResults)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .contains
    
    func test_byName_matchContainsText_fileNameMatch() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "04 - Endless Dream", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match2 = addTrack(fileName: "Track07_DreamFortress", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2].compactMap {$0.fileSystemInfo.fileName}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "dream", type: .contains, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchContainsText_titleMatch() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "Track04", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match2 = addTrack(fileName: "Track07", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2].compactMap {$0.displayName}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "dream", type: .contains, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchContainsText_artistMatch() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        let match1 = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        let match2 = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        let match3 = addTrack(fileName: "Track03", title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2, match3].compactMap {$0.displayName}
        let expectedResultTrackIndexes = [match1, match2, match3].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "pink", type: .contains, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 3,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchContainsText_fileNameMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "04 - Endless dream", title: "Endless dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match = addTrack(fileName: "Track07_DreamFortress", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.fileSystemInfo.fileName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Dream", type: .contains, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchContainsText_titleMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "04 - Endless dream", title: "Endless dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match = addTrack(fileName: "Track07", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.displayName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Dream", type: .contains, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchContainsText_artistMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        let match1 = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        let match2 = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2].compactMap {$0.displayName}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "Pink", type: .contains, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .beginsWith
    
    func test_byName_matchBeginsWithText_fileNameMatch() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "Endless Dream", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match = addTrack(fileName: "DreamFortress", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.fileSystemInfo.fileName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "dream", type: .beginsWith, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchBeginsWithText_titleMatch() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "Track04", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match = addTrack(fileName: "Track07", title: "Dream Fortress", artist: nil, album: "Visions")
        
        let expectedResultFieldValues = [match.displayName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "dream", type: .beginsWith, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchBeginsWithText_artistMatch() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        let match1 = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        let match2 = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        let match3 = addTrack(fileName: "Track03", title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2, match3].compactMap {$0.displayName}
        let expectedResultTrackIndexes = [match1, match2, match3].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "pink", type: .beginsWith, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 3,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchBeginsWithText_fileNameMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        let match = addTrack(fileName: "BrothersInArms", title: "Brothers in arms", artist: "Dire Straits", album: "Brothers in arms")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "brotherhood", title: "Brotherhood", artist: "Soli", album: "Fantasies of family")
        
        let expectedResultFieldValues = [match.fileSystemInfo.fileName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Brother", type: .beginsWith, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchBeginsWithText_titleMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "04 - dreams of reality", title: "dreams of reality", artist: nil, album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        let match = addTrack(fileName: "Track07", title: "Dream Fortress", artist: nil, album: "Visions")
        
        let expectedResultFieldValues = [match.displayName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Dream", type: .beginsWith, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchBeginsWithText_artistMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        let match1 = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        let match2 = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2].compactMap {$0.displayName}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "Pink", type: .beginsWith, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .endsWith
    
    func test_byName_matchEndsWithText_fileNameMatch() {
        
        assertEmptyPlaylist()
        
        let match = addTrack(fileName: "EndlessDream", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "DreamFortress", title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.fileSystemInfo.fileName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "dream", type: .endsWith, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchEndsWithText_titleMatch() {
        
        assertEmptyPlaylist()
        
        let match = addTrack(fileName: "Track04", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track07", title: "Dream Fortress", artist: nil, album: "Visions")
        
        let expectedResultFieldValues = [match.displayName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "dream", type: .endsWith, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchEndsWithText_fileNameMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "PeaceOfTheForest", title: "Peace of the forest", artist: "Dr. Sound Effects", album: "210 hours of nature sounds")
        _ = addTrack(fileName: "rainforest", title: "Rainforest", artist: "Soli", album: "Fantasies of solitude")
        _ = addTrack(fileName: "wild forest", title: "Wild forest", artist: "Soli", album: "Fantasies of solitude")
        let match2 = addTrack(fileName: "RainInTheForest", title: "Rain in the forest", artist: "Dr. Sound Effects", album: "210 hours of nature sounds")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        
        let expectedResultFieldValues = [match1, match2].map {$0.fileSystemInfo.fileName}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "Forest", type: .endsWith, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchEndsWithText_titleMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "Track01", title: "Peace of the Forest", artist: "Dr. Sound Effects", album: "210 hours of nature sounds")
        _ = addTrack(fileName: "Track02", title: "Rainforest", artist: "Soli", album: "Fantasies of solitude")
        _ = addTrack(fileName: "Track03", title: "Wild forest", artist: "Soli", album: "Fantasies of solitude")
        let match2 = addTrack(fileName: "Track04", title: "Rain in the Forest", artist: "Dr. Sound Effects", album: "210 hours of nature sounds")
        
        _ = addTrack(title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(title: "Time", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        
        let expectedResultFieldValues = [match1, match2].map {$0.displayName}
        let expectedResultTrackIndexes = [match1, match2].compactMap {playlist.indexOfTrack($0)}

        let query = SearchQuery(text: "Forest", type: .endsWith, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 2,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    // ------------------------------------------------------------------------------------
    
    // MARK: Tests with search type = .equals
    
    func test_byName_matchEqualsText_fileNameMatch() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "Conjure One - Endless Dream")
        let match1 = addTrack(fileName: "Endless Dream")
        let match2 = addTrack(fileName: "endless dream")
        let match3 = addTrack(fileName: "Endless dream")
        _ = addTrack(fileName: "EndlessDream")
        
        _ = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2, match3].map {$0.fileSystemInfo.fileName}
        let expectedResultTrackIndexes = [match1, match2, match3].compactMap {playlist.indexOfTrack($0)!}

        let query = SearchQuery(text: "endless dream", type: .equals, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 3,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchEqualsText_fileNameMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        _ = addTrack(fileName: "Conjure One - Endless Dream")
        let match = addTrack(fileName: "Endless Dream")
        _ = addTrack(fileName: "endless dream")
        _ = addTrack(fileName: "Endless dream")
        _ = addTrack(fileName: "EndlessDream")
        
        _ = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.displayName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Endless Dream", type: .equals, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["filename"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchEqualsText_displayNameMatch() {
        
        assertEmptyPlaylist()
        
        let match1 = addTrack(fileName: "track2", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        let match2 = addTrack(fileName: "track2_copy", title: "endless dream", artist: "conjure one", album: "Exilarch")
        let match3 = addTrack(fileName: "track2 copy2", title: "Endless dream", artist: "Conjure one", album: "Exilarch")
        
        _ = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match1, match2, match3].map {$0.displayName}
        let expectedResultTrackIndexes = [match1, match2, match3].compactMap {playlist.indexOfTrack($0)!}

        let query = SearchQuery(text: "conjure one - endless dream", type: .equals, fields: .name, options: [])
        
        doTest(query: query,
               expectedResultCount: 3,
               expectedResultFieldKeys: ["name"],
               expectedResultFieldValues: expectedResultFieldValues,
               expectedResultTrackIndexes: expectedResultTrackIndexes)
    }
    
    func test_byName_matchEqualsText_displayNameMatch_caseSensitive() {
        
        assertEmptyPlaylist()
        
        let match = addTrack(fileName: "track2", title: "Endless Dream", artist: "Conjure One", album: "Exilarch")
        _ = addTrack(fileName: "track2_copy", title: "endless dream", artist: "conjure one", album: "Exilarch")
        
        _ = addTrack(fileName: "Track06", title: "Money", artist: "Pink Floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track01", title: "Breathe", artist: "Pink Floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(fileName: "Track03", title: "Time", artist: "pink floyd", album: "Dark Side of the Moon")
        _ = addTrack(fileName: "Track08", title: "Us and them", artist: "pink floyd", album: "Dark Side of the Moon")
        
        _ = addTrack(title: "Dream Fortress", artist: "Grimes", album: "Visions")
        
        let expectedResultFieldValues = [match.displayName]
        let expectedResultTrackIndexes = [playlist.indexOfTrack(match)!]

        let query = SearchQuery(text: "Conjure One - Endless Dream", type: .equals, fields: .name, options: .caseSensitive)
        
        doTest(query: query,
               expectedResultCount: 1,
               expectedResultFieldKeys: ["name"],
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
