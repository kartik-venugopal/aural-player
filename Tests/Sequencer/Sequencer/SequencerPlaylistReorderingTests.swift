//
//  SequencerPlaylistReorderingTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class SequencerPlaylistReorderingTests: SequencerTests {
    
    private func playlistIndexOfTrack(_ playlistType: PlaylistType, _ track: Track) -> Int {
        
        if playlistType == .tracks {
            return playlist.indexOfTrack(track)!
        }
        
        var scopeTracks: [Track] = []
        
        let groups = playlist.allGroups(playlistType.toGroupType()!)
        groups.forEach({scopeTracks.append(contentsOf: $0.tracks)})

        return scopeTracks.firstIndex(of: track)!
    }
    
    // MARK: tracksReordered() tests -----------------------------------------------------------------------------------------------
    
    // When tracks are reordered within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testTracksReordered_tracksPlaylistScope_otherPlaylistsReordered() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(100)
            let playingTrackIndexBeforeMove: Int = 67
            let playingTrack = sequencer.select(playingTrackIndexBeforeMove)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
            
            _ = createAndAddNTracks(100)
            let playingGroup = playlist.allGroups(playingGroupType).first!
            let playingTrack = sequencer.select(playingGroup)
            
            let playingTrackIndexBeforeMove: Int = playingGroup.indexOfTrack(playingTrack!)!
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
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
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
                XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
                XCTAssertEqual(sequencer.scope.type, playingGroupType.toScopeType())
                XCTAssertEqual(sequencer.scope.group, playingGroup)
            }
            
            // Reorder tracks playlist
            
            let moveResults = playlist.moveTracksDown(IndexSet([25, 57, 79]))
            XCTAssertFalse(moveResults.results.isEmpty)
            
            sequencer.tracksReordered(moveResults)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
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
            
            _ = createAndAddNTracks(25)
            
            XCTAssertNil(sequencer.currentTrack)
            XCTAssertNil(sequencer.sequence.curTrackIndex)
            XCTAssertNil(sequencer.scope.group)
            
            // Take the last 3 tracks of the playlist, and move them up
            let size: Int = playlist.size
            let last3Tracks: IndexSet = IndexSet((size - 3)...(size - 1))
            
            let moveResults = playlist.moveTracksUp(last3Tracks)
            XCTAssertFalse(moveResults.results.isEmpty)
            
            sequencer.tracksReordered(moveResults)
            
            XCTAssertNil(sequencer.currentTrack)
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
                
                _ = createAndAddNTracks(25)
                
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.scope.group)
                
                // Take the last group in the playlist, and move it up
                let lastGroup = playlist.allGroups(groupType).last!
                let moveResults = playlist.moveTracksAndGroupsUp([], [lastGroup], groupType)
                XCTAssertFalse(moveResults.results.isEmpty)
                
                sequencer.tracksReordered(moveResults)
                
                XCTAssertNil(sequencer.currentTrack)
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
            
            _ = createAndAddNTracks(25)
            let playingTrackIndexBeforeMove: Int = 23
            let playingTrack = sequencer.select(playingTrackIndexBeforeMove)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
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
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)
            
            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let tracksToMoveInMadonnaGroup: [Track] = [1, 9, 17].compactMap {madonnaArtistGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(madonnaArtistGroup, tracksToMoveInMadonnaGroup, [grimesArtistGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_artistGroupPlaying_groupNotAffected_groupsMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.artists, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)
            
            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let tracksToMoveInGrimesGroup: [Track] = [1, 5, 7].compactMap {grimesArtistGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(madonnaArtistGroup, tracksToMoveInGrimesGroup, [])
        }
    }
    
    // When tracks within the playing group are reordered, the sequence should be updated accordingly.
    func testTracksReordered_albumGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")
            
            let album_erotica = "Erotica"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", album_erotica)
            
            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            
            let tracksToMoveInEroticaGroup: [Track] = [1, 9, 17].compactMap {eroticaAlbumGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(eroticaAlbumGroup, tracksToMoveInEroticaGroup, [halfaxaAlbumGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_albumGroupPlaying_groupNotAffected_groupsMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")
            
            let album_erotica = "Erotica"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", album_erotica)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")
            
            let album_erotica = "Erotica"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", album_erotica)
            
            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            
            let tracksToMoveInHalfaxaGroup: [Track] = [1, 5, 7].compactMap {halfaxaAlbumGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(eroticaAlbumGroup, tracksToMoveInHalfaxaGroup, [])
        }
    }
    
    // When tracks within the playing group are reordered, the sequence should be updated accordingly.
    func testTracksReordered_genreGroupPlaying_groupAffected() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)
            
            let danceGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "Dance"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let tracksToMoveInPopGroup: [Track] = [1, 9, 17].compactMap {popGenreGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(popGenreGroup, tracksToMoveInPopGroup, [danceGenreGroup])
        }
    }
    
    // When no tracks within the playing group are reordered, the sequence should remain unchanged.
    func testTracksReordered_genreGroupPlaying_groupNotAffected_groupsMoved() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)
            
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
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)
            
            let danceGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "Dance"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let tracksToMoveInDanceGroup: [Track] = [1, 5, 7].compactMap {danceGenreGroup.trackAtIndex($0)}
            
            doTestTracksReordered_groupPlaying(popGenreGroup, tracksToMoveInDanceGroup, [])
        }
    }
    
    private func doTestTracksReordered_groupPlaying(_ playingGroup: Group, _ tracksToMove: [Track], _ groupsToMove: [Group]) {
        
        let playingTrack = sequencer.select(playingGroup)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
        XCTAssertEqual(sequencer.scope.type, playingGroup.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, playingGroup)
        
        let groupSizeBeforeMove: Int = playingGroup.size
        
        let moveResults = playlist.moveTracksAndGroupsUp(tracksToMove, groupsToMove, playingGroup.type)
        XCTAssertFalse(moveResults.results.isEmpty)
        
        sequencer.tracksReordered(moveResults)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, groupSizeBeforeMove)
        XCTAssertEqual(sequencer.scope.type, playingGroup.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, playingGroup)
    }
    
    // MARK: playlistSorted() tests -----------------------------------------------------------------------------------------------
    
    // When tracks are sorted within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testPlaylistSorted_tracksPlaylistScope_otherPlaylistsSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(100)
            let playingTrackIndexBeforeMove: Int = 67
            let playingTrack = sequencer.select(playingTrackIndexBeforeMove)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
            XCTAssertEqual(sequencer.sequence.size, playlist.size)
            XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
            XCTAssertNil(sequencer.scope.group)
            
            for otherPlaylistType: PlaylistType in [.artists, .albums, .genres] {
                
                let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.descending))
                let sortResults = playlist.sort(sort, otherPlaylistType)
                XCTAssertTrue(sortResults.tracksSorted)
                
                sequencer.playlistSorted(sortResults)
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, SequenceScopeType.allTracks)
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When tracks are sorted within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testPlaylistSorted_artistPlaying_otherPlaylistsSorted() {
        doTestPlaylistSorted_groupingPlaylists_otherPlaylistsSorted(.artist)
    }
    
    // When tracks are sorted within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testPlaylistSorted_albumPlaying_otherPlaylistsSorted() {
        doTestPlaylistSorted_groupingPlaylists_otherPlaylistsSorted(.album)
    }
    
    // When tracks are sorted within a playlist that is different from that of the playing sequence scope, the sequence
    // should remain unchanged.
    func testPlaylistSorted_genrePlaying_otherPlaylistsSorted() {
        doTestPlaylistSorted_groupingPlaylists_otherPlaylistsSorted(.genre)
    }
    
    private func doTestPlaylistSorted_groupingPlaylists_otherPlaylistsSorted(_ playingGroupType: GroupType) {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            preTest(playingGroupType.toPlaylistType(), repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(100)
            let playingGroup = playlist.allGroups(playingGroupType).first!
            let playingTrack = sequencer.select(playingGroup)
            
            let playingTrackIndexBeforeMove: Int = sequencer.sequence.curTrackIndex!
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
            XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
            XCTAssertEqual(sequencer.scope.type, playingGroupType.toScopeType())
            XCTAssertEqual(sequencer.scope.group, playingGroup)
            
            // Sort other grouping playlists
            
            for otherGroupType: GroupType in GroupType.allCases.filter({$0 != playingGroupType}) {
                
                let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.descending).withScope(.allGroups))
                let sortResults = playlist.sort(sort, otherGroupType.toPlaylistType())
                XCTAssertTrue(sortResults.tracksSorted)
                
                sequencer.playlistSorted(sortResults)
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
                XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
                XCTAssertEqual(sequencer.scope.type, playingGroupType.toScopeType())
                XCTAssertEqual(sequencer.scope.group, playingGroup)
            }
            
            // Sort tracks playlist
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.descending))
            let sortResults = playlist.sort(sort, .tracks)
            XCTAssertTrue(sortResults.tracksSorted)
            
            sequencer.playlistSorted(sortResults)
            
            XCTAssertEqual(sequencer.currentTrack, playingTrack!)
            XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingTrackIndexBeforeMove)
            XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
            XCTAssertEqual(sequencer.scope.type, playingGroupType.toScopeType())
            XCTAssertEqual(sequencer.scope.group, playingGroup)
        }
    }
    
    // When there is no playing track, and tracks are sorted, the sequence (empty) should remain unchanged.
    func testPlaylistSorted_tracksPlaylist_noPlayingTrack() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            preTest(.tracks, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(25)
            
            XCTAssertNil(sequencer.currentTrack)
            XCTAssertNil(sequencer.sequence.curTrackIndex)
            XCTAssertNil(sequencer.scope.group)
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending))
            let sortResults = playlist.sort(sort, .tracks)
            XCTAssertTrue(sortResults.tracksSorted)
            
            sequencer.playlistSorted(sortResults)
            
            XCTAssertNil(sequencer.currentTrack)
            XCTAssertNil(sequencer.sequence.curTrackIndex)
            XCTAssertNil(sequencer.scope.group)
        }
    }
    
    // When there is no playing track, and tracks are sorted, the sequence (empty) should remain unchanged.
    func testPlaylistSorted_groupingPlaylists_noPlayingTrack() {
        
        for playlistType: PlaylistType in [.artists, .albums, .genres] {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(.tracks, repeatMode, shuffleMode)
                
                _ = createAndAddNTracks(25)
                
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.scope.group)
                
                let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.allGroups))
                let sortResults = playlist.sort(sort, playlistType)
                XCTAssertTrue(sortResults.tracksSorted)
                
                sequencer.playlistSorted(sortResults)
                
                XCTAssertNil(sequencer.currentTrack)
                XCTAssertNil(sequencer.sequence.curTrackIndex)
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When tracks are sorted, the sequence should be updated accordingly.
    func testPlaylistSorted_playlistScopes() {
        
        for playlistType in PlaylistType.allCases {
            
            for (repeatMode, shuffleMode) in repeatShufflePermutations {
                
                playlist.clear()
                sequencer.end()
                preTest(playlistType, repeatMode, shuffleMode)
                
                _ = createAndAddNTracks(25)
                let playingTrack = sequencer.begin()
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
                
                let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending))
                
                if playlistType != .tracks {
                    sort.tracksSort = sort.tracksSort?.withScope(.allGroups)
                }
                
                let sortResults = playlist.sort(sort, playlistType)
                XCTAssertTrue(sortResults.tracksSorted)
                
                sequencer.playlistSorted(sortResults)
                
                XCTAssertEqual(sequencer.currentTrack, playingTrack!)
                XCTAssertEqual(sequencer.sequence.curTrackIndex!, playlistIndexOfTrack(playlistType, playingTrack!))
                
                XCTAssertEqual(sequencer.sequence.size, playlist.size)
                XCTAssertEqual(sequencer.scope.type, playlistType.toPlaylistScopeType())
                XCTAssertNil(sequencer.scope.group)
            }
        }
    }
    
    // When tracks within the playing group are sorted, the sequence should be updated accordingly.
    func testPlaylistSorted_artistGroupPlaying_groupAffected_allGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.artists, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)
            
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.allGroups))
            
            doTestPlaylistSorted_groupPlaying(madonnaArtistGroup, sort)
        }
    }
    
    // When tracks within the playing group are sorted, the sequence should be updated accordingly.
    func testPlaylistSorted_artistGroupPlaying_groupAffected_someGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.artists, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)
            
            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.selectedGroups).withParentGroups([grimesArtistGroup, madonnaArtistGroup]))
            
            doTestPlaylistSorted_groupPlaying(madonnaArtistGroup, sort)
        }
    }
    
    // When no tracks within the playing group are sorted, the sequence should remain unchanged.
    func testPlaylistSorted_artistGroupPlaying_groupNotAffected_noTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.artists, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)
            
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let sort: Sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.descending))
            
            doTestPlaylistSorted_groupPlaying(madonnaArtistGroup, sort)
        }
    }
    
    // When no tracks within the playing group are sorted, the sequence should remain unchanged.
    func testPlaylistSorted_artistGroupPlaying_groupNotAffected_otherGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.artists, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes")
            
            let artist_madonna = "Madonna"
            _ = createAndAddNTracks(Int.random(in: 20...40), artist_madonna)
            
            let conjureOneArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Conjure One"}).first!
            let grimesArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == "Grimes"}).first!
            let madonnaArtistGroup: Group = playlist.allGroups(.artist).filter({$0.name == artist_madonna}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.selectedGroups).withParentGroups([conjureOneArtistGroup, grimesArtistGroup]))
            
            doTestPlaylistSorted_groupPlaying(madonnaArtistGroup, sort)
        }
    }
    
    // When tracks within the playing group are sorted, the sequence should be updated accordingly.
    func testPlaylistSorted_albumGroupPlaying_groupAffected_allGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")
            
            let album_erotica = "Erotica"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", album_erotica)
            
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.allGroups))
            
            doTestPlaylistSorted_groupPlaying(eroticaAlbumGroup, sort)
        }
    }
    
    // When tracks within the playing group are sorted, the sequence should be updated accordingly.
    func testPlaylistSorted_albumGroupPlaying_groupAffected_someGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")
            
            let album_erotica = "Erotica"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", album_erotica)
            
            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.selectedGroups).withParentGroups([halfaxaAlbumGroup, eroticaAlbumGroup]))
            
            doTestPlaylistSorted_groupPlaying(eroticaAlbumGroup, sort)
        }
    }
    
    // When no tracks within the playing group are sorted, the sequence should remain unchanged.
    func testPlaylistSorted_albumGroupPlaying_groupNotAffected_noTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")
            
            let album_erotica = "Erotica"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", album_erotica)
            
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            let sort: Sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
            
            doTestPlaylistSorted_groupPlaying(eroticaAlbumGroup, sort)
        }
    }
    
    // When no tracks within the playing group are sorted, the sequence should remain unchanged.
    func testPlaylistSorted_albumGroupPlaying_groupNotAffected_otherGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.albums, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa")
            
            let album_erotica = "Erotica"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", album_erotica)
            
            let halfaxaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == "Halfaxa"}).first!
            let eroticaAlbumGroup: Group = playlist.allGroups(.album).filter({$0.name == album_erotica}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.selectedGroups).withParentGroups([halfaxaAlbumGroup]))
            
            doTestPlaylistSorted_groupPlaying(eroticaAlbumGroup, sort)
        }
    }
    
    // When tracks within the playing group are sorted, the sequence should be updated accordingly.
    func testPlaylistSorted_genreGroupPlaying_groupAffected_allGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)
            
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.allGroups))
            
            doTestPlaylistSorted_groupPlaying(popGenreGroup, sort)
        }
    }
    
    // When tracks within the playing group are sorted, the sequence should be updated accordingly.
    func testPlaylistSorted_genreGroupPlaying_groupAffected_someGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)
            
            let danceGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "Dance"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.selectedGroups).withParentGroups([danceGenreGroup, popGenreGroup]))
            
            doTestPlaylistSorted_groupPlaying(popGenreGroup, sort)
        }
    }
    
    // When no tracks within the playing group are sorted, the sequence should remain unchanged.
    func testPlaylistSorted_genreGroupPlaying_groupNotAffected_noTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)
            
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let sort: Sort = Sort().withGroupsSort(GroupsSort().withFields(.name).withOrder(.ascending))
            
            doTestPlaylistSorted_groupPlaying(popGenreGroup, sort)
        }
    }
    
    // When no tracks within the playing group are sorted, the sequence should remain unchanged.
    func testPlaylistSorted_genreGroupPlaying_groupNotAffected_otherGroupTracksSorted() {
        
        for (repeatMode, shuffleMode) in repeatShufflePermutations {
            
            playlist.clear()
            sequencer.end()
            
            preTest(.genres, repeatMode, shuffleMode)
            
            _ = createAndAddNTracks(Int.random(in: 10...20), "Conjure One", "Exilarch", "International")
            _ = createAndAddNTracks(Int.random(in: 10...20), "Grimes", "Halfaxa", "Dance")
            
            let genre_pop = "Pop"
            _ = createAndAddNTracks(Int.random(in: 20...40), "Madonna", "Erotica", genre_pop)
            
            let danceGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == "Dance"}).first!
            let popGenreGroup: Group = playlist.allGroups(.genre).filter({$0.name == genre_pop}).first!
            
            let sort: Sort = Sort().withTracksSort(TracksSort().withFields(.name).withOrder(.ascending).withScope(.selectedGroups).withParentGroups([danceGenreGroup]))
            
            doTestPlaylistSorted_groupPlaying(popGenreGroup, sort)
        }
    }
    
    private func doTestPlaylistSorted_groupPlaying(_ playingGroup: Group, _ sort: Sort) {
        
        let playingTrack = sequencer.select(playingGroup)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, playingGroup.size)
        XCTAssertEqual(sequencer.scope.type, playingGroup.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, playingGroup)
        
        let groupSizeBeforeSort: Int = playingGroup.size
        
        let sortResults = playlist.sort(sort, playingGroup.type.toPlaylistType())
        XCTAssertEqual(sortResults.tracksSorted, sort.tracksSort != nil)
        
        sequencer.playlistSorted(sortResults)
        
        XCTAssertEqual(sequencer.currentTrack, playingTrack!)
        XCTAssertEqual(sequencer.sequence.curTrackIndex!, playingGroup.indexOfTrack(playingTrack!))
        XCTAssertEqual(sequencer.sequence.size, groupSizeBeforeSort)
        XCTAssertEqual(sequencer.scope.type, playingGroup.type.toScopeType())
        XCTAssertEqual(sequencer.scope.group, playingGroup)
    }
}
