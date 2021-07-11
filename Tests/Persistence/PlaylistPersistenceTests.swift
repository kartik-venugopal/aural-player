//
//  PlaylistPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class PlaylistPersistenceTests: PersistenceTestCase {
    
    func testPersistence_emptyPlaylist() {
        
        let groupingPlaylists: [String: GroupingPlaylistPersistentState] = [
        
            "artists": GroupingPlaylistPersistentState(type: .artists, groups: []),
            "albums": GroupingPlaylistPersistentState(type: .albums, groups: []),
            "genres": GroupingPlaylistPersistentState(type: .genres, groups: []),
        ]
        
        let playlistState = PlaylistPersistentState(tracks: [], groupingPlaylists: groupingPlaylists)
        doTestPersistence(serializedState: playlistState)
    }
    
    func testPersistence() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
        
            let newTracks = createNTracks(numTracks: Int.random(in: 1...1000))
            
            let trackPaths: [URLPath] = newTracks.tracks.map {$0.file.path}
            
            var artistGroups: [GroupPersistentState] = []
            for (artist, tracks) in newTracks.artistGroups {
                artistGroups.append(GroupPersistentState(name: artist, tracks: tracks.map {$0.file.path}))
            }
            
            var albumGroups: [GroupPersistentState] = []
            for (album, tracks) in newTracks.albumGroups {
                albumGroups.append(GroupPersistentState(name: album, tracks: tracks.map {$0.file.path}))
            }
            
            var genreGroups: [GroupPersistentState] = []
            for (genre, tracks) in newTracks.genreGroups {
                genreGroups.append(GroupPersistentState(name: genre, tracks: tracks.map {$0.file.path}))
            }
            
            let groupingPlaylists: [String: GroupingPlaylistPersistentState] = [
            
                "artists": GroupingPlaylistPersistentState(type: .artists, groups: artistGroups),
                "albums": GroupingPlaylistPersistentState(type: .albums, groups: albumGroups),
                "genres": GroupingPlaylistPersistentState(type: .genres, groups: genreGroups),
            ]
            
            let playlistState = PlaylistPersistentState(tracks: trackPaths, groupingPlaylists: groupingPlaylists)
            doTestPersistence(serializedState: playlistState)
        }
    }
    
    private func createNTracks(numTracks: Int) -> (tracks: [Track], artistGroups: [String: [Track]],
                                                   albumGroups: [String: [Track]],
                                                   genreGroups: [String: [Track]]) {

        var tracks: [Track] = []
        var artistGroups: [String: [Track]] = [:]
        var albumGroups: [String: [Track]] = [:]
        var genreGroups: [String: [Track]] = [:]

        for counter in 1...numTracks {

            let title = "Track-" + String(counter)
            let artist = randomArtist()
            let album = randomAlbum()
            let genre = randomGenre()

            let track = Track(URL(fileURLWithPath: String(format: "/Users/auralPlayerUser/Music/%@/%@.mp3", artist, title)))
            
            if artistGroups[artist] == nil {
                artistGroups[artist] = []
            }
            
            artistGroups[artist]!.append(track)
            
            if albumGroups[album] == nil {
                albumGroups[album] = []
            }
            
            albumGroups[album]!.append(track)
            
            if genreGroups[genre] == nil {
                genreGroups[genre] = []
            }
            
            genreGroups[genre]!.append(track)
            
            let fileMetadata: FileMetadata = FileMetadata()
            var playlistMetadata: PlaylistMetadata = PlaylistMetadata()
            
            playlistMetadata.artist = artist
            playlistMetadata.album = album
            playlistMetadata.genre = genre
            playlistMetadata.duration = 300
            
            fileMetadata.playlist = playlistMetadata
            track.setPlaylistMetadata(from: fileMetadata)

            tracks.append(track)
        }

        return (tracks, artistGroups, albumGroups, genreGroups)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension PlaylistPersistentState: Equatable {
    
    static func == (lhs: PlaylistPersistentState, rhs: PlaylistPersistentState) -> Bool {
        lhs.tracks == rhs.tracks && lhs.groupingPlaylists == rhs.groupingPlaylists
    }
}

extension GroupingPlaylistPersistentState: Equatable {
    
    static func == (lhs: GroupingPlaylistPersistentState, rhs: GroupingPlaylistPersistentState) -> Bool {
        lhs.type == rhs.type && lhs.groups == rhs.groups
    }
}

extension GroupPersistentState: Equatable {
    
    static func == (lhs: GroupPersistentState, rhs: GroupPersistentState) -> Bool {
        lhs.name == rhs.name && lhs.tracks == rhs.tracks
    }
}
