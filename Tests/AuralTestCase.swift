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
    
//    func createTrack(_ title: String, _ duration: Double, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil, isValid: Bool = true) -> Track {
//        return createTrack(title, "mp3", duration, artist, album, genre, isValid: isValid)
//    }
//
//    func createTrack(_ title: String, _ fileExtension: String, _ duration: Double,
//                     _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil, isValid: Bool = true) -> Track {
//
//        let track = MockTrack(URL(fileURLWithPath: String(format: "/Dummy/%@.%@", title, fileExtension)), isValid)
////        track.setPrimaryMetadata(artist, title, album, genre, duration)
//
//        return track
//    }
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

        if val1 == nil {

            XCTAssertNil(val2)
            return
        }

        XCTAssertNotNil(val2)

        guard let theVal1 = val1, let theVal2 = val2 else {

            XCTFail("Something went wrong. One of the Double values is nil but shouldn't be.")
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
