import XCTest

class PlaybackSequencePeekingTests: PlaybackSequenceTests {
    
//    override var runLongRunningTests: Bool {return true}
    
    // MARK: peekSubsequent() tests -----------------------------------------------------------------------------------------------
    
    func testPeekSubsequent_repeatOff_shuffleOff_withPlayingTrack() {
        
        doTestPeekSubsequent(true, .off, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // When there is a playing track, startIndex cannot be nil.
            XCTAssertNotNil(startIndex)
            
            // Because there is a playing track (represented by startIndex), the test should start at startIndex + 1.
            var peekSubsequentIndices: [Int?] = size == 1 ? [] : Array((startIndex! + 1)..<size)
            
            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            peekSubsequentIndices.append(nil)
            
            // Following the nil value, the sequence should restart at index 0. Test this with a repeat count.
            
            // The test results should look like this:
            // startIndex + 1, startIndex + 2, ..., (n - 1), nil, 0, 1, 2, ... (n - 1), 0, 1, 2, ... where n is the size of the array
            
            return peekSubsequentIndices
            
        }, sequenceRestart_count)  // Repeat sequence recreation
    }
    
    func testPeekSubsequent_repeatOff_shuffleOff_noPlayingTrack() {

        doTestPeekSubsequent(false, .off, .off, {(size: Int, startIndex: Int?) -> [Int?] in

            // Because there is no playing track, the test should start at 0 and contain the entire sequence.
            var peekSubsequentIndices: [Int?] = Array(0..<size)

            // Test that:
            // 1 - after the last track (i.e. at the end of the sequence), nil is returned.
            // 2 - after the sequence has ended and nil is returned, the following call to peekSubsequent() should return 0 because the sequence restarts.
            // 3 - the sequence should then repeat again sequentially: 0, 1, 2, ...
            peekSubsequentIndices.append(nil)
            peekSubsequentIndices += Array(0..<size)

            // The test results should look like this:
            // 0, 1, 2, ..., (n - 1), nil, 0, 1, 2, ... (n - 1), where n is the size of the array

            return peekSubsequentIndices
        })
    }

    func testPeekSubsequent_repeatOne_shuffleOff_withPlayingTrack() {

        doTestPeekSubsequent(true, .one, .off, {(size: Int, startIndex: Int?) -> [Int?] in

            // When there is a playing track, startIndex cannot be nil.
            XCTAssertNotNil(startIndex)

            // When there is a playing track (represented by startIndex), the first call to peekSubsequent()
            // should produce the same track, i.e. startIndex. Repeated peekSubsequent() calls should also
            // produce startIndex indefinitely.
            return Array(repeating: startIndex!, count: repeatOneIdempotence_count)
        })
    }

    func testPeekSubsequent_repeatOne_shuffleOff_noPlayingTrack() {

        doTestPeekSubsequent(false, .one, .off, {(size: Int, startIndex: Int?) -> [Int?] in

            // When there is no playing track, the first call to peekSubsequent() should produce the first track, i.e. index 0.
            // Repeated peekSubsequent() calls should also produce 0 indefinitely.
            return Array(repeating: 0, count: repeatOneIdempotence_count)
        })
    }

    func testPeekSubsequent_repeatAll_shuffleOff_withPlayingTrack() {

        doTestPeekSubsequent(true, .all, .off, {(size: Int, startIndex: Int?) -> [Int?] in

            // When there is a playing track, startIndex cannot be nil.
            XCTAssertNotNil(startIndex)

            // Because there is a playing track (represented by startIndex), the test should start at startIndex + 1.

            // The test results should look like this:
            // startIndex + 1, startIndex + 2, ..., (n - 1), 0, 1, 2, ... (n - 1), where n is the size of the array.

            return size == 1 ? [] : Array((startIndex! + 1)..<size)

        }, sequenceRestart_count)
    }

    func testPeekSubsequent_repeatAll_shuffleOff_noPlayingTrack() {

        doTestPeekSubsequent(false, .all, .off, {(size: Int, startIndex: Int?) -> [Int?] in

            // Because there is no playing track, the test should start at 0 and contain the entire sequence.

            // The test results should look like this:
            // 0, 1, 2, ..., (n - 1), 0, 1, 2, ... (n - 1), 0, 1, 2, ... (n - 1), where n is the size of the array.

            return Array(0..<size)

        }, sequenceRestart_count)
    }

    func testPeekSubsequent_repeatOff_shuffleOn_withPlayingTrack() {

        doTestPeekSubsequent(true, .off, .on, {(size: Int, startIndex: Int?) -> [Int?] in

            // When there is a playing track, startIndex cannot be nil.
            XCTAssertNotNil(startIndex)

            // The sequence of elements produced by calls to peekSubsequent() should match the shuffle sequence array,
            // starting with its 2nd element (the first element is already playing).
            var peekSubsequentIndices: [Int?] = sequence.shuffleSequence.sequence.suffix(size - 1)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            peekSubsequentIndices.append(nil)

            return peekSubsequentIndices
        })
    }

    func testPeekSubsequent_repeatOff_shuffleOn_noPlayingTrack() {

        doTestPeekSubsequent(false, .off, .on, {(size: Int, startIndex: Int?) -> [Int?] in

            // The sequence of elements produced by calls to peekSubsequent() should exactly match the shuffle sequence array.
            var peekSubsequentIndices: [Int?] = Array(sequence.shuffleSequence.sequence)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            peekSubsequentIndices.append(nil)

            return peekSubsequentIndices
        })
    }

    func testPeekSubsequent_repeatAll_shuffleOn_withPlayingTrack() {

        doTestPeekSubsequent(true, .all, .on, {(size: Int, startIndex: Int?) -> [Int?] in

            // The sequence of elements produced by calls to peekSubsequent() should exactly match
            // the shuffle sequence array (minus the first element, which represents the already
            // playing track)
            return Array(sequence.shuffleSequence.sequence.suffix(size - 1))

        }, sequenceRestart_count)   // Repeat sequence iteration 10 times to test repeat all.
    }

    func testPeekSubsequent_repeatAll_shuffleOn_noPlayingTrack() {

        doTestPeekSubsequent(false, .all, .on, {(size: Int, startIndex: Int?) -> [Int?] in

            // The sequence of elements produced by calls to peekSubsequent() should exactly match
            // the shuffle sequence array.
            return Array(sequence.shuffleSequence.sequence)

        }, sequenceRestart_count)  // Repeat sequence iteration 10 times to test repeat all.
    }
    
    private func doTestPeekSubsequent(_ hasPlayingTrack: Bool, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode, _ expectedIndicesFunction: ExpectedIndicesFunction, _ repeatCount: Int = 0) {
        
        for size in testSequenceSizes {
            
            var startIndices: Set<Int?> = Set()
            
            // Select a random start index (playing track index).
            if hasPlayingTrack {
                
                // These 2 indices are essential for testing and should always be present.
                startIndices.insert(0)
                startIndices.insert(size - 1)
                
                // Select up to 10 other random indices for the test
                for _ in 1...min(size, 10) {
                    startIndices.insert(size == 1 ? 0 : Int.random(in: 0..<size))
                }
                
            } else {
                startIndices.insert(nil)
            }
            
            for startIndex in startIndices {
                
                initSequence(size, startIndex, repeatMode, shuffleMode)
                
                // Exercise the given indices function to obtain an array of expected results from repeated calls to peekSubsequent().
                // NOTE - The size of the expectedIndices array will determine how many times peekSubsequent() will be called (and tested).
                let expectedIndices: [Int?] = expectedIndicesFunction(size, startIndex)
                
                // For each expected index value, call peekSubsequent() and match its return value.
                for value in expectedIndices {
                    
                    // Capture the track index before the peek calls.
                    let indexBeforePeeking: Int? = sequence.curTrackIndex

                    // Repeated calls to peekSubsequent() should produce the same value.
                    for _ in 1...5 {
                    
                        XCTAssertEqual(sequence.peekSubsequent(), value)
                        
                        // Also verify that the sequence is still pointing at the same value as that before the peek (i.e. no iteration).
                        XCTAssertEqual(sequence.curTrackIndex, indexBeforePeeking)
                    }
                    
                    // Advance by one element so the test can be repeated for the subsequent value in the sequence.
                    _ = sequence.subsequent()
                }
            }
            
            // Test sequence restart once per size
            
            // When repeatMode = .all, the sequence will be restarted the next time peekSubsequent() is called.
            // If a repeatCount is given, perform further testing by looping through the sequence again.
            if repeatCount > 0 && repeatMode != .one {
                
                if shuffleMode == .on {
                    
                    // This test is not meaningful for very small sequences.
                    if repeatMode == .all && size >= 3 {
                        doTestPeekSubsequent_sequenceRestart_repeatAll_shuffleOn(repeatCount)
                    }
                    
                } else {
                    
                    doTestPeekSubsequent_sequenceRestart_shuffleOff(repeatCount)
                }
            }
        }
    }
    
    // Loop around to the beginning of the sequence and iterate through it.
    private func doTestPeekSubsequent_sequenceRestart_shuffleOff(_ repeatCount: Int) {
        
        var sequenceRange: [Int?] = Array(0..<sequence.size)
        
        // When repeat mode is off, track playback will stop before the sequence is restarted.
        // This corresponds to a nil value before sequence restart.
        if sequence.repeatAndShuffleModes.repeatMode == .off {
            sequenceRange.append(nil)
        }
        
        for _ in 1...repeatCount {
            
            // Iterate through the same sequence again, from the beginning, and verify that calls to peekSubsequent()
            // produce the same sequence again.
            for value in sequenceRange {
                
                // Capture the track index before the peek calls.
                let indexBeforePeeking: Int? = sequence.curTrackIndex

                // Repeated calls to peekSubsequent() should produce the same value.
                for _ in 1...5 {
                
                    XCTAssertEqual(sequence.peekSubsequent(), value)
                    
                    // Also verify that the sequence is still pointing at the same value as that before the peek (i.e. no iteration).
                    XCTAssertEqual(sequence.curTrackIndex, indexBeforePeeking)
                }
                
                // Advance by one element so the test can be repeated for the subsequent value in the sequence.
                _ = sequence.subsequent()
            }
        }
    }
    
    // Helper function that iterates through an entire shuffle sequence, testing that calls to
    // peekSubsequent() produce values matching the sequence. Based on the given repeatCount,
    // the iteration through the sequence is repeated a number of times so that multiple new
    // sequences are created (as a result of the repeat all setting).
    //
    // firstShuffleSequence is used for comparison to the new sequence created when it ends.
    // As each following sequence ends, a new one is created (because of the repeat all setting).
    // Need to ensure that each new sequence differs from the last.
    private func doTestPeekSubsequent_sequenceRestart_repeatAll_shuffleOn(_ repeatCount: Int) {
        
        // Start the loop with firstShuffleSequence
        var previousShuffleSequence: [Int] = Array(sequence.shuffleSequence.sequence)
        let size: Int = previousShuffleSequence.count
        
        // Each loop iteration will trigger the creation of a new shuffle sequence, and iterate through it.
        for _ in 1...repeatCount {
            
            // NOTE - The first element of the new shuffle sequence cannot be predicted, but it suffices to test that it is
            // non-nil and that it differs from the last element of the first sequence (this is by requirement).
            
            let firstElementOfNewSequence: Int? = sequence.subsequent()
            XCTAssertNotNil(firstElementOfNewSequence)
            
            if size > 1 {
                XCTAssertNotEqual(firstElementOfNewSequence, previousShuffleSequence.last)
            }
            
            // Capture the newly created sequence, and ensure it's of the same size as the previous one.
            let newShuffleSequence = Array(sequence.shuffleSequence.sequence)
            XCTAssertEqual(newShuffleSequence.count, previousShuffleSequence.count)
            
            // Test that the newly created shuffle sequence differs from the last one, if it is sufficiently large.
            // NOTE - For small sequences, the new sequence might co-incidentally be the same as the first one.
            if size >= 10 {
                XCTAssertFalse(newShuffleSequence.elementsEqual(previousShuffleSequence))
            }
            
            // Now, ensure that the following calls to peekSubsequent() produce a sequence matching the new shuffle sequence (minus the first element).
            // NOTE - Skip the first element which has already been produced and tested.
            for value in newShuffleSequence.suffix(size - 1) {
                
                // Capture the track index before the peek calls.
                let indexBeforePeeking: Int? = sequence.curTrackIndex

                // Repeated calls to peekSubsequent() should produce the same value.
                for _ in 1...5 {
                
                    XCTAssertEqual(sequence.peekSubsequent(), value)
                    
                    // Also verify that the sequence is still pointing at the same value as that before the peek (i.e. no iteration).
                    XCTAssertEqual(sequence.curTrackIndex, indexBeforePeeking)
                }
                
                // Advance by one element so the test can be repeated for the subsequent value in the sequence.
                _ = sequence.subsequent()
            }
            
            // When repeat mode is off, track playback will stop before the sequence is restarted.
            // This corresponds to a nil value before sequence restart.
            if sequence.repeatAndShuffleModes.repeatMode == .off {
                XCTAssertNil(sequence.subsequent())
            }
            
            // Update the previousShuffleSequence variable with the new sequence, to be used for comparison in the next loop iteration.
            previousShuffleSequence = newShuffleSequence
        }
    }
    
    func testPeekSubsequent_repeatOff_shuffleOff_emptySequence() {
        doTestPeekSubsequent_emptySequence(.off, .off)
    }

    func testPeekSubsequent_repeatOne_shuffleOff_emptySequence() {
        doTestPeekSubsequent_emptySequence(.one, .off)
    }

    func testPeekSubsequent_repeatAll_shuffleOff_emptySequence() {
        doTestPeekSubsequent_emptySequence(.all, .off)
    }

    func testPeekSubsequent_repeatOff_shuffleOn_emptySequence() {
        doTestPeekSubsequent_emptySequence(.off, .on)
    }

    func testPeekSubsequent_repeatAll_shuffleOn_emptySequence() {
        doTestPeekSubsequent_emptySequence(.all, .on)
    }
    
    private func doTestPeekSubsequent_emptySequence(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        // Create and verify an empty sequence.
        initSequence(0, nil, repeatMode, shuffleMode)
        XCTAssertEqual(sequence.size, 0)
        XCTAssertEqual(sequence.curTrackIndex, nil)
        
        // Repeated calls to peekSubsequent() should all produce nil.
        for _ in 1...10 {
            
            XCTAssertNil(sequence.peekSubsequent())
            
            // Ensure that no resizing/iteration has taken place.
            XCTAssertEqual(sequence.size, 0)
            XCTAssertEqual(sequence.curTrackIndex, nil)
        }
    }
    
    // MARK: peekNext() tests ------------------------------------------------------------------------------
    
    func testPeekNext_repeatOff_shuffleOff_withPlayingTrack() {
        
        doTestPeekNext(.off, .off, {(size: Int, startIndex: Int?) -> [Int?] in
            
            // When there is a playing track, startIndex cannot be nil.
            XCTAssertNotNil(startIndex)
            
            // If there aren't at least 2 tracks in the sequence, peekNext() should always produce nil, even with repeated calls.
            if size < 2 {return Array(repeating: nil, count: 10)}
            
            // Because there is a playing track (represented by startIndex), the test should start at startIndex + 1.
            var peekPeekNextIndices: [Int?] = Array((startIndex! + 1)..<size)
            
            // Test that after the last track (i.e. at the end of the sequence), nil should be returned, even with repeated calls.
            peekPeekNextIndices += Array(repeating: nil, count: 10)
            
            // The test results should look like this:
            // startIndex + 1, startIndex + 2, ..., (n - 1), nil, nil, nil, ... where n is the size of the array
            
            return peekPeekNextIndices
        })
    }
    
    func testPeekNext_repeatOff_shuffleOff_noPlayingTrack() {

        for size in testSequenceSizes {

            initSequence(size, nil, .off, .off)

            // When no track is currently playing, nil should be returned, even with repeated calls.
            for _ in 1...10 {

                XCTAssertNil(sequence.peekNext())

                // Also ensure that the sequence is still not pointing to any particular element (i.e. no iteration)
                XCTAssertNil(sequence.curTrackIndex)
            }
        }
    }

    func testPeekNext_repeatOne_shuffleOff_withPlayingTrack() {

        doTestPeekNext(.one, .off, {(size: Int, startIndex: Int?) -> [Int?] in

            // When there is a playing track, startIndex cannot be nil.
            XCTAssertNotNil(startIndex)
            
            // If there aren't at least 2 tracks in the sequence, peekNext() should always produce nil, even with repeated calls.
            if size < 2 {return Array(repeating: nil, count: 10)}
            
            // Because there is a playing track (represented by startIndex), the test should start at startIndex + 1.
            var peekPeekNextIndices: [Int?] = Array((startIndex! + 1)..<size)
            
            // Test that after the last track (i.e. at the end of the sequence), nil should be returned, even with repeated calls.
            peekPeekNextIndices += Array(repeating: nil, count: 10)
            
            // The test results should look like this:
            // startIndex + 1, startIndex + 2, ..., (n - 1), nil, nil, nil, ... where n is the size of the array
            
            return peekPeekNextIndices
        })
    }

    func testPeekNext_repeatOne_shuffleOff_noPlayingTrack() {

        for size in testSequenceSizes {

            initSequence(size, nil, .one, .off)

            // When no track is currently playing, nil should be returned, even with repeated calls.
            for _ in 1...10 {

                XCTAssertNil(sequence.peekNext())

                // Also ensure that the sequence is still not pointing to any particular element (i.e. no iteration)
                XCTAssertNil(sequence.curTrackIndex)
            }
        }
    }

    func testPeekNext_repeatAll_shuffleOff_withPlayingTrack() {

        doTestPeekNext(.all, .off, {(size: Int, startIndex: Int?) -> [Int?] in

            // When there is a playing track, startIndex cannot be nil.
            XCTAssertNotNil(startIndex)

            // If there aren't at least 2 tracks in the sequence, peekNext() should always produce nil, even with repeated calls.
            if size < 2 {return Array(repeating: nil, count: 10)}

            // Because there is a playing track (represented by startIndex), the test should start at startIndex + 1.

            // The test results should look like this:
            // startIndex + 1, startIndex + 2, ..., (n - 1), 0, 1, 2, ... (n - 1), where n is the size of the array.

            return Array((startIndex! + 1)..<size)

        }, sequenceRestart_count)
    }

    func testPeekNext_repeatAll_shuffleOff_noPlayingTrack() {

        for size in testSequenceSizes {

            initSequence(size, nil, .all, .off)

            // When no track is currently playing, nil should be returned, even with repeated calls.
            for _ in 1...10 {

                XCTAssertNil(sequence.peekNext())

                // Also ensure that the sequence is still not pointing to any particular element (i.e. no iteration)
                XCTAssertNil(sequence.curTrackIndex)
            }
        }
    }

    func testPeekNext_repeatOff_shuffleOn_withPlayingTrack() {

        doTestPeekNext(.off, .on, {(size: Int, startIndex: Int?) -> [Int?] in

            // The sequence of elements produced by calls to peekNext() should match the shuffle sequence array,
            // starting with its 2nd element (the first element is already playing).
            var peekPeekNextIndices: [Int?] = sequence.shuffleSequence.sequence.suffix(size - 1)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned, even with repeated calls.
            peekPeekNextIndices += Array(repeating: nil, count: 10)

            return peekPeekNextIndices
        })
    }

    func testPeekNext_repeatOff_shuffleOn_noPlayingTrack() {

        for size in testSequenceSizes {

            initSequence(size, nil, .off, .on)

            // When no track is currently playing, nil should be returned, even with repeated calls.
            for _ in 1...10 {

                XCTAssertNil(sequence.peekNext())

                // Also ensure that the sequence is still not pointing to any particular element (i.e. no iteration)
                XCTAssertNil(sequence.curTrackIndex)
            }
        }
    }

    func testPeekNext_repeatAll_shuffleOn_withPlayingTrack() {

        doTestPeekNext(.all, .on, {(size: Int, startIndex: Int?) -> [Int?] in

            // The sequence of elements produced by calls to peekNext() should exactly match
            // the shuffle sequence array (minus the first element, which represents the already
            // playing track)
            return Array(sequence.shuffleSequence.sequence.suffix(size - 1))

        }, sequenceRestart_count)   // Repeat sequence iteration 10 times to test repeat all.
    }

    func testPeekNext_repeatAll_shuffleOn_noPlayingTrack() {

        for size in testSequenceSizes {

            initSequence(size, nil, .all, .on)

            // When no track is currently playing, nil should be returned, even with repeated calls.
            for _ in 1...10 {

                XCTAssertNil(sequence.peekNext())

                // Also ensure that the sequence is still not pointing to any particular element (i.e. no iteration)
                XCTAssertNil(sequence.curTrackIndex)
            }
        }
    }
    
    private func doTestPeekNext(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode, _ expectedIndicesFunction: ExpectedIndicesFunction, _ repeatCount: Int = 0) {
        
        for size in testSequenceSizes {
            
            var startIndices: Set<Int> = Set()
            
            // These 2 indices are essential for testing and should always be present.
            startIndices.insert(0)
            startIndices.insert(size - 1)
            
            // Select up to 10 other random indices for the test
            for _ in 1...min(size, 10) {
                startIndices.insert(size == 1 ? 0 : Int.random(in: 0..<size))
            }
            
            for startIndex in startIndices {
                
                initSequence(size, startIndex, repeatMode, shuffleMode)
                
                // Exercise the given indices function to obtain an array of expected results from repeated calls to peekNext().
                // NOTE - The size of the expectedIndices array will determine how many times peekNext() will be called (and tested).
                let expectedIndices: [Int?] = expectedIndicesFunction(size, startIndex)
                
                // For each expected index value, call peekNext() and match its return value.
                for expectedIndex in expectedIndices {
                    
                    // Capture the track index before the peek calls.
                    let indexBeforePeeking: Int? = sequence.curTrackIndex
                    
                    // Repeated calls to peekSubsequent() should produce the same value.
                    for _ in 1...5 {
                    
                        XCTAssertEqual(sequence.peekNext(), expectedIndex)
                        
                        // Also verify that the sequence is still pointing at the same value as that before the peek (i.e. no iteration).
                        XCTAssertEqual(sequence.curTrackIndex, indexBeforePeeking)
                    }
                    
                    // Advance by one element so the test can be repeated for the next value in the sequence.
                    _ = sequence.next()
                }
            }
            
            // Test sequence restart once per size
            
            // When repeatMode = .all, the sequence will be restarted the next time peekNext() is called.
            // If a repeatCount is given, perform further testing by looping through the sequence again.
            if repeatCount > 0 && repeatMode == .all {
                
                if shuffleMode == .on {
                    
                    // This test is not meaningful for very small sequences.
                    if size >= 3 {
                        doTestPeekNext_sequenceRestart_repeatAll_shuffleOn(repeatCount)
                    }
                    
                } else {
                    
                    // For sequences with only one element, this test is not relevant.
                    if size > 1 {
                        doTestPeekNext_sequenceRestart_repeatAll_shuffleOff(repeatCount)
                    }
                }
            }
        }
    }
    
    // Loop around to the beginning of the sequence and iterate through it.
    private func doTestPeekNext_sequenceRestart_repeatAll_shuffleOff(_ repeatCount: Int) {
        
        let sequenceRange: Range<Int> = 0..<sequence.size
        
        for _ in 1...repeatCount {
            
            // Iterate through the same sequence again, from the beginning, and verify that calls to peekNext()
            // produce the same sequence again.
            for value in sequenceRange {
                
                // Capture the track index before the peek calls.
                let indexBeforePeeking: Int? = sequence.curTrackIndex
                
                // Repeated calls to peekSubsequent() should produce the same value.
                for _ in 1...5 {
                
                    XCTAssertEqual(sequence.peekNext(), value)
                    
                    // Also verify that the sequence is still pointing at the same value as that before the peek (i.e. no iteration).
                    XCTAssertEqual(sequence.curTrackIndex, indexBeforePeeking)
                }
                
                // Advance by one element so the test can be repeated for the next value in the sequence.
                _ = sequence.next()
            }
        }
    }
    
    // Helper function that iterates through an entire shuffle sequence, testing that calls to
    // peekNext() produce values matching the sequence. Based on the given repeatCount,
    // the iteration through the sequence is repeated a number of times so that multiple new
    // sequences are created (as a result of the repeat all setting).
    //
    // firstShuffleSequence is used for comparison to the new sequence created when it ends.
    // As each following sequence ends, a new one is created (because of the repeat all setting).
    // Need to ensure that each new sequence differs from the last.
    private func doTestPeekNext_sequenceRestart_repeatAll_shuffleOn(_ repeatCount: Int) {
        
        // Start the loop with firstShuffleSequence
        var previousShuffleSequence: [Int] = Array(sequence.shuffleSequence.sequence)
        let size: Int = previousShuffleSequence.count
        
        // Each loop iteration will trigger the creation of a new shuffle sequence, and iterate through it.
        for _ in 1...repeatCount {
            
            // NOTE - The first element of the new shuffle sequence cannot be predicted, but it suffices to test that it is
            // non-nil and that it differs from the last element of the first sequence (this is by requirement).
            let firstElementOfNewSequence: Int? = sequence.next()
            XCTAssertNotNil(firstElementOfNewSequence)
            
            // If there is only one element in the sequence, this comparison is not valid.
            if size > 1 {
                XCTAssertNotEqual(firstElementOfNewSequence, previousShuffleSequence.last)
            }
            
            // Capture the newly created sequence, and ensure it's of the same size as the previous one.
            let newShuffleSequence = Array(sequence.shuffleSequence.sequence)
            XCTAssertEqual(newShuffleSequence.count, previousShuffleSequence.count)
            
            // Test that the newly created shuffle sequence differs from the last one, if it is sufficiently large.
            // NOTE - For small sequences, the new sequence might co-incidentally be the same as the first one.
            if size >= 10 {
                XCTAssertFalse(newShuffleSequence.elementsEqual(previousShuffleSequence))
            }
            
            // Now, ensure that the following calls to peekNext() produce a sequence matching the new shuffle sequence (minus the first element).
            // NOTE - Skip the first element which has already been produced and tested.
            for value in newShuffleSequence.suffix(size - 1) {
                
                // Capture the track index before the peek calls.
                let indexBeforePeeking: Int? = sequence.curTrackIndex
                
                // Repeated calls to peekNext() should produce the same value.
                for _ in 1...5 {
                
                    XCTAssertEqual(sequence.peekNext(), value)
                    
                    // Also verify that the sequence is still pointing at the same value as that before the peek (i.e. no iteration).
                    XCTAssertEqual(sequence.curTrackIndex, indexBeforePeeking)
                }
                
                // Advance by one element so the test can be repeated for the next value in the sequence.
                _ = sequence.next()
            }
            
            // Update the previousShuffleSequence variable with the new sequence, to be used for comparison in the next loop iteration.
            previousShuffleSequence = newShuffleSequence
        }
    }
    
    func testPeekNext_repeatOff_shuffleOff_emptySequence() {
        doTestPeekNext_emptySequence(.off, .off)
    }
    
    func testPeekNext_repeatOne_shuffleOff_emptySequence() {
        doTestPeekNext_emptySequence(.one, .off)
    }
    
    func testPeekNext_repeatAll_shuffleOff_emptySequence() {
        doTestPeekNext_emptySequence(.all, .off)
    }
    
    func testPeekNext_repeatOff_shuffleOn_emptySequence() {
        doTestPeekNext_emptySequence(.off, .on)
    }
    
    func testPeekNext_repeatAll_shuffleOn_emptySequence() {
        doTestPeekNext_emptySequence(.all, .on)
    }
    
    private func doTestPeekNext_emptySequence(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        // Create and verify an empty sequence.
        initSequence(0, nil, repeatMode, shuffleMode)
        XCTAssertEqual(sequence.size, 0)
        XCTAssertEqual(sequence.curTrackIndex, nil)
        
        // Repeated calls to peekNext() should all produce nil.
        for _ in 1...10 {
            
            XCTAssertNil(sequence.peekNext())
            
            // Ensure that no resizing/iteration has taken place.
            XCTAssertEqual(sequence.size, 0)
            XCTAssertEqual(sequence.curTrackIndex, nil)
        }
    }
    
}
