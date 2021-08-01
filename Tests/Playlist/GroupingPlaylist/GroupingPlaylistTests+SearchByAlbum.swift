//
//  GroupingPlaylistTests+SearchByAlbum.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GroupingPlaylistTests_SearchByAlbum: GroupingPlaylistTestCase {
    
    let playlist = GroupingPlaylist(.albums)
    
    lazy var halfaxaTracks = createNTracks(5, artist: "Grimes", album: "Halfaxa")
    lazy var visionsTracks = createNTracks(2, artist: "Grimes", album: "Visions")
    lazy var substrataTracks = createNTracks(10, artist: "Biosphere", album: "Substrata")
    
    lazy var dreamTracks = createNTracks(5, album: "Dream")
    lazy var dreamsOfRealityTracks = createNTracks(10, album: "Dreams of Reality")
    
    private func setUpWithDistinctAlbumNames() {
        
        for track in halfaxaTracks + visionsTracks + substrataTracks {
            _ = playlist.addTrack(track)
        }
        
        XCTAssertEqual(playlist.numberOfGroups, 3)
    }
    
    private func setUpWithOverlappingAlbumNames() {
        
        for track in dreamTracks + dreamsOfRealityTracks {
            _ = playlist.addTrack(track)
        }
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
    }
    
    func test1_matchContainsText() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["h", "l", "f", "x", "H", "L", "F", "X",
                          "hal", "halfa", "halfaxa",
                          "Hal", "Halfa", "Halfaxa",
                          "HAL", "HALFA", "HALFAXA",
                          "alf", "lfax", "ALFAXA", "alfa", "axa", "AXA"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["v", "i", "o", "n",
                          "V", "I", "O", "N",
                          "vi", "vis", "visio", "vision", "visions",
                          "Vi", "Vis", "Visio", "Vision", "Visions",
                          "VI", "VIS", "VISIO", "VISION", "VISIONS",
                          "ion", "Ion", "sions", "SIONS", "Sions", "isio"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["u", "b", "t", "r",
                          "U", "B", "T", "R",
                          "sub", "subs", "substr", "substrata",
                          "Sub", "Subs", "Substr", "Substrata",
                          "SUB", "SUBS", "SUBSTR", "SUBSTRATA",
                          "ubs", "Ubs", "UBS", "strata", "Strata", "STRATA"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // Matches from multiple groups ----------------------------------------------------
        
        for queryText in ["a", "A"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: halfaxaTracks + substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["s", "S"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: visionsTracks + substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["c", "g", "w", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Halfi", "Vison", "Subtra", "stratum", "siones"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchContainsText() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["d", "r", "e" , "a", "m",
                          "dr", "Dr", "DR",
                          "eam", "Eam", "EAM",
                          "dream", "Dream", "DREAM"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamTracks + dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["dreams", "Dreams", "DREAMS",
                          "of", "OF", "Of",
                          "Reality", "reality", "REALITY"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
    }
    
    func test1_matchContainsText_caseSensitive() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["H", "l", "f", "x",
                          "Hal", "Halfa", "Halfaxa",
                          "lfax", "alfaxa"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["V",
                          "Vi", "Vis", "Visi", "Vision", "Visions",
                          "isi", "isio", "ision", "ions"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["S", "u", "b", "t", "r",
                          "Sub", "Subs", "Substrata",
                          "strat", "strata"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // Matches from multiple groups ----------------------------------------------------
        
        for queryText in ["a"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: halfaxaTracks + substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["s"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: visionsTracks + substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["c", "g", "w", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["HAlfaxa", "VIsions", "SUbstrata",
                                                         "halfaxa", "visions", "substrata",
                                                         "HALFAXA", "VISIONS", "SUBSTRATA"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchContainsText_caseSensitive() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["r", "e" , "a", "m",
                          "Dr", "eam", "Dream"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: dreamTracks + dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["Dreams", "of", "R", "Reality"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        for queryText in ["d", "E", "A", "M",
                          "dr", "DR",
                          "dre", "DRE",
                          "dream", "DREAM",
                          "OF", "reality", "rEALITY", "REALITY"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .album, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test1_matchBeginsWithText() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["h", "H",
                          "hal", "halfa", "halfaxa",
                          "Hal", "Halfa", "Halfaxa",
                          "HAL", "HALFA", "HALFAXA"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["v", "V",
                          "vi", "vis", "vision", "visions",
                          "Vi", "Vis", "Vision", "Visions",
                          "VI", "VIS", "VISION", "VISIONS"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["s", "S",
                          "sub", "substr", "substrata",
                          "Sub", "Substr", "Substrata",
                          "SUB", "SUBSTR", "SUBSTRATA"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["u", "b", "e", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Hald", "Vid", "Subd",
                                                         "hald", "vid", "subd",
                                                         "ubstrata", "alfaxa", "isions"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchBeginsWithText() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["d", "D",
                          "dr", "Dr", "DR",
                          "dre", "Dre", "DRE",
                          "dream", "Dream", "DREAM"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamTracks + dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["Dreams", "dreams", "Dreams ", "dreams ",
                          "Dreams of", "dreams of", "Dreams Of",
                          "Dreams of Reality", "dreams of reality", "Dreams Of Reality"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
    }
    
    func test1_matchBeginsWithText_caseSensitive() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["H", "Hal", "Halfa", "Halfaxa"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["V", "Vi", "Vis", "Vision", "Visions"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["S", "Sub", "Substr", "Substrata"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["a", "d", "r", "e", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["h", "v", "s",
                                                         "hal", "halfa", "halfaxa",
                                                         "HAL", "HALFA", "HALFAXA",
                                                         "vi", "vis", "vision", "visions",
                                                         "VI", "VIS", "VISION", "VISIONS",
                                                         "sub", "substr", "substrata",
                                                         "SUB", "SUBSTR", "SUBSTRATA",
                                                         "Hald", "Viz", "Sun"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchBeginsWithText_caseSensitive() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["D", "Dr", "Dre", "Drea", "Dream"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: dreamTracks + dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["Dreams", "Dreams ", "Dreams of", "Dreams of R", "Dreams of Reality"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
    }
    
    func test1_matchEndsWithText() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["halfaxa", "Halfaxa", "HALFAXA",
                          "xa", "Xa", "XA",
                          "faxa", "Faxa", "FAXA"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["visions", "Visions", "VISIONS",
                          "s", "S", "ns", "NS",
                          "sions", "Sions", "SIONS"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["substrata", "Substrata", "SUBSTRATA",
                          "ata", "Ata", "ATA", "AtA",
                          "strata", "Strata", "STRATA"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // Matches from 2 groups ----------------------------------------------------
        
        for queryText in ["a", "A"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: halfaxaTracks + substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["n", "d", "r", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Halfax", "alaxa", "Vision", "siones",
                                                         "Substrat", "stratum"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEndsWithText() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["m", "am", "eam", "M", "AM", "EAM",
                          "Dream", "dream", "DREAM"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["y", "ty", "reality", "Y", "TY", "REALITY",
                          "of reality", "Of Reality", "of Reality", "Of reality",
                          "Dreams of reality", "Dreams Of Reality", "dreams of reality",
                          "dreams Of Reality", "Dreams of Reality", "dreams of Reality"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
    }
    
    func test1_matchEndsWithText_caseSensitive() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["Halfaxa", "xa", "axa", "faxa", "alfaxa"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["Visions", "s", "ns", "ions", "sions"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["Substrata", "ta", "ata", "strata"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["n", "d", "r", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Halfax", "Vision", "Substrat",
                                                         "alaxa", "alfax", "siones", "sion", "strat", "stratum"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEndsWithText_caseSensitive() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["m", "am", "eam", "ream", "Dream"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: dreamTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["y", "ty", "Reality", "of Reality", " of Reality", " Reality", "Dreams of Reality"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .album, options: .caseSensitive)
            doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
    }
    
    func test1_matchEqualsText() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["halfaxa", "Halfaxa", "HALFAXA", "HalfaxA", "HAlfaxa", "HaLfAxA", "hALfaxa"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["visions", "Visions", "VISIONS", "VisionS", "VISions", "ViSiOnS", "vISIOns"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["substrata", "Substrata", "SUBSTRATA", "SubstratA", "SUBStrata", "SuBsTrAtA", "sUBSTrata"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        // No matches ----------------------------------------------------
        
        for queryText in ["Halfax", "alfaxa", "Vision", "isions", "Substrat", "ubstrata"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEqualsText() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["Dream", "dream", "DREAM", "DrEAm", "dREAm", "dReAm"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamTracks, expectedFieldValueFunction: {$0.album!})
        }
        
        for queryText in ["Dreams of Reality", "Dreams of reality", "dreams of reality", "Dreams OF reaLITY", "dREAms oF reaLIty"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .none)
            doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        }
    }
    
    func test1_matchEqualsText_caseSensitive() {
        
        setUpWithDistinctAlbumNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        var query = SearchQuery(text: "Halfaxa", type: .equals, fields: .album, options: .caseSensitive)
        doSearch(query, expectedResultTracks: halfaxaTracks, expectedFieldValueFunction: {$0.album!})
        
        query = SearchQuery(text: "Visions", type: .equals, fields: .album, options: .caseSensitive)
        doSearch(query, expectedResultTracks: visionsTracks, expectedFieldValueFunction: {$0.album!})
        
        query = SearchQuery(text: "Substrata", type: .equals, fields: .album, options: .none)
        doSearch(query, expectedResultTracks: substrataTracks, expectedFieldValueFunction: {$0.album!})
        
        // No matches ----------------------------------------------------
        
        for queryText in ["halfaxa", "HALFAXA", "HalfaxA", "HALfaxa", "HaLfAxA", "hALFaxa",
                          "visions", "VISIONS", "VisionS", "VISions", "ViSiOnS", "vISIons",
                          "substrata", "SUBSTRATA", "SubstratA", "SUBStrata", "SuBsTrAtA", "sUBStraTa"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEqualsText_caseSensitive() {
        
        setUpWithOverlappingAlbumNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        var query = SearchQuery(text: "Dream", type: .equals, fields: .album, options: .caseSensitive)
        doSearch(query, expectedResultTracks: dreamTracks, expectedFieldValueFunction: {$0.album!})
        
        query = SearchQuery(text: "Dreams of Reality", type: .equals, fields: .album, options: .caseSensitive)
        doSearch(query, expectedResultTracks: dreamsOfRealityTracks, expectedFieldValueFunction: {$0.album!})
        
        // No matches ----------------------------------------------------
        
        for queryText in ["dream", "DREAM", "DReam", "dReAm", "dREAm"] +
            ["dreams of reality", "Dreams Of Reality", "dreams of Reality", "dreAMS oF rEALity"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .album, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    private func doSearch(_ query: SearchQuery, expectedResultTracks: [Track], expectedFieldValueFunction: (Track) -> String) {
        
        let results = playlist.search(query)
        
        XCTAssertTrue(results.hasResults)
        XCTAssertEqual(results.count, expectedResultTracks.count)
        
        for track in expectedResultTracks {
            
            guard let resultForTrack = results.results.first(where: {$0.location.track == track}) else {
                
                XCTFail("Didn't find search result for track: \(track.displayName)")
                return
            }
            
            XCTAssertEqual(resultForTrack.match.fieldKey, playlist.typeOfGroups.rawValue)
            XCTAssertEqual(resultForTrack.match.fieldValue, expectedFieldValueFunction(track))
        }
    }
    
    private func assertNoResults(for query: SearchQuery) {
        
        let results = playlist.search(query)
        
        XCTAssertFalse(results.hasResults)
        XCTAssertEqual(results.count, 0)
    }
}

