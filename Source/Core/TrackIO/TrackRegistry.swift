//
// TrackRegistry.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class TrackRegistry {
    
    private var tracks: ConcurrentMap<URL, Track> = ConcurrentMap()
    private var clients: [TrackRegistryClient] = []
    
    func registerClient(_ client: TrackRegistryClient) {
        clients.append(client)
    }
    
    func addTracks(_ tracks: any Sequence<Track>) {
        
        self.tracks.performUpdate {map in
            
            for track in tracks {
                map[track.file] = track
            }
        }
    }
    
    func updateTracks(_ tracks: any Sequence<Track>) {
        
        addTracks(tracks)
        
        clients.forEach {
            $0.updateWithTracksIfPresent(tracks)
        }
    }
    
    func findTrack(forFile file: URL) -> Track? {
        tracks[file]
    }
}

protocol TrackRegistryClient {
    
    func updateWithTracksIfPresent(_ tracks: any Sequence<Track>)
}

//class TrackRegistryEntry {
//    
//    let track: Track
//    var trackLists: TrackLists
//    
//    init(track: Track, trackLists: TrackLists) {
//        
//        self.track = track
//        self.trackLists = trackLists
//    }
//    
//    func addToTrackList(_ list: TrackLists) {
//        trackLists.formUnion(list)
//    }
//}
//
//struct TrackLists: OptionSet {
//    
//    let rawValue: Int
//    
//    static let playQueue = TrackLists(rawValue: 1 << 0)
//    static let history = TrackLists(rawValue: 1 << 1)
//    static let favorites = TrackLists(rawValue: 1 << 2)
//    static let bookmarks = TrackLists(rawValue: 1 << 3)
////    static let library = TrackLists(rawValue: 1 << 4)
//}
