//
//  SequencerTrackSelectionTests.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerTrackSelectionTests: SequencerTests {

    func testSelectIndex() {
        
        _ = createAndAddNTracks(Int.random(in: 10...1000))
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            preTest(.tracks, repeatMode, shuffleMode)
            
            var randomIndices: [Int] = Array(0..<playlist.size)
            randomIndices.shuffle()
            
            for index in randomIndices {
                
                let track = sequencer.select(index)
                
                XCTAssertNotNil(track)
                
                // Check that the returned track matches the sequencer's playingTrack property
                XCTAssertEqual(sequencer.currentTrack, track)
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
     
        let tracks = createAndAddNTracks(Int.random(in: 10...1000)).map {$0.track}
        
        let indexOfSelTrack = Int.random(in: 0..<playlist.size)
        let selTrack = tracks[indexOfSelTrack]
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            preTest(.tracks, repeatMode, shuffleMode)
            
            let track = sequencer.select(selTrack)
            
            XCTAssertNotNil(track)
            
            // Check that the returned track matches the sequencer's playingTrack property
            XCTAssertEqual(sequencer.currentTrack, track)
            XCTAssertEqual(selTrack, track)
            
            let sequence = sequencer.sequenceInfo
            
            XCTAssertNil(sequence.scope.group)
            
            XCTAssertEqual(sequence.scope.type, PlaylistType.tracks.toPlaylistScopeType())
            XCTAssertEqual(sequence.trackIndex, indexOfSelTrack + 1)
            XCTAssertEqual(sequence.totalTracks, playlist.size)
        }
    }
    
    func testSelectTrack_artistsPlaylist() {
        
        _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes")
        _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One")
        
        let artist_madonna = "Madonna"
        let madonnaTracks = createAndAddNTracks(Int.random(in: 10...20), artist_madonna).map {$0.track}
        let selectedTrack = madonnaTracks[Int.random(in: 0..<madonnaTracks.count)]

        // Select a track by artist "Madonna"
        doTestSelectTrack_fromGroup(selectedTrack, PlaylistType.artists, artist_madonna)
    }
    
    func testSelectTrack_albumsPlaylist() {
     
        _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")
        _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera")
        
        let album_exilarch = "Exilarch"
        let exilarchTracks = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", album_exilarch).map {$0.track}
        let selectedTrack = exilarchTracks[Int.random(in: 0..<exilarchTracks.count)]

        // Select a track from album "Exilarch"
        doTestSelectTrack_fromGroup(selectedTrack, PlaylistType.albums, album_exilarch)
    }
    
    func testSelectTrack_genresPlaylist() {
     
        _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
        _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")
        
        let genre_rock = "Rock"
        var rockTracks = createAndAddNTracks(Int.random(in: 10...20), "Pink Floyd", "The Dark Side of the Moon", genre_rock).map {$0.track}
        rockTracks.append(contentsOf: createAndAddNTracks(Int.random(in: 5...12), "Dire Straits", "Brothers in Arms", genre_rock).map {$0.track})
        let selectedTrack = rockTracks[Int.random(in: 0..<rockTracks.count)]

        // Select a track from genre "Rock"
        doTestSelectTrack_fromGroup(selectedTrack, PlaylistType.genres, genre_rock)
    }
    
    private func doTestSelectTrack_fromGroup(_ track: Track, _ playlistType: PlaylistType, _ expectedParentGroupName: String) {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            preTest(playlistType, repeatMode, shuffleMode)
            
            let playingTrack = sequencer.select(track)
            
            XCTAssertNotNil(playingTrack)
            
            // Check that the returned track matches the sequencer's playingTrack property
            XCTAssertEqual(sequencer.currentTrack, playingTrack)
            XCTAssertEqual(track, playingTrack)
            
            let sequence = sequencer.sequenceInfo
            
            XCTAssertEqual(sequence.scope.type, playlistType.toGroupScopeType())
            XCTAssertNotNil(sequence.scope.group)
            
            let group = playlist.groupingInfoForTrack(playlistType.toGroupType()!, track)?.group
            XCTAssertNotNil(group)
            
            if let parentGroup = group {
                
                XCTAssertEqual(sequence.scope.group, parentGroup)
                XCTAssertTrue(parentGroup.tracks.contains(track))
                
                XCTAssertEqual(parentGroup.name, expectedParentGroupName)
                XCTAssertEqual(sequence.trackIndex, parentGroup.indexOfTrack(track)! + 1)
                XCTAssertEqual(sequence.totalTracks, parentGroup.size)
                
                switch parentGroup.type {
                    
                case .artist:
                    
                    XCTAssertEqual(playingTrack?.artist, parentGroup.name)
                    
                case .album:
                    
                    XCTAssertEqual(playingTrack?.album, parentGroup.name)
                    
                case .genre:
                    
                    XCTAssertEqual(playingTrack?.genre, parentGroup.name)
                }
            }
        }
    }
    
    func testSelectGroup_artist() {
     
        _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes")
        _ = createAndAddNTracks(Int.random(in: 5...10), "Conjure One")
        
        let artist_madonna = "Madonna"
        let madonnaTracks = createAndAddNTracks(Int.random(in: 5...10), artist_madonna)
        
        let madonnaArtistGroup: Group? = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first
        XCTAssertNotNil(madonnaArtistGroup)
        
        if let theGroup = madonnaArtistGroup {
            
            XCTAssertEqual(theGroup.name, artist_madonna)
            XCTAssertEqual(theGroup.size, madonnaTracks.count)

            // Select artist group "Madonna"
            doTestSelectGroup(theGroup)
        }
    }
    
    func testSelectGroup_album() {
     
        _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa")
        _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera")
        
        let album_exilarch = "Exilarch"
        let exilarchTracks = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", album_exilarch)
        
        let exilarchAlbumGroup: Group? = playlist.allGroups(.album).filter({$0.name == album_exilarch}).first
        XCTAssertNotNil(exilarchAlbumGroup)
        
        if let theGroup = exilarchAlbumGroup {
            
            XCTAssertEqual(theGroup.name, album_exilarch)
            XCTAssertEqual(theGroup.size, exilarchTracks.count)
            
            // Select album group "Exilarch"
            doTestSelectGroup(theGroup)
        }
    }
    
    func testSelectGroup_genre() {
     
        _ = createAndAddNTracks(Int.random(in: 5...10), "Grimes", "Halfaxa", "Dance & DJ")
        _ = createAndAddNTracks(Int.random(in: 5...10), "Delerium", "Music Box Opera", "International")
        
        let genre_rock = "Rock"
        var rockTracks = createAndAddNTracks(Int.random(in: 10...20), "Pink Floyd", "The Dark Side of the Moon", genre_rock)
        rockTracks.append(contentsOf: createAndAddNTracks(Int.random(in: 5...12), "Dire Straits", "Brothers in Arms", genre_rock))
        
        let rockGenreGroup: Group? = playlist.allGroups(.genre).filter({$0.name == genre_rock}).first
        XCTAssertNotNil(rockGenreGroup)
        
        if let theGroup = rockGenreGroup {
            
            XCTAssertEqual(theGroup.name, genre_rock)
            XCTAssertEqual(theGroup.size, rockTracks.count)
            
            // Select genre group "Rock"
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
            XCTAssertEqual(sequencer.currentTrack, playingTrack)
            
            if shuffleMode == .off {
                
                // If shuffle is off, the first track in the group should be selected.
                XCTAssertEqual(playingTrack, group.trackAtIndex(0))
                
            } else {
                
                // If shuffle is on, the shuffle sequence's first element should match the index of the track selected.
                let shuffleSequence = sequencer.sequence.shuffleSequence.sequence
                XCTAssertEqual(playingTrack, group.trackAtIndex(shuffleSequence[0]))
            }
            
            let sequence = sequencer.sequenceInfo

            XCTAssertEqual(sequence.scope.group, group)
            XCTAssertEqual(sequence.scope.type, group.type.toScopeType())
            
            XCTAssertEqual(sequence.trackIndex, shuffleMode == .off ? 1 : group.indexOfTrack(playingTrack!)! + 1)
            XCTAssertEqual(sequence.totalTracks, group.size)
            
            switch group.type {
                
            case .artist:
                
                XCTAssertEqual(playingTrack?.artist, group.name)
                
            case .album:
                
                XCTAssertEqual(playingTrack?.album, group.name)
                
            case .genre:
                
                XCTAssertEqual(playingTrack?.genre, group.name)
            }
        }
    }
}
