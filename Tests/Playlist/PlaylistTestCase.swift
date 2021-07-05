//
//  PlaylistTestCase.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PlaylistTestCase: AuralTestCase {

    let artists: [String] = ["Conjure One", "Grimes", "Madonna", "Pink Floyd", "Dire Straits", "Ace of Base", "Delerium", "Blue Stone", "Jaia", "Paul Van Dyk"]
    
    let albums: [String] = ["Exilarch", "Halfaxa", "Vogue", "The Wall", "Brothers in Arms", "The Sign", "Music Box Opera", "Messages", "Mai Mai", "Reflections"]
    
    let genres: [String] = ["Electronica", "Pop", "Rock", "Dance", "International", "Jazz", "Ambient", "House", "Trance", "Techno", "Psybient", "PsyTrance", "Classical", "Opera"]
    
    func randomTitle() -> String {
        randomString(length: Int.random(in: 3...50))
    }
    
    func randomDuration() -> Double {
        Double.random(in: 60...10800)
    }
    
    func randomArtist() -> String {
        return artists[Int.random(in: 0..<artists.count)]
    }
    
    func randomAlbum() -> String {
        return albums[Int.random(in: 0..<albums.count)]
    }
    
    func randomGenre() -> String {
        return genres[Int.random(in: 0..<genres.count)]
    }
    
    var testPlaylistSizes: [Int] {
        
        var sizes: [Int] = [1, 2, 3, 5, 10, 50, 100, 500, 1000]
        
        if runLongRunningTests {sizes.append(10000)}
        
        let numRandomSizes = runLongRunningTests ? 100 : 10
        let maxSize = runLongRunningTests ? 10000 : 1000
        
        for _ in 1...numRandomSizes {
            sizes.append(Int.random(in: 5...maxSize))
        }
        
        return sizes
    }
}

