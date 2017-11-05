import Cocoa

class GroupingPlaylistDragDropDelegate: NSObject, NSOutlineViewDelegate {
    
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    private var grouping: GroupType = .artist
    
    func setGrouping(_ groupType: GroupType) {
        self.grouping = groupType
    }
 
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        var srcRows = [Int]()
        items.forEach({srcRows.append(outlineView.row(forItem: $0))})
        
        let data = NSKeyedArchiver.archivedData(withRootObject: IndexSet(srcRows))
        let item = NSPasteboardItem()
        item.setData(data, forType: "public.data")
        pasteboard.writeObjects([item])
        
        return true
    }
    
    // Drag n drop - Helper function to retrieve source indexes from NSDraggingInfo
    private func getSourceIndexes(_ draggingInfo: NSDraggingInfo) -> IndexSet? {
        
        let pasteboard = draggingInfo.draggingPasteboard()
        
        if let data = pasteboard.pasteboardItems?.first?.data(forType: "public.data"),
            let sourceIndexSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet
        {
            return sourceIndexSet
        }
        
        return nil
    }
    
    // Drag n drop - determines the drag/drop operation
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        // If the source is the outlineView, that means playlist tracks/groups are being reordered
        if (info.draggingSource() is NSOutlineView) {
            
            if let srcRows = getSourceIndexes(info) {
                
                if validateReorderOperation(outlineView, srcRows, item, index) {
                    return .move
                }
            }

            return invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Drag n drop - Given a destination parent and child index, determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination items)
    private func validateReorderOperation(_ outlineView: NSOutlineView, _ srcIndexes: IndexSet, _ parent: Any?, _ childIndex: Int) -> Bool {
        
        // All items selected
        if srcIndexes.count == outlineView.numberOfRows {
            return false
        }
        
        let tracksAndGroups = collectTracksAndGroups(outlineView, srcIndexes)
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        let movingTracks = !tracks.isEmpty
        let movingGroups = !movingTracks
        
        // Cannot move both groups and tracks
        if (movingTracks && movingGroups) {
            return false
        }
        
        if (movingTracks) {
            
            // Find out which group these tracks belong to, and categorize them
            var parentGroups: Set<Group> = Set<Group>()
            
            // Categorize tracks by group
            for track in tracks {
                
                let group = outlineView.parent(forItem: track) as! Group
                parentGroups.insert(group)
            }
            
            // Cannot move tracks from different groups
            if (parentGroups.count > 1) {
                return false
            }
            
            let group = parentGroups.first!
            
            // All tracks within group selected
            if tracks.count == group.size() {
                return false
            }
            
            // Validate parent group and child index
            if (parent == nil || (!(parent is Group)) || ((parent! as! Group) !== group) || childIndex < 0 || childIndex > group.size()) {
                return false
            }
            
            // Dropping on a selected track is not allowed
            if childIndex < group.size(), let parentGroup = parent as? Group {
                
                let dropTrack = parentGroup.trackAtIndex(childIndex)
                if tracks.contains(dropTrack) {
                    return false
                }
            }
            
        } else {
            
            // If all groups are selected, they cannot be moved
            if (groups.count == playlist.numberOfGroups(self.grouping)) {
                return false
            }
            
            // Validate parent group and child index
            let numGroups = playlist.numberOfGroups(self.grouping)
            if (parent != nil || childIndex < 0 || childIndex > numGroups) {
                return false
            }
            
            // Dropping on a selected group is not allowed
            if (childIndex < numGroups) {
                let dropGroup = playlist.groupAtIndex(self.grouping, childIndex)
                if (groups.contains(dropGroup)) {
                    return false
                }
            }
        }
        
        // Doesn't match any of the invalid cases, it's a valid operation
        return true
    }
    
    // Drag n drop - accepts and performs the drop
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        if (info.draggingSource() is NSOutlineView) {
            
            if let srcRows = getSourceIndexes(info) {
            
                // Collect the information needed to perform the reordering
                let tracksAndGroups = collectTracksAndGroups(outlineView, srcRows)
                let parentAsGroup: Group? = item as? Group ?? nil
                
                // Perform the reordering
                let results = playlist.dropTracksAndGroups(tracksAndGroups.tracks, tracksAndGroups.groups, self.grouping, parentAsGroup, index)
                
                // Given the results of the reordering, refresh the playlist view
                refreshView(outlineView, results)
                
                // The playback sequence may have changed and the UI may need to be updated
                if (playbackInfo.getPlayingTrack() != nil) {
                    SyncMessenger.publishNotification(SequenceChangedNotification.instance)
                }
                
                return true
            }
            
        } else {
            
            // Files added from Finder, add them to the playlist as URLs
            let objects = info.draggingPasteboard().readObjects(forClasses: [NSURL.self], options: nil)
            playlist.addFiles(objects! as! [URL])
            
            return true
        }
        
        return false
    }
    
    private func collectTracksAndGroups(_ outlineView: NSOutlineView, _ sourceIndexes: IndexSet) -> (tracks: [Track], groups: [Group]) {
        
        var tracks = [Track]()
        var groups = [Group]()
        
        sourceIndexes.forEach({
            
            let item = outlineView.item(atRow: $0)
            
            if let track = item as? Track {
                tracks.append(track)
            } else {
                // Group
                groups.append(item as! Group)
            }
        })
        
        return (tracks, groups)
    }
    
    private func refreshView(_ outlineView: NSOutlineView, _ results: ItemMoveResults) {
        
        // First, sort all the move operations, so that they do not interfere with each other (all downward moves in descending order, followed by all upward moves in ascending order)
        
        var sortedMoves = [ItemMoveResult]()
        sortedMoves.append(contentsOf: results.results.filter({$0.movedDown}).sorted(by: {r1, r2 -> Bool in r1.sortIndex > r2.sortIndex}))
        sortedMoves.append(contentsOf: results.results.filter({$0.movedUp}).sorted(by: {r1, r2 -> Bool in r1.sortIndex < r2.sortIndex}))
        
        // Then, move the relevant items within the playlist view
        sortedMoves.forEach({
            
            if let trackMoveResult = $0 as? TrackMoveResult {
                
                outlineView.moveItem(at: trackMoveResult.oldTrackIndex, inParent: trackMoveResult.parentGroup!, to: trackMoveResult.newTrackIndex, inParent: trackMoveResult.parentGroup!)
            } else {
                
                let groupMoveResult = $0 as! GroupMoveResult
                
                outlineView.moveItem(at: groupMoveResult.oldGroupIndex, inParent: nil, to: groupMoveResult.newGroupIndex, inParent: nil)
            }
        })
    }
}
