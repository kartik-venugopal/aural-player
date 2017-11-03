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
            
            // Impossible
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
        
        let movingTracks = tracks.count > 0
        let movingGroups = groups.count > 0
        
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
            if tracks.count == group.tracks.count {
                return false
            }
            
            // Validate parent group and child index
            if (parent == nil || (!(parent is Group)) || ((parent! as! Group) !== group) || childIndex < 0) {
                return false
            }
            
        } else {
            
            // If all groups are selected, they cannot be moved
            if (groups.count == playlist.numberOfGroups(self.grouping)) {
                return false
            }
            
            // Validate parent group and child index
            if (parent != nil || childIndex < 0) {
                return false
            }
        }
        
        // Doesn't match any of the invalid cases, it's a valid operation
        return true
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
    
    // Drag n drop - accepts and performs the drop
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        if (info.draggingSource() is NSOutlineView) {
            
            if let srcRows = getSourceIndexes(info) {
            
                // Calculate the destination rows for the reorder operation, and perform the reordering
                let childIndexes = getSelectedChildIndexes(outlineView, srcRows)
                let destination = calculateReorderingDestination(childIndexes, item, index)
                
                performReordering(outlineView, srcRows: srcRows, childIndexes, index, destination)
                
                if (playbackInfo.getPlayingTrack() != nil) {
                    
                    let sequenceInfo = playbackInfo.getPlaybackSequenceInfo()
                    let sequenceChangedMsg = SequenceChangedNotification(sequenceInfo.scope, sequenceInfo.trackIndex, sequenceInfo.totalTracks)
                    
                    SyncMessenger.publishNotification(sequenceChangedMsg)
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
    
    private func getSelectedChildIndexes(_ outlineView: NSOutlineView, _ rowIndexes: IndexSet) -> IndexSet {
        
        let tracksAndGroups = collectTracksAndGroups(outlineView, rowIndexes)
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        let movingTracks = tracks.count > 0
        
        var childIndexes = [Int]()
        
        if (movingTracks) {
            
            let group = outlineView.parent(forItem: tracks[0]) as! Group
            tracks.forEach({childIndexes.append(group.indexOfTrack($0)!)})
            
        } else {
            
            groups.forEach({childIndexes.append(playlist.indexOfGroup($0))})
        }
        
        return IndexSet(childIndexes)
    }
    
    /*
     In response to a playlist reordering by drag and drop, and given source indexes, a destination index, and the drop operation (on/above), determines which indexes the source rows will occupy.
     */
    private func calculateReorderingDestination(_ sourceIndexSet: IndexSet, _ parent: Any?, _ childIndex: Int) -> IndexSet {
        
        // Find out how many source items are above the dropRow and how many below
        let sourceIndexesAboveDropRow = sourceIndexSet.filter({$0 < childIndex})
        let sourceIndexesBelowDropRow = sourceIndexSet.filter({$0 > childIndex})
        
        // All source items above the dropRow will form a contiguous block ending at the dropRow
        // All source items below the dropRow will form a contiguous block starting one row below the dropRow and extending below it
        
        // The lowest index in the destination rows
        let minDestinationRow = childIndex - sourceIndexesAboveDropRow.count
        
        // The highest index in the destination rows
        let maxDestinationRow = childIndex + sourceIndexesBelowDropRow.count - 1
        
        return IndexSet(minDestinationRow...maxDestinationRow)
    }
    
    private func performReordering(_ outlineView: NSOutlineView, srcRows: IndexSet, _ childIndexes: IndexSet, _ dropRow: Int, _ destination: IndexSet) {
        
        let tracksAndGroups = collectTracksAndGroups(outlineView, srcRows)
        let tracks = tracksAndGroups.tracks
        
        let movingTracks = !tracks.isEmpty
        
        if (movingTracks) {
            
            let group = outlineView.parent(forItem: tracks.first) as! Group
            let reorderOps = reorderTracks(childIndexes, group, dropRow, destination)
            
            var moveUpOps = [GroupedTrackInsertOperation]()
            var moveDownOps = [GroupedTrackInsertOperation]()
            
            for op in reorderOps {
                
                if let insertOp = op as? GroupedTrackInsertOperation {
                    
                    if insertOp.destIndex < dropRow {
                        moveDownOps.append(insertOp)
                    } else {
                        moveUpOps.append(insertOp)
                    }
                }
            }
            
            moveUpOps = moveUpOps.sorted(by: {o1, o2 -> Bool in return o1.destIndex < o2.destIndex})
            moveDownOps = moveDownOps.sorted(by: {o1, o2 -> Bool in return o1.destIndex > o2.destIndex})
            
            moveDownOps.forEach({outlineView.moveItem(at: $0.srcIndex, inParent: $0.group, to: $0.destIndex, inParent: $0.group)})
            moveUpOps.forEach({outlineView.moveItem(at: $0.srcIndex, inParent: $0.group, to: $0.destIndex, inParent: $0.group)})
            
        } else {
            
            // Reordering groups
            
            let reorderOps = reorderGroups(childIndexes, dropRow, destination)
            
            var moveUpOps = [GroupInsertOperation]()
            var moveDownOps = [GroupInsertOperation]()
            
            for op in reorderOps {
                
                if let insertOp = op as? GroupInsertOperation {
                    
                    if insertOp.destIndex < dropRow {
                        moveDownOps.append(insertOp)
                    } else {
                        moveUpOps.append(insertOp)
                    }
                }
            }
            
            moveUpOps = moveUpOps.sorted(by: {o1, o2 -> Bool in return o1.destIndex < o2.destIndex})
            moveDownOps = moveDownOps.sorted(by: {o1, o2 -> Bool in return o1.destIndex > o2.destIndex})
            
            moveDownOps.forEach({outlineView.moveItem(at: $0.srcIndex, inParent: nil, to: $0.destIndex, inParent: nil)})
            moveUpOps.forEach({outlineView.moveItem(at: $0.srcIndex, inParent: nil, to: $0.destIndex, inParent: nil)})
            
        }
    }
    
    private func reorderTracks(_ sourceIndexSet: IndexSet, _ parentGroup: Group, _ dropRow: Int, _ destination: IndexSet) -> [GroupingPlaylistReorderOperation] {
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var playlistReorderOperations = [GroupingPlaylistReorderOperation]()
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Track]()
        var sourceIndexMappings = [Track: Int]()
        
        // Make sure they the source indexes are iterated in descending order. This will be important in Step 4.
        sourceIndexSet.sorted(by: {x, y -> Bool in x > y}).forEach({
            
            let track = parentGroup.tracks[$0]
            sourceItems.append(track)
            sourceIndexMappings[track] = $0
            playlistReorderOperations.append(GroupedTrackRemoveOperation(group: parentGroup, index: $0))
        })
        
        // Step 4 - Copy over the source items into the destination holes
        var cursor = 0
        
        // Destination rows need to be sorted in ascending order
        let destinationRows = destination.sorted(by: {x, y -> Bool in x < y})
        
        sourceItems = sourceItems.reversed()
        
        destinationRows.forEach({
            
            // For each destination row, copy over a source item into the corresponding destination hole
            let track = sourceItems[cursor]
            let srcIndex = sourceIndexMappings[track]!
            let reorderOperation = GroupedTrackInsertOperation(group: parentGroup, srcTrack: track, srcIndex: srcIndex, destIndex: $0)
            playlistReorderOperations.append(reorderOperation)
            cursor += 1
        })
        
        // Submit the reorder operations to the playlist
        playlist.reorderTracksAndGroups(playlistReorderOperations, self.grouping)
        
        return playlistReorderOperations
    }
    
    private func reorderGroups(_ sourceIndexSet: IndexSet, _ dropRow: Int, _ destination: IndexSet) -> [GroupingPlaylistReorderOperation] {
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var playlistReorderOperations = [GroupingPlaylistReorderOperation]()
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Group]()
        var sourceIndexMappings = [Group: Int]()
        
        // Make sure they the source indexes are iterated in descending order. This will be important in Step 4.
        sourceIndexSet.sorted(by: {x, y -> Bool in x > y}).forEach({
            
            let group = playlist.groupAtIndex(self.grouping, $0)
            sourceItems.append(group)
            sourceIndexMappings[group] = $0
            playlistReorderOperations.append(GroupRemoveOperation(index: $0))
        })
        
        // Step 4 - Copy over the source items into the destination holes
        var cursor = 0
        
        // Destination rows need to be sorted in ascending order
        let destinationRows = destination.sorted(by: {x, y -> Bool in x < y})
        
        sourceItems = sourceItems.reversed()
        
        destinationRows.forEach({
            
            // For each destination row, copy over a source item into the corresponding destination hole
            let group = sourceItems[cursor]
            let srcIndex = sourceIndexMappings[group]!
            let reorderOperation = GroupInsertOperation(srcGroup: group, srcIndex: srcIndex, destIndex: $0)
            playlistReorderOperations.append(reorderOperation)
            cursor += 1
        })
        
        // Submit the reorder operations to the playlist
        playlist.reorderTracksAndGroups(playlistReorderOperations, self.grouping)
        
        return playlistReorderOperations
    }
}
