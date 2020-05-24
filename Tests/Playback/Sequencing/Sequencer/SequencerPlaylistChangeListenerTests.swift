import XCTest

class SequencerPlaylistChangeListenerTests: SequencerTests {
    
    func testTracksAdded_playlistScopes_noTracksAdded() {
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                _ = createNTracks(5)
                let playingTrack = sequencer.select(2)
                
                XCTAssertNotNil(playingTrack)
                XCTAssertEqual(sequencer.sequence.curTrackIndex, playlist.indexOfTrack(playingTrack!)!)
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
                XCTAssertNil(sequencer.scope.group)
                
                let sequenceSizeBeforeAdd = sequencer.sequence.size
                let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
                
                sequencer.tracksAdded([])
                
                XCTAssertEqual(sequencer.sequence.curTrackIndex, sequenceTrackIndexBeforeAdd)
                XCTAssertEqual(sequencer.sequence.size, sequenceSizeBeforeAdd)
                XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
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
                
                XCTAssertNotNil(playingTrack)
                XCTAssertNotNil(sequencer.sequence.curTrackIndex)
                XCTAssertEqual(sequencer.sequence.curTrackIndex, randomGroup.indexOfTrack(playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, randomGroup.size)
                
                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, playlistType.toGroupScopeType())
                
                let sequenceSizeBeforeAdd = sequencer.sequence.size
                let sequenceTrackIndexBeforeAdd = sequencer.sequence.curTrackIndex
                
                sequencer.tracksAdded([])
                
                XCTAssertEqual(sequencer.sequence.curTrackIndex, sequenceTrackIndexBeforeAdd)
                XCTAssertEqual(sequencer.sequence.size, sequenceSizeBeforeAdd)
                
                XCTAssertEqual(sequencer.scope.group, randomGroup)
                XCTAssertEqual(sequencer.scope.type, playlistType.toGroupScopeType())
            }
        }
    }
    
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

    func testTracksAdded_tracksPlaylist() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
        
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            var tracks = createNTracks(5)
            let playingTrack = sequencer.select(2)
            
            XCTAssertNotNil(playingTrack)
            XCTAssertEqual(sequencer.sequence.curTrackIndex, playlist.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
            
            tracks = createNTracks(12)
            sequencer.tracksAdded(tracks)
            
            XCTAssertEqual(sequencer.sequence.curTrackIndex, playlist.indexOfTrack(playingTrack!))
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
        }
    }
    
    func testTracksAdded_groupingPlaylists() {
        
        for playlistType: PlaylistType in [.artists, .albums, .genres] {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                var tracks = createNTracks(5)
                let playingTrack = sequencer.begin()
                
                XCTAssertNotNil(playingTrack)
                XCTAssertEqual(sequencer.sequence.curTrackIndex, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                tracks = createNTracks(12)
                sequencer.tracksAdded(tracks)
                
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.sequence.curTrackIndex, playlistIndexOfTrack(playlistType, playingTrack!))
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
        
        XCTAssertNotNil(playingTrack)
        XCTAssertEqual(sequencer.sequence.curTrackIndex, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
        
        let groupSizeBeforeAdd = group.size
        
        sequencer.tracksAdded(createNTracks(numTracksToAdd, artist, album, genre))
            
        XCTAssertEqual(group.size, groupSizeBeforeAdd + (groupAffectedByAdd ? numTracksToAdd : 0))
        XCTAssertEqual(sequencer.sequence.size, group.size)
        XCTAssertEqual(sequencer.sequence.curTrackIndex, group.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.scope.type, group.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, group)
    }
}
