import XCTest

class SequencerBeginAndEndTests: PlaybackSequencerTests {

    func testBegin_emptyPlaylist() {
        
        for playlistType in PlaylistType.allCases {
        
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                if shuffleMode == .off {
                    doTestBegin_noShuffle(playlistType, repeatMode, nil, 0, 0)
                } else {
                    doTestBegin_withShuffle(playlistType, repeatMode, true, false, nil, 0...0, 0)
                }
            }
        }
    }
    
    func testBegin_singleTrackInPlaylist() {
        
        let track = createTrack("Track-1", 300, randomArtist(), randomAlbum())
        
        for playlistType in PlaylistType.allCases {
        
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                if shuffleMode == .off {
                    doTestBegin_noShuffle(playlistType, repeatMode, track, 1, 1)
                } else {
                    doTestBegin_withShuffle(playlistType, repeatMode, true, true, track, 1...1, 1)
                }
            }
        }
    }

    func testBegin_shuffleOff() {
        
        _ = createNTracks(Int.random(in: 10...1000))
        
        for playlistType in PlaylistType.allCases {
        
            for repeatMode in RepeatMode.allCases {
                
                let expectedTrack = playlistType == .tracks ? playlist.tracks[0] : playlist.groupAtIndex(playlistType.toGroupType()!, 0).trackAtIndex(0)
                
                doTestBegin_noShuffle(playlistType, repeatMode, expectedTrack, 1, playlist.size)
            }
        }
    }
    
    func testBegin_shuffleOn() {
        
        _ = createNTracks(Int.random(in: 10...1000))
        
        for playlistType in PlaylistType.allCases {
        
            for repeatMode: RepeatMode in [.off, .all] {
                doTestBegin_withShuffle(playlistType, repeatMode, false, true, nil, 1...playlist.size, playlist.size)
            }
        }
    }
    
    private func doTestBegin_noShuffle(_ playlistType: PlaylistType, _ repeatMode: RepeatMode, _ expectedPlayingTrack: Track? = nil, _ expectedTrackIndex: Int? = nil, _ expectedTotalTracks: Int? = nil) {
        
        sequencer.end()
        XCTAssertNil(sequencer.playingTrack)
        
        preTest(playlistType, repeatMode, .off)
        
        let track = sequencer.begin()

        // Check that the returned track matches the sequencer's playingTrack property
        XCTAssertEqual(sequencer.playingTrack, track)

        if let theExpectedTrack = expectedPlayingTrack {
            
            // Check that the returned track matches the expected playing track
            XCTAssertNotNil(track)
            XCTAssertEqual(track, theExpectedTrack)
            
        } else {
            
            // Playing track must be nil
            XCTAssertNil(track)
        }
        
        let sequence = sequencer.sequenceInfo
        
        XCTAssertEqual(sequence.scope.type, playlistType.toPlaylistScopeType())
        XCTAssertEqual(sequence.scope.group, nil)
        
        if let trackIndex = expectedTrackIndex {
            XCTAssertEqual(sequence.trackIndex, trackIndex)
        }
        
        if let totalTracks = expectedTotalTracks {
            XCTAssertEqual(sequence.totalTracks, totalTracks)
        }
    }
    
    private func doTestBegin_withShuffle(_ playlistType: PlaylistType, _ repeatMode: RepeatMode, _ matchPlayingTrack: Bool, _ playingTrackMustBeNonNil: Bool, _ expectedPlayingTrack: Track? = nil, _ expectedTrackIndexRange: ClosedRange<Int>, _ expectedTotalTracks: Int? = nil) {
        
        // TODO: Get the shuffle sequence here, map it to playlist tracks, and check the first track
        
        sequencer.end()
        XCTAssertNil(sequencer.playingTrack)
        
        preTest(playlistType, repeatMode, .on)
        
        let track = sequencer.begin()

        // Check that the returned track matches the sequencer's playingTrack property
        XCTAssertEqual(sequencer.playingTrack, track)

        playingTrackMustBeNonNil ? XCTAssertNotNil(track) : XCTAssertNil(track)
        
        // Check that the returned track matches the expected playing track
        if matchPlayingTrack {
            XCTAssertEqual(track, expectedPlayingTrack)
        }
        
        let sequence = sequencer.sequenceInfo
        
        XCTAssertEqual(sequence.scope.type, playlistType.toPlaylistScopeType())
        XCTAssertEqual(sequence.scope.group, nil)
        
        XCTAssertTrue(expectedTrackIndexRange.contains(sequence.trackIndex))
        
        if let totalTracks = expectedTotalTracks {
            XCTAssertEqual(sequence.totalTracks, totalTracks)
        }
    }
    
    func testEnd_shuffleOff() {
        
        _ = createNTracks(Int.random(in: 10...1000))
        
        for playlistType in PlaylistType.allCases {
        
            for repeatMode in RepeatMode.allCases {
                
                let expectedTrack = playlistType == .tracks ? playlist.tracks[0] : playlist.groupAtIndex(playlistType.toGroupType()!, 0).trackAtIndex(0)
                
                doTestBegin_noShuffle(playlistType, repeatMode, expectedTrack, 1, playlist.size)
                
                sequencer.end()
                XCTAssertNil(sequencer.playingTrack)
            }
        }
    }
    
    func testEnd_shuffleOn() {
        
        _ = createNTracks(Int.random(in: 10...1000))
        
        for playlistType: PlaylistType in [.tracks, .artists, .albums, .genres] {
        
            for repeatMode: RepeatMode in [.off, .all] {
                
                doTestBegin_withShuffle(playlistType, repeatMode, false, true, nil, 1...playlist.size, playlist.size)
                
                sequencer.end()
                XCTAssertNil(sequencer.playingTrack)
            }
        }
    }

}
