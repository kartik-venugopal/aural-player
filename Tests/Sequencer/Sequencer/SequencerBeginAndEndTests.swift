//
//  SequencerBeginAndEndTests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerBeginAndEndTests: SequencerTests {

    func testBegin_emptyPlaylist() {
        
        for playlistType in PlaylistType.allCases {
        
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                if shuffleMode == .off {
                    doTestBegin_noShuffle(playlistType, repeatMode, nil, 0, 0)
                } else {
                    doTestBegin_withShuffle(playlistType, repeatMode)
                }
            }
        }
    }
    
    func testBegin_singleTrackInPlaylist() {
        
        let track = createAndAddTrack("Track-1", 300, randomArtist(), randomAlbum())
        
        for playlistType in PlaylistType.allCases {
        
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                if shuffleMode == .off {
                    doTestBegin_noShuffle(playlistType, repeatMode, track, 1, 1)
                } else {
                    doTestBegin_withShuffle(playlistType, repeatMode)
                }
            }
        }
    }

    func testBegin_shuffleOff() {
        
        _ = createAndAddNTracks(Int.random(in: 10...1000))
        
        for playlistType in PlaylistType.allCases {
        
            for repeatMode in RepeatMode.allCases {
                
                let expectedTrack = playlistType == .tracks ? playlist.tracks[0] : playlist.groupAtIndex(playlistType.toGroupType()!, 0)!.trackAtIndex(0)
                
                doTestBegin_noShuffle(playlistType, repeatMode, expectedTrack, 1, playlist.size)
            }
        }
    }
    
    func testBegin_shuffleOn() {
        
        _ = createAndAddNTracks(Int.random(in: 10...1000))
        
        for playlistType in PlaylistType.allCases {
        
            for repeatMode: RepeatMode in [.off, .all] {
                doTestBegin_withShuffle(playlistType, repeatMode)
            }
        }
    }
    
    private func doTestBegin_noShuffle(_ playlistType: PlaylistType, _ repeatMode: RepeatMode, _ expectedPlayingTrack: Track? = nil, _ expectedTrackIndex: Int? = nil, _ expectedTotalTracks: Int? = nil) {
        
        sequencer.end()
        XCTAssertNil(sequencer.currentTrack)
        
        preTest(playlistType, repeatMode, .off)
        
        let track = sequencer.begin()

        // Check that the returned track matches the sequencer's playingTrack property
        XCTAssertEqual(sequencer.currentTrack, track)

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
    
    private func doTestBegin_withShuffle(_ playlistType: PlaylistType, _ repeatMode: RepeatMode) {
        
        sequencer.end()
        XCTAssertNil(sequencer.currentTrack)
        
        preTest(playlistType, repeatMode, .on)
        
        let track = sequencer.begin()

        // Check that the returned track matches the sequencer's playingTrack property
        XCTAssertEqual(sequencer.currentTrack, track)
        
        if playlist.size == 0 {
            
            XCTAssertNil(track)
            return
        }

        // Check that the returned track matches the expected playing track
        let shuffleSequence = sequencer.sequence.shuffleSequence.sequence
        
        // Compute scope tracks
        let tracksForPlaylist = getPlaylistTracks(sequencer.scope)
        let totalTracks = tracksForPlaylist.count
        
        // Match track
        XCTAssertEqual(track, tracksForPlaylist[shuffleSequence[0]])
        
        let sequence = sequencer.sequenceInfo
        
        XCTAssertEqual(sequence.scope.type, playlistType.toPlaylistScopeType())
        XCTAssertEqual(sequence.scope.group, nil)
        
        XCTAssertEqual(sequence.trackIndex, shuffleSequence[0] + 1)
        XCTAssertEqual(sequence.totalTracks, totalTracks)
    }
    
    private func getPlaylistTracks(_ scope: SequenceScope) -> [Track] {
        
        if scope.type.toPlaylistType() == .tracks {
            
            return playlist.tracks
            
        } else {
            
            let groups = playlist.allGroups(scope.type.toGroupType()!)
            
            var tracks: [Track] = []
            groups.forEach({tracks.append(contentsOf: $0.tracks)})
            
            return tracks
        }
    }
    
    func testEnd_shuffleOff() {
        
        _ = createAndAddNTracks(Int.random(in: 10...1000))
        
        for playlistType in PlaylistType.allCases {
        
            for repeatMode in RepeatMode.allCases {
                
                let expectedTrack = playlistType == .tracks ? playlist.tracks[0] : playlist.groupAtIndex(playlistType.toGroupType()!, 0)!.trackAtIndex(0)
                
                doTestBegin_noShuffle(playlistType, repeatMode, expectedTrack, 1, playlist.size)
                
                sequencer.end()
                XCTAssertNil(sequencer.currentTrack)
            }
        }
    }
    
    func testEnd_shuffleOn() {
        
        _ = createAndAddNTracks(Int.random(in: 10...1000))
        
        for playlistType: PlaylistType in [.tracks, .artists, .albums, .genres] {
        
            for repeatMode: RepeatMode in [.off, .all] {
                
                doTestBegin_withShuffle(playlistType, repeatMode)
                
                sequencer.end()
                XCTAssertNil(sequencer.currentTrack)
            }
        }
    }

}
