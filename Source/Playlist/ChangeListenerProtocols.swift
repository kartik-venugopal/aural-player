//
//  ChangeListenerProtocols.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Contract for an observer responding to changes in the playlist, e.g. the playback sequence needs to be recomputed when the playlist is sorted and shuffle mode is on.
 */

import Foundation

protocol PlaylistChangeListenerProtocol {
    
    // New tracks have been added
    func tracksAdded(_ addResults: [TrackAddResult])
    
    // Tracks have been removed. The playingTrackRemoved argument specifies whether the currently playing track, if one, was removed.
    func tracksRemoved(_ removeResults: TrackRemovalResults)
    
    // Tracks have been moved, in the playlist of the specified type
    func tracksReordered(_ moveResults: ItemMoveResults)
    
    // The playlist has been sorted. The sortResults parameter provides details about the sort performed.
    func playlistSorted(_ sortResults: SortResults)
    
    // The entire playlist has been cleared
    func playlistCleared()
}

// Default function implementations (to provide the convenience to implementors to implement only functions they are interested in)
extension PlaylistChangeListenerProtocol {
    
    func tracksAdded(_ addResults: [TrackAddResult]) {}
    
    func tracksRemoved(_ removeResults: TrackRemovalResults) {}
    
    func tracksReordered(_ moveResults: ItemMoveResults) {}
    
    func playlistSorted(_ sortResults: SortResults) {}
    
    func playlistCleared() {}
}
