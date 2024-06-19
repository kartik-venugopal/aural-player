//
//  GroupedTrackList.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class GroupedSortedTrackList: SortedTrackList, GroupedSortedTrackListProtocol {
    
    let groupings: [Grouping]
    
    init(sortOrder: TrackListSort, withGroupings groupings: [Grouping]) {
        
        self.groupings = groupings
        super.init(sortOrder: sortOrder)
    }
    
    @inlinable
    @inline(__always)
    override func doAddTracks(_ newTracks: [Track]) -> IndexSet {
        
        let indices = super.doAddTracks(newTracks)
        
        groupings.forEach {
            $0.addTracks(newTracks)
        }
        
        return indices
    }
    
    override func removeTracks(at indices: IndexSet) -> [Track] {
        
        let removedTracks = super.removeTracks(at: IndexSet(indices.sortedDescending()))
        
        groupings.forEach {
            $0.removeTracks(removedTracks)
        }
        
        return removedTracks
    }
    
    override func removeTracks(_ tracksToRemove: [Track]) -> IndexSet {
        
        let indices = super.removeTracks(tracksToRemove)
        
        groupings.forEach {
            $0.removeTracks(tracksToRemove)
        }
        
        return indices
    }
    
    func remove(tracks: [GroupedTrack], andGroups groups: [Group], from grouping: Grouping) -> IndexSet {
        
        // TODO: Remove the tracks / groups from the current grouping, then remove those
        // tracks from the track list and other groupings. Finally, collate all the results.
        
        // TODO: See the old 'GroupingPlaylist' class
        
        let tracksToRemove = tracks.map {$0.track} + groups.flatMap {$0.tracks}
        let indices = super.removeTracks(tracksToRemove)
        
        grouping.remove(tracks: tracks, andGroups: groups)
        
        groupings.filter {$0 != grouping}.forEach {
            $0.removeTracks(tracksToRemove)
        }
        
        return indices
    }
    
    override func removeAllTracks() {
        
        super.removeAllTracks()
        
        groupings.forEach {
            $0.removeAllTracks()
        }
    }
    
    override func cropTracks(_ tracksToKeep: [Track]) {
        
        super.cropTracks(tracksToKeep)
        
        groupings.forEach {
            $0.cropTracks(tracksToKeep)
        }
    }
    
    func sort(grouping: Grouping, by sort: GroupedTrackListSort) {
        grouping.sortOrder = sort
    }
}
