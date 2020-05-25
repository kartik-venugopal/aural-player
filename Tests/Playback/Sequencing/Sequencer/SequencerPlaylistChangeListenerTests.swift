import XCTest

class SequencerPlaylistChangeListenerTests: SequencerTests {
    
    // MARK: tracksAdded() tests --------------------------------------------------------------------------------------------------
    
    // When the last track is playing, and a new track is added,
    // peekSubsequent() and peekNext() should change from nil to non-nil.
    func testTracksAdded_tracksPlaylist_lastTrackPlaying() {
        
        playlist.clear()
        sequencer.end()
        preTest(.tracks, .off, .off)
        
        _ = createNTracks(5)
        let playingTrack = sequencer.select(4)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, 4)
        
        XCTAssertNil(sequencer.peekSubsequent())
        XCTAssertNil(sequencer.peekNext())
        
        let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
        
        let trackAdd = createNTracks(1)
        sequencer.tracksAdded(trackAdd)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeAdd)
        
        XCTAssertEqual(sequencer.peekSubsequent()!, trackAdd[0].track)
        XCTAssertEqual(sequencer.peekNext()!, trackAdd[0].track)
    }
    
    // When the last track is playing, and a new track is added,
    // peekSubsequent() and peekNext() should change from nil to non-nil.
    func testTracksAdded_group_lastTrackPlaying() {
        
        for groupType in GroupType.allCases {
        
            playlist.clear()
            sequencer.end()
            preTest(groupType.toPlaylistType(), .off, .off)
            
            _ = createNTracks(25)
            
            let lastGroup = playlist.allGroups(groupType).last!
            let lastTrack = lastGroup.allTracks().last!
            let playingTrack = sequencer.select(lastTrack)
            XCTAssertEqual(playingTrack!, lastTrack)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, lastGroup.size - 1)
            
            XCTAssertNil(sequencer.peekSubsequent())
            XCTAssertNil(sequencer.peekNext())
            
            let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
            
            var trackAdd: [TrackAddResult]
            
            switch groupType {
                
            case .artist:   trackAdd = createNTracks(1, lastGroup.name)
                
            case .album:    trackAdd = createNTracks(1, randomArtist(), lastGroup.name)
                
            case .genre:    trackAdd = createNTracks(1, randomArtist(), randomAlbum(), lastGroup.name)
                
            }
            
            sequencer.tracksAdded(trackAdd)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeAdd)
            
            XCTAssertEqual(sequencer.peekSubsequent()!, trackAdd[0].track)
            XCTAssertEqual(sequencer.peekNext()!, trackAdd[0].track)
        }
    }
    
    // When no new tracks are added, there should be no changes made to the sequence.
    func testTracksAdded_playlistScopes_noTracksAdded() {
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                _ = createNTracks(5)
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                let sequenceSizeBeforeAdd = sequencer.sequence.size
                let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
                
                sequencer.tracksAdded([])
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeAdd)
                XCTAssertEqual(sequencer.sequence.size, sequenceSizeBeforeAdd)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When no new tracks are added, there should be no changes made to the sequence.
    func testTracksAdded_groupScopes_noTracksAdded() {
        
        for playlistType: PlaylistType in [.artists, .albums, .genres] {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                _ = createNTracks(100)
                
                let groups = playlist.allGroups(playlistType.toGroupType()!)
                let randomGroup = groups[Int.random(in: 0..<groups.count)]
                let playingTrack = sequencer.select(randomGroup)
                
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, randomGroup.indexOfTrack(playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, randomGroup.size)
                
                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, playlistType.toGroupScopeType())
                
                let sequenceSizeBeforeAdd = sequencer.sequence.size
                let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
                
                sequencer.tracksAdded([])
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeAdd)
                XCTAssertEqual(sequencer.sequence.size, sequenceSizeBeforeAdd)
                
                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, playlistType.toGroupScopeType())
            }
        }
    }
    
    // When no track is currently playing, there should be no changes made to the sequence.
    func testTracksAdded_noTrackPlaying() {
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                // Add tracks to the playlist, but don't begin playback.
                sequencer.tracksAdded(createNTracks(5))

                XCTAssertNil(sequencer.playingTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                
                sequencer.tracksAdded(createNTracks(3))
                
                XCTAssertNil(sequencer.playingTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
            }
        }
    }

    // When tracks are added, the sequence should be updated accordingly.
    func testTracksAdded_tracksPlaylist() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
        
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            var tracks = createNTracks(5)
            let playingTrack = sequencer.select(2)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlist.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
            
            tracks = createNTracks(12)
            sequencer.tracksAdded(tracks)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlist.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
        }
    }
    
    // When tracks are added, the sequence should be updated accordingly.
    func testTracksAdded_groupingPlaylists() {
        
        for playlistType: PlaylistType in [.artists, .albums, .genres] {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                var tracks = createNTracks(5)
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                tracks = createNTracks(12)
                sequencer.tracksAdded(tracks)
                
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    private func playlistIndexOfTrack(_ playlistType: PlaylistType, _ track: Track) -> Int {
        
        if playlistType == .tracks {
            return playlist.indexOfTrack(track)!
        }
        
        var scopeTracks: [Track] = []
        
        let groups = playlist.allGroups(playlistType.toGroupType()!)
        groups.forEach({scopeTracks.append(contentsOf: $0.allTracks())})

        return scopeTracks.firstIndex(of: track)!
    }
    
    // When tracks are added to the playing group, the sequence should be updated accordingly.
    func testTracksAdded_artistGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.artists, repeatMode, shuffleMode)
            
            _ = createNTracks(Int.random(in: 5...10), "Grimes")
            _ = createNTracks(Int.random(in: 5...10), "Conjure One")
            
            let artist_madonna = "Madonna"
            _ = createNTracks(Int.random(in: 5...10), artist_madonna)
            
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            doTestTracksAdded_groupPlaying(madonnaArtistGroup, true, 1, artist_madonna)
        }
    }
    
    // When tracks are added outside the playing group, the sequence should not be updated.
    func testTracksAdded_artistGroupPlaying_groupNotAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.artists, repeatMode, shuffleMode)
            
            _ = createNTracks(Int.random(in: 5...10), "Grimes")
            _ = createNTracks(Int.random(in: 5...10), "Conjure One")
            
            let artist_madonna = "Madonna"
            _ = createNTracks(Int.random(in: 5...10), artist_madonna)
            
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            doTestTracksAdded_groupPlaying(madonnaArtistGroup, false, 3, "Grimes")
        }
    }
    
    // When tracks are added to the playing group, the sequence should be updated accordingly.
    func testTracksAdded_albumGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")
            
            let album_visions = "Visions"
            _ = createNTracks(Int.random(in: 5...10), "Grimes", album_visions)
            
            let visionsAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_visions}).first!
            
            doTestTracksAdded_groupPlaying(visionsAlbumGroup, true, 7, "Grimes", album_visions)
        }
    }
    
    // When tracks are added outside the playing group, the sequence should not be updated.
    func testTracksAdded_albumGroupPlaying_groupNotAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")
            
            let album_visions = "Visions"
            _ = createNTracks(Int.random(in: 5...10), "Grimes", album_visions)
            
            let visionsAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_visions}).first!
            
            doTestTracksAdded_groupPlaying(visionsAlbumGroup, false, 7, "Grimes", "Halfaxa")
        }
    }
    
    // When tracks are added to the playing group, the sequence should be updated accordingly.
    func testTracksAdded_genreGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")
            
            let genre_pop = "Pop"
            _ = createNTracks(Int.random(in: 5...10), "Madonna", "Ray of Light", genre_pop)
            
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            doTestTracksAdded_groupPlaying(popGenreGroup, true, 3, "Michael Jackson", "Thriller", genre_pop)
        }
    }
    
    // When tracks are added outside the playing group, the sequence should not be updated.
    func testTracksAdded_genreGroupPlaying_groupNotAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")
            
            let genre_pop = "Pop"
            _ = createNTracks(Int.random(in: 5...10), "Madonna", "Ray of Light", genre_pop)
            
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            doTestTracksAdded_groupPlaying(popGenreGroup, false, 3, "Michael Jackson", "History", "Pop / Dance")
        }
    }
    
    private func doTestTracksAdded_groupPlaying(_ group: Group, _ groupAffectedByAdd: Bool, _ numTracksToAdd: Int, _ artist: String? = nil,
                                                _ album: String? = nil, _ genre: String? = nil) {
        
        let playingTrack = sequencer.select(group)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
        
        let groupSizeBeforeAdd = group.size
        
        sequencer.tracksAdded(createNTracks(numTracksToAdd, artist, album, genre))
            
        XCTAssertEqual(group.size, groupSizeBeforeAdd + (groupAffectedByAdd ? numTracksToAdd : 0))
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
    }
    
    // MARK: tracksRemoved() tests --------------------------------------------------------------------------------------------------
    
    // When the second-last track in the sequence is playing, and the last track is removed,
    // the return values of peekSubsequent() and peekNext() should change from non-nil to nil.
    func testTracksRemoved_tracksPlaylist_secondLastTrackPlaying_lastTrackRemoved() {
        
        playlist.clear()
        sequencer.end()
        preTest(.tracks, .off, .off)
        
        _ = createNTracks(5)
        let playingTrack = sequencer.select(3)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, 3)
        
        XCTAssertEqual(sequencer.peekSubsequent()!, playlist.tracks[4])
        XCTAssertEqual(sequencer.peekNext()!, playlist.tracks[4])
        
        let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex

        let removeResults = playlist.removeTracks(IndexSet([4]))
        sequencer.tracksRemoved(removeResults, false, nil)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeRemove)
        
        XCTAssertNil(sequencer.peekSubsequent())
        XCTAssertNil(sequencer.peekNext())
    }
    
    // When the second-last track in the sequence is playing, and the last track is removed,
    // the return values of peekSubsequent() and peekNext() should change from non-nil to nil.
    func testTracksRemoved_group_secondLastTrackPlaying_lastTrackRemoved() {
        
        for groupType in GroupType.allCases {
        
            playlist.clear()
            sequencer.end()
            preTest(groupType.toPlaylistType(), .off, .off)
            
            _ = createNTracks(100)
            
            let lastGroup = playlist.allGroups(groupType).last!
            
            // Before removing, add some tracks to the playing group to ensure that the group has more than 2 tracks
            var trackAdd: [TrackAddResult]
            
            switch groupType {
                
            case .artist:   trackAdd = createNTracks(5, lastGroup.name)
                
            case .album:    trackAdd = createNTracks(5, randomArtist(), lastGroup.name)
                
            case .genre:    trackAdd = createNTracks(5, randomArtist(), randomAlbum(), lastGroup.name)
                
            }
            
            sequencer.tracksAdded(trackAdd)
            
            let secondLastTrack = lastGroup.allTracks()[lastGroup.size - 2]
            let lastTrack = lastGroup.allTracks().last!
            
            // Select the second-last track for playback
            
            let playingTrack = sequencer.select(secondLastTrack)
            XCTAssertEqual(playingTrack!, secondLastTrack)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, lastGroup.size - 2)
            
            // Last track is the subsequent/next track
            XCTAssertEqual(sequencer.peekSubsequent()!, lastTrack)
            XCTAssertEqual(sequencer.peekNext()!, lastTrack)
            
            let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex

            // Remove the last track from the group
            let removeResults = playlist.removeTracksAndGroups([lastTrack], [], groupType)
            sequencer.tracksRemoved(removeResults, false, nil)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeRemove)

            // Now, there is no subsequent/next track.
            XCTAssertNil(sequencer.peekSubsequent())
            XCTAssertNil(sequencer.peekNext())
        }
    }
    
    // When no tracks are removed, the sequence should remain unchanged.
    func testTracksRemoved_playlistScopes_noTracksRemoved() {
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                _ = createNTracks(5)
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                let sequenceSizeBeforeRemove = sequencer.sequence.size
                let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex
                
                sequencer.tracksRemoved(TrackRemovalResults.empty, false, nil)
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeRemove)
                XCTAssertEqual(sequencer.sequence.size, sequenceSizeBeforeRemove)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When no tracks are removed, the sequence should remain unchanged.
    func testTracksRemoved_groupScopes_noTracksRemoved() {

        for playlistType: PlaylistType in [.artists, .albums, .genres] {

            for (repeatMode, shuffleMode) in repeatShufflePermutations {

                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)

                _ = createNTracks(100)

                let groups = playlist.allGroups(playlistType.toGroupType()!)
                let randomGroup = groups[Int.random(in: 0..<groups.count)]
                let playingTrack = sequencer.select(randomGroup)

                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, randomGroup.indexOfTrack(playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, randomGroup.size)

                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, playlistType.toGroupScopeType())

                let sequenceSizeBeforeRemove = sequencer.sequence.size
                let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex

                sequencer.tracksRemoved(TrackRemovalResults.empty, false, nil)

                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, sequenceTrackIndexBeforeRemove)
                XCTAssertEqual(sequencer.sequence.size, sequenceSizeBeforeRemove)

                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, playlistType.toGroupScopeType())
            }
        }
    }

    // When no track is playing, the sequence should remain unchanged.
    func testTracksRemoved_noTrackPlaying() {

        for playlistType in PlaylistType.allCases {

            for (repeatMode, shuffleMode) in repeatShufflePermutations {

                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)

                // Add tracks to the playlist, but don't begin playback.
                _ = createNTracks(100)
                
                XCTAssertNil(sequencer.playingTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                
                var removedTracksIndices: Set<Int> = Set()
                for _ in 1...10 {
                    removedTracksIndices.insert(Int.random(in: 0..<playlist.size))
                }
                
                let removedTracks = playlist.removeTracks(IndexSet(removedTracksIndices))

                sequencer.tracksRemoved(removedTracks, false, nil)

                XCTAssertNil(sequencer.playingTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
            }
        }
    }

    // When tracks are removed, the sequence should be updated.
    func testTracksRemoved_tracksPlaylist() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)

            _ = createNTracks(50)
            let playingTrack = sequencer.select(23)

            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlist.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
            
            let playlistSizeBeforeRemoval: Int = playlist.size

            // Select some random tracks for removal
            var removedTracksIndices: Set<Int> = Set()
            for _ in 1...5 {
                removedTracksIndices.insert(Int.random(in: 0..<playlist.size))
            }
            
            // Don't remove the playing track for this test.
            removedTracksIndices.remove(sequencer.sequence.curTrackIndex!)
            
            let removedTracks = playlist.removeTracks(IndexSet(removedTracksIndices))
            XCTAssertEqual(playlist.size, playlistSizeBeforeRemoval - removedTracksIndices.count)
            
            sequencer.tracksRemoved(removedTracks, false, nil)

            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlist.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
        }
    }

    // When tracks are removed, the sequence should be updated.
    func testTracksRemoved_groupingPlaylists() {

        for playlistType: PlaylistType in [.artists, .albums, .genres] {

            for (repeatMode, shuffleMode) in repeatShufflePermutations {

                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)

                _ = createNTracks(20)
                let playingTrack = sequencer.begin()

                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)

                let playlistSizeBeforeRemoval: Int = playlist.size
                
                var scopeTracks: [Track] = []
                
                let groups = playlist.allGroups(playlistType.toGroupType()!)
                groups.forEach({scopeTracks.append(contentsOf: $0.allTracks())})
                
                // Select some random tracks for removal
                var tracksToRemove: Set<Track> = Set()
                for _ in 1...5 {
                    tracksToRemove.insert(scopeTracks[Int.random(in: 0..<scopeTracks.count)])
                }
                
                let tracksToRemoveArr: [Track] = Array(tracksToRemove.filter({$0 != playingTrack}))
                
                let removedTrackResults = playlist.removeTracksAndGroups(tracksToRemoveArr, [], playlistType.toGroupType()!)
                XCTAssertEqual(playlist.size, playlistSizeBeforeRemoval - tracksToRemoveArr.count)
                
                sequencer.tracksRemoved(removedTrackResults, false, nil)

                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }

    // When tracks are removed from the playing group, the sequence should be updated accordingly.
    func testTracksRemoved_artistGroupPlaying_groupAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.artists, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Grimes")
            _ = createNTracks(Int.random(in: 10...20), "Conjure One")

            let artist_madonna = "Madonna"
            _ = createNTracks(Int.random(in: 20...40), artist_madonna)

            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let tracksToRemoveFromMadonnaGroup: [Track] = [1, 9, 17].map {madonnaArtistGroup.trackAtIndex($0)}
            doTestTracksRemoved_groupPlaying(madonnaArtistGroup, tracksToRemoveFromMadonnaGroup + Array(grimesArtistGroup.allTracks().suffix(5)), [])
        }
    }
    
    // When no tracks are removed from the playing group, the sequence should remain unchanged.
    func testTracksRemoved_artistGroupPlaying_groupNotAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.artists, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Grimes")
            _ = createNTracks(Int.random(in: 10...20), "Conjure One")

            let artist_madonna = "Madonna"
            _ = createNTracks(Int.random(in: 20...40), artist_madonna)

            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            doTestTracksRemoved_groupPlaying(madonnaArtistGroup, Array(grimesArtistGroup.allTracks().prefix(5)), [])
        }
    }

    // When tracks are removed from the playing group, the sequence should be updated accordingly.
    func testTracksRemoved_albumGroupPlaying_groupAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.albums, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")

            let album_visions = "Visions"
            _ = createNTracks(Int.random(in: 20...30), "Grimes", album_visions)

            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let visionsAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_visions}).first!

            let tracksToRemoveFromVisionsGroup: [Track] = [1, 9, 17].map {visionsAlbumGroup.trackAtIndex($0)}
            
            doTestTracksRemoved_groupPlaying(visionsAlbumGroup, tracksToRemoveFromVisionsGroup, [halfaxaAlbumGroup])
        }
    }

    // When no tracks are removed from the playing group, the sequence should remain unchanged.
    func testTracksRemoved_albumGroupPlaying_groupNotAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.albums, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")

            let album_visions = "Visions"
            _ = createNTracks(Int.random(in: 20...30), "Grimes", album_visions)

            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let visionsAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_visions}).first!

            doTestTracksRemoved_groupPlaying(visionsAlbumGroup, [], [halfaxaAlbumGroup])
        }
    }

    // When tracks are removed from the playing group, the sequence should be updated accordingly.
    func testTracksRemoved_genreGroupPlaying_groupAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.genres, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")

            let genre_pop = "Pop"
            _ = createNTracks(Int.random(in: 20...30), "Madonna", "Ray of Light", genre_pop)

            let intlGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "International"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!

            let tracksToRemoveFromPopGroup: [Track] = [1, 9, 17].map {popGenreGroup.trackAtIndex($0)}
            doTestTracksRemoved_groupPlaying(popGenreGroup, tracksToRemoveFromPopGroup, [intlGenreGroup])
        }
    }

    // When no tracks are removed from the playing group, the sequence should remain unchanged.
    func testTracksRemoved_genreGroupPlaying_groupNotAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.genres, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")

            let genre_pop = "Pop"
            _ = createNTracks(Int.random(in: 20...30), "Madonna", "Ray of Light", genre_pop)

            let intlGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "International"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            doTestTracksRemoved_groupPlaying(popGenreGroup, [], [intlGenreGroup])
        }
    }

    private func doTestTracksRemoved_groupPlaying(_ group: Group, _ tracksToRemove: [Track], _ groupsToRemove: [Group]) {

        let playingTrack = sequencer.select(group)

        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)

        let groupSizeBeforeRemove = group.size
        
        // For this test, the playing track should not be removed.
        let filteredTracksToRemove = tracksToRemove.filter({$0 != playingTrack})
        
        // Compute how many of the removed tracks belonged to the group that is the current sequencer scope.
        // Use this count to validate the group size after the remove operation.
        let groupTracks = group.allTracks()
        let numTracksRemovedFromScopeGroup: Int = filteredTracksToRemove.filter({groupTracks.contains($0)}).count
        
        let removalResults = playlist.removeTracksAndGroups(filteredTracksToRemove, groupsToRemove, group.type)
        sequencer.tracksRemoved(removalResults, false, nil)
        
        XCTAssertEqual(group.size, groupSizeBeforeRemove - numTracksRemovedFromScopeGroup)
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
    }
    
    // When the playing track is removed, the sequence should end.
    func testTracksRemoved_playingTrackRemoved() {

        playlist.clear()
        sequencer.end()
        
        preTest(.tracks, .off, .off)
        
        _ = createNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
        
        let playingTrack = sequencer.select(3)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, 3)
        XCTAssertEqual(sequencer.sequence.size, playlist.size)
        XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
        XCTAssertNil(sequencer.scope.group)
        
        let trackRemovalResults = playlist.removeTracks(IndexSet([3]))
        sequencer.tracksRemoved(trackRemovalResults, true, playingTrack)
        
        // Check that the sequence has ended.
        XCTAssertNil(sequencer.playingTrack)
        XCTAssertNil(sequencer.sequence.curTrackIndex)
    }
    
    // MARK: tracksReordered() tests -----------------------------------------------------------------------------------------------
    
    // When tracks are reordered within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testTracksReordered_tracksPlaylistScope_otherPlaylistsReordered() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
        
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            _ = createNTracks(100)
            let playingTrackIndexBeforeMove: Int = 67
            let playingTrack = sequencer.select(playingTrackIndexBeforeMove)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
            
            for groupType in GroupType.allCases {
                
                // Take the last group of the playlist, and move it up
                let lastGroup = playlist.allGroups(groupType).last!
                let moveResults = playlist.moveTracksAndGroupsUp([], [lastGroup], groupType)
                XCTAssertFalse(moveResults.results.isEmpty)
                
                sequencer.tracksReordered(moveResults)
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When tracks are reordered within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testTracksReordered_artistPlaying_otherPlaylistsReordered() {
        doTestTracksReordered_groupingPlayist_otherPlaylistsReordered(.artist)
    }
    
    // When tracks are reordered within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testTracksReordered_albumPlaying_otherPlaylistsReordered() {
        doTestTracksReordered_groupingPlayist_otherPlaylistsReordered(.album)
    }
    
    // When tracks are reordered within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testTracksReordered_genrePlaying_otherPlaylistsReordered() {
        doTestTracksReordered_groupingPlayist_otherPlaylistsReordered(.genre)
    }
    
    private func doTestTracksReordered_groupingPlayist_otherPlaylistsReordered(_ playingGroupType: GroupType) {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
        
            playlist.clear()
            sequencer.end()
            preTest(playingGroupType.toPlaylistType(), repeatMode, shuffleMode)
            
            _ = createNTracks(100)
            let playingGroup = playlist.allGroups(playingGroupType).first!
            let playingTrack = sequencer.select(playingGroup)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
            XCTAssertEqual(sequencer.scope.type, playingGroupType.toScopeType())
            XCTAssertEqual(sequencer.scope.group, playingGroup)
            
            // Reorder other grouping playlists
            
            for otherGroupType: GroupType in GroupType.allCases.filter({$0 != playingGroupType}) {
                
                // Take the last group of the playlist, and move it up
                let lastGroup = playlist.allGroups(otherGroupType).last!
                let moveResults = playlist.moveTracksAndGroupsUp([], [lastGroup], otherGroupType)
                XCTAssertFalse(moveResults.results.isEmpty)
                
                sequencer.tracksReordered(moveResults)
                
                XCTAssertEqual(sequencer.playingTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
                XCTAssertEqual(sequencer.scope.type, playingGroupType.toScopeType())
                XCTAssertEqual(sequencer.scope.group, playingGroup)
            }
            
            // Reorder tracks playlist
            
            let moveResults = playlist.moveTracksDown(IndexSet([25, 57, 79]))
            XCTAssertFalse(moveResults.results.isEmpty)
            
            sequencer.tracksReordered(moveResults)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
            XCTAssertEqual(sequencer.scope.type, playingGroupType.toScopeType())
            XCTAssertEqual(sequencer.scope.group, playingGroup)
        }
        
    }
    
    // When there is no playing track, and tracks are reordered, the sequence (empty) should remain unchanged.
    func testTracksReordered_tracksPlaylist_noPlayingTrack() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
        
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            _ = createNTracks(25)
            
            XCTAssertNil(sequencer.playingTrack)
            XCTAssertNil(sequencer.sequence.curTrackIndex)
            XCTAssertNil(sequencer.scope.group)
            
            // Take the last 3 tracks of the playlist, and move them up
            let size: Int = playlist.size
            let last3Tracks: IndexSet = IndexSet((size - 3)...(size - 1))
            
            let moveResults = playlist.moveTracksUp(last3Tracks)
            XCTAssertFalse(moveResults.results.isEmpty)
            
            sequencer.tracksReordered(moveResults)
            
            XCTAssertNil(sequencer.playingTrack)
            XCTAssertNil(sequencer.sequence.curTrackIndex)
            XCTAssertNil(sequencer.scope.group)
        }
    }
    
    // When there is no playing track, and tracks are reordered, the sequence (empty) should remain unchanged.
    func testTracksReordered_groupingPlaylists_noPlayingTrack() {
        
        for groupType in GroupType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(.tracks, repeatMode, shuffleMode)
                
                _ = createNTracks(25)
                
                XCTAssertNil(sequencer.playingTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.scope.group)
                
                // Take the last group in the playlist, and move it up
                let lastGroup = playlist.allGroups(groupType).last!
                let moveResults = playlist.moveTracksAndGroupsUp([], [lastGroup], groupType)
                XCTAssertFalse(moveResults.results.isEmpty)
                
                sequencer.tracksReordered(moveResults)
                
                XCTAssertNil(sequencer.playingTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When tracks are reordered, the sequence should be updated accordingly.
    func testTracksReordered_tracksPlaylist() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
        
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            _ = createNTracks(25)
            let playingTrackIndexBeforeMove: Int = 23
            let playingTrack = sequencer.select(playingTrackIndexBeforeMove)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
            
            // Take the last 3 tracks of the playlist, and move them up
            let size: Int = playlist.size
            let last3Tracks: IndexSet = IndexSet((size - 3)...(size - 1))
            
            let moveResults = playlist.moveTracksUp(last3Tracks)
            XCTAssertFalse(moveResults.results.isEmpty)
            
            sequencer.tracksReordered(moveResults)
            XCTAssertEqual(playlist.indexOfTrack(playingTrack!), playingTrackIndexBeforeMove - 1)
            
            XCTAssertEqual(sequencer.playingTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove - 1)
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
        }
    }
    
    // When tracks within the playing group are reordered, the sequence should be updated accordingly.
    func testTracksReordered_artistGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.artists, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createNTracks(Int.random(in: 10...20), "Grimes")

            let artist_madonna = "Madonna"
            _ = createNTracks(Int.random(in: 20...40), artist_madonna)

            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let tracksToMoveInMadonnaGroup: [Track] = [1, 9, 17].map {madonnaArtistGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(madonnaArtistGroup, tracksToMoveInMadonnaGroup, [grimesArtistGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_artistGroupPlaying_groupNotAffected_groupsMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.artists, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createNTracks(Int.random(in: 10...20), "Grimes")

            let artist_madonna = "Madonna"
            _ = createNTracks(Int.random(in: 20...40), artist_madonna)

            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!

            doTestTracksReordered_groupPlaying(madonnaArtistGroup, [], [grimesArtistGroup, madonnaArtistGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_artistGroupPlaying_groupNotAffected_otherGroupTracksMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.artists, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createNTracks(Int.random(in: 10...20), "Grimes")

            let artist_madonna = "Madonna"
            _ = createNTracks(Int.random(in: 20...40), artist_madonna)

            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let tracksToMoveInGrimesGroup: [Track] = [1, 5, 7].map {grimesArtistGroup.trackAtIndex($0)}

            doTestTracksReordered_groupPlaying(madonnaArtistGroup, tracksToMoveInGrimesGroup, [])
        }
    }
    
    // When tracks within the playing group are reordered, the sequence should be updated accordingly.
    func testTracksReordered_albumGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.albums, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")

            let album_erotica = "Erotica"
            _ = createNTracks(Int.random(in: 20...40), "Madonna", album_erotica)

            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            
            let tracksToMoveInEroticaGroup: [Track] = [1, 9, 17].map {eroticaAlbumGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(eroticaAlbumGroup, tracksToMoveInEroticaGroup, [halfaxaAlbumGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_albumGroupPlaying_groupNotAffected_groupsMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.albums, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")

            let album_erotica = "Erotica"
            _ = createNTracks(Int.random(in: 20...40), "Madonna", album_erotica)

            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!

            doTestTracksReordered_groupPlaying(eroticaAlbumGroup, [], [halfaxaAlbumGroup, eroticaAlbumGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_albumGroupPlaying_groupNotAffected_otherGroupTracksMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.albums, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")

            let album_erotica = "Erotica"
            _ = createNTracks(Int.random(in: 20...40), "Madonna", album_erotica)

            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            
            let tracksToMoveInHalfaxaGroup: [Track] = [1, 5, 7].map {halfaxaAlbumGroup.trackAtIndex($0)}

            doTestTracksReordered_groupPlaying(eroticaAlbumGroup, tracksToMoveInHalfaxaGroup, [])
        }
    }
    
    // When tracks within the playing group are reordered, the sequence should be updated accordingly.
    func testTracksReordered_genreGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.genres, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")

            let genre_pop = "Pop"
            _ = createNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)

            let danceGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "Dance"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let tracksToMoveInPopGroup: [Track] = [1, 9, 17].map {popGenreGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(popGenreGroup, tracksToMoveInPopGroup, [danceGenreGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_genreGroupPlaying_groupNotAffected_groupsMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.genres, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")

            let genre_pop = "Pop"
            _ = createNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)

            let danceGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "Dance"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!

            doTestTracksReordered_groupPlaying(popGenreGroup, [], [danceGenreGroup, popGenreGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_genreGroupPlaying_groupNotAffected_otherGroupTracksMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.genres, repeatMode, shuffleMode)

            _ = createNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")

            let genre_pop = "Pop"
            _ = createNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)

            let danceGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "Dance"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let tracksToMoveInDanceGroup: [Track] = [1, 5, 7].map {danceGenreGroup.trackAtIndex($0)}

            doTestTracksReordered_groupPlaying(popGenreGroup, tracksToMoveInDanceGroup, [])
        }
    }
    
    private func doTestTracksReordered_groupPlaying(_ playingGroup: Group, _ tracksToMove: [Track], _ groupsToMove: [Group]) {
        
        let playingTrack = sequencer.select(playingGroup)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
        XCTAssertEqual(sequencer.scope.type, playingGroup.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, playingGroup)
        
        let groupSizeBeforeMove: Int = playingGroup.size
        
        let moveResults = playlist.moveTracksAndGroupsUp(tracksToMove, groupsToMove, playingGroup.type)
        XCTAssertFalse(moveResults.results.isEmpty)
        
        sequencer.tracksReordered(moveResults)
        
        XCTAssertEqual(sequencer.playingTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, groupSizeBeforeMove)
        XCTAssertEqual(sequencer.scope.type, playingGroup.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, playingGroup)
    }
}

fileprivate extension TrackRemovalResults {
    
    static var empty: TrackRemovalResults {
        return TrackRemovalResults(groupingPlaylistResults: [:], flatPlaylistResults: IndexSet([]), tracks: [])
    }
}
