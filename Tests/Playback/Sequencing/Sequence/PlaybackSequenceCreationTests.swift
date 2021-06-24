//
//  PlaybackSequenceCreationTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaybackSequenceCreationTests: PlaybackSequenceTests {
    
//    override var runLongRunningTests: Bool {return true}
    
    func testResizeAndStart_lessThan100Elements() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 1..<100 {
                
                doTestResizeAndStart(size, repeatMode, shuffleMode)
                
                for startTrackIndex in 0..<size {
                    doTestResizeAndStart(size, repeatMode, shuffleMode, startTrackIndex)
                }
            }
        }
    }
    
    // Long running test: ~ 45 seconds
    func testResizeAndStart_100To1000Elements_longRunning() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 101...1000 {
                
                // First, perform the test without a starting track index
                doTestResizeAndStart(size, repeatMode, shuffleMode)
                
                // Generate random numbers and use them as starting track indices in the tests.
                // Also test with the first and last elements
                var testStartIndices: [Int] = [0, size - 1]
                
                for _ in 1...25 {
                    testStartIndices.append(Int.random(in: 1..<(size - 1)))
                }
                
                for startIndex in testStartIndices {
                    doTestResizeAndStart(size, repeatMode, shuffleMode, startIndex)
                }
            }
        }
    }
    
    // Long running test: ~ 7 minutes
    func testResizeAndStart_moreThan1000Elements_longRunning() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 1001...10000 {
                
                // First, perform the test without a starting track index
                doTestResizeAndStart(size, repeatMode, shuffleMode)
                
                // Generate random numbers and use them as starting track indices in the tests.
                // Also test with the first and last elements
                var testStartIndices: [Int] = [0, size - 1]
                
                for _ in 1...10 {
                    testStartIndices.append(Int.random(in: 1..<(size - 1)))
                }
                
                for startIndex in testStartIndices {
                    doTestResizeAndStart(size, repeatMode, shuffleMode, startIndex)
                }
            }
        }
    }
    
    private func doTestResizeAndStart(_ size: Int, _ repeatMode: RepeatMode = .off, _ shuffleMode: ShuffleMode = .off, _ startTrackIndex: Int? = nil) {
        
        sequence.clear()
        
        _ = sequence.setRepeatMode(repeatMode)
        _ = sequence.setShuffleMode(shuffleMode)
        
        sequence.resizeAndStart(size: size, withTrackIndex: startTrackIndex)
        
        XCTAssertEqual(sequence.size, size)
        XCTAssertEqual(sequence.curTrackIndex, startTrackIndex)
        
        XCTAssertEqual(sequence.shuffleSequence.size, shuffleMode == .on ? size : 0)
    }
    
    func testResizeAndStart_performance() {
        
        // Only shuffled sequences will result in any significant computations being performed (i.e. allocation of an array),
        // so set the shuffle mode to .on, and set a playing track for all these tests.
        
        _ = sequence.setShuffleMode(.on)
        
        doTestResizeAndStart_performance(100, 2)
        doTestResizeAndStart_performance(500, 5)
        doTestResizeAndStart_performance(1000, 10)
        doTestResizeAndStart_performance(5000, 50)
        doTestResizeAndStart_performance(10000, 100)
    }
    
    private func doTestResizeAndStart_performance(_ size: Int, _ maxExecTime_msec: Double) {
        
        var totalExecTime: Double = 0
        let numRepetitions: Int = 5
        
        // Repeat a few times to get an accurate average execution time.
        for _ in 1...numRepetitions {
            
            // This is important. Must start with an empty sequence to force the sequence to actually allocate a new array each time.
            sequence.clear()
            XCTAssertEqual(sequence.size, 0)
            XCTAssertEqual(sequence.shuffleSequence.size, 0)

            totalExecTime += executionTimeFor {
                
                // Set a playing track to ensure that a shuffle sequence is created
                sequence.resizeAndStart(size: size, withTrackIndex: 0)
            }
            
            // Verify the sequence size property
            XCTAssertEqual(sequence.size, size)
            XCTAssertEqual(sequence.shuffleSequence.size, size)
        }
        
        let avgExecTime: Double = totalExecTime / Double(numRepetitions)
        XCTAssertLessThan(avgExecTime, maxExecTime_msec / 1000.0)
    }
    
    func testStart_performance() {
        
        // Only shuffled sequences will result in any significant computations being performed (i.e. allocation of an array),
        // so set the shuffle mode to .on, and set a playing track for all these tests.
        
        _ = sequence.setShuffleMode(.on)
        
        doTestStart_performance(100, 1)
        doTestStart_performance(500, 1)
        doTestStart_performance(1000, 2)
        doTestStart_performance(5000, 10)
        doTestStart_performance(10000, 20)
    }
    
    private func doTestStart_performance(_ size: Int, _ maxExecTime_msec: Double) {
        
        sequence.resizeAndStart(size: size, withTrackIndex: 0)
        XCTAssertEqual(sequence.size, size)
        XCTAssertEqual(sequence.shuffleSequence.size, size)
        
        var totalExecTime: Double = 0
        let numRepetitions: Int = 5
        
        // Repeat a few times to get an accurate average execution time.
        for _ in 1...numRepetitions {
            
            totalExecTime += executionTimeFor {
                
                // Set a playing track to ensure that a shuffle sequence is created
                sequence.start(withTrackIndex: Int.random(in: 0..<size))
            }
            
            // Verify that the sequence size has not changed
            XCTAssertEqual(sequence.size, size)
            XCTAssertEqual(sequence.shuffleSequence.size, size)
        }
        
        let avgExecTime: Double = totalExecTime / Double(numRepetitions)
        XCTAssertLessThan(avgExecTime, maxExecTime_msec / 1000.0)
    }
    
    func testStart_upTo100Elements() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 1...100 {
                doTestStart(size, repeatMode, shuffleMode)
            }
        }
    }
    
    // Long running test !
    func testStart_100To1000Elements_longRunning() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 101...1000 {
                doTestStart(size, repeatMode, shuffleMode)
            }
        }
    }
    
    // Long running test !
    func testStart_moreThan1000Elements_longRunning() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 1001...10000 {
                doTestStart(size, repeatMode, shuffleMode)
            }
        }
    }
    
    private func doTestStart(_ size: Int, _ repeatMode: RepeatMode = .off, _ shuffleMode: ShuffleMode = .off) {
        
        sequence.clear()
        
        _ = sequence.setRepeatMode(repeatMode)
        _ = sequence.setShuffleMode(shuffleMode)
        
        sequence.resizeAndStart(size: size)
        
        for startTrackIndex in 0..<size {
            
            sequence.start(withTrackIndex: startTrackIndex)
            
            XCTAssertEqual(sequence.size, size)
            XCTAssertEqual(sequence.curTrackIndex, startTrackIndex)
            
            XCTAssertEqual(sequence.shuffleSequence.size, shuffleMode == .on ? size : 0)
        }
    }
    
    func testEnd() {
        
        for size in [0, 1, 2, 3, 4, 5, 10, 100, 500, 1000, 5000, 10000] {
        
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                _ = sequence.setRepeatMode(repeatMode)
                let modes = sequence.setShuffleMode(shuffleMode)
                
                XCTAssertEqual(modes.repeatMode, repeatMode)
                XCTAssertEqual(modes.shuffleMode, shuffleMode)
                
                sequence.resizeAndStart(size: size, withTrackIndex: size / 2)
                
                XCTAssertEqual(sequence.size, size)
                XCTAssertEqual(sequence.curTrackIndex, size / 2)
                
                sequence.end()
                
                // The sequence should no longer be pointing to any element.
                XCTAssertNil(sequence.curTrackIndex)
                
                // The sequence size should not have changed.
                XCTAssertEqual(sequence.size, size)
            }
        }
    }
    
    func testClear() {
        
        for size in [0, 1, 2, 3, 5, 10, 100, 1000, 5000, 10000] {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
                _ = sequence.setRepeatMode(repeatMode)
                let modes = sequence.setShuffleMode(shuffleMode)
                
                XCTAssertEqual(modes.repeatMode, repeatMode)
                XCTAssertEqual(modes.shuffleMode, shuffleMode)
            
                sequence.resizeAndStart(size: size)
                XCTAssertEqual(sequence.size, size)
                
                sequence.clear()
                XCTAssertEqual(sequence.size, 0)
                
                XCTAssertNil(sequence.peekSubsequent())
                XCTAssertNil(sequence.peekPrevious())
                XCTAssertNil(sequence.peekNext())
            }
        }
    }
}
