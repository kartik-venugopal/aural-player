//
//  AuralTestCase.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class AuralTestCase: XCTestCase {

    var runLongRunningTests: Bool {return false}
    
    var tempDirectory: URL {FileManager.default.temporaryDirectory}
    
    var numSkippedTests: Int = 0
    
    override func perform(_ run: XCTestRun) {
        
        if run.test.name.contains("longRunning") && !runLongRunningTests {
            
            print(String(format: "\tSkipped long running test: %@...", run.test.name))
            numSkippedTests.increment()
            return
        }
        
        super.perform(run)
    }
    
    func executeAfter(_ timeSeconds: Double, _ work: (@escaping () -> Void)) {
        
        let theExpectation = expectation(description: "some expectation")
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + timeSeconds) {
            
            work()
            theExpectation.fulfill()
        }
        
        wait(for: [theExpectation], timeout: timeSeconds + 1)
    }
    
    func justWait(_ timeSeconds: Double) {
        
        let theExpectation = expectation(description: "some expectation")
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + timeSeconds) {
            theExpectation.fulfill()
        }
        
        wait(for: [theExpectation], timeout: timeSeconds + 1)
    }
    
    func fileMetadata(_ title: String, _ artist: String?, _ album: String?, _ genre: String?, _ duration: Double) -> FileMetadata {
        
        let fileMetadata: FileMetadata = FileMetadata()
        var playlistMetadata: PlaylistMetadata = PlaylistMetadata()
        
        playlistMetadata.artist = artist
        playlistMetadata.album = album
        playlistMetadata.genre = genre
        playlistMetadata.duration = duration
        
        fileMetadata.playlist = playlistMetadata
        
        return fileMetadata
    }
    
    func createTrack(title: String, duration: Double, artist: String? = nil, album: String? = nil, genre: String? = nil,
                     isValid: Bool = true) -> Track {
        
        return createTrack(title: title, fileExtension: "mp3", duration: duration, artist: artist, album: album, genre: genre, isValid: isValid)
    }

    func createTrack(title: String, fileExtension: String, duration: Double,
                     artist: String? = nil, album: String? = nil, genre: String? = nil, isValid: Bool = true) -> Track {

        let track = MockTrack(URL(fileURLWithPath: String(format: "/Dummy/%@.%@", title, fileExtension)), isValid)
        let metadata = fileMetadata(title, artist, album, genre, duration)
        track.setPlaylistMetadata(from: metadata)

        return track
    }
    
    // TODO: Run a program to list all unique artists / albums / genres from Music folder and put them into a text/json file.
    // Then load them up in one place (a Utils class) and reuse the Util across unit tests.
    
    let artists: [String] = ["Conjure One", "Grimes", "Madonna", "Pink Floyd", "Dire Straits", "Ace of Base", "Delerium", "Blue Stone", "Jaia", "Paul Van Dyk", "Balligomingo", "Michael Jackson", "ATB"]
    
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
}

extension XCTestCase {
    
    func XCTAssertAllNil(_ expressions: Any?...) {
        expressions.forEach({XCTAssertNil($0)})
    }
    
    func AssertEqual(_ val1: Float?, _ val2: Float?, accuracy: Float) {

        if val1 == nil {

            XCTAssertNil(val2)
            return
        }

        XCTAssertNotNil(val2)

        guard let theVal1 = val1, let theVal2 = val2 else {

            XCTFail("Something went wrong. One of the Float values is nil but shouldn't be.")
            return
        }

        XCTAssertEqual(theVal1, theVal2, accuracy: accuracy)
    }
    
    func AssertEqual(_ val1: Double?, _ val2: Double?, accuracy: Double) {
        
        guard let theVal1 = val1, let theVal2 = val2 else {
            
            if val1 == nil && val2 == nil {
                return
            }

            XCTFail("One of the Double values is nil but shouldn't be.")
            return
        }

        XCTAssertEqual(theVal1, theVal2, accuracy: accuracy)
    }
    
    func AssertEqual(_ arr1: [Float]?, _ arr2: [Float]?, accuracy: Float) {

        if arr1 == nil {

            XCTAssertNil(arr2)
            return
        }

        XCTAssertNotNil(arr2)

        guard let theArr1 = arr1, let theArr2 = arr2 else {

            XCTFail("Something went wrong. One of the [Float] values is nil but shouldn't be.")
            return
        }
        
        XCTAssertEqual(theArr1.count, theArr2.count)
        
        for (elm1, elm2) in zip(theArr1, theArr2) {
            XCTAssertEqual(elm1, elm2, accuracy: accuracy)
        }
    }
}
