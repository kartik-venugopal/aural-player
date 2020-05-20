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
        
        print(String(format: "\nExecTime for size: %d = %.5f", size, avgExecTime * 1000.0))
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
        
        print(String(format: "\nExecTime for size: %d = %.5f", size, avgExecTime * 1000.0))
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
        
        _ = sequence.setRepeatMode(.off)
        _ = sequence.setShuffleMode(.off)
        
        sequence.resizeAndStart(size: 10, withTrackIndex: 3)
        XCTAssertEqual(sequence.curTrackIndex, 3)
        
        _ = sequence.next()     // Iterate from #3 to #4
        _ = sequence.next()     // Iterate from #4 to #5
        
        XCTAssertEqual(sequence.curTrackIndex, 5)
        
        sequence.end()
        XCTAssertNil(sequence.curTrackIndex)
    }
    
    func testClear() {
        
        for size in [1, 2, 3, 5, 10, 100, 1000, 5000, 10000] {
            doTestClear(size)
        }
    }
    
    private func doTestClear(_ size: Int) {
        
        sequence.resizeAndStart(size: size)
        XCTAssertEqual(sequence.size, size)
        
        sequence.clear()
        XCTAssertEqual(sequence.size, 0)
        
        XCTAssertNil(sequence.peekSubsequent())
        XCTAssertNil(sequence.peekPrevious())
        XCTAssertNil(sequence.peekNext())
    }
    
    // MARK: toggleRepeatMode() tests ----------------------------------------------------------------------------
    
    func testToggleRepeatMode() {
        
        doTestToggleRepeatMode(.off, .off, .one, .off)
        doTestToggleRepeatMode(.off, .on, .one, .off)
        
        doTestToggleRepeatMode(.one, .off, .all, .off)
        
        doTestToggleRepeatMode(.all, .off, .off, .off)
        doTestToggleRepeatMode(.all, .on, .off, .on)
    }
    
    private func doTestToggleRepeatMode(_ repeatModeBeforeToggle: RepeatMode, _ shuffleModeBeforeToggle: ShuffleMode,
                                        _ expectedRepeatModeAfterToggle: RepeatMode, _ expectedShuffleModeAfterToggle: ShuffleMode) {
        
        _ = sequence.setShuffleMode(shuffleModeBeforeToggle)
        let modes = sequence.setRepeatMode(repeatModeBeforeToggle)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBeforeToggle)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBeforeToggle)
        
        let modesAfterToggle = sequence.toggleRepeatMode()
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfterToggle, expectedShuffleModeAfterToggle))
        
        if modesAfterToggle == (.one, .off) {
            
            // When repeat one is set, shuffle is disabled, resulting in the shuffle sequence being cleared.
            XCTAssertEqual(sequence.shuffleSequence.size, 0)
        }
    }
    
    func testSetRepeatMode() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            for newRepeatMode in RepeatMode.allCases {
                
                // When the new repeat mode is .one, the new shuffle mode must be .off because
                // repeat one and shuffle on cannot be set simultaneously; they are mutually exclusive
                doTestSetRepeatMode(repeatMode, shuffleMode, newRepeatMode, newRepeatMode == .one ? .off : shuffleMode)
            }
        }
    }
    
    private func doTestSetRepeatMode(_ repeatModeBefore: RepeatMode, _ shuffleModeBefore: ShuffleMode,
                                     _ newRepeatMode: RepeatMode, _ expectedShuffleModeAfter: ShuffleMode) {
        
        _ = sequence.setShuffleMode(shuffleModeBefore)
        let modes = sequence.setRepeatMode(repeatModeBefore)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBefore)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBefore)
        
        let modesAfterToggle = sequence.setRepeatMode(newRepeatMode)
        XCTAssertTrue(modesAfterToggle == (newRepeatMode, expectedShuffleModeAfter))
        
        if modesAfterToggle == (.one, .off) {
            
            // When repeat one is set, shuffle is disabled, resulting in the shuffle sequence being cleared.
            XCTAssertEqual(sequence.shuffleSequence.size, 0)
        }
    }
    
    // MARK: toggleShuffleMode() tests ----------------------------------------------------------------------------
    
    func testToggleShuffleMode() {
        
        doTestToggleShuffleMode(.off, .off, .off, .on)
        doTestToggleShuffleMode(.off, .on, .off, .off)
        
        // Repeat one should be disabled when shuffle is turned on.
        doTestToggleShuffleMode(.one, .off, .off, .on)
        
        doTestToggleShuffleMode(.all, .off, .all, .on)
        doTestToggleShuffleMode(.all, .on, .all, .off)
    }
    
    private func doTestToggleShuffleMode(_ repeatModeBeforeToggle: RepeatMode, _ shuffleModeBeforeToggle: ShuffleMode,
                                        _ expectedRepeatModeAfterToggle: RepeatMode, _ expectedShuffleModeAfterToggle: ShuffleMode) {
        
        _ = sequence.setRepeatMode(repeatModeBeforeToggle)
        let modes = sequence.setShuffleMode(shuffleModeBeforeToggle)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBeforeToggle)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBeforeToggle)
        
        let modesAfterToggle = sequence.toggleShuffleMode()
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfterToggle, expectedShuffleModeAfterToggle))
        
        if modesAfterToggle.shuffleMode == .off {
            
            // When shuffle is disabled, the shuffle sequence should be cleared.
            XCTAssertEqual(sequence.shuffleSequence.size, 0)
        }
    }
    
    func testToggleShuffleMode_OffToOn_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Since no track is playing, shuffle sequence should not have been created when shuffle was set to On.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
    }
    
    func testToggleShuffleMode_OnToOff_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is on, but there is no playing track, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // On -> Off
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been cleared when shuffle was turned off.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
    }
    
    func testToggleShuffleMode_OffToOn_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
    }
    
    func testToggleShuffleMode_OnToOff_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is on, and there is a playing track, so shuffle sequence should not be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
        
        // On -> Off
        let shuffleModeAfter = sequence.toggleShuffleMode().shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
    }
    
    func testSetShuffleMode() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            for newShuffleMode in ShuffleMode.allCases {
                
                // When the new repeat mode is .one, the new shuffle mode must be .off because
                // repeat one and shuffle on cannot be set simultaneously; they are mutually exclusive
                doTestSetShuffleMode(repeatMode, shuffleMode, (repeatMode, newShuffleMode) == (.one, .on) ? .off : repeatMode, newShuffleMode)
            }
        }
    }
    
    private func doTestSetShuffleMode(_ repeatModeBefore: RepeatMode, _ shuffleModeBefore: ShuffleMode,
                                     _ expectedRepeatModeAfter: RepeatMode, _ newShuffleMode: ShuffleMode) {
        
        _ = sequence.setRepeatMode(repeatModeBefore)
        let modes = sequence.setShuffleMode(shuffleModeBefore)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBefore)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBefore)
        
        let modesAfterToggle = sequence.setShuffleMode(newShuffleMode)
        XCTAssertTrue(modesAfterToggle == (expectedRepeatModeAfter, newShuffleMode))
    }
    
    func testSetShuffleMode_OffToOn_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Since no track is playing, shuffle sequence should not have been created when shuffle was set to On.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
    }
    
    func testSetShuffleMode_OnToOff_noPlayingTrack() {
        
        sequence.resizeAndStart(size: 10)
        
        // Ensure no playing track
        XCTAssertNil(sequence.curTrackIndex)

        // Shuffle is on, but there is no playing track, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // On -> Off
        let shuffleModeAfter = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been cleared when shuffle was turned off.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
    }
    
    func testSetShuffleMode_OffToOn_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is off, so shuffle sequence should be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .off)
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        
        // Off -> On
        let shuffleModeAfter = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .on)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
    }
    
    func testSetShuffleMode_OnToOff_withPlayingTrack() {
        
        // Create a sequence and set a playing track index to simulate a currently playing track.
        sequence.resizeAndStart(size: 10, withTrackIndex: 4)
        
        // Ensure the playing track index matches.
        XCTAssertEqual(sequence.curTrackIndex, 4)

        // Shuffle is on, and there is a playing track, so shuffle sequence should not be empty.
        let shuffleModeBefore = sequence.setShuffleMode(.on).shuffleMode
        XCTAssertEqual(shuffleModeBefore, .on)
        XCTAssertEqual(sequence.shuffleSequence.size, sequence.size)
        XCTAssertEqual(sequence.shuffleSequence.currentValue, sequence.curTrackIndex)
        
        // On -> Off
        let shuffleModeAfter = sequence.setShuffleMode(.off).shuffleMode
        XCTAssertEqual(shuffleModeAfter, .off)
        
        // Shuffle sequence should have been created when shuffle was turned On, and its start index should match the playing track.
        XCTAssertEqual(sequence.shuffleSequence.size, 0)
        XCTAssertNil(sequence.shuffleSequence.currentValue)
    }
    
    // MARK: subsequent() tests -----------------------------------------------------------------------------------------------
    
    // A function that, given the size and start index of a sequence ... produces a sequence of indices in the order that they should be
    // produced by calls to any of the iteration functions e.g. subsequent(), previous(), etc. This is passed from a test function
    // to a helper function to set the right expectations for the test.
    fileprivate typealias ExpectedIndicesFunction = (_ size: Int, _ startIndex: Int?) -> [Int?]
    
    func testSubsequent_repeatOff_ShuffleOff_withPlayingTrack() {
        
        doTestSubsequent(true, .off, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            var subsequentIndices: [Int?] = size == 1 ? [] : Array((startIndex! + 1)..<size)
            
            // Test that:
            // 1 - after the last track (i.e. at the end of the sequence), nil is returned.
            // 2 - after the sequence has ended and nil is returned, the following call to subsequent() should return 0 because the sequence restarts.
            // 3 - the sequence should then repeat again sequentially: 0, 1, 2, ...
            subsequentIndices.append(nil)
            subsequentIndices.append(contentsOf: Array(0..<size))
            
            // The results should look like this:
            // startIndex, startIndex + 1, startIndex + 2, ..., (n - 1), nil, 0, 1, 2, ... (n - 1), where n is the size of the array
            
            return subsequentIndices
        })
    }
    
    func testSubsequent_repeatOff_ShuffleOff_noPlayingTrack() {
        
        doTestSubsequent(false, .off, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // Because there is no playing track, the sequence should start at 0.
            var subsequentIndices: [Int?] = Array(0..<size)
            
            // Test that:
            // 1 - after the last track (i.e. at the end of the sequence), nil is returned.
            // 2 - after the sequence has ended and nil is returned, the following call to subsequent() should return 0 because the sequence restarts.
            // 3 - the sequence should then repeat again sequentially: 0, 1, 2, ...
            subsequentIndices.append(nil)
            subsequentIndices.append(contentsOf: Array(0..<size))
            
            // The results should look like this:
            // 0, 1, 2, ..., (n - 1), nil, 0, 1, 2, ... (n - 1), where n is the size of the array
            
            return subsequentIndices
        })
    }
    
    func testSubsequent_repeatOne_ShuffleOff_withPlayingTrack() {
        
        doTestSubsequent(true, .one, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // When there is a playing track, the first call to subsequent() should produce the same track, i.e. startIndex.
            // Repeated subsequent() calls should also produce startIndex indefinitely.
            return Array(repeating: startIndex!, count: 10000)
        })
    }
    
    func testSubsequent_repeatOne_ShuffleOff_noPlayingTrack() {
        
        doTestSubsequent(false, .one, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // When there is no playing track, the first call to subsequent() should produce the first track, i.e. 0.
            // Repeated subsequent() calls should also produce 0 indefinitely.
            return Array(repeating: 0, count: 10000)
        })
    }
    
    func testSubsequent_repeatAll_ShuffleOff_withPlayingTrack() {
        
        doTestSubsequent(true, .all, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            var subsequentIndices: [Int?] = size == 1 ? [] : Array((startIndex! + 1)..<size)
            
            // Test that:
            // 1 - after the last track (i.e. at the end of the sequence), the following call to subsequent() should return 0 because the sequence restarts.
            // 2 - the sequence should then repeat again sequentially: 0, 1, 2, ...
            subsequentIndices.append(contentsOf: Array(0..<size))
            
            // The results should look like this:
            // startIndex, startIndex + 1, startIndex + 2, ..., (n - 1), 0, 1, 2, ... (n - 1), where n is the size of the array
            
            return subsequentIndices
        })
    }
    
    func testSubsequent_repeatAll_ShuffleOff_noPlayingTrack() {
        
        doTestSubsequent(false, .all, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            var subsequentIndices: [Int?] = Array(0..<size)
            
            // Test that:
            // 1 - after the last track (i.e. at the end of the sequence), the following call to subsequent() should return 0 because the sequence restarts.
            // 2 - the sequence should then repeat again sequentially: 0, 1, 2, ...
            subsequentIndices.append(contentsOf: Array(0..<size))
            
            // The results should look like this:
            // 0, 1, 2, ..., (n - 1), 0, 1, 2, ... (n - 1), 0, 1, 2, ... (n - 1), where n is the size of the array.
            
            return subsequentIndices
        })
    }
    
    func testSubsequent_repeatOff_ShuffleOn_withPlayingTrack() {
        
        doTestSubsequent(true, .off, .on, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // The sequence of elements produced by calls to subsequent() should match the shuffle sequence array,
            // starting with its 2nd element (the first element is already playing).
            var subsequentIndices: [Int?] = sequence.shuffleSequence.sequence.suffix(size - 1)
            
            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            subsequentIndices.append(nil)
            
            return subsequentIndices
        })
    }
    
    func testSubsequent_repeatOff_ShuffleOn_noPlayingTrack() {
        
        doTestSubsequent(false, .off, .on, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // The sequence of elements produced by calls to subsequent() should exactly match the shuffle sequence array.
            var subsequentIndices: [Int?] = Array(sequence.shuffleSequence.sequence)
            
            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            subsequentIndices.append(nil)
            
            return subsequentIndices
        })
    }
    
    func testSubsequent_repeatAll_ShuffleOn_withPlayingTrack() {

        doTestSubsequent(true, .all, .on, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // The sequence of elements produced by calls to subsequent() should exactly match the shuffle sequence array.
            return Array(sequence.shuffleSequence.sequence.suffix(size - 1))
            
        }, 10)   // Repeat sequence iteration 10 times to test repeat all.
    }
    
    func testSubsequent_repeatAll_ShuffleOn_noPlayingTrack() {
        
        doTestSubsequent(false, .all, .on, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // The sequence of elements produced by calls to subsequent() should exactly match the shuffle sequence array.
            return Array(sequence.shuffleSequence.sequence)
            
        }, 10) // Repeat sequence iteration 10 times to test repeat all.
    }
    
    // NOTE - The size of the expectedIndices array will determine how many times subsequent() will be called (and tested).
    private func doTestSubsequent(_ hasPlayingTrack: Bool, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode, _ expectedIndicesFunction: ExpectedIndicesFunction, _ repeatCount: Int = 0) {
        
        var randomSizes: [Int] = [1, 2, 3, 4]
        
        for _ in 1...100 {
            randomSizes.append(Int.random(in: 5...10000))
        }
        
        for size in randomSizes {
            
            var startIndex: Int? = nil
            
            if hasPlayingTrack {
                startIndex = size == 1 ? 0 : Int.random(in: 0..<(size - 1))
            }
            
            initSequence(size, startIndex, repeatMode, shuffleMode)
            
            let subsequentIndices: [Int?] = expectedIndicesFunction(size, startIndex)
            
            for value in subsequentIndices {
                
                XCTAssertEqual(sequence.subsequent(), value)
                XCTAssertEqual(sequence.curTrackIndex, value)
            }
            
            // This should only execute when repeat = .all and shuffle = .on, and the test is meaningful only for sufficiently large sequences.
            if repeatCount > 0 && size >= 10 {
                doTestSubsequent_shuffleAndRepeat_uniqueSequenceCreation(sequence.shuffleSequence.sequence, repeatCount)
            }
        }
    }
    
    // Helper function that iterates through an entire shuffle sequence, testing that calls to
    // subsequent() produce values matching the sequence. Based on the given repeatCount,
    // the iteration through the sequence is repeated a number of times so that multiple new
    // sequences are created (as a result of the repeat all setting).
    //
    // firstShuffleSequence is used for comparison to the new sequence created when it ends.
    // As each following sequence ends, a new one is created (because of the repeat all setting).
    // Need to ensure that each new sequence differs from the last.
    private func doTestSubsequent_shuffleAndRepeat_uniqueSequenceCreation(_ firstShuffleSequence: [Int], _ repeatCount: Int) {
        
        // Start the loop with firstShuffleSequence
        var previousShuffleSequence: [Int] = firstShuffleSequence
        let size: Int = previousShuffleSequence.count
        
        for _ in 1...repeatCount {
        
            // NOTE - The first element of the new shuffle sequence cannot be predicted, but it suffices to test that it is
            // non-nil and that it differs from the last element of the first sequence (this is by requirement).
            let firstElementOfNewSequence: Int? = sequence.subsequent()
            XCTAssertNotNil(firstElementOfNewSequence)
            
            // If there is only one element in the sequence, this comparison is not valid.
            if size > 1 {
                XCTAssertNotEqual(firstElementOfNewSequence, previousShuffleSequence.last)
            }
            
            // Capture the newly created sequence, and ensure it's of the same size as the previous one.
            let newShuffleSequence = Array(sequence.shuffleSequence.sequence)
            XCTAssertEqual(newShuffleSequence.count, previousShuffleSequence.count)
            
            // Test that the newly created shuffle sequence differs from the last one, if it is sufficiently large.
            // NOTE - For small sequences the new sequence might co-incidentally be the same as the first one.
            if size >= 10 {
                XCTAssertFalse(newShuffleSequence.elementsEqual(previousShuffleSequence))
            }
            
            // Now, ensure that the following calls to subsequent() produce a sequence matching the new shuffle sequence (minus the first element).
            // NOTE - Skip the first element which has already been produced and tested.
            for value in newShuffleSequence.suffix(size - 1) {
                
                XCTAssertEqual(sequence.subsequent(), value)
                XCTAssertEqual(sequence.curTrackIndex, value)
            }
            
            // Update the previousShuffleSequence variable with the new sequence, to be used for comparison in the next loop iteration.
            previousShuffleSequence = newShuffleSequence
        }
    }
    
    private func initSequence(_ size: Int, _ startingTrackIndex: Int?, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        sequence.clear()
        
        _ = sequence.setRepeatMode(repeatMode)
        let modes = sequence.setShuffleMode(shuffleMode)
        XCTAssertTrue(modes == (repeatMode, shuffleMode))
        
        sequence.resizeAndStart(size: size, withTrackIndex: startingTrackIndex)
    }
}
