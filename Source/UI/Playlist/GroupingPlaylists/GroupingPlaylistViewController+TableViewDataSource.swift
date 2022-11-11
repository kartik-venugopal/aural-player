//
//  GroupingPlaylistViewController+TableViewDataSource.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Data source base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
extension GroupingPlaylistViewController: NSOutlineViewDataSource {
    
    // Signifies an invalid drag/drop operation
    private static let invalidDragOperation: NSDragOperation = []
    
    // Returns the number of children for a given item
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            
            // Root
            return playlist.numberOfGroups(groupType)
            
        } else if let group = item as? Group {
            
            // Group
            return group.size
        }
        
        // Tracks don't have children
        return 0
    }
    
    // Returns the child, at a given index, for a given item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            // Child of the root is a group
            return playlist.groupAtIndex(groupType, index) ?? ""
            
        } else if let group = item as? Group {
            
            // Child of a group is a track
            return group.trackAtIndex(index) ?? ""
        }
        
        // Impossible
        return ""
    }
    
    // Determines if a given item is expandable (only groups are expandable)
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is Group
    }
    
    // MARK: Drag n Drop
    
    // Writes source information to the pasteboard
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        if playlist.isBeingModified {return false}
        
        let srcRows = items.map {outlineView.row(forItem: $0)}
        pasteboard.sourceIndexes = IndexSet(srcRows)
        
        return true
    }
    
    // Validates the drag/drop operation
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        if playlist.isBeingModified {return Self.invalidDragOperation}
        
        // If the source is the outlineView, that means playlist tracks/groups are being reordered
        if info.draggingSource is NSOutlineView {
            
            if let sourceIndexSet = info.draggingPasteboard.sourceIndexes,
               validateReorderOperation(outlineView, sourceIndexSet, item, index) {
                
                return .move
            }
            
            return Self.invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Given a destination parent and child index, determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination items)
    private func validateReorderOperation(_ outlineView: NSOutlineView, _ srcIndexes: IndexSet, _ parent: Any?, _ childIndex: Int) -> Bool {
        
        // All items selected
        if srcIndexes.count == outlineView.numberOfRows {
            return false
        }
        
        // Determine which tracks/groups are being reordered
        let tracksAndGroups = collectTracksAndGroups(outlineView, srcIndexes)
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        let movingTracks = tracks.isNonEmpty
        let movingGroups = groups.isNonEmpty
        
        // Cannot move both groups and tracks
        if movingTracks && movingGroups {
            return false
        }
        
        if movingTracks {
            
            // Find out which group these tracks belong to, and categorize them
            let parentGroups: Set<Group> = Set<Group>(tracks.compactMap {outlineView.parent(forItem: $0) as? Group})
            
            // Cannot move tracks from different groups (all tracks being moved must belong to the same group)
            guard parentGroups.count == 1, let group = parentGroups.first else {return false}
            
            // All tracks within group selected
            if tracks.count == group.size {
                return false
            }
            
            // Validate parent group and child index
            if (parent as? Group?) != group || childIndex < 0 || childIndex > group.size {
                return false
            }
            
            // Dropping on a selected track is not allowed
            if childIndex < group.size, let parentGroup = parent as? Group,
               let childTrack = parentGroup.trackAtIndex(childIndex), tracks.contains(childTrack) {
                
                return false
            }
            
        } else {    // Moving groups
            
            let numGroups = playlist.numberOfGroups(self.groupType)
            
            // If all groups are selected, they cannot be moved
            if groups.count == numGroups {
                return false
            }
            
            // Validate parent group and child index
            if parent != nil || childIndex < 0 || childIndex > numGroups {
                return false
            }
            
            // Dropping on a selected group is not allowed
            if childIndex < numGroups, let destinationGroup = playlist.groupAtIndex(self.groupType, childIndex), groups.contains(destinationGroup) {
                return false
            }
        }
        
        // Doesn't match any of the invalid cases, it's a valid operation
        return true
    }
    
    // Performs the drop
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        if playlist.isBeingModified {return false}
        
        if info.draggingSource is NSOutlineView {
            
            if let sourceIndexSet = info.draggingPasteboard.sourceIndexes {
                
                // Collect the information needed to perform the reordering
                let tracksAndGroups = collectTracksAndGroups(outlineView, sourceIndexSet)
                
                // Perform the reordering
                let results = playlist.dropTracksAndGroups(tracksAndGroups.tracks, tracksAndGroups.groups, self.groupType, item as? Group, index)
                
                // Given the results of the reordering, refresh the playlist view
                refreshView(outlineView, results)
                
                return true
            }
            
        } else if let files = info.urls {
            
            // Files added from Finder, add them to the playlist as URLs
            playlist.addFiles(files)
            return true
        }
        
        return false
    }
    
    // Helper function that gathers all selected (dragged) playlist items as tracks and groups
    private func collectTracksAndGroups(_ outlineView: NSOutlineView, _ sourceIndexes: IndexSet) -> (tracks: [Track], groups: [Group]) {
        
        let tracks = sourceIndexes.compactMap {outlineView.item(atRow: $0) as? Track}
        let groups = sourceIndexes.compactMap {outlineView.item(atRow: $0) as? Group}
        
        return (tracks, groups)
    }
    
    // Given the results of a reorder operation, rearranges playlist view items to reflect the new playlist order
    private func refreshView(_ outlineView: NSOutlineView, _ results: ItemMoveResults) {
        
        // First, sort all the move operations, so that they do not interfere with each other (all downward moves in descending order, followed by all upward moves in ascending order)
        let sortedMoves = results.results.filter({$0.movedDown}).sorted(by: ItemMoveResult.compareDescending) +
            results.results.filter({$0.movedUp}).sorted(by: ItemMoveResult.compareAscending)
        
        // Then, move the relevant items within the playlist view
        for move in sortedMoves {
            
            if let trackMoveResult = move as? TrackMoveResult, let parentGroup = trackMoveResult.parentGroup {
                
                // Move track from the old source index within its parent group to its new destination index
                outlineView.moveItem(at: trackMoveResult.sourceIndex, inParent: parentGroup, to: trackMoveResult.destinationIndex, inParent: parentGroup)
                
            } else if let groupMoveResult = move as? GroupMoveResult {
                
                // Move group from the old source index within its parent (root) to its new destination index
                outlineView.moveItem(at: groupMoveResult.sourceIndex, inParent: nil, to: groupMoveResult.destinationIndex, inParent: nil)
            }
        }
    }
}
