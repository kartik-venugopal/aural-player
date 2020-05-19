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
        XCTAssertEqual(modesAfterToggle.repeatMode, expectedRepeatModeAfterToggle)
        XCTAssertEqual(modesAfterToggle.shuffleMode, expectedShuffleModeAfterToggle)
        
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
        XCTAssertEqual(modesAfterToggle.repeatMode, newRepeatMode)
        XCTAssertEqual(modesAfterToggle.shuffleMode, expectedShuffleModeAfter)
        
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
        XCTAssertEqual(modesAfterToggle.repeatMode, expectedRepeatModeAfterToggle)
        XCTAssertEqual(modesAfterToggle.shuffleMode, expectedShuffleModeAfterToggle)
        
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

            for newRepeatMode in RepeatMode.allCases {
                
                // When the new repeat mode is .one, the new shuffle mode must be .off because
                // repeat one and shuffle on cannot be set simultaneously; they are mutually exclusive
                doTestSetShuffleMode(repeatMode, shuffleMode, newRepeatMode, newRepeatMode == .one ? .off : shuffleMode)
            }
        }
    }
    
    private func doTestSetShuffleMode(_ repeatModeBefore: RepeatMode, _ shuffleModeBefore: ShuffleMode,
                                     _ newRepeatMode: RepeatMode, _ expectedShuffleModeAfter: ShuffleMode) {
        
        _ = sequence.setShuffleMode(shuffleModeBefore)
        let modes = sequence.setRepeatMode(repeatModeBefore)
        
        XCTAssertEqual(modes.repeatMode, repeatModeBefore)
        XCTAssertEqual(modes.shuffleMode, shuffleModeBefore)
        
        let modesAfterToggle = sequence.setRepeatMode(newRepeatMode)
        XCTAssertEqual(modesAfterToggle.repeatMode, newRepeatMode)
        XCTAssertEqual(modesAfterToggle.shuffleMode, expectedShuffleModeAfter)
        
        if modesAfterToggle == (.one, .off) {
            
            // When repeat one is set, shuffle is disabled, resulting in the shuffle sequence being cleared.
            XCTAssertEqual(sequence.shuffleSequence.size, 0)
        }
    }
}
