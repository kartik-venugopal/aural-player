import XCTest

class PlaybackSequenceTests: AuralTestCase {
    
//    override var runLongRunningTests: Bool {return true}
    
    private var sequence: PlaybackSequence = PlaybackSequence(.off, .off)
    
    override func setUp() {
        sequence.clear()
    }
    
    private var repeatShufflePermutations: [(repeatMode: RepeatMode, shuffleMode: ShuffleMode)] {
        
        var array: [(repeatMode: RepeatMode, shuffleMode: ShuffleMode)] = []
        
        for repeatMode in RepeatMode.allCases {
        
            for shuffleMode in ShuffleMode.allCases {
                
                // Repeat One / Shuffle On is not a valid permutation
                if (repeatMode, shuffleMode) != (.one, .on) {
                    array.append((repeatMode, shuffleMode))
                }
            }
        }
        
        return array
    }

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
    
    func testStart_upTo100Elements() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 1...100 {
                doTestStart(size, repeatMode, shuffleMode)
            }
        }
    }
    
    // Long running test !
    func test_longRunning_Start_100To1000Elements() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            for size in 101...1000 {
                doTestStart(size, repeatMode, shuffleMode)
            }
        }
    }
    
    // Long running test !
    func test_longRunning_Start_moreThan1000Elements() {
        
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
}
