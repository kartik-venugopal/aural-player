//
//  GroupingPlaylistTestCase.swift
//  Tests
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import XCTest

class GroupingPlaylistTestCase: AuralTestCase {
    
    func createNTracks(_ numTracks: Int, artist: String? = nil, album: String? = nil, genre: String? = nil) -> [Track] {

        return (1...numTracks).map {index in

            let title = "\(artist ?? "")-\(album ?? "")-Track-" + String(index)
            return createTrack(fileName: title, artist: artist, album: album, genre: genre)
        }
    }
    
    func createTrack(fileName: String, artist: String? = nil, album: String? = nil, genre: String? = nil) -> Track {
        
        let track = Track(URL(fileURLWithPath: String(format: "/Dummy/%@.mp3", fileName)))
        
        var fileMetadata: FileMetadata = FileMetadata()
        var playlistMetadata: PlaylistMetadata = PlaylistMetadata()
        
        playlistMetadata.artist = artist
        playlistMetadata.album = album
        playlistMetadata.genre = genre
        playlistMetadata.duration = .random(in: 60...600)
        
        fileMetadata.playlist = playlistMetadata
        track.setPlaylistMetadata(from: fileMetadata)
        
        return track
    }
}
