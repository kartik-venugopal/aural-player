//
//  GroupingPlaylistTests+SearchByArtist.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GroupingPlaylistTests_SearchByArtist: GroupingPlaylistTestCase {
    
    let playlist = GroupingPlaylist(.artists)
    
    lazy var madonnaTracks = createNTracks(5, artist: "Madonna")
    lazy var grimesTracks = createNTracks(2, artist: "Grimes")
    lazy var biosphereTracks = createNTracks(10, artist: "Biosphere")
    
    lazy var pinkTracks = createNTracks(5, artist: "Pink")
    lazy var pinkFloydTracks = createNTracks(10, artist: "Pink Floyd")
    
    private func setUpWithDistinctArtistNames() {
        
        for track in madonnaTracks + grimesTracks + biosphereTracks {
            _ = playlist.addTrack(track)
        }
        
        XCTAssertEqual(playlist.numberOfGroups, 3)
    }
    
    private func setUpWithOverlappingArtistNames() {
        
        for track in pinkTracks + pinkFloydTracks {
            _ = playlist.addTrack(track)
        }
        
        XCTAssertEqual(playlist.numberOfGroups, 2)
    }
    
    func test1_matchContainsText() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["a", "d", "n", "A", "D", "N",
                          "mad", "madon", "madonna",
                          "Mad", "Madon", "Madonna",
                          "MAD", "MADON", "MADONNA",
                          "ado", "Ado", "ADO", "donna", "Donna", "DONNA"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["g", "G",
                          "gr", "gri", "grim", "grime", "grimes",
                          "Gr", "Gri", "Grim", "Grime", "Grimes",
                          "GR", "GRI", "GRIM", "GRIME", "GRIMES",
                          "rim", "Rim", "RIM", "mes", "Mes", "MES"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["b", "p", "h", "B", "P", "H",
                          "bio", "bios", "biosphere",
                          "Bio", "Bios", "Biosphere",
                          "BIO", "BIOS", "BIOSPHERE",
                          "osp", "Osp", "OSP", "sphere", "Sphere", "SPHERE"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // Matches from multiple groups ----------------------------------------------------
        
        for queryText in ["m", "M"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: madonnaTracks + grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["o", "O"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: madonnaTracks + biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["r", "R", "i", "I", "e", "E", "s", "S"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: grimesTracks + biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Madi", "Gra", "Bia", "sphier", "donni", "rymes"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchContainsText() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["p", "P", "i", "I", "n", "N", "k", "K",
                          "pi", "Pi", "PI",
                          "pin", "Pin", "PIN",
                          "pink", "Pink",
                          "in", "ink"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkTracks + pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["f", "F", "l", "L", "o", "O", "y", "Y", "d", "D",
                          "loy", "loyd", "oyd",
                          "flo", "floy", "floyd",
                          "Flo", "Floy", "Floyd"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
    }
    
    func test1_matchContainsText_caseSensitive() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["M", "a", "d", "n",
                          "Mad", "Madon", "Madonna",
                          "ado", "donna"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["G",
                          "Gr", "Gri", "Grim", "Grime", "Grimes",
                          "rim", "rime", "rimes", "mes"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["B", "p", "h",
                          "Bio", "Bios", "Biosphere",
                          "osp", "sphere"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // Matches from multiple groups ----------------------------------------------------
        
        for queryText in ["o"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: madonnaTracks + biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["r", "i", "e", "s"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: grimesTracks + biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters +
            ["madonna", "grimes", "biosphere", "MAdonna", "GRimes", "BIosphere"] +
            ["Madi", "Gra", "Bia", "sphier", "donni", "rymes"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchContainsText_caseSensitive() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["P", "i", "n", "k",
                          "in", "ink",
                          "Pi", "Pin", "Pink"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: pinkTracks + pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["F", "l", "o", "y", "d",
                          "loy", "oyd",
                          "Flo", "Floy", "Floyd"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        for queryText in ["p", "I", "N", "K",
                          "pi", "PI",
                          "pin", "PIN",
                          "pink", "PINK",
                          "f", "L", "O", "Y", "D",
                          "flo", "floy", "floyd"] {
            
            let query = SearchQuery(text: queryText, type: .contains, fields: .artist, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test1_matchBeginsWithText() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["m", "M",
                          "mad", "madon", "madonna",
                          "Mad", "Madon", "Madonna",
                          "MAD", "MADON", "MADONNA"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["g", "G",
                          "gr", "gri", "grim", "grime", "grimes",
                          "Gr", "Gri", "Grim", "Grime", "Grimes",
                          "GR", "GRI", "GRIM", "GRIME", "GRIMES"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["b", "B",
                          "bio", "bios", "biosphere",
                          "Bio", "Bios", "Biosphere",
                          "BIO", "BIOS", "BIOSPHERE"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["a", "d", "s", "r", "e", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Madi", "Gra", "Bia", "sphier", "donni", "rymes",
                                                         "ado", "Ado", "ADO", "donna", "Donna", "DONNA",
                                                         "rim", "Rim", "RIM", "mes", "Mes", "MES",
                                                         "osp", "Osp", "OSP", "sphere", "Sphere", "SPHERE"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchBeginsWithText() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["p", "P",
                          "pi", "Pi", "PI",
                          "pin", "Pin", "PIN",
                          "pink", "Pink", "PINK"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkTracks + pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["Pink ", "pink ",
                          "Pink F", "pink f", "Pink f",
                          "Pink Floyd", "pink floyd", "Pink floyd", "PINK FLOYD"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
    }
    
    func test1_matchBeginsWithText_caseSensitive() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["M", "Mad", "Madon", "Madonna"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["G", "Gr", "Gri", "Grim", "Grime", "Grimes"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["B", "Bio", "Bios", "Biosphere"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["a", "d", "s", "r", "e", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["m", "g", "b",
                                                         "mad", "madon", "madonna",
                                                         "MAD", "MADON", "MADONNA",
                                                         "GR", "GRI", "GRIM", "GRIME", "GRIMES",
                                                         "gr", "gri", "grim", "grime", "grimes",
                                                         "bio", "bios", "biosphere",
                                                         "BIO", "BIOS", "BIOSPHERE",
                                                         "Madi", "Gra", "Bia"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchBeginsWithText_caseSensitive() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from both groups ----------------------------------------------------
        
        for queryText in ["P", "Pi", "Pin", "Pink"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: pinkTracks + pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["Pink ", "Pink F", "Pink Fl", "Pink Flo", "Pink Floy", "Pink Floyd"] {
            
            let query = SearchQuery(text: queryText, type: .beginsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
    }
    
    func test1_matchEndsWithText() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["madonna", "Madonna", "MADONNA",
                          "a", "A", "na", "NA",
                          "donna", "Donna", "DONNA"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["grimes", "Grimes", "GRIMES",
                          "s", "S", "es", "ES", "mes", "Mes", "MES",
                          "imes", "rimes", "Rimes", "RIMES"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["biosphere", "Biosphere", "BIOSPHERE",
                          "e", "E", "re", "RE", "Re",
                          "sphere", "Sphere", "SPHERE"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["n", "d", "r", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Madonn", "Grime", "Biospher",
                                                         "rymes", "donni", "sphier"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEndsWithText() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["k", "nk", "ink", "K", "NK", "INK",
                          "Pink", "pink", "PINK"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["d", "yd", "oyd", "loyd", "D", "YD", "OYD", "LOYD",
                          "floyd", "Floyd", "FLOYD",
                          "Pink Floyd", "pink floyd", "Pink floyd"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
    }
    
    func test1_matchEndsWithText_caseSensitive() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["Madonna", "a", "na", "onna", "donna"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["Grimes", "s", "es", "mes", "imes", "rimes"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["Biosphere", "e", "re", "sphere"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        let letters = ["n", "d", "r", "i", "o", "c", "f", "u", "x", "y", "z"]
        let capitalizedLetters = letters.map {$0.capitalized}
        
        for queryText in letters + capitalizedLetters + ["Madonn", "Grime", "Biospher",
                                                         "grimes", "madonna", "biosphere",
                                                         "MADONNA", "GRIMES", "BIOSPHERE",
                                                         "Mes", "MES",
                                                         "NNA", "Nna",
                                                         "Donna", "DONNA", "Onna", "ONNA",
                                                         "Rimes", "RIMES",
                                                         "Sphere", "SPHERE",
                                                         "rymes", "donni", "sphier"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEndsWithText_caseSensitive() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["k", "nk", "ink", "Pink"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: pinkTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["d", "yd", "oyd", "loyd", "Floyd", "Pink Floyd"] {
            
            let query = SearchQuery(text: queryText, type: .endsWith, fields: .artist, options: .caseSensitive)
            doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
    }
    
    func test1_matchEqualsText() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        for queryText in ["madonna", "Madonna", "MADONNA", "MadonnA", "MADonna", "MaDoNnA", "mADOnna"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["grimes", "Grimes", "GRIMES", "GrimeS", "GRImes", "GrImEs", "gRIMes"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["biosphere", "Biosphere", "BIOSPHERE", "BiospherE", "BIOSphere", "BiOsPhErE", "bIOSPhere"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        // No matches ----------------------------------------------------
        
        for queryText in ["Madonn", "adonna", "Biospher", "iosphere", "Grime", "rimes"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .none)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEqualsText() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        for queryText in ["Pink", "pink", "PINK", "PiNk", "pInK", "pINk"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkTracks, expectedFieldValueFunction: {$0.artist!})
        }
        
        for queryText in ["Pink Floyd", "pink floyd", "Pink floyd", "pInK fLoYd"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .none)
            doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        }
    }
    
    func test1_matchEqualsText_caseSensitive() {
        
        setUpWithDistinctArtistNames()
        
        // Matches from only 1 group ----------------------------------------------------
        
        var query = SearchQuery(text: "Madonna", type: .equals, fields: .artist, options: .caseSensitive)
        doSearch(query, expectedResultTracks: madonnaTracks, expectedFieldValueFunction: {$0.artist!})
        
        query = SearchQuery(text: "Grimes", type: .equals, fields: .artist, options: .caseSensitive)
        doSearch(query, expectedResultTracks: grimesTracks, expectedFieldValueFunction: {$0.artist!})
        
        query = SearchQuery(text: "Biosphere", type: .equals, fields: .artist, options: .none)
        doSearch(query, expectedResultTracks: biosphereTracks, expectedFieldValueFunction: {$0.artist!})
        
        // No matches ----------------------------------------------------
        
        for queryText in ["madonna", "MADONNA", "MadonnA", "MADonna", "MaDoNnA", "mADOnna",
                          "grimes", "GRIMES", "GrimeS", "GRImes", "GrImEs", "gRIMes",
                          "biosphere", "BIOSPHERE", "BiospherE", "BIOSphere", "BiOsPhErE", "bIOSPhere"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .caseSensitive)
            assertNoResults(for: query)
        }
    }
    
    func test2_matchEqualsText_caseSensitive() {
        
        setUpWithOverlappingArtistNames()
        
        // Matches from only 1 group  ----------------------------------------------------
        
        var query = SearchQuery(text: "Pink", type: .equals, fields: .artist, options: .caseSensitive)
        doSearch(query, expectedResultTracks: pinkTracks, expectedFieldValueFunction: {$0.artist!})
        
        query = SearchQuery(text: "Pink Floyd", type: .equals, fields: .artist, options: .caseSensitive)
        doSearch(query, expectedResultTracks: pinkFloydTracks, expectedFieldValueFunction: {$0.artist!})
        
        // No matches ----------------------------------------------------
        
        for queryText in ["pink", "PINK", "PiNk", "pInK", "pINk"] +
            ["pink floyd", "Pink floyd", "pInK fLoYd"] {
            
            let query = SearchQuery(text: queryText, type: .equals, fields: .artist, options: .caseSensitive)
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
