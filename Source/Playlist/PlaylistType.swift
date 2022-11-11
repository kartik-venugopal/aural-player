//
//  PlaylistType.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An enumeration of all playlist types.
///
enum PlaylistType: String, CaseIterable, Codable {
    
    // Flat playlist listing all tracks
    case tracks
    
    // Hierarchical playlist that groups tracks by their artist
    case artists
    
    // Hierarchical playlist that groups tracks by their album
    case albums
    
    // Hierarchical playlist that groups tracks by their genre
    case genres
    
    // Maps a PlaylistType to a corresponding GroupType
    func toGroupType() -> GroupType? {
        
        switch self {
            
        // Group type is not applicable for the flat "Tracks" playlist
        case .tracks: return nil
            
        case .artists: return .artist
            
        case .albums: return .album
            
        case .genres: return .genre
            
        }
    }
    
    // Maps a playlist type to an optional scope type applicable if the playlist type is a grouping/hierarchical playlist, i.e. groups are its root elements.
    // So, the tracks playlist will not have a corresponding group scope, whereas the other playlists will.
    func toGroupScopeType() -> SequenceScopeType? {

        switch self {

            // Group type is not applicable for the flat "Tracks" playlist
            case .tracks: return nil

            case .artists: return .artist

            case .albums: return .album

            case .genres: return .genre
        }
    }
    
    // Maps this playlist type to a scope type corresponding to that playlist type. e.g., for the "Albums" playlist type, the corresponding playlist scope type will be "All Albums".
    func toPlaylistScopeType() -> SequenceScopeType {

        switch self {
            
        case .tracks: return .allTracks
            
        case .artists: return .allArtists
            
        case .albums: return .allAlbums
            
        case .genres: return .allGenres
            
        }
    }
    
    // Index of this playlist type's view within the playlist window.
    var index: Int {
        
        switch self {
            
        case .tracks: return 0
            
        case .artists: return 1
            
        case .albums: return 2
            
        case .genres: return 3
            
        }
    }
}
