//
//  Group.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Represents a group of tracks categorized by a certain property of the tracks - such as artist, album, or genre.
///
/// Contains an ordered collection of tracks, accessed linearly through indexes, analogous to a one-dimensional array.
///
/// Instances of this class are the top level items within a **GroupingPlaylist**.
///
/// - SeeAlso: **GroupingPlaylist**
///
class Group: Hashable, PlaylistItem {
    
    let type: GroupType
    
    // The unique name of this group (either an artist, album, or genre name)
    let name: String
    
    // The tracks within this group
    private(set) var tracks: [Track] = []
    
    // Total duration of all tracks in this group
    var duration: Double {
        tracks.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
    }
    
    init(_ type: GroupType, _ name: String) {
        
        self.type = type
        self.name = name
    }
    
    func hash(into hasher: inout Hasher) {
        
        hasher.combine(type)
        hasher.combine(name)
    }
    
    // 2 Groups are equal if they are of the same type and have the same name.
    static func == (lhs: Group, rhs: Group) -> Bool {
        return (lhs.type == rhs.type) && (lhs.name == rhs.name)
    }
    
    // Number of tracks
    var size: Int {tracks.count}
    
    func indexOfTrack(_ track: Track) -> Int? {
        return tracks.firstIndex(of: track)
    }
    
    func trackAtIndex(_ index: Int) -> Track? {
        return tracks.itemAtIndex(index)
    }
    
    // Adds a track and returns the index of the new track
    func addTrack(_ track: Track) -> Int {
        return tracks.addItem(track)
    }
    
    func removeTracks(_ removedTracks: [Track]) -> IndexSet {
        return tracks.removeItems(removedTracks)
    }
    
    func moveTracksUp(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsUp(tracksToMove)
    }
    
    // Moves tracks within this group, at the given indexes, up one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveTracksUp(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsUp(indices)
    }
    
    // Assume tracks can be moved
    func moveTracksToTop(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsToTop(indices)
    }
    
    func moveTracksToTop(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsToTop(tracksToMove)
    }
    
    func moveTracksDown(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsDown(tracksToMove)
    }
    
    // Moves tracks within this group, at the given indexes, down one index, if possible. Returns a mapping of source indexes to destination indexes.
    func moveTracksDown(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsDown(indices)
    }
    
    func moveTracksToBottom(_ tracksToMove: [Track]) -> [Int: Int] {
        return tracks.moveItemsToBottom(tracksToMove)
    }
    
    func moveTracksToBottom(_ indices: IndexSet) -> [Int: Int] {
        return tracks.moveItemsToBottom(indices)
    }
    
    func dragAndDropItems(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [Int: Int] {
        return tracks.dragAndDropItems(sourceIndices, dropIndex)
    }
    
    // Sorts all tracks in this group, using the given strategy to compare tracks
    func sort(_ strategy: (Track, Track) -> Bool) {
        tracks.sort(by: strategy)
    }
    
    ///
    /// Re-order the group (tracks), upon app startup, according to the sort order of the playlist from the last app launch.
    ///
    /// - Parameter state:  Application state persisted from the last app launch, including group sort order.
    ///                     This will determine how the group is reordered.
    ///
    func reOrder(accordingTo state: GroupPersistentState) {
        
        // Create a fast lookup map of URL -> Track, for all tracks in this group.
        var tracksMap: [URL: Track] = [:]
        self.tracks.forEach {tracksMap[$0.file] = $0}
        
        // Re-order the group by replacing the existing tracks array with an ordered collection created
        // by mapping URLs from state to their corresponding tracks (by using the lookup map).
        if let trackPaths = state.tracks, trackPaths.count == self.tracks.count {
            
            let tracks = trackPaths.map {URL(fileURLWithPath: $0)}
            self.tracks = tracks.compactMap {tracksMap[$0]}
        }
    }
}
