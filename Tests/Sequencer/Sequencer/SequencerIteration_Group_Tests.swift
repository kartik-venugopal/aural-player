//
//  SequencerIteration_Group_Tests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerIteration_Group_Tests: SequencerTests {
    
    var scopeTracks: [Track] = []
    var scopeSize: Int {return scopeTracks.count}
    
    private func scopeUpdated(_ group: Group) {
        
        scopeTracks.removeAll()
        scopeTracks.append(contentsOf: group.tracks)
        
        XCTAssertEqual(scopeSize, group.size)
    }

    // MARK: subsequent() tests -----------------------------------------------------------------------------------------------
    
    func testSubsequent_group_repeatOff_shuffleOff() {

        doTestSubsequent_group(.off, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            // Start the test with the track at index playingTrackIndex.
            var subsequentTracks: [Track?] = scopeTracks.suffix(playlistSize - playingTrackIndex)
            var subsequentIndices: [Int] = Array(1...playlistSize).suffix(playlistSize - playingTrackIndex)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            subsequentTracks.append(nil)
            subsequentIndices.append(0)

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex + 1, playingTrackIndex + 2, ..., (n - 1), nil, where n is the size of the array

            return (subsequentTracks, subsequentIndices)
        })
    }

    func testSubsequent_group_repeatOne_shuffleOff() {

        doTestSubsequent_group(.one, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            let playingTrack: Track = scopeTracks[playingTrackIndex]

            // Because of the repeat one setting, the playing track should repeat indefinitely
            let subsequentTracks: [Track?] = Array(repeating: playingTrack, count: repeatOneIdempotence_count)
            let subsequentIndices: [Int] = Array(repeating: playingTrackIndex + 1, count: repeatOneIdempotence_count)

            return (subsequentTracks, subsequentIndices)
        })
    }

    func testSubsequent_group_repeatAll_shuffleOff() {

        doTestSubsequent_group(.all, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            // Start the test with the track at index playingTrackIndex.
            let subsequentTracks: [Track?] = scopeTracks.suffix(playlistSize - playingTrackIndex)
            let subsequentIndices: [Int] = Array(1...playlistSize).suffix(playlistSize - playingTrackIndex)

            // After the last track (i.e. at the end of the sequence), the sequence should restart and repeat.

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex + 1, playingTrackIndex + 2, ..., (n - 1), 0, 1, 2, ..., where n is the size of the array

            return (subsequentTracks, subsequentIndices)

        }, sequenceRestart_count)   // Restart the sequence and repeat the test.
    }

    func testSubsequent_group_repeatOff_shuffleOn() {

        doTestSubsequent_group(.off, .on, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            // Obtain the shuffle sequence ... this will determine the order of playback.
            let shuffleSequence = Array(sequencer.sequence.shuffleSequence.sequence)

            // Map the sequence indices to playlist tracks.
            var subsequentTracks: [Track?] = shuffleSequence.map {scopeTracks[$0]}
            var subsequentIndices: [Int] = Array(shuffleSequence).map {$0 + 1}

            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            subsequentTracks.append(nil)
            subsequentIndices.append(0)

            return (subsequentTracks, subsequentIndices)
        })
    }

    func testSubsequent_group_repeatAll_shuffleOn() {

        doTestSubsequent_group(.all, .on, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            // Obtain the shuffle sequence
            let shuffleSequence = Array(sequencer.sequence.shuffleSequence.sequence)

            // Map the sequence indices to playlist tracks.
            let subsequentTracks: [Track?] = shuffleSequence.map {scopeTracks[$0]}
            let subsequentIndices: [Int] = Array(shuffleSequence).map {$0 + 1}

            return (subsequentTracks, subsequentIndices)

        }, sequenceRestart_count)   // Restart the sequence and repeat the test.
    }
    
    private func doTestSubsequent_group(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode,
                                                 _ expectedTracksFunction: ExpectedTracksFunction, _ repeatCount: Int = 0) {

        for playlistType: PlaylistType in [.artists, .albums, .genres] {
        
            preTest(playlistType, repeatMode, shuffleMode)
            
            for size in testPlaylistSizes {
                
                sequencer.end()
                XCTAssertNil(sequencer.currentTrack)
                
                playlist.clear()
                _ = createAndAddNTracks(size)
                
                // Select different groups as the scope for the tests.
                for group in playlist.allGroups(playlistType.toGroupType()!) {
                    
                    scopeUpdated(group)
                    
                    var playingTrackIndices: Set<Int> = Set([0, scopeSize - 1])
                    
                    // Select up to 10 other random indices for the test
                    for _ in 1...min(scopeSize, 10) {
                        playingTrackIndices.insert(scopeSize == 1 ? 0 : Int.random(in: 0..<scopeSize))
                    }
                    
                    for playingTrackIndex in playingTrackIndices {
                        
                        // Begin the playback sequence (either from a specified index, or from the beginning - i.e. index 0)
                        let playingTrack = sequencer.select(group.trackAtIndex(playingTrackIndex)!)
                        
                        let sequence = sequencer.sequenceInfo
                        XCTAssertEqual(sequence.scope.type, group.type.toScopeType())
                        XCTAssertEqual(sequence.scope.group, group)
                        XCTAssertEqual(sequence.totalTracks, scopeSize)
                        
                        // Exercise the given function to obtain an array of expected results from repeated calls to subsequent().
                        // NOTE - The size of the expectedTracks array will determine how many times subsequent() will be called (and tested).
                        let expectedTracksAndIndices = expectedTracksFunction(scopeSize, playingTrackIndex, sequencer.sequenceInfo.scope)
                        var expectedTracks = expectedTracksAndIndices.expectedTracks
                        var expectedIndices = expectedTracksAndIndices.expectedIndices
                        
                        XCTAssertEqual(playingTrack, expectedTracks[0])
                        XCTAssertEqual(sequence.trackIndex, expectedIndices[0])
                        
                        // The first track in the sequence has already been tested. Remove it from the expectations so that it is not tested again in the loop below.
                        expectedTracks.remove(at: 0)
                        expectedIndices.remove(at: 0)
                        
                        // For each expected track, call subsequent() and match its return value to the expectation.
                        for index in 0..<expectedTracks.count {
                            
                            XCTAssertEqual(sequencer.subsequent(), expectedTracks[index])
                            
                            // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                            XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[index])
                        }
                    }
                    
                    // Test sequence restart once per group
                    
                    // When repeatMode = .all, the sequence will be restarted the next time subsequent() is called.
                    // If a repeatCount is given, perform further testing by looping through the sequence again.
                    if repeatCount > 0 && repeatMode == .all {
                        
                        if shuffleMode == .off {
                            doTestSubsequent_sequenceRestart_repeatAll_shuffleOff(repeatCount)
                        } else {
                            doTestSubsequent_sequenceRestart_repeatAll_shuffleOn(repeatCount)
                        }
                    }
                }
            }
        }
    }

    // Loop around to the beginning of the sequence and iterate through it.
    private func doTestSubsequent_sequenceRestart_repeatAll_shuffleOff(_ repeatCount: Int) {

        let sequenceRange: Range<Int> = 0..<scopeSize
        
        for _ in 1...repeatCount {

            // Iterate through the same sequence again, from the beginning, and verify that calls to subsequent()
            // produce the same sequence again.
            for value in sequenceRange {

                XCTAssertEqual(sequencer.subsequent(), scopeTracks[value])

                // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                XCTAssertEqual(sequencer.sequenceInfo.trackIndex, value + 1)
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
    private func doTestSubsequent_sequenceRestart_repeatAll_shuffleOn(_ repeatCount: Int) {

        // Start the loop with firstShuffleSequence
        var previousShuffleSequence: [Track] = sequencer.sequence.shuffleSequence.sequence.map {scopeTracks[$0]}
        
        // Each loop iteration will trigger the creation of a new shuffle sequence, and iterate through it.
        for _ in 1...repeatCount {

            // NOTE - The first element of the new shuffle sequence cannot be predicted before calling subsequent(),
            // but it suffices to test that it differs from the last element of the first sequence (this is by requirement).
            let firstTrackInNewSequence: Track? = sequencer.subsequent()

            // If there is only one element in the sequence, this comparison is not valid.
            if scopeSize > 1 {
                XCTAssertNotEqual(firstTrackInNewSequence, previousShuffleSequence.last)
            }

            // Capture the newly created sequence, and ensure it's of the same size as the previous one.
            let newShuffleSequence: [Track] = sequencer.sequence.shuffleSequence.sequence.map {scopeTracks[$0]}
            let newShuffleSequenceIndices: [Int] = sequencer.sequence.shuffleSequence.sequence.map {$0 + 1}
            
            // Now that we have the new sequence, we can test the first track that we could not predict before.
            XCTAssertEqual(firstTrackInNewSequence, newShuffleSequence[0])
            XCTAssertEqual(sequencer.sequenceInfo.trackIndex, newShuffleSequenceIndices[0])
            
            XCTAssertEqual(newShuffleSequence.count, previousShuffleSequence.count)

            // Test that the newly created shuffle sequence differs from the last one, if it is sufficiently large.
            // NOTE - For small sequences, the new sequence might co-incidentally be the same as the first one.
            if scopeSize >= 10 {
                XCTAssertFalse(newShuffleSequence.elementsEqual(previousShuffleSequence))
            }

            // Now, ensure that the following calls to subsequent() produce a sequence matching the new shuffle sequence (minus the first element).
            // NOTE - Skip the first element which has already been produced and tested.
            for index in 1..<scopeSize {

                XCTAssertEqual(sequencer.subsequent(), newShuffleSequence[index])

                // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                XCTAssertEqual(sequencer.sequenceInfo.trackIndex, newShuffleSequenceIndices[index])
            }

            // Update the previousShuffleSequence variable with the new sequence, to be used for comparison in the next loop iteration.
            previousShuffleSequence = newShuffleSequence
        }
    }
    
    // MARK: next() tests ------------------------------------------------------------------------------
    
    func testNext_group_repeatOff_shuffleOff() {

        doTestNext_group(.off, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let nextTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (nextTracks, Array(repeating: 1, count: 11))
            }

            // Start the test with the track at index playingTrackIndex.
            var nextTracks: [Track?] = scopeTracks.suffix(playlistSize - playingTrackIndex)
            var nextIndices: [Int] = Array(1...playlistSize).suffix(playlistSize - playingTrackIndex)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned, even with repeated calls.
            nextTracks.append(contentsOf: Array(repeating: nil, count: 10))

            // When next() returns nil, the sequence index should not change from the previous value (i.e. track will continue playing).
            nextIndices.append(contentsOf: Array(repeating: nextIndices.last!, count: 10))

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex + 1, playingTrackIndex + 2, ..., (n - 1), nil, where n is the size of the array

            return (nextTracks, nextIndices)
        })
    }

    func testNext_group_repeatOne_shuffleOff() {

        doTestNext_group(.one, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let nextTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (nextTracks, Array(repeating: 1, count: 11))
            }

            // Start the test with the track at index playingTrackIndex.
            var nextTracks: [Track?] = scopeTracks.suffix(playlistSize - playingTrackIndex)
            var nextIndices: [Int] = Array(1...playlistSize).suffix(playlistSize - playingTrackIndex)

            // Test that after the last track (i.e. at the end of the sequence), nil is returned, even with repeated calls.
            nextTracks.append(contentsOf: Array(repeating: nil, count: 10))

            // When next() returns nil, the sequence index should not change from the previous value (i.e. track will continue playing).
            nextIndices.append(contentsOf: Array(repeating: nextIndices.last!, count: 10))

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex + 1, playingTrackIndex + 2, ..., (n - 1), nil, where n is the size of the array

            return (nextTracks, nextIndices)
        })
    }

    func testNext_group_repeatAll_shuffleOff() {

        doTestNext_group(.all, .off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let nextTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (nextTracks, Array(repeating: 1, count: 11))
            }

            // Start the test with the track at index playingTrackIndex.
            let nextTracks: [Track?] = scopeTracks.suffix(playlistSize - playingTrackIndex)
            let nextIndices: [Int] = Array(1...playlistSize).suffix(playlistSize - playingTrackIndex)

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex + 1, playingTrackIndex + 2, ..., (n - 1), 0, 1, 2, ..., where n is the size of the array

            return (nextTracks, nextIndices)

        }, sequenceRestart_count)
    }

    func testNext_group_repeatOff_shuffleOn() {

        doTestNext_group(.off, .on, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let nextTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (nextTracks, Array(repeating: 1, count: 11))
            }

            // Obtain the shuffle sequence ... this will determine the order of playback.
            let shuffleSequence = Array(sequencer.sequence.shuffleSequence.sequence)

            // Map the sequence indices to playlist tracks.
            var nextTracks: [Track?] = shuffleSequence.map {scopeTracks[$0]}
            var nextIndices: [Int] = Array(shuffleSequence).map {$0 + 1}

            // Test that after the last track (i.e. at the end of the sequence), nil is returned.
            nextTracks.append(nil)
            nextIndices.append(nextIndices.last!)

            return (nextTracks, nextIndices)
        })
    }

    func testNext_group_repeatAll_shuffleOn() {

        doTestNext_group(.all, .on, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let nextTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (nextTracks, Array(repeating: 1, count: 11))
            }

            // Obtain the shuffle sequence and remove the first element fro
            let shuffleSequence = Array(sequencer.sequence.shuffleSequence.sequence)

            // Map the sequence indices to playlist tracks.
            let subsequentTracks: [Track?] = shuffleSequence.map {scopeTracks[$0]}
            let subsequentIndices: [Int] = Array(shuffleSequence).map {$0 + 1}

            return (subsequentTracks, subsequentIndices)

        }, sequenceRestart_count)   // Restart the sequence and repeat the test.
    }

    private func doTestNext_group(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode,
                                           _ expectedTracksFunction: ExpectedTracksFunction, _ repeatCount: Int = 0) {

        for playlistType: PlaylistType in [.artists, .albums, .genres] {
        
            preTest(playlistType, repeatMode, shuffleMode)
            
            for size in testPlaylistSizes {
                
                sequencer.end()
                XCTAssertNil(sequencer.currentTrack)
                
                playlist.clear()
                _ = createAndAddNTracks(size)
                
                // Select different groups as the scope for the tests.
                for group in playlist.allGroups(playlistType.toGroupType()!) {
                    
                    scopeUpdated(group)
                    
                    var playingTrackIndices: Set<Int> = Set([0, scopeSize - 1])
                    
                    // Select up to 10 other random indices for the test
                    for _ in 1...min(scopeSize, 10) {
                        playingTrackIndices.insert(scopeSize == 1 ? 0 : Int.random(in: 0..<scopeSize))
                    }
                    
                    for playingTrackIndex in playingTrackIndices {
                        
                        // Begin the playback sequence (either from a specified index, or from the beginning - i.e. index 0)
                        let playingTrack = sequencer.select(group.trackAtIndex(playingTrackIndex)!)
                        
                        let sequence = sequencer.sequenceInfo
                        XCTAssertEqual(sequence.scope.type, group.type.toScopeType())
                        XCTAssertEqual(sequence.scope.group, group)
                        XCTAssertEqual(sequence.totalTracks, scopeSize)
                        
                        // Exercise the given function to obtain an array of expected results from repeated calls to next().
                        // NOTE - The size of the expectedTracks array will determine how many times next() will be called (and tested).
                        let expectedTracksAndIndices = expectedTracksFunction(scopeSize, playingTrackIndex, sequencer.sequenceInfo.scope)
                        var expectedTracks = expectedTracksAndIndices.expectedTracks
                        var expectedIndices = expectedTracksAndIndices.expectedIndices

                        XCTAssertEqual(playingTrack, expectedTracks[0])
                        XCTAssertEqual(sequence.trackIndex, expectedIndices[0])

                        // The first track in the sequence has already been tested. Remove it from the expectations so that it is not tested again in the loop below.
                        expectedTracks.remove(at: 0)
                        expectedIndices.remove(at: 0)

                        // For each expected track, call next() and match its return value to the expectation.
                        for index in 0..<expectedTracks.count {

                            XCTAssertEqual(sequencer.next(), expectedTracks[index])

                            // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                            XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[index])
                        }
                    }

                    // Test sequence restart once per group

                    // When repeatMode = .all, the sequence will be restarted the next time next() is called.
                    // If a repeatCount is given, perform further testing by looping through the sequence again.
                    if repeatCount > 0 && repeatMode == .all && scopeSize > 1 {

                        if shuffleMode == .off {
                            doTestNext_sequenceRestart_repeatAll_shuffleOff(repeatCount)
                        } else {
                            doTestNext_sequenceRestart_repeatAll_shuffleOn(repeatCount)
                        }
                    }
                }
            }
        }
    }

    // Loop around to the beginning of the sequence and iterate through it.
    private func doTestNext_sequenceRestart_repeatAll_shuffleOff(_ repeatCount: Int) {

        let sequenceRange: Range<Int> = 0..<scopeSize

        for _ in 1...repeatCount {

            // Iterate through the same sequence again, from the beginning, and verify that calls to next()
            // produce the same sequence again.
            for trackIndex in sequenceRange {

                XCTAssertEqual(sequencer.next(), scopeTracks[trackIndex])

                // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                XCTAssertEqual(sequencer.sequenceInfo.trackIndex, trackIndex + 1)
            }
        }
    }

    // Helper function that iterates through an entire shuffle sequence, testing that calls to
    // next() produce values matching the sequence. Based on the given repeatCount,
    // the iteration through the sequence is repeated a number of times so that multiple new
    // sequences are created (as a result of the repeat all setting).
    //
    // firstShuffleSequence is used for comparison to the new sequence created when it ends.
    // As each following sequence ends, a new one is created (because of the repeat all setting).
    // Need to ensure that each new sequence differs from the last.
    private func doTestNext_sequenceRestart_repeatAll_shuffleOn(_ repeatCount: Int) {

        // Start the loop with firstShuffleSequence
        var previousShuffleSequence: [Track] = sequencer.sequence.shuffleSequence.sequence.map {scopeTracks[$0]}

        // Each loop iteration will trigger the creation of a new shuffle sequence, and iterate through it.
        for _ in 1...repeatCount {

            // NOTE - The first element of the new shuffle sequence cannot be predicted before calling next(),
            // but it suffices to test that it differs from the last element of the first sequence (this is by requirement).
            let firstTrackInNewSequence: Track? = sequencer.next()

            // If there is only one element in the sequence, this comparison is not valid.
            if scopeSize > 1 {
                XCTAssertNotEqual(firstTrackInNewSequence, previousShuffleSequence.last)
            }

            // Capture the newly created sequence, and ensure it's of the same size as the previous one.
            let newShuffleSequence: [Track] = sequencer.sequence.shuffleSequence.sequence.map {scopeTracks[$0]}
            let newShuffleSequenceIndices: [Int] = sequencer.sequence.shuffleSequence.sequence.map {$0 + 1}

            // Now that we have the new sequence, we can test the first track that we could not predict before.
            XCTAssertEqual(firstTrackInNewSequence, newShuffleSequence[0])
            XCTAssertEqual(sequencer.sequenceInfo.trackIndex, newShuffleSequenceIndices[0])

            XCTAssertEqual(newShuffleSequence.count, previousShuffleSequence.count)

            // Test that the newly created shuffle sequence differs from the last one, if it is sufficiently large.
            // NOTE - For small sequences, the new sequence might co-incidentally be the same as the first one.
            if scopeSize >= 10 {
                XCTAssertFalse(newShuffleSequence.elementsEqual(previousShuffleSequence))
            }

            // Now, ensure that the following calls to next() produce a sequence matching the new shuffle sequence (minus the first element).
            // NOTE - Skip the first element which has already been produced and tested.
            for index in 1..<scopeSize {

                XCTAssertEqual(sequencer.next(), newShuffleSequence[index])

                // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                XCTAssertEqual(sequencer.sequenceInfo.trackIndex, newShuffleSequenceIndices[index])
            }

            // Update the previousShuffleSequence variable with the new sequence, to be used for comparison in the next loop iteration.
            previousShuffleSequence = newShuffleSequence
        }
    }

    // MARK: previous() tests ------------------------------------------------------------------------------

    func testPrevious_group_repeatOff_shuffleOff() {

        doTestPrevious_group_noShuffle(.off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let previousTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (previousTracks, Array(repeating: 1, count: 11))
            }

            // Start the test with the track at index playingTrackIndex.
            var previousTracks: [Track?] = scopeTracks.prefix(playingTrackIndex + 1).reversed()
            var previousIndices: [Int] = Array(1...(playingTrackIndex + 1)).reversed()

            // Test that after the first track (i.e. at the beginning of the sequence), nil is returned, even with repeated calls.
            previousTracks.append(contentsOf: Array(repeating: nil, count: 10))

            // When previous() returns nil, the sequence index should not change from the previous value (i.e. track will continue playing).
            previousIndices.append(contentsOf: Array(repeating: 1, count: 10))

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex - 1, playingTrackIndex - 2, ..., 0, nil, nil, nil, ...

            return (previousTracks, previousIndices)
        })
    }

    func testPrevious_group_repeatOne_shuffleOff() {

        doTestPrevious_group_noShuffle(.one, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let previousTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (previousTracks, Array(repeating: 1, count: 11))
            }

            // Start the test with the track at index playingTrackIndex.
            var previousTracks: [Track?] = scopeTracks.prefix(playingTrackIndex + 1).reversed()
            var previousIndices: [Int] = Array(1...(playingTrackIndex + 1)).reversed()

            // Test that after the first track (i.e. at the beginning of the sequence), nil is returned, even with repeated calls.
            previousTracks.append(contentsOf: Array(repeating: nil, count: 10))

            // When previous() returns nil, the sequence index should not change from the previous value (i.e. track will continue playing).
            previousIndices.append(contentsOf: Array(repeating: 1, count: 10))

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex - 1, playingTrackIndex - 2, ..., 0, nil, nil, nil, ...

            return (previousTracks, previousIndices)
        })
    }

    func testPrevious_group_repeatAll_shuffleOff() {

        doTestPrevious_group_noShuffle(.all, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let previousTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (previousTracks, Array(repeating: 1, count: 11))
            }

            // Start the test with the track at index playingTrackIndex.
            let previousTracks: [Track?] = scopeTracks.prefix(playingTrackIndex + 1).reversed()
            let previousIndices: [Int] = Array(1...(playingTrackIndex + 1)).reversed()

            // The test results should consist of tracks having the indices:
            // playingTrackIndex, playingTrackIndex - 1, playingTrackIndex - 2, ..., 0, (n - 1), (n - 2), (n - 3), ..., where n is the size of the playlist.

            return (previousTracks, previousIndices)

        }, sequenceRestart_count)
    }

    func testPrevious_group_repeatOff_shuffleOn() {

        doTestPrevious_group_shuffleOn(.off, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let nextTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (nextTracks, Array(repeating: 1, count: 11))
            }

            // Obtain the shuffle sequence ... this will determine the order of playback.
            let shuffleSequence = Array(sequencer.sequence.shuffleSequence.sequence)

            // Map the sequence indices to playlist tracks.
            var nextTracks: [Track?] = (shuffleSequence.map {scopeTracks[$0]}).reversed()
            var nextIndices: [Int] = (Array(shuffleSequence).map {$0 + 1}).reversed()

            // Test that after the first track (i.e. at the beginning of the sequence), nil is returned.
            nextTracks.append(contentsOf: Array(repeating: nil, count: 10))
            nextIndices.append(contentsOf: Array(repeating: nextIndices.last!, count: 10))

            return (nextTracks, nextIndices)
        })
    }

    func testPrevious_group_repeatAll_shuffleOn() {

        doTestPrevious_group_shuffleOn(.all, {(_ playlistSize: Int, _ playingTrackIndex: Int, _ scope: SequenceScope) -> ([Track?], [Int]) in

            if playlistSize == 1 {

                let nextTracks: [Track?] = [scopeTracks[0]] + Array(repeating: nil, count: 10)
                return (nextTracks, Array(repeating: 1, count: 11))
            }

            // Obtain the shuffle sequence ... this will determine the order of playback.
            let shuffleSequence = Array(sequencer.sequence.shuffleSequence.sequence)

            // Map the sequence indices to playlist tracks.
            var nextTracks: [Track?] = (shuffleSequence.map {scopeTracks[$0]}).reversed()
            var nextIndices: [Int] = (Array(shuffleSequence).map {$0 + 1}).reversed()

            // Test that after the first track (i.e. at the beginning of the sequence), nil is returned.
            nextTracks.append(contentsOf: Array(repeating: nil, count: 10))
            nextIndices.append(contentsOf: Array(repeating: nextIndices.last!, count: 10))

            return (nextTracks, nextIndices)
        })
    }

    private func doTestPrevious_group_noShuffle(_ repeatMode: RepeatMode, _ expectedTracksFunction: ExpectedTracksFunction, _ repeatCount: Int = 0) {

        for playlistType: PlaylistType in [.artists, .albums, .genres] {
        
            preTest(playlistType, repeatMode, .off)
            
            for size in testPlaylistSizes {
                
                sequencer.end()
                XCTAssertNil(sequencer.currentTrack)
                
                playlist.clear()
                _ = createAndAddNTracks(size)
                
                // Select different groups as the scope for the tests.
                for group in playlist.allGroups(playlistType.toGroupType()!) {
                    
                    scopeUpdated(group)
                    
                    var playingTrackIndices: Set<Int> = Set([0, scopeSize - 1])
                    
                    // Select up to 10 other random indices for the test
                    for _ in 1...min(scopeSize, 10) {
                        playingTrackIndices.insert(scopeSize == 1 ? 0 : Int.random(in: 0..<scopeSize))
                    }
                    
                    for playingTrackIndex in playingTrackIndices {
                        
                        // Begin the playback sequence (either from a specified index, or from the beginning - i.e. index 0)
                        let playingTrack = sequencer.select(group.trackAtIndex(playingTrackIndex)!)
                        
                        let sequence = sequencer.sequenceInfo
                        XCTAssertEqual(sequence.scope.type, group.type.toScopeType())
                        XCTAssertEqual(sequence.scope.group, group)
                        XCTAssertEqual(sequence.totalTracks, scopeSize)
                        
                        // Exercise the given function to obtain an array of expected results from repeated calls to next().
                        // NOTE - The size of the expectedTracks array will determine how many times next() will be called (and tested).
                        let expectedTracksAndIndices = expectedTracksFunction(scopeSize, playingTrackIndex, sequencer.sequenceInfo.scope)
                        var expectedTracks = expectedTracksAndIndices.expectedTracks
                        var expectedIndices = expectedTracksAndIndices.expectedIndices

                        XCTAssertEqual(playingTrack, expectedTracks[0])
                        XCTAssertEqual(sequence.trackIndex, expectedIndices[0])

                        // The first track in the sequence has already been tested. Remove it from the expectations so that it is not tested again in the loop below.
                        expectedTracks.remove(at: 0)
                        expectedIndices.remove(at: 0)

                        // For each expected track, call previous() and match its return value to the expectation.
                        for index in 0..<expectedTracks.count {

                            XCTAssertEqual(sequencer.previous(), expectedTracks[index])

                            // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                            XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[index])
                        }
                    }

                    // Test sequence restart once per group

                    // When repeatMode = .all, the sequence will be restarted the next time previous() is called.
                    // If a repeatCount is given, perform further testing by looping through the sequence again.
                    if repeatCount > 0 && repeatMode == .all && scopeSize > 1 {
                        doTestPrevious_sequenceRestart_repeatAll_shuffleOff(repeatCount)
                    }
                }
            }
        }
    }

    // Loop around to the end of the sequence and iterate backwards through it.
    private func doTestPrevious_sequenceRestart_repeatAll_shuffleOff(_ repeatCount: Int) {

        // Iteration will start at the end of the sequence and proceed towards the beginning (i.e. index 0).
        let sequenceRange = (0..<scopeSize).reversed()

        for _ in 1...repeatCount {

            // Iterate through the same sequence again, from the end, and verify that calls to previous()
            // produce the same sequence again.
            for trackIndex in sequenceRange {

                XCTAssertEqual(sequencer.previous(), scopeTracks[trackIndex])

                // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                XCTAssertEqual(sequencer.sequenceInfo.trackIndex, trackIndex + 1)
            }
        }
    }

    private func doTestPrevious_group_shuffleOn(_ repeatMode: RepeatMode, _ expectedTracksFunction: ExpectedTracksFunction) {

        for playlistType: PlaylistType in [.artists, .albums, .genres] {
            
            preTest(playlistType, repeatMode, .on)
            
            for size in testPlaylistSizes {
                
                sequencer.end()
                XCTAssertNil(sequencer.currentTrack)
                
                playlist.clear()
                _ = createAndAddNTracks(size)
                
                // Select different groups as the scope for the tests.
                for group in playlist.allGroups(playlistType.toGroupType()!) {
                    
                    scopeUpdated(group)
                    
                    // Start the sequence and iterate to the end.
                    _ = sequencer.select(group.tracks.last!)
                    
                    let sequence = sequencer.sequenceInfo
                    XCTAssertEqual(sequence.scope.type, group.type.toScopeType())
                    XCTAssertEqual(sequence.scope.group, group)
                    XCTAssertEqual(sequence.totalTracks, scopeSize)
                    
                    while sequencer.peekNext() != nil {
                        _ = sequencer.next()
                    }
                    
                    // Exercise the given function to obtain an array of expected results from repeated calls to previous().
                    // NOTE - The size of the expectedTracks array will determine how many times previous() will be called (and tested).
                    let expectedTracksAndIndices = expectedTracksFunction(scopeSize, scopeSize - 1, sequencer.sequenceInfo.scope)
                    var expectedTracks = expectedTracksAndIndices.expectedTracks
                    var expectedIndices = expectedTracksAndIndices.expectedIndices
                    
                    // The last track in the sequence (i.e. now the current track) should match the first expectation.
                    XCTAssertEqual(sequencer.currentTrack, expectedTracks[0])
                    XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[0])
                    
                    // The first track in the sequence has already been tested. Remove it from the expectations so that it is not tested again in the loop below.
                    expectedTracks.remove(at: 0)
                    expectedIndices.remove(at: 0)
                    
                    // For each expected track, call previous() and match its return value to the expectation.
                    for index in 0..<expectedTracks.count {
                        
                        XCTAssertEqual(sequencer.previous(), expectedTracks[index])
                        
                        // Also verify that the sequence is now pointing at this new value (i.e. iteration took place)
                        XCTAssertEqual(sequencer.sequenceInfo.trackIndex, expectedIndices[index])
                    }
                }
            }
        }
    }
}
