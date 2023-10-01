//
//  FlatPlaylistProtocol.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Set of protocols for CRUD operations performed on the flat playlist
 */
import Foundation

///
/// A functional contract for the flat (non-hierarchical) playlist, i.e. the *Tracks* playlist.
///
protocol FlatPlaylistProtocol: CommonPlaylistMutatorProtocol {
    
    // MARK: Read operations ----------------------------------------
    
    // Returns the size (i.e. total number of tracks) of the playlist
    var size: Int {get}
    
    // Returns the total duration of the playlist tracks
    var duration: Double {get}
    
    // Retrieves all tracks
    var tracks: [Track] {get}
    
    // Returns the track at a given index. Returns nil if an invalid index is specified.
    func trackAtIndex(_ index: Int) -> Track?
    
    // Determines the index of a given track, within the playlist. Returns nil if the track doesn't exist within the playlist.
    func indexOfTrack(_ track: Track) -> Int?
    
    // Searches the playlist, given certain query parameters, and returns all matching results.
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    // Returns the display name for a track within the playlist.
    func displayNameForTrack(_ track: Track) -> String
    
    // MARK: Mutation operations ----------------------------------------
    
    // Adds a single track to the playlist, and returns its index within the playlist.
    func addTrack(_ track: Track) -> Int
    
    // Removes track(s) with the given indexes. Returns the specific tracks that were removed.
    func removeTracks(_ indexes: IndexSet) -> [Track]
    
    // Removes the specific tracks from the playlist. Returns the indexes of the removed tracks.
    func removeTracks(_ tracks: [Track]) -> IndexSet
    
    /*
        Moves the tracks at the specified indexes, up one index, in the playlist, if they can be moved (they are not already at the top). 
     
        Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksUp(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksToTop(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Moves the tracks at the specified indexes, down one index, in the playlist, if they can be moved (they are not already at the bottom).
     
        Returns a mapping of the old indexes to the new indexes, for each of the tracks (for tracks that didn't move, the mapping will have the same key and value).
     
        NOTE - Even if some tracks cannot move, those that can will be moved. i.e. This is not an all or nothing operation.
     */
    func moveTracksDown(_ indexes: IndexSet) -> ItemMoveResults
    
    func moveTracksToBottom(_ indexes: IndexSet) -> ItemMoveResults
    
    /*
        Performs a drag and drop reordering operation on the playlist, from a set of source indexes to a destination drop index (above the drop index). 
     
        Returns the set of new destination indexes for the reordered tracks.
     */
    func dropTracks(_ sourceIndexes: IndexSet, _ dropIndex: Int) -> ItemMoveResults
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}
