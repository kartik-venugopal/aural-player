import XCTest

class PlaybackSequenceTests: AuralTestCase {

    var sequence: PlaybackSequence = PlaybackSequence(.off, .off)
    
    var testSequenceSizes: [Int] {
        
        var sizes: [Int] = [1, 2, 3, 5, 10, 50, 100, 500, 1000]
        
        if runLongRunningTests {sizes.append(10000)}
        
        let numRandomSizes = runLongRunningTests ? 100 : 10
        let maxSize = runLongRunningTests ? 10000 : 1000
        
        for _ in 1...numRandomSizes {
            sizes.append(Int.random(in: 5...maxSize))
        }
        
        return sizes
    }
    
    var repeatOneIdempotence_count: Int {
        return runLongRunningTests ? 10000 : 100
    }
    
    var sequenceRestart_count: Int {
        return runLongRunningTests ? 10 : 3
    }

    var maxStartIndices_count: Int {
        return runLongRunningTests ? 100 : 10
    }
    
    override func setUp() {
        sequence.clear()
    }
    
    let repeatShufflePermutations: [(repeatMode: RepeatMode, shuffleMode: ShuffleMode)] = {
        
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
        
    }()
    
    func initSequence(_ size: Int, _ startingTrackIndex: Int?, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        sequence.clear()
        
        _ = sequence.setRepeatMode(repeatMode)
        let modes = sequence.setShuffleMode(shuffleMode)
        XCTAssertTrue(modes == (repeatMode, shuffleMode))
        
        if size > 0 {
            
            sequence.resizeAndStart(size: size, withTrackIndex: startingTrackIndex)
            
            // Verify the size and current track index.
            XCTAssertEqual(sequence.size, size)
            XCTAssertEqual(sequence.curTrackIndex, startingTrackIndex)
        }
    }
    
    // A function that, given the size and start index of a sequence ... produces a sequence of indices in the order that they should be
    // produced by calls to any of the iteration functions e.g. subsequent(), previous(), etc. This is passed from a test function
    // to a helper function to set the right expectations for the test.
    typealias ExpectedIndicesFunction = (_ size: Int, _ startIndex: Int?) -> [Int?]
}
