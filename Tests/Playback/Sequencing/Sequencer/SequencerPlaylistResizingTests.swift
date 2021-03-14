import XCTest

class SequencerPlaylistResizingTests: SequencerTests {
    
    // MARK: tracksAdded() tests --------------------------------------------------------------------------------------------------
    
    // When the last track is playing, and a new track is added,
    // peekSubsequent() and peekNext() should change from nil to non-nil.
    func testTracksAdded_tracksPlaylist_lastTrackPlaying() {
        
        playlist.clear()
        sequencer.end()
        preTest(.tracks, .off, .off)
        
        _ = createAndAddNTracks(5)
        let playingTrack = sequencer.select(4)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, 4)
        
        XCTAssertNil(sequencer.peekSubsequent())
        XCTAssertNil(sequencer.peekNext())
        
        let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
        
        let trackAdd = createAndAddNTracks(1)
        sequencer.tracksAdded(trackAdd)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
            
            _ = createAndAddNTracks(25)
            
            let lastGroup = playlist.allGroups(groupType).last!
            let lastTrack = lastGroup.allTracks().last!
            let playingTrack = sequencer.select(lastTrack)
            XCTAssertEqual(playingTrack!, lastTrack)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, lastGroup.size - 1)
            
            XCTAssertNil(sequencer.peekSubsequent())
            XCTAssertNil(sequencer.peekNext())
            
            let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
            
            var trackAdd: [TrackAddResult]
            
            switch groupType {
                
            case .artist:   trackAdd = createAndAddNTracks(1, lastGroup.name)
                
            case .album:    trackAdd = createAndAddNTracks(1, randomArtist(), lastGroup.name)
                
            case .genre:    trackAdd = createAndAddNTracks(1, randomArtist(), randomAlbum(), lastGroup.name)
                
            }
            
            sequencer.tracksAdded(trackAdd)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                
                _ = createAndAddNTracks(5)
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                let sequenceSizeBeforeAdd = sequencer.sequence.size
                let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
                
                sequencer.tracksAdded([])
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                
                _ = createAndAddNTracks(100)
                
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
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                sequencer.tracksAdded(createAndAddNTracks(5))

                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                
                sequencer.tracksAdded(createAndAddNTracks(3))
                
                XCTAssertNil(sequencer.currentTrack)
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
            
            var tracks = createAndAddNTracks(5)
            let playingTrack = sequencer.select(2)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlist.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
            
            tracks = createAndAddNTracks(12)
            sequencer.tracksAdded(tracks)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                
                var tracks = createAndAddNTracks(5)
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                tracks = createAndAddNTracks(12)
                sequencer.tracksAdded(tracks)
                
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
            
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 5...10), artist_madonna)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 5...10), artist_madonna)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")
            
            let album_visions = "Visions"
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", album_visions)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")
            
            let album_visions = "Visions"
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", album_visions)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 5...10), "Madonna", "Ray of Light", genre_pop)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 5...10), "Madonna", "Ray of Light", genre_pop)
            
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            doTestTracksAdded_groupPlaying(popGenreGroup, false, 3, "Michael Jackson", "History", "Pop / Dance")
        }
    }
    
    private func doTestTracksAdded_groupPlaying(_ group: Group, _ groupAffectedByAdd: Bool, _ numTracksToAdd: Int, _ artist: String? = nil,
                                                _ album: String? = nil, _ genre: String? = nil) {
        
        let playingTrack = sequencer.select(group)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
        
        let groupSizeBeforeAdd = group.size
        
        sequencer.tracksAdded(createAndAddNTracks(numTracksToAdd, artist, album, genre))
            
        XCTAssertEqual(group.size, groupSizeBeforeAdd + (groupAffectedByAdd ? numTracksToAdd : 0))
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
    }
    
    // MARK: tracksRemoved() tests --------------------------------------------------------------------------------------------------
    
    // When the second-last track in the sequence is playing, and the last track is removed,
    // the return values of peekSubsequent() and peekNext() should change from non-nil to nil.
    func testTracksRemoved_tracksPlaylist_allTracksRemoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(5)
            let playingTrack = sequencer.select(3)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, 3)
            
            let removeResults = playlist.removeTracks(IndexSet(0...4))
            sequencer.tracksRemoved(removeResults)
            
            XCTAssertNil(sequencer.sequence.curTrackIndex)
            XCTAssertNil(sequencer.currentTrack)
            XCTAssertNil(sequencer.scope.group)
        }
    }
    
    func testTracksRemoved_groupingPlaylists_allTracksRemoved() {
        
        for playlistType: PlaylistType in [.artists, .albums, .genres] {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                _ = createAndAddNTracks(50)
                
                let groups = playlist.allGroups(playlistType.toGroupType()!)
                let randomGroup = groups[Int.random(in: 0..<groups.count)]
                let playingTrack = sequencer.select(randomGroup)
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, randomGroup.indexOfTrack(playingTrack!))
                
                let removeResults = playlist.removeTracksAndGroups([], groups, playlistType.toGroupType()!)
                sequencer.tracksRemoved(removeResults)
                
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When the second-last track in the sequence is playing, and the last track is removed,
    // the return values of peekSubsequent() and peekNext() should change from non-nil to nil.
    func testTracksRemoved_tracksPlaylist_secondLastTrackPlaying_lastTrackRemoved() {
        
        playlist.clear()
        sequencer.end()
        preTest(.tracks, .off, .off)
        
        _ = createAndAddNTracks(5)
        let playingTrack = sequencer.select(3)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, 3)
        
        XCTAssertEqual(sequencer.peekSubsequent()!, playlist.tracks[4])
        XCTAssertEqual(sequencer.peekNext()!, playlist.tracks[4])
        
        let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex

        let removeResults = playlist.removeTracks(IndexSet([4]))
        sequencer.tracksRemoved(removeResults)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
            
            _ = createAndAddNTracks(100)
            
            let lastGroup = playlist.allGroups(groupType).last!
            
            // Before removing, add some tracks to the playing group to ensure that the group has more than 2 tracks
            var trackAdd: [TrackAddResult]
            
            switch groupType {
                
            case .artist:   trackAdd = createAndAddNTracks(5, lastGroup.name)
                
            case .album:    trackAdd = createAndAddNTracks(5, randomArtist(), lastGroup.name)
                
            case .genre:    trackAdd = createAndAddNTracks(5, randomArtist(), randomAlbum(), lastGroup.name)
                
            }
            
            sequencer.tracksAdded(trackAdd)
            
            let secondLastTrack = lastGroup.allTracks()[lastGroup.size - 2]
            let lastTrack = lastGroup.allTracks().last!
            
            // Select the second-last track for playback
            
            let playingTrack = sequencer.select(secondLastTrack)
            XCTAssertEqual(playingTrack!, secondLastTrack)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, lastGroup.size - 2)
            
            // Last track is the subsequent/next track
            XCTAssertEqual(sequencer.peekSubsequent()!, lastTrack)
            XCTAssertEqual(sequencer.peekNext()!, lastTrack)
            
            let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex

            // Remove the last track from the group
            let removeResults = playlist.removeTracksAndGroups([lastTrack], [], groupType)
            sequencer.tracksRemoved(removeResults)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                
                _ = createAndAddNTracks(5)
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                let sequenceSizeBeforeRemove = sequencer.sequence.size
                let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex
                
                sequencer.tracksRemoved(TrackRemovalResults.empty)
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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

                _ = createAndAddNTracks(100)

                let groups = playlist.allGroups(playlistType.toGroupType()!)
                let randomGroup = groups[Int.random(in: 0..<groups.count)]
                let playingTrack = sequencer.select(randomGroup)

                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, randomGroup.indexOfTrack(playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, randomGroup.size)

                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, playlistType.toGroupScopeType())

                let sequenceSizeBeforeRemove = sequencer.sequence.size
                let sequenceTrackIndexBeforeRemove = sequencer.sequence.curTrackIndex

                sequencer.tracksRemoved(TrackRemovalResults.empty)

                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                _ = createAndAddNTracks(100)
                
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                
                var removedTracksIndices: Set<Int> = Set()
                for _ in 1...10 {
                    removedTracksIndices.insert(Int.random(in: 0..<playlist.size))
                }
                
                let removedTracks = playlist.removeTracks(IndexSet(removedTracksIndices))

                sequencer.tracksRemoved(removedTracks)

                XCTAssertNil(sequencer.currentTrack)
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

            _ = createAndAddNTracks(50)
            let playingTrack = sequencer.select(23)

            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
            
            sequencer.tracksRemoved(removedTracks)

            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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

                _ = createAndAddNTracks(20)
                let playingTrack = sequencer.begin()

                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                
                sequencer.tracksRemoved(removedTrackResults)

                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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

            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")

            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)

            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let tracksToRemoveFromMadonnaGroup: [Track] = [1, 9, 17].compactMap {madonnaArtistGroup.trackAtIndex($0)}
            doTestTracksRemoved_groupPlaying(madonnaArtistGroup, tracksToRemoveFromMadonnaGroup + Array(grimesArtistGroup.allTracks().suffix(5)), [])
        }
    }
    
    // When no tracks are removed from the playing group, the sequence should remain unchanged.
    func testTracksRemoved_artistGroupPlaying_groupNotAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.artists, repeatMode, shuffleMode)

            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")

            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)

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

            _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")

            let album_visions = "Visions"
            _ = createAndAddNTracks(Int.random(in: 20...30), "Grimes", album_visions)

            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let visionsAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_visions}).first!

            let tracksToRemoveFromVisionsGroup: [Track] = [1, 9, 17].compactMap {visionsAlbumGroup.trackAtIndex($0)}
            
            doTestTracksRemoved_groupPlaying(visionsAlbumGroup, tracksToRemoveFromVisionsGroup, [halfaxaAlbumGroup])
        }
    }

    // When no tracks are removed from the playing group, the sequence should remain unchanged.
    func testTracksRemoved_albumGroupPlaying_groupNotAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.albums, repeatMode, shuffleMode)

            _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")

            let album_visions = "Visions"
            _ = createAndAddNTracks(Int.random(in: 20...30), "Grimes", album_visions)

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

            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")

            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...30), "Madonna", "Ray of Light", genre_pop)

            let intlGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "International"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!

            let tracksToRemoveFromPopGroup: [Track] = [1, 9, 17].compactMap {popGenreGroup.trackAtIndex($0)}
            doTestTracksRemoved_groupPlaying(popGenreGroup, tracksToRemoveFromPopGroup, [intlGenreGroup])
        }
    }

    // When no tracks are removed from the playing group, the sequence should remain unchanged.
    func testTracksRemoved_genreGroupPlaying_groupNotAffected() {

        for (repeatMode, shuffleMode) in repeatShufflePermutations {

            playlist.clear()
            sequencer.end()

            preTest(.genres, repeatMode, shuffleMode)

            _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
            _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")

            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...30), "Madonna", "Ray of Light", genre_pop)

            let intlGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "International"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            doTestTracksRemoved_groupPlaying(popGenreGroup, [], [intlGenreGroup])
        }
    }

    private func doTestTracksRemoved_groupPlaying(_ group: Group, _ tracksToRemove: [Track], _ groupsToRemove: [Group]) {

        let playingTrack = sequencer.select(group)

        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
        sequencer.tracksRemoved(removalResults)
        
        XCTAssertEqual(group.size, groupSizeBeforeRemove - numTracksRemovedFromScopeGroup)
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
    }
    
    // When the playing track is removed, the sequence should end.
    func testTracksRemoved_playingTrackRemoved() {

        playlist.clear()
        sequencer.end()

        preTest(.tracks, .off, .off)

        _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")

        let playingTrack = sequencer.select(3)

        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, 3)
        XCTAssertEqual(sequencer.sequence.size, playlist.size)
        XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
        XCTAssertNil(sequencer.scope.group)

        let trackRemovalResults = playlist.removeTracks(IndexSet([3]))
        sequencer.tracksRemoved(trackRemovalResults)

        // Check that the sequence has ended.
        XCTAssertNil(sequencer.currentTrack)
        XCTAssertNil(sequencer.sequence.curTrackIndex)
    }
    
    // MARK: playlistCleared() tests --------------------------------------------------------
    
    func testPlaylistCleared_noPlayingTrack() {
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                let addedTracks = createAndAddNTracks(100)
                sequencer.tracksAdded(addedTracks)
                
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.currentTrack)
                
                sequencer.playlistCleared()
                
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.scope.group)
                XCTAssertEqual(sequencer.sequence.size, 0)
                XCTAssertEqual(sequencer.sequence.shuffleSequence.size, 0)
            }
        }
    }
    
    func testPlaylistCleared_playlistScopes_withPlayingTrack() {
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                let addedTracks = createAndAddNTracks(100)
                sequencer.tracksAdded(addedTracks)
                
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.currentTrack!, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                sequencer.playlistCleared()
                
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.scope.group)
                XCTAssertEqual(sequencer.sequence.size, 0)
                XCTAssertEqual(sequencer.sequence.shuffleSequence.size, 0)
            }
        }
    }
    
    func testPlaylistCleared_groupScopes_withPlayingTrack() {
        
        for groupType in GroupType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(groupType.toPlaylistType(), repeatMode, shuffleMode)
                
                let addedTracks = createAndAddNTracks(100)
                sequencer.tracksAdded(addedTracks)
                
                let groups = playlist.allGroups(groupType)
                let randomGroup = groups[Int.random(in: 0..<groups.count)]
                let playingTrack = sequencer.select(randomGroup)
                
                XCTAssertEqual(sequencer.currentTrack!, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, randomGroup.indexOfTrack(playingTrack!)!)
                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, groupType.toScopeType())
                
                sequencer.playlistCleared()
                
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.scope.group)
                XCTAssertEqual(sequencer.sequence.size, 0)
                XCTAssertEqual(sequencer.sequence.shuffleSequence.size, 0)
            }
        }
    }
}

extension TrackRemovalResults {
    
    static var empty: TrackRemovalResults {
        return TrackRemovalResults(groupingPlaylistResults: [:], flatPlaylistResults: IndexSet([]), tracks: [])
    }
}
