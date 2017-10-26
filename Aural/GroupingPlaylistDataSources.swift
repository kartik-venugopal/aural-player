import Cocoa

class GroupingPlaylistDataSource: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    // TODO: This will be non-nil and provided by ObjectGraph
    // TODO: Use delegate, not accessor directly
    internal var playlist: PlaylistAccessorProtocol = ObjectGraph.getPlaylistAccessor()
    
    internal var playlistDelegate: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    internal var grouping: GroupType {return .artist}
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return item is Group ? 26 : 22
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if (item == nil) {
            return playlist.getNumberOfGroups(grouping)
        } else if let group = item as? Group {
            return group.tracks.count
        }
        
        // Tracks don't have children
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if (item == nil) {
            return playlist.getGroupAt(grouping, index)
        } else if let group = item as? Group {
            return group.tracks[index]
        }
        
        return "Muthusami"
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        if item is Group {
            return true
        }
        
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if (tableColumn?.identifier == "cv_groupName") {
            
            if let group = item as? Group {
                
                let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
                
                view!.textField?.stringValue = String(format: "%@ (%d)", group.name, group.size())
                view!.isName = true
                view!.imageView?.image = UIConstants.imgGroup
                
                return view
                
            } else if let track = item as? Track {
                
                let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
                
                view!.textField?.stringValue = playlist.displayNameFor(grouping, track)
                view!.isName = false
                view!.imageView?.image = track.displayInfo.art
                
                return view
            }
            
        } else if (tableColumn?.identifier == "cv_duration") {
            
            let view: GroupedTrackCellView? = outlineView.make(withIdentifier: (tableColumn?.identifier)!, owner: self) as? GroupedTrackCellView
            
            if let group = item as? Group {
                
                view!.textField?.stringValue = StringUtils.formatSecondsToHMS(group.duration)
                view?.isName = true
                view!.textField?.setFrameOrigin(NSPoint(x: 0, y: -12))
                
            } else if let track = item as? Track {
                
                view!.textField?.stringValue = StringUtils.formatSecondsToHMS(track.duration)
                view?.isName = false
            }
            
            return view
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        let selRows = outlineView.selectedRowIndexes
        print("SourceItems:", selRows.toArray())
        
        let data = NSKeyedArchiver.archivedData(withRootObject: selRows)
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
        
        print("Dest item:", item, "childIndex:", index)
    
        // If the source is the outlineView, that means playlist tracks/groups are being reordered
        if (info.draggingSource() is NSOutlineView) {
            
            if validateReorderOperation(outlineView, item, index) {
                return .move
            }
            
            // Impossible
            return invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Drag n drop - Given a destination parent and child index, determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination items)
    private func validateReorderOperation(_ outlineView: NSOutlineView, _ parent: Any?, _ childIndex: Int) -> Bool {
        
        // All items selected
        if outlineView.selectedRowIndexes.count == outlineView.numberOfRows {
            print("\nAll items selected")
            return false
        }
        
        let tracksAndGroups = collectTracksAndGroups(outlineView)
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        let movingTracks = tracks.count > 0
        let movingGroups = groups.count > 0
        
        // Cannot move both groups and tracks
        if (movingTracks && movingGroups) {
            print("\nCannot move both groups and tracks")
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
                print("\nCannot move tracks from different groups")
                return false
            }
            
            let group = parentGroups.first!
            
            // All tracks within group selected
            if tracks.count == group.tracks.count {
                print("\nAll tracks within group selected")
                return false
            }
            
            // Validate parent group and child index
            if (parent == nil || (!(parent is Group)) || ((parent! as! Group) !== group) || childIndex < 0) {
                print("\nInvalid parent or childIndex")
                return false
            }
            
        } else {
         
            // If all groups are selected, they cannot be moved
            if (groups.count == playlist.getNumberOfGroups(self.grouping)) {
                print("\nAll groups selected")
                return false
            }
            
            // Validate parent group and child index
            if (parent != nil || childIndex < 0) {
                print("\nInvalid parent group or childIndex")
                return false
            }
        }
        
        // Doesn't match any of the invalid cases, it's a valid operation
        print("\nValid drop !")
        return true
    }
    
    private func collectTracksAndGroups(_ outlineView: NSOutlineView) -> (tracks: [Track], groups: [Group]) {
        
        let indexes = outlineView.selectedRowIndexes
        var tracks = [Track]()
        var groups = [Group]()
        
        indexes.forEach({
            
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
            
            // Calculate the destination rows for the reorder operation, and perform the reordering
            let childIndexes = getSelectedChildIndexes(outlineView)
            let destination = calculateReorderingDestination(childIndexes, item, index)
            
            print("Dest rows:", destination.rows.toArray(), "partPt:", destination.partitionPoint, "above:", destination.sourceIndexesAboveDropRow, "below", destination.sourceIndexesBelowDropRow)
            
            performReordering(outlineView, childIndexes, index, destination)

            // Refresh the playlist view (only the relevant rows), and re-select the source rows that were reordered
            
            
            return true
            
            
        } else {
            
            // Files added from Finder, add them to the playlist as URLs
            let objects = info.draggingPasteboard().readObjects(forClasses: [NSURL.self], options: nil)
            playlistDelegate.addFiles(objects! as! [URL])
            
            return true
        }
    }
    
    private func getSelectedChildIndexes(_ outlineView: NSOutlineView) -> IndexSet {
        
        let tracksAndGroups = collectTracksAndGroups(outlineView)
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        let movingTracks = tracks.count > 0
        
        var childIndexes = [Int]()
        
        if (movingTracks) {
            
            let group = outlineView.parent(forItem: tracks[0]) as! Group
            tracks.forEach({childIndexes.append(group.indexOf($0))})
            
        } else {
            
            groups.forEach({childIndexes.append(playlist.getIndexOf($0))})
        }
        
        return IndexSet(childIndexes)
    }
    
    /*
     In response to a playlist reordering by drag and drop, and given source indexes, a destination index, and the drop operation (on/above), determines which indexes the source rows will occupy, and a "partitionPoint", which is the dividing line between reordered items that were above (index less than) the dropRow and items that were below (index greater than) the dropRow ... it is the last (highest index) destination row for items that were above the dropRow.
     
     In addition the calculation returns the indexes above/below the dropRow, for use when performing the reordering.
     
     For example, if the source rows are [2,3,7], the dropRow is 5, and the destination rows are [4,5,6], the reordering will be as follows:
     
     Source items above the dropRow:
     source at 2 -> destination at 4
     source at 3 -> destination at 5 (partitionPoint)
     
     Source items below the dropRow:
     source at 7 -> destination at 6
     
     Then, the partitionPoint will be 5 (it is the last (highest index) destination row for source items that were above the dropRow).
     
     */
    private func calculateReorderingDestination(_ sourceIndexSet: IndexSet, _ parent: Any?, _ childIndex: Int) -> (rows: IndexSet, partitionPoint: Int, sourceIndexesAboveDropRow: [Int], sourceIndexesBelowDropRow: [Int]) {
        
        // Find out how many source items are above the dropRow and how many below
        let sourceIndexesAboveDropRow = sourceIndexSet.filter({$0 < childIndex})
        let sourceIndexesBelowDropRow = sourceIndexSet.filter({$0 > childIndex})
        
        // The lowest index in the destination rows
        var minDestinationRow: Int
        
        // The highest index in the destination rows
        var maxDestinationRow: Int
        
        // Partition point for source items (explained in function comments above)
        var partitionPoint: Int = 0
        
        // If the drop is being performed on the dropRow, the destination rows will further depend on whether there are more source items above or below the dropRow.
        if (sourceIndexesAboveDropRow.count > sourceIndexesBelowDropRow.count) {
            
            // There are more source items above the dropRow than below it
            
            // All source items above the dropRow will form a contiguous block ending at the dropRow
            // All source items below the dropRow will form a contiguous block starting one row below the dropRow and extending below it
            
            minDestinationRow = childIndex - sourceIndexesAboveDropRow.count + 1
            maxDestinationRow = childIndex + sourceIndexesBelowDropRow.count
            
            partitionPoint = childIndex
            
        } else {
            
            // There are more source items below the dropRow than above it
            
            // All source items above the dropRow will form a contiguous block ending just above (one row above) the dropRow
            // All source items below the dropRow will form a contiguous block starting at the dropRow and extending below it
            
            minDestinationRow = childIndex - sourceIndexesAboveDropRow.count
            maxDestinationRow = childIndex + sourceIndexesBelowDropRow.count - 1
            
            partitionPoint = childIndex - 1
        }
        
        
        return (IndexSet(minDestinationRow...maxDestinationRow), partitionPoint, sourceIndexesAboveDropRow, sourceIndexesBelowDropRow)
    }
    
    private func performReordering(_ outlineView: NSOutlineView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ destination: (rows: IndexSet, partitionPoint: Int, sourceIndexesAboveDropRow: [Int], sourceIndexesBelowDropRow: [Int])) {
        
        let tracksAndGroups = collectTracksAndGroups(outlineView)
        let tracks = tracksAndGroups.tracks
        
        let movingTracks = tracks.count > 0
        
        if (movingTracks) {
            
            let group = outlineView.parent(forItem: tracks[0]) as! Group
            reorderTracks(sourceIndexSet, group, dropRow, destination)
            
            let src = sourceIndexSet.toArray()
            let dest = destination.rows.toArray()
            
            var cur = 0
            while (cur < src.count) {
                outlineView.moveItem(at: src[cur], inParent: group, to: dest[cur], inParent: group)
                cur += 1
            }
            
        } else {
            
            reorderGroups(sourceIndexSet, dropRow, destination)
            
            let src = sourceIndexSet.toArray()
            let dest = destination.rows.toArray()
            
            var cur = 0
            while (cur < src.count) {
                outlineView.moveItem(at: src[cur], inParent: nil, to: dest[cur], inParent: nil)
                cur += 1
            }
        }
    }
    
    private func reorderTracks(_ sourceIndexSet: IndexSet, _ parentGroup: Group, _ dropRow: Int, _ destination: (rows: IndexSet, partitionPoint: Int, sourceIndexesAboveDropRow: [Int], sourceIndexesBelowDropRow: [Int])) {
        
        // TODO: Simplify this algorithm. Remove source items and insert at destination indexes
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Track]()
        
        // Make sure they the source indexes are iterated in ascending order. This will be important in Step 4.
        sourceIndexSet.sorted(by: {x, y -> Bool in x < y}).forEach({sourceItems.append(parentGroup.tracks[$0])})
        
        let sourceIndexesAboveDropRow = destination.sourceIndexesAboveDropRow
        
        // Source rows below the drop row need to be sorted in descending order for iteration during percolation
        let sourceIndexesBelowDropRow = destination.sourceIndexesBelowDropRow.sorted(by: {x, y -> Bool in x > y})
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var playlistReorderOperations = [GroupingPlaylistReorderOperation]()
        
        // Step 2 - Percolate up (above dropRow). As items move up, holes move down.
        if (sourceIndexesAboveDropRow.count > 0) {
            
            // Cursor that keeps track of the current index being processed. Initial value will be one row below the first source index in sourceIndexesAboveDropRow.
            var cursor = sourceIndexesAboveDropRow[0] + 1
            
            // Keeps track of how many "holes" (i.e. empty playlist rows) have been encountered thus far. Starting below the first source index in sourceIndexesAboveDropRow, we already have one "hole".
            var holes = 1
            
            // Iterate down through the rows, till the partitionPoint
            while (cursor <= destination.partitionPoint) {
                
                // If this is a source row, mark it as a hole
                if (sourceIndexesAboveDropRow.contains(cursor)) {
                    holes += 1
                    
                } else {
                    
                    // Percolate the non-source item up into the farthest hole, swapping the hole with this item
                    
                    let reorderOperation = TrackCopyOperation(group: parentGroup, srcIndex: cursor, destIndex: cursor - holes)
                    playlistReorderOperations.append(reorderOperation)
                }
                
                cursor += 1
            }
        }
        
        // Step 3 - Percolate down (below dropRow). As items move down, holes move up.
        if (sourceIndexesBelowDropRow.count > 0) {
            
            // Cursor that keeps track of the current index being processed. Initial value will be one row above the first source index in sourceIndexesBelowDropRow.
            var cursor = sourceIndexesBelowDropRow[0] - 1
            
            // Keeps track of how many "holes" (i.e. empty playlist rows) have been encountered thus far. Starting above the first source index in sourceIndexesBelowDropRow, we already have one "hole".
            var holes = 1
            
            // Iterate up through the rows, till the partitionPoint
            while (cursor > destination.partitionPoint) {
                
                // If this is a source row, mark it as a hole
                if (sourceIndexesBelowDropRow.contains(cursor)) {
                    holes += 1
                    
                } else {
                    
                    // Percolate the non-source item down into the farthest hole, swapping the hole with this item
                    
                    let reorderOperation = TrackCopyOperation(group: parentGroup, srcIndex: cursor, destIndex: cursor + holes)
                    playlistReorderOperations.append(reorderOperation)
                }
                
                cursor -= 1
            }
        }
        
        // Step 4 - Copy over the source items into the destination holes
        var cursor = 0
        
        // Destination rows need to be sorted in ascending order
        let destinationRows = destination.rows.sorted(by: {x, y -> Bool in x < y})
        
        destinationRows.forEach({
            
            // For each destination row, copy over a source item into the corresponding destination hole
            let reorderOperation = TrackOverwriteOperation(group: parentGroup, srcTrack: sourceItems[cursor], destIndex: $0)
            playlistReorderOperations.append(reorderOperation)
            cursor += 1
        })
        
        // Submit the reorder operations to the playlist
        playlistDelegate.reorderTracks(playlistReorderOperations, self.grouping)
    }
    
    private func reorderGroups(_ sourceIndexSet: IndexSet, _ dropRow: Int, _ destination: (rows: IndexSet, partitionPoint: Int, sourceIndexesAboveDropRow: [Int], sourceIndexesBelowDropRow: [Int])) {
        
        // TODO: Simplify this algorithm. Remove source items and insert at destination indexes
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Group]()
        
        // Make sure they the source indexes are iterated in ascending order. This will be important in Step 4.
        sourceIndexSet.sorted(by: {x, y -> Bool in x < y}).forEach({sourceItems.append(playlist.getGroupAt(self.grouping, $0))})
        
        let sourceIndexesAboveDropRow = destination.sourceIndexesAboveDropRow
        
        // Source rows below the drop row need to be sorted in descending order for iteration during percolation
        let sourceIndexesBelowDropRow = destination.sourceIndexesBelowDropRow.sorted(by: {x, y -> Bool in x > y})
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var playlistReorderOperations = [GroupingPlaylistReorderOperation]()
        
        // Step 2 - Percolate up (above dropRow). As items move up, holes move down.
        if (sourceIndexesAboveDropRow.count > 0) {
            
            // Cursor that keeps track of the current index being processed. Initial value will be one row below the first source index in sourceIndexesAboveDropRow.
            var cursor = sourceIndexesAboveDropRow[0] + 1
            
            // Keeps track of how many "holes" (i.e. empty playlist rows) have been encountered thus far. Starting below the first source index in sourceIndexesAboveDropRow, we already have one "hole".
            var holes = 1
            
            // Iterate down through the rows, till the partitionPoint
            while (cursor <= destination.partitionPoint) {
                
                // If this is a source row, mark it as a hole
                if (sourceIndexesAboveDropRow.contains(cursor)) {
                    holes += 1
                    
                } else {
                    
                    // Percolate the non-source item up into the farthest hole, swapping the hole with this item
                    
                    let reorderOperation = GroupCopyOperation(srcIndex: cursor, destIndex: cursor - holes)
                    playlistReorderOperations.append(reorderOperation)
                }
                
                cursor += 1
            }
        }
        
        // Step 3 - Percolate down (below dropRow). As items move down, holes move up.
        if (sourceIndexesBelowDropRow.count > 0) {
            
            // Cursor that keeps track of the current index being processed. Initial value will be one row above the first source index in sourceIndexesBelowDropRow.
            var cursor = sourceIndexesBelowDropRow[0] - 1
            
            // Keeps track of how many "holes" (i.e. empty playlist rows) have been encountered thus far. Starting above the first source index in sourceIndexesBelowDropRow, we already have one "hole".
            var holes = 1
            
            // Iterate up through the rows, till the partitionPoint
            while (cursor > destination.partitionPoint) {
                
                // If this is a source row, mark it as a hole
                if (sourceIndexesBelowDropRow.contains(cursor)) {
                    holes += 1
                    
                } else {
                    
                    // Percolate the non-source item down into the farthest hole, swapping the hole with this item
                    
                    let reorderOperation = GroupCopyOperation(srcIndex: cursor, destIndex: cursor + holes)
                    playlistReorderOperations.append(reorderOperation)
                }
                
                cursor -= 1
            }
        }
        
        // Step 4 - Copy over the source items into the destination holes
        var cursor = 0
        
        // Destination rows need to be sorted in ascending order
        let destinationRows = destination.rows.sorted(by: {x, y -> Bool in x < y})
        
        destinationRows.forEach({
            
            // For each destination row, copy over a source item into the corresponding destination hole
            let reorderOperation = GroupOverwriteOperation(srcGroup: sourceItems[cursor], destIndex: $0)
            playlistReorderOperations.append(reorderOperation)
            cursor += 1
        })
        
        // Submit the reorder operations to the playlist
        playlistDelegate.reorderTracks(playlistReorderOperations, self.grouping)
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class GroupedTrackCellView: NSTableCellView {
    
    var isName: Bool = false
    
    // When the background changes (as a result of selection/deselection) switch appropriate colours
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            if let field = self.textField {
                
                if (backgroundStyle == NSBackgroundStyle.dark) {
                    
                    // Selected
                    
                    if (isName) {
                        
                        field.textColor = Colors.playlistGroupNameSelectedTextColor
                        field.font = UIConstants.playlistGroupNameSelectedTextFont
                        
                    } else {
                        
                        field.textColor = Colors.playlistGroupItemSelectedTextColor
                        field.font = UIConstants.playlistGroupItemSelectedTextFont
                    }
                    
                } else {
                    
                    // Not selected
                    
                    if (isName) {
                        
                        field.textColor = Colors.playlistGroupNameTextColor
                        field.font = UIConstants.playlistGroupNameTextFont
                        
                    } else {
                        
                        field.textColor = Colors.playlistGroupItemTextColor
                        field.font = UIConstants.playlistGroupItemTextFont
                    }
                }
            }
        }
    }
}

class ArtistsPlaylistDataSource: GroupingPlaylistDataSource {
    
    override var grouping: GroupType {return .artist}
}

class AlbumsPlaylistDataSource: GroupingPlaylistDataSource {
    
    override var grouping: GroupType {return .album}
}

class GenresPlaylistDataSource: GroupingPlaylistDataSource {
    
    override var grouping: GroupType {return .genre}
}
