import XCTest

class PlaybackSequencerTests: PlaybackSequenceTests {

    private var sequencer: PlaybackSequencer!
    private var playlist: Playlist!
    
    private let artists: [String] = ["Conjure One", "Grimes", "Madonna", "Pink Floyd", "Dire Straits", "Ace of Base", "Delerium", "Blue Stone", "Jaia", "Paul Van Dyk"]
    
    private let albums: [String] = ["Exilarch", "Halfaxa", "Vogue", "The Wall", "Brothers in Arms", "The Sign", "Music Box Opera", "Messages", "Mai Mai", "Reflections"]
    
    private let genres: [String] = ["Electronica", "Pop", "Rock", "Dance"]
    
    private func randomArtist() -> String {
        return artists[Int.random(in: 0..<artists.count)]
    }
    
    private func randomAlbum() -> String {
        return albums[Int.random(in: 0..<albums.count)]
    }
    
    private func randomGenre() -> String {
        return genres[Int.random(in: 0..<genres.count)]
    }

    override func setUp() {
        
        if sequencer == nil {
            
            let flatPlaylist = FlatPlaylist()
            let artistsPlaylist = GroupingPlaylist(.artists, .artist)
            let albumsPlaylist = GroupingPlaylist(.albums, .album)
            let genresPlaylist = GroupingPlaylist(.genres, .genre)
            
            playlist = Playlist(flatPlaylist, [artistsPlaylist, albumsPlaylist, genresPlaylist])
            sequencer = PlaybackSequencer(playlist, .off, .off)
        }
        
        playlist.clear()
    }
    
    private func createTrack(_ title: String, _ duration: Double, _ artist: String? = nil, _ album: String? = nil, _ genre: String? = nil) -> Track {
        
        let track = Track(URL(fileURLWithPath: String(format: "/Dummy/%@.mp3", title)))
        track.setPrimaryMetadata(artist, title, album, genre, duration)
        
        _ = playlist.addTrack(track)
        
        return track
    }
    
    func testBegin_emptyPlaylist() {
        
        for playlistType in PlaylistType.allCases {
        
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                
                if shuffleMode == .off {
                    doTestBegin_noShuffle(playlistType, repeatMode, nil, 0, 0)
                } else {
                    doTestBegin_withShuffle(playlistType, repeatMode, true, false, nil, 0...0, 0)
                }
            }
        }
    }
    
    func testBegin_singleTrackInPlaylist() {
        
        playlist.clear()
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
        
        playlist.clear()
        
            _ = createTrack("Track-1", 300, randomArtist(), randomAlbum())
            _ = createTrack("Track-2", 200, randomArtist(), randomAlbum())
            _ = createTrack("Track-3", 180, randomArtist(), randomAlbum())
        
        for playlistType in PlaylistType.allCases {
        
            for repeatMode in RepeatMode.allCases {
                
                let expectedTrack = playlistType == .tracks ? playlist.tracks[0] : playlist.groupAtIndex(playlistType.toGroupType()!, 0).trackAtIndex(0)
                
                doTestBegin_noShuffle(playlistType, repeatMode, expectedTrack, 1, playlist.size)
            }
        }
    }
    
    func testBegin_shuffleOn() {
        
        playlist.clear()
        
            _ = createTrack("Track-1", 300, randomArtist(), randomAlbum())
            _ = createTrack("Track-2", 200, randomArtist(), randomAlbum())
            _ = createTrack("Track-3", 180, randomArtist(), randomAlbum())
        
        for playlistType: PlaylistType in [.tracks, .artists, .albums, .genres] {
        
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
        
        sequencer.end()
        XCTAssertNil(sequencer.playingTrack)
        
        // Cannot shuffle and repeat one track
        XCTAssertNotEqual(repeatMode, .one)
        
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
    
    private func preTest(_ playlistType: PlaylistType, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        sequencer.consumeNotification(PlaylistTypeChangedNotification(newPlaylistType: playlistType))
        
        _ = sequencer.setRepeatMode(repeatMode)
        let modes = sequencer.setShuffleMode(shuffleMode)
        
        XCTAssertEqual(modes.repeatMode, repeatMode)
        XCTAssertEqual(modes.shuffleMode, shuffleMode)
    }
    
    func testEnd_shuffleOff() {
        
        playlist.clear()
        
            _ = createTrack("Track-1", 300, randomArtist(), randomAlbum())
            _ = createTrack("Track-2", 200, randomArtist(), randomAlbum())
            _ = createTrack("Track-3", 180, randomArtist(), randomAlbum())
        
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
        
        playlist.clear()
        
            _ = createTrack("Track-1", 300, randomArtist(), randomAlbum())
            _ = createTrack("Track-2", 200, randomArtist(), randomAlbum())
            _ = createTrack("Track-3", 180, randomArtist(), randomAlbum())
        
        for playlistType: PlaylistType in [.tracks, .artists, .albums, .genres] {
        
            for repeatMode: RepeatMode in [.off, .all] {
                
                doTestBegin_withShuffle(playlistType, repeatMode, false, true, nil, 1...playlist.size, playlist.size)
                
                sequencer.end()
                XCTAssertNil(sequencer.playingTrack)
            }
        }
    }
    
    func testSelectIndex() {
        
        playlist.clear()
        _ = createTrack("Track-1", 300, randomArtist(), randomAlbum())
        _ = createTrack("Track-2", 200, randomArtist(), randomAlbum())
        _ = createTrack("Track-3", 180, randomArtist(), randomAlbum())
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            preTest(.tracks, repeatMode, shuffleMode)
            
            for index in 0..<playlist.size {
                
                let track = sequencer.select(index)
                
                XCTAssertNotNil(track)
                
                // Check that the returned track matches the sequencer's playingTrack property
                XCTAssertEqual(sequencer.playingTrack, track)
                XCTAssertEqual(playlist.tracks[index], track)
                
                let sequence = sequencer.sequenceInfo
                
                XCTAssertNil(sequence.scope.group)
                
                XCTAssertEqual(sequence.scope.type, PlaylistType.tracks.toPlaylistScopeType())
                XCTAssertEqual(sequence.trackIndex, index + 1)
                XCTAssertEqual(sequence.totalTracks, playlist.size)
            }
        }
    }
    
    func testSelectTrack_tracksPlaylist() {
     
        playlist.clear()
        _ = createTrack("Track-1", 300, randomArtist(), randomAlbum())
        let selTrack = createTrack("Track-2", 200, randomArtist(), randomAlbum())
        _ = createTrack("Track-3", 180, randomArtist(), randomAlbum())
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            preTest(.tracks, repeatMode, shuffleMode)
            
            let track = sequencer.select(selTrack)
            
            XCTAssertNotNil(track)
            
            // Check that the returned track matches the sequencer's playingTrack property
            XCTAssertEqual(sequencer.playingTrack, track)
            XCTAssertEqual(selTrack, track)
            
            let sequence = sequencer.sequenceInfo
            
            XCTAssertNil(sequence.scope.group)
            
            XCTAssertEqual(sequence.scope.type, PlaylistType.tracks.toPlaylistScopeType())
            XCTAssertEqual(sequence.trackIndex, playlist.indexOfTrack(selTrack)! + 1)
            XCTAssertEqual(sequence.totalTracks, playlist.size)
        }
    }
    
    func testSelectTrack_artistsPlaylist() {
     
        playlist.clear()
        
        // Artist group "Grimes"
        _ = createTrack("Track-1", 300, "Grimes", randomAlbum())
        
        // Artist group "Conjure One"
        _ = createTrack("Track-2", 180, "Conjure One", randomAlbum())
        _ = createTrack("Track-3", 195, "Conjure One", randomAlbum())
        
        // Artist group "Madonna"
        let artist = "Madonna"
        let selTrack = createTrack("Track-4", 200, artist, randomAlbum())
        _ = createTrack("Track-5", 200, artist, randomAlbum())
        _ = createTrack("Track-6", 200, artist, randomAlbum())
        _ = createTrack("Track-7", 200, artist, randomAlbum())
        
        doTestSelectTrack_fromGroup(selTrack, PlaylistType.artists, artist)
    }
    
    func testSelectTrack_albumsPlaylist() {
     
        playlist.clear()

        // Album group "Halfaxa"
        _ = createTrack("Track-1", 300, "Grimes", "Halfaxa")
        
        // Album group "Visions"
        _ = createTrack("Track-2", 180, "Grimes", "Visions")
        _ = createTrack("Track-3", 195, "Grimes", "Visions")
        
        // Album group "Exilarch"
        let artist = "Conjure One"
        let album = "Exilarch"
        
        let selTrack = createTrack("Track-4", 200, artist, album)
        _ = createTrack("Track-5", 200, artist, album)
        _ = createTrack("Track-6", 200, artist, album)
        _ = createTrack("Track-7", 200, artist, album)
        
        doTestSelectTrack_fromGroup(selTrack, PlaylistType.albums, album)
    }
    
    func testSelectTrack_genresPlaylist() {
     
        playlist.clear()

        // Genre group "Electronica"
        _ = createTrack("Track-1", 300, "Grimes", "Halfaxa", "Electronica")
        _ = createTrack("Track-2", 180, "Grimes", "Visions", "Electronica")
        _ = createTrack("Track-3", 195, "Grimes", "Visions", "Electronica")
        
        // Genre group "International"
        let artist = "Conjure One"
        let album = "Exilarch"
        let genre = "International"
        
        let selTrack = createTrack("Track-4", 200, artist, album, genre)
        _ = createTrack("Track-5", 200, artist, album, genre)
        _ = createTrack("Track-6", 200, artist, album, genre)
        _ = createTrack("Track-7", 200, artist, album, genre)
        
        doTestSelectTrack_fromGroup(selTrack, PlaylistType.genres, genre)
    }
    
    private func doTestSelectTrack_fromGroup(_ track: Track, _ playlistType: PlaylistType, _ expectedParentGroupName: String) {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            preTest(playlistType, repeatMode, shuffleMode)
            
            let playingTrack = sequencer.select(track)
            
            XCTAssertNotNil(playingTrack)
            
            // Check that the returned track matches the sequencer's playingTrack property
            XCTAssertEqual(sequencer.playingTrack, playingTrack)
            XCTAssertEqual(track, playingTrack)
            
            let sequence = sequencer.sequenceInfo
            
            XCTAssertEqual(sequence.scope.type, playlistType.toGroupScopeType())
            XCTAssertNotNil(sequence.scope.group)
            
            let group = playlist.groupingInfoForTrack(playlistType.toGroupType()!, track)?.group
            XCTAssertNotNil(group)
            
            if let parentGroup = group {
                
                XCTAssertEqual(sequence.scope.group, parentGroup)
                XCTAssertTrue(parentGroup.allTracks().contains(track))
                
                XCTAssertEqual(parentGroup.name, expectedParentGroupName)
                XCTAssertEqual(sequence.trackIndex, parentGroup.indexOfTrack(track)! + 1)
                XCTAssertEqual(sequence.totalTracks, parentGroup.size)
                
                switch parentGroup.type {
                    
                case .artist:
                    
                    XCTAssertEqual(playingTrack?.groupingInfo.artist, parentGroup.name)
                    
                case .album:
                    
                    XCTAssertEqual(playingTrack?.groupingInfo.album, parentGroup.name)
                    
                case .genre:
                    
                    XCTAssertEqual(playingTrack?.groupingInfo.genre, parentGroup.name)
                }
            }
        }
    }
    
    func testSelectGroup_artist() {
     
        playlist.clear()
        
        // Artist group "Grimes"
        _ = createTrack("Track-1", 300, "Grimes", randomAlbum())
        
        // Artist group "Conjure One"
        _ = createTrack("Track-2", 180, "Conjure One", randomAlbum())
        _ = createTrack("Track-3", 195, "Conjure One", randomAlbum())
        
        // Artist group "Madonna"
        let artist_madonna = "Madonna"
        _ = createTrack("Track-4", 200, artist_madonna, randomAlbum())
        _ = createTrack("Track-5", 200, artist_madonna, randomAlbum())
        _ = createTrack("Track-6", 200, artist_madonna, randomAlbum())
        _ = createTrack("Track-7", 200, artist_madonna, randomAlbum())
        
        let madonnaArtistGroup: Group? = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first
        XCTAssertNotNil(madonnaArtistGroup)
        
        if let theGroup = madonnaArtistGroup {
            
            XCTAssertEqual(theGroup.name, artist_madonna)
            XCTAssertEqual(theGroup.size, 4)
            
            doTestSelectGroup(theGroup)
        }
    }
    
    func testSelectGroup_album() {
     
        playlist.clear()
        
        // Album group "Halfaxa"
        _ = createTrack("Track-1", 300, "Grimes", "Halfaxa")
        
        // Album group "Visions"
        _ = createTrack("Track-2", 180, "Grimes", "Visions")
        _ = createTrack("Track-3", 195, "Grimes", "Visions")
        
        // Album group "Exilarch"
        let artist = "Conjure One"
        let album_exilarch = "Exilarch"
        
        _ = createTrack("Track-4", 200, artist, album_exilarch)
        _ = createTrack("Track-5", 200, artist, album_exilarch)
        _ = createTrack("Track-6", 200, artist, album_exilarch)
        _ = createTrack("Track-7", 200, artist, album_exilarch)
        
        let exilarchAlbumGroup: Group? = playlist.allGroups(.album).filter({$0.name == album_exilarch}).first
        XCTAssertNotNil(exilarchAlbumGroup)
        
        if let theGroup = exilarchAlbumGroup {
            
            XCTAssertEqual(theGroup.name, album_exilarch)
            XCTAssertEqual(theGroup.size, 4)
            
            doTestSelectGroup(theGroup)
        }
    }
    
    func testSelectGroup_genre() {
     
        playlist.clear()
        
        // Genre group "Electronica"
        _ = createTrack("Track-1", 300, "Grimes", "Halfaxa", "Electronica")
        _ = createTrack("Track-2", 180, "Grimes", "Visions", "Electronica")
        _ = createTrack("Track-3", 195, "Grimes", "Visions", "Electronica")
        
        // Genre group "International"
        let artist = "Conjure One"
        let album = "Exilarch"
        let genre_international = "International"
        
        _ = createTrack("Track-4", 200, artist, album, genre_international)
        _ = createTrack("Track-5", 200, artist, album, genre_international)
        _ = createTrack("Track-6", 200, artist, album, genre_international)
        _ = createTrack("Track-7", 200, artist, album, genre_international)
        
        let internationalGenreGroup: Group? = playlist.allGroups(.genre).filter({$0.name == genre_international}).first
        XCTAssertNotNil(internationalGenreGroup)
        
        if let theGroup = internationalGenreGroup {
            
            XCTAssertEqual(theGroup.name, genre_international)
            XCTAssertEqual(theGroup.size, 4)
            
            doTestSelectGroup(theGroup)
        }
    }
    
    private func doTestSelectGroup(_ group: Group) {
        
        let playlistType = group.type.toPlaylistType()
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            preTest(playlistType, repeatMode, shuffleMode)
            
            let playingTrack = sequencer.select(group)
            XCTAssertNotNil(playingTrack)
            
            // Check that the returned track matches the sequencer's playingTrack property
            XCTAssertEqual(sequencer.playingTrack, playingTrack)
            
            if shuffleMode == .off {
                
                // If shuffle is off, the first track in the group should be selected.
                XCTAssertEqual(group.trackAtIndex(0), playingTrack)
                
            } else {
                
                // If shuffle is on, we cannot predict the index of the track within the group.
                // It suffices to check the selected group contains the playing track.
                XCTAssertTrue(group.allTracks().contains(playingTrack!))
            }
            
            let sequence = sequencer.sequenceInfo

            XCTAssertEqual(sequence.scope.group, group)
            XCTAssertEqual(sequence.scope.type, group.type.toScopeType())
            
            XCTAssertEqual(sequence.trackIndex, shuffleMode == .off ? 1 : group.indexOfTrack(playingTrack!)! + 1)
            XCTAssertEqual(sequence.totalTracks, group.size)
            
            switch group.type {
                
            case .artist:
                
                XCTAssertEqual(playingTrack?.groupingInfo.artist, group.name)
                
            case .album:
                
                XCTAssertEqual(playingTrack?.groupingInfo.album, group.name)
                
            case .genre:
                
                XCTAssertEqual(playingTrack?.groupingInfo.genre, group.name)
            }
        }
    }
}
