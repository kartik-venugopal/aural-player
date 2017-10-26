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
            return false
        }
        
        let tracksAndGroups = collectTracksAndGroups(outlineView)
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
            if (groups.count == playlist.getNumberOfGroups(self.grouping)) {
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
            
            performReordering(outlineView, childIndexes, index, destination)
            
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
    private func calculateReorderingDestination(_ sourceIndexSet: IndexSet, _ parent: Any?, _ childIndex: Int) -> IndexSet {
        
        // Find out how many source items are above the dropRow and how many below
        let sourceIndexesAboveDropRow = sourceIndexSet.filter({$0 < childIndex})
        let sourceIndexesBelowDropRow = sourceIndexSet.filter({$0 > childIndex})
        
        // The lowest index in the destination rows
        var minDestinationRow: Int
        
        // The highest index in the destination rows
        var maxDestinationRow: Int
        
        // If the drop is being performed on the dropRow, the destination rows will further depend on whether there are more source items above or below the dropRow.
        if (sourceIndexesAboveDropRow.count > sourceIndexesBelowDropRow.count) {
            
            // There are more source items above the dropRow than below it
            
            // All source items above the dropRow will form a contiguous block ending at the dropRow
            // All source items below the dropRow will form a contiguous block starting one row below the dropRow and extending below it
            
            minDestinationRow = childIndex - sourceIndexesAboveDropRow.count
            maxDestinationRow = childIndex + sourceIndexesBelowDropRow.count - 1
            
        } else {
            
            // There are more source items below the dropRow than above it
            
            // All source items above the dropRow will form a contiguous block ending just above (one row above) the dropRow
            // All source items below the dropRow will form a contiguous block starting at the dropRow and extending below it
            
            minDestinationRow = childIndex - sourceIndexesAboveDropRow.count
            maxDestinationRow = childIndex + sourceIndexesBelowDropRow.count - 1
        }
        
        return IndexSet(minDestinationRow...maxDestinationRow)
    }
    
    private func performReordering(_ outlineView: NSOutlineView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ destination: IndexSet) {
        
        let tracksAndGroups = collectTracksAndGroups(outlineView)
        let tracks = tracksAndGroups.tracks
        
        let movingTracks = tracks.count > 0
        
        if (movingTracks) {
            
            let group = outlineView.parent(forItem: tracks[0]) as! Group
            let reorderOps = reorderTracks(sourceIndexSet, group, dropRow, destination)
            
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
            
            let reorderOps = reorderGroups(sourceIndexSet, dropRow, destination)
            
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
        playlistDelegate.reorderTracks(playlistReorderOperations, self.grouping)
        
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
            
            let group = playlist.getGroupAt(self.grouping, $0)
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
        playlistDelegate.reorderTracks(playlistReorderOperations, self.grouping)
        
        return playlistReorderOperations
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
