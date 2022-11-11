//
//  PlaylistViewSelector.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// Helps in filtering command notifications sent to playlist views, i.e. "selects" a playlist view
// as the intended recipient of a command notification.
struct PlaylistViewSelector: OptionSet {
    
    let rawValue: Int
    
    static let tracks = PlaylistViewSelector(rawValue: 1 << 0)
    static let artists = PlaylistViewSelector(rawValue: 1 << 1)
    static let albums = PlaylistViewSelector(rawValue: 1 << 2)
    static let genres = PlaylistViewSelector(rawValue: 1 << 3)
    
    // A selector instance that specifies a selection of all playlist views.
    static let all: PlaylistViewSelector = [tracks, artists, albums, genres]
    
    static func selector(forView view: PlaylistType) -> PlaylistViewSelector {
        
        switch view {
        
        case .tracks:   return .tracks
            
        case .artists:  return .artists
            
        case .albums:   return .albums
            
        case .genres:   return .genres
            
        }
    }
}
