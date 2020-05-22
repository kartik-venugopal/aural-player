import XCTest

class SequencerIterationTests: PlaybackSequencerTests {
    
    // MARK: subsequent() tests -----------------------------------------------------------------------------------------------
    
    func testSubsequent_emptyPlaylist() {
        
        playlist.clear()
        XCTAssertEqual(playlist.size, 0)
        
        sequencer.end()
        XCTAssertNil(sequencer.playingTrack)
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                preTest(playlistType, repeatMode, shuffleMode)
                
                // Repeated calls to subsequent() should all produce nil.
                for _ in 1...10 {
                    
                    XCTAssertNil(sequencer.subsequent())
                    XCTAssertNil(sequencer.playingTrack)
                }
            }
        }
    }
    
    func testSubsequent_tracksPlaylist_repeatOff_shuffleOff() {

        doTestSubsequent_tracksPlaylist(true, .off, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int?, _ scope: SequenceScope) -> ([Track?], [Int?]) in

            // When there is a playing track, playingTrackIndex cannot be nil.
            XCTAssertNotNil(playingTrackIndex)

            // Because there is a playing track (whose index is playingTrackIndex),
            // the test should start at the track with index playingTrackIndex + 1.
            var subsequentTracks: [Track?] = playlist.tracks.suffix(playlistSize - playingTrackIndex!)
            var subsequentIndices: [Int?] = Array(1...playlistSize).suffix(playlistSize - playingTrackIndex!)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            subsequentTracks.append(nil)
            subsequentIndices.append(0)

            // The test results should consist of tracks having the indices:
            // playingTrackIndex + 1, playingTrackIndex + 2, ..., (n - 1), nil, where n is the size of the array

            return (subsequentTracks, subsequentIndices)
        })
    }

    func testSubsequent_tracksPlaylist_repeatOff_shuffleOff_noPlayingTrack() {

        doTestSubsequent_tracksPlaylist(false, .off, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int?, _ scope: SequenceScope) -> ([Track?], [Int?]) in

            // Because there is a playing track (whose index is playingTrackIndex),
            // the test should start at the track with index playingTrackIndex + 1.
            var subsequentTracks: [Track?] = Array(playlist.tracks)
            var subsequentIndices: [Int?] = Array(1...playlistSize)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            subsequentTracks.append(nil)
            subsequentIndices.append(0)

            // The test results should consist of tracks having the indices:
            // playingTrackIndex + 1, playingTrackIndex + 2, ..., (n - 1), nil, where n is the size of the array

            return (subsequentTracks, subsequentIndices)
        })
    }

    func testSubsequent_tracksPlaylist_repeatOne_shuffleOff() {
        
        doTestSubsequent_tracksPlaylist(true, .one, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int?, _ scope: SequenceScope) -> ([Track?], [Int?]) in

            // When there is a playing track, playingTrackIndex cannot be nil.
            XCTAssertNotNil(playingTrackIndex)

            let playingTrack: Track = playlist.tracks[playingTrackIndex!]
            
            // Because of the repeat one setting, the playing track should repeat indefinitely
            let subsequentTracks: [Track?] = Array(repeating: playingTrack, count: repeatOneIdempotence_count)
            let subsequentIndices: [Int?] = Array(repeating: playingTrackIndex! + 1, count: repeatOneIdempotence_count)

            return (subsequentTracks, subsequentIndices)
        })
    }

    func testSubsequent_tracksPlaylist_repeatOne_shuffleOff_noPlayingTrack() {

        doTestSubsequent_tracksPlaylist(false, .one, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int?, _ scope: SequenceScope) -> ([Track?], [Int?]) in

            let playingTrack: Track = playlist.tracks[0]
            
            // Because of the repeat one setting, the playing track should repeat indefinitely
            let subsequentTracks: [Track?] = Array(repeating: playingTrack, count: repeatOneIdempotence_count)
            let subsequentIndices: [Int?] = Array(repeating: 1, count: repeatOneIdempotence_count)

            return (subsequentTracks, subsequentIndices)
        })
    }

    func testSubsequent_repeatAll_shuffleOff() {

        doTestSubsequent_tracksPlaylist(true, .all, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int?, _ scope: SequenceScope) -> ([Track?], [Int?]) in

            // When there is a playing track, playingTrackIndex cannot be nil.
            XCTAssertNotNil(playingTrackIndex)

            // Because there is a playing track (whose index is playingTrackIndex),
            // the test should start at the track with index playingTrackIndex + 1.
            let subsequentTracks: [Track?] = playlist.tracks.suffix(playlistSize - playingTrackIndex!)
            let subsequentIndices: [Int?] = Array(1...playlistSize).suffix(playlistSize - playingTrackIndex!)

            // After the last track (i.e. at the end of the sequence), the sequence should restart and repeat.

            // The test results should consist of tracks having the indices:
            // 0, 1, 2, ..., (n - 1), 0, 1, 2 ..., (n - 1), 0, 1, 2 ..., where n is the size of the array

            return (subsequentTracks, subsequentIndices)
            
        }, sequenceRestart_count)
    }

    func testSubsequent_repeatAll_shuffleOff_noPlayingTrack() {

        doTestSubsequent_tracksPlaylist(false, .all, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int?, _ scope: SequenceScope) -> ([Track?], [Int?]) in

            // Because there is a playing track (whose index is playingTrackIndex),
            // the test should start at the track with index playingTrackIndex + 1.
            let subsequentTracks: [Track?] = Array(playlist.tracks)
            let subsequentIndices: [Int?] = Array(1...playlistSize)

            // After the last track (i.e. at the end of the sequence), the sequence should restart and repeat.

            // The test results should consist of tracks having the indices:
            // 0, 1, 2, ..., (n - 1), 0, 1, 2 ..., (n - 1), 0, 1, 2 ..., where n is the size of the array

            return (subsequentTracks, subsequentIndices)
            
        }, sequenceRestart_count)
    }
//
//    func testSubsequent_repeatOff_shuffleOn() {
//
//        doTestSubsequent(true, .off, .on, {(size: Int, startIndex: Int?) -> [Int?] in
//
//            // When there is a playing track, startIndex cannot be nil.
//            XCTAssertNotNil(startIndex)
//
//            // The sequence of elements produced by calls to subsequent() should match the shuffle sequence array,
//            // starting with its 2nd element (the first element is already playing).
//            var subsequentIndices: [Int?] = sequence.shuffleSequence.sequence.suffix(size - 1)
//
//            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
//            subsequentIndices.append(nil)
//
//            return subsequentIndices
//        })
//    }
//
//    func testSubsequent_repeatOff_shuffleOn_noPlayingTrack() {
//
//        doTestSubsequent(false, .off, .on, {(size: Int, startIndex: Int?) -> [Int?] in
//
//            // The sequence of elements produced by calls to subsequent() should exactly match the shuffle sequence array.
//            var subsequentIndices: [Int?] = Array(sequence.shuffleSequence.sequence)
//
//            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
//            subsequentIndices.append(nil)
//
//            return subsequentIndices
//        })
//    }
//
//    func testSubsequent_repeatAll_shuffleOn() {
//
//        doTestSubsequent(true, .all, .on, {(size: Int, startIndex: Int?) -> [Int?] in
//
//            // The sequence of elements produced by calls to subsequent() should exactly match
//            // the shuffle sequence array (minus the first element, which represents the already
//            // playing track)
//            return Array(sequence.shuffleSequence.sequence.suffix(size - 1))
//
//        }, sequenceRestart_count)   // Repeat sequence iteration 10 times to test repeat all.
//    }
//
//    func testSubsequent_repeatAll_shuffleOn_noPlayingTrack() {
//
//        doTestSubsequent(false, .all, .on, {(size: Int, startIndex: Int?) -> [Int?] in
//
//            // The sequence of elements produced by calls to subsequent() should exactly match
//            // the shuffle sequence array.
//            return Array(sequence.shuffleSequence.sequence)
//
//        }, sequenceRestart_count)  // Repeat sequence iteration 10 times to test repeat all.
//    }
//
    private func doTestSubsequent_tracksPlaylist(_ hasPlayingTrack: Bool, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode,
                                                 _ expectedTracksFunction: ExpectedTracksFunction, _ repeatCount: Int = 0) {

        preTest(.tracks, repeatMode, shuffleMode)
        
        for size in testPlaylistSizes {
            
            sequencer.end()
            XCTAssertNil(sequencer.playingTrack)
            
            playlist.clear()
            _ = createNTracks(size)
        
            var playingTrackIndices: Set<Int?> = Set()
            
            // Select a random start index (playing track index).
            if hasPlayingTrack {
                
                // These 2 indices are essential for testing and should always be present.
                playingTrackIndices.insert(0)
                playingTrackIndices.insert(size - 1)
                
                // Select up to 10 other random indices for the test
                for _ in 1...min(size, 10) {
                    playingTrackIndices.insert(size == 1 ? 0 : Int.random(in: 0..<size))
                }
                
            } else {
                playingTrackIndices.insert(nil)
            }
            
            for playingTrackIndex in playingTrackIndices {

                // Exercise the given function to obtain an array of expected results from repeated calls to subsequent().
                // NOTE - The size of the expectedTracks array will determine how many times subsequent() will be called (and tested).
                let expectedTracksAndIndices = expectedTracksFunction(playlist.size, playingTrackIndex, sequencer.sequenceInfo.scope)
                var expectedTracks = expectedTracksAndIndices.expectedTracks
                var expectedIndices = expectedTracksAndIndices.expectedIndices
                
                // Begin the playback sequence (either from a specified index, or from the beginning - i.e. index 0)
                if let index = playingTrackIndex {
                    
                    XCTAssertEqual(sequencer.select(index), expectedTracks[0])
                    XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[0])
                    
                } else {
                    
                    XCTAssertEqual(sequencer.begin(), expectedTracks[0])
                    XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[0])
                }
                
                // The first track in the sequence has already been tested. Remove it from the expectations so that it is not tested again in the loop below.
                expectedTracks.remove(at: 0)
                expectedIndices.remove(at: 0)
                
                // For each expected track, call subsequent() and match its return value to the expectation.
                for expIndex in 0..<expectedTracks.count {

                    XCTAssertEqual(sequencer.subsequent(), expectedTracks[expIndex])
    
                    // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                    XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[expIndex])
                }
            }
            
            // Test sequence restart once per size
            
            // When repeatMode = .all, the sequence will be restarted the next time peekSubsequent() is called.
            // If a repeatCount is given, perform further testing by looping through the sequence again.
            if repeatCount > 0 && repeatMode == .all {
                
//                if shuffleMode == .off {
                    doTestSubsequent_sequenceRestart_repeatAll_shuffleOff(repeatCount)
//
//                } else if size >= 3 {
//
//                    // This test is not meaningful for very small sequences.
//                    doTestSubsequent_sequenceRestart_repeatAll_shuffleOn(repeatCount)
//                }
            }
        }
    }

    // Loop around to the beginning of the sequence and iterate through it.
    private func doTestSubsequent_sequenceRestart_repeatAll_shuffleOff(_ repeatCount: Int) {

        let sequenceRange: Range<Int> = 0..<playlist.size

        for _ in 1...repeatCount {

            // Iterate through the same sequence again, from the beginning, and verify that calls to subsequent()
            // produce the same sequence again.
            for value in sequenceRange {

                XCTAssertEqual(sequencer.subsequent(), playlist.tracks[value])

                // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                XCTAssertEqual(sequencer.sequenceInfo.trackIndex, value + 1)
            }
        }
    }
//
//    // Helper function that iterates through an entire shuffle sequence, testing that calls to
//    // subsequent() produce values matching the sequence. Based on the given repeatCount,
//    // the iteration through the sequence is repeated a number of times so that multiple new
//    // sequences are created (as a result of the repeat all setting).
//    //
//    // firstShuffleSequence is used for comparison to the new sequence created when it ends.
//    // As each following sequence ends, a new one is created (because of the repeat all setting).
//    // Need to ensure that each new sequence differs from the last.
//    private func doTestSubsequent_sequenceRestart_repeatAll_shuffleOn(_ repeatCount: Int) {
//
//        // Start the loop with firstShuffleSequence
//        var previousShuffleSequence: [Int] = Array(sequence.shuffleSequence.sequence)
//        let size: Int = previousShuffleSequence.count
//
//        // Each loop iteration will trigger the creation of a new shuffle sequence, and iterate through it.
//        for _ in 1...repeatCount {
//
//            // NOTE - The first element of the new shuffle sequence cannot be predicted, but it suffices to test that it is
//            // non-nil and that it differs from the last element of the first sequence (this is by requirement).
//            let firstElementOfNewSequence: Int? = sequence.subsequent()
//            XCTAssertNotNil(firstElementOfNewSequence)
//
//            // If there is only one element in the sequence, this comparison is not valid.
//            if size > 1 {
//                XCTAssertNotEqual(firstElementOfNewSequence, previousShuffleSequence.last)
//            }
//
//            // Capture the newly created sequence, and ensure it's of the same size as the previous one.
//            let newShuffleSequence = Array(sequence.shuffleSequence.sequence)
//            XCTAssertEqual(newShuffleSequence.count, previousShuffleSequence.count)
//
//            // Test that the newly created shuffle sequence differs from the last one, if it is sufficiently large.
//            // NOTE - For small sequences, the new sequence might co-incidentally be the same as the first one.
//            if size >= 10 {
//                XCTAssertFalse(newShuffleSequence.elementsEqual(previousShuffleSequence))
//            }
//
//            // Now, ensure that the following calls to subsequent() produce a sequence matching the new shuffle sequence (minus the first element).
//            // NOTE - Skip the first element which has already been produced and tested.
//            for value in newShuffleSequence.suffix(size - 1) {
//
//                XCTAssertEqual(sequence.subsequent(), value)
//
//                // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
//                XCTAssertEqual(sequence.curTrackIndex, value)
//            }
//
//            // Update the previousShuffleSequence variable with the new sequence, to be used for comparison in the next loop iteration.
//            previousShuffleSequence = newShuffleSequence
//        }
//    }
}
