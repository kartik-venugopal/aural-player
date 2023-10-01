//
//  GroupType.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An enumeration of all the different types of track groups.
///
enum GroupType: String, CaseIterable {
    
    // Group of tracks categorized by their artist
    case artist
    
    // Group of tracks categorized by their album
    case album
    
    // Group of tracks categorized by their genre
    case genre
    
    // Maps a GroupType to a corresponding PlaylistType
    func toPlaylistType() -> PlaylistType {
        
        switch self {
            
        case .artist: return .artists
            
        case.album: return .albums
            
        case.genre: return .genres
            
        }
    }
    
    func toScopeType() -> SequenceScopeType {
        
        switch self {
            
        case .artist: return .artist
            
        case.album: return .album
            
        case.genre: return .genre
            
        }
    }
}
