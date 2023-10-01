//
//  SequenceScope.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A sequence scope defines the set of tracks that constitute the playback sequence. It could
/// either be one of the playlists (for ex, all tracks or all genres), or a single specific group
/// (for ex, Artist "Madonna" or Genre "Pop").
///
class SequenceScope {
    
    // The type of the scope (ex, "All tracks", or "Album")
    var type: SequenceScopeType
    
    // If only a particular artist/album/genre is being played back, holds the specific artist/album/genre group. Nil otherwise.
    var group: Group?
    
    init(_ type: SequenceScopeType) {
        self.type = type
    }
}

///
/// An enumeration of all possible types of sequence scopes.
///
enum SequenceScopeType: String {
    
    // All tracks will be played from the "Tracks" playlist
    case allTracks
    
    // All tracks will be played from the "Artists" playlist
    case allArtists
    
    // All tracks will be played from the "Albums" playlist
    case allAlbums
    
    // All tracks will be played from the "Genres" playlist
    case allGenres
    
    // A single selected group will be played from the "Artists" playlist
    case artist
    
    // A single selected group will be played from the "Albums" playlist
    case album
    
    // A single selected group will be played from the "Genres" playlist
    case genre
    
    // Maps a sequence scope type to a GroupType
    func toGroupType() -> GroupType? {
        
        switch self {
            
        // No applicable group type for the flat playlist
        case .allTracks: return nil
            
        case .allArtists, .artist: return .artist
            
        case .allAlbums, .album: return .album
            
        case .allGenres, .genre: return .genre
            
        }
    }
    
    // Maps a sequence scope type to a PlaylistType
    func toPlaylistType() -> PlaylistType {
        
        switch self {
            
        case .allTracks: return .tracks
            
        case .allArtists, .artist: return .artists
            
        case .allAlbums, .album: return .albums
            
        case .allGenres, .genre: return .genres
            
        }
    }
}
