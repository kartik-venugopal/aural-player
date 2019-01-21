import Cocoa

/*
    Data source base class for the NSOutlineView instances that display the "Artists", "Albums", and "Genres" (hierarchical/grouping) playlist views.
 */
class GroupingPlaylistDataSource: NSObject, NSOutlineViewDataSource {
    
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that relays CRUD operations to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Used to determine if a track is currently playing
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Indicates the type of groups displayed by this NSOutlineView (intended to be overridden by subclasses)
    fileprivate var playlistType: PlaylistType
    fileprivate var groupType: GroupType
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    init(_ playlistType: PlaylistType, _ groupType: GroupType) {
        self.playlistType = playlistType
        self.groupType = groupType
    }
    
    // Returns the number of children for a given item
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if (item == nil) {
            
            // Root
            return playlist.numberOfGroups(groupType)
            
        } else if let group = item as? Group {
            
            // Group
            return group.size()
            
        } else if let track = item as? Track {
            
            return track.chapters.count
        }
        
        // Track chapters don't have children
        return 0
    }
    
    // Returns the child, at a given index, for a given item
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if (item == nil) {
            
            // Child of the root is a group
            return playlist.groupAtIndex(groupType, index)
            
        } else if let group = item as? Group {
            
            // Child of a group is a track
            return group.trackAtIndex(index)
        
        } else if let track = item as? Track {
            
            return track.chapters[index]
        }
        
        // Impossible
        return ""
    }
    
    // Determines if a given item is expandable
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        // Only groups and tracks with defined chapters are expandable
        return item is Group || (item is Track && (item as! Track).chapters.count > 0)
    }
    
    // MARK: Drag n Drop
    
    // Writes source information to the pasteboard
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        
        if playlist.isBeingModified {
            return false
        }
        
        var srcRows = [Int]()
        items.forEach({srcRows.append(outlineView.row(forItem: $0))})
        
        let data = NSKeyedArchiver.archivedData(withRootObject: IndexSet(srcRows))
        let item = NSPasteboardItem()
        item.setData(data, forType: convertToNSPasteboardPasteboardType("public.data"))
        pasteboard.writeObjects([item])
        
        return true
    }
    
    // Helper function to retrieve source indexes from the NSDraggingInfo pasteboard
    private func getSourceIndexes(_ draggingInfo: NSDraggingInfo) -> IndexSet? {
        
        let pasteboard = draggingInfo.draggingPasteboard
        
        if let data = pasteboard.pasteboardItems?.first?.data(forType: convertToNSPasteboardPasteboardType("public.data")),
            let sourceIndexSet = NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet
        {
            return sourceIndexSet
        }
        
        return nil
    }
    
    // Validates the drag/drop operation
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        if playlist.isBeingModified {
            return invalidDragOperation
        }
        
        // If the source is the outlineView, that means playlist tracks/groups are being reordered
        if (info.draggingSource is NSOutlineView) {
            
            if let sourceIndexSet = getSourceIndexes(info) {
                
                if validateReorderOperation(outlineView, sourceIndexSet, item, index) {
                    return .move
                }
            }
            
            return invalidDragOperation
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
            
            // Cannot move tracks from different groups (all tracks being moved must belong to the same group)
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
            if (groups.count == playlist.numberOfGroups(self.groupType)) {
                return false
            }
            
            // Validate parent group and child index
            let numGroups = playlist.numberOfGroups(self.groupType)
            if (parent != nil || childIndex < 0 || childIndex > numGroups) {
                return false
            }
            
            // Dropping on a selected group is not allowed
            if (childIndex < numGroups) {
                
                let dropGroup = playlist.groupAtIndex(self.groupType, childIndex)
                if (groups.contains(dropGroup)) {
                    return false
                }
            }
        }
        
        // Doesn't match any of the invalid cases, it's a valid operation
        return true
    }
    
    // Performs the drop
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        if playlist.isBeingModified {
            return false
        }
        
        if (info.draggingSource is NSOutlineView) {
            
            if let sourceIndexSet = getSourceIndexes(info) {
                
                // Collect the information needed to perform the reordering
                let tracksAndGroups = collectTracksAndGroups(outlineView, sourceIndexSet)
                let parentAsGroup: Group? = item as? Group ?? nil
                
                // Perform the reordering
                let results = playlist.dropTracksAndGroups(tracksAndGroups.tracks, tracksAndGroups.groups, self.groupType, parentAsGroup, index)
                
                // Given the results of the reordering, refresh the playlist view
                refreshView(outlineView, results)
                
                // The playback sequence may have changed and the UI may need to be updated
                if (playbackInfo.playingTrack != nil) {
                    SyncMessenger.publishNotification(SequenceChangedNotification.instance)
                }
                
                return true
            }
        } else {
            
            // Files added from Finder, add them to the playlist as URLs
            let objects = info.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil)
            playlist.addFiles(objects! as! [URL])
            
            return true
        }
        
        return false
    }
    
    // Helper function that gathers all selected playlist items as tracks and groups
    private func collectTracksAndGroups(_ outlineView: NSOutlineView, _ sourceIndexes: IndexSet) -> (tracks: [Track], groups: [Group]) {
        
        var tracks = [Track]()
        var groups = [Group]()
        
        sourceIndexes.forEach({
            
            let item = outlineView.item(atRow: $0)
            
            if let track = item as? Track {
                
                // Track
                tracks.append(track)
                
            } else {
                
                // Group
                groups.append(item as! Group)
            }
        })
        
        return (tracks, groups)
    }
    
    // Given the results of a reorder operation, rearranges playlist view items to reflect the new playlist order
    private func refreshView(_ outlineView: NSOutlineView, _ results: ItemMoveResults) {
        
        // First, sort all the move operations, so that they do not interfere with each other (all downward moves in descending order, followed by all upward moves in ascending order)
        
        var sortedMoves = [ItemMoveResult]()
        sortedMoves.append(contentsOf: results.results.filter({$0.movedDown}).sorted(by: {r1, r2 -> Bool in r1.sortIndex > r2.sortIndex}))
        sortedMoves.append(contentsOf: results.results.filter({$0.movedUp}).sorted(by: {r1, r2 -> Bool in r1.sortIndex < r2.sortIndex}))
        
        // Then, move the relevant items within the playlist view
        sortedMoves.forEach({
            
            if let trackMoveResult = $0 as? TrackMoveResult {
                
                // Move track from the old source index within its parent group to its new destination index
                outlineView.moveItem(at: trackMoveResult.oldTrackIndex, inParent: trackMoveResult.parentGroup!, to: trackMoveResult.newTrackIndex, inParent: trackMoveResult.parentGroup!)
            } else {
                
                let groupMoveResult = $0 as! GroupMoveResult
                
                // Move group from the old source index within its parent (root) to its new destination index
                outlineView.moveItem(at: groupMoveResult.oldGroupIndex, inParent: nil, to: groupMoveResult.newGroupIndex, inParent: nil)
            }
        })
    }
}

/*
    Data source and view delegate subclass for the "Artists" (hierarchical/grouping) playlist view
 */
class ArtistsPlaylistDataSource: GroupingPlaylistDataSource {
    
    @objc init() {
        super.init(.artists, .artist)
    }
}

/*
    Data source and view delegate subclass for the "Albums" (hierarchical/grouping) playlist view
 */
class AlbumsPlaylistDataSource: GroupingPlaylistDataSource {
    
    @objc init() {
        super.init(.albums, .album)
    }
}

/*
    Data source and view delegate subclass for the "Genres" (hierarchical/grouping) playlist view
 */
class GenresPlaylistDataSource: GroupingPlaylistDataSource {
    
    @objc init() {
        super.init(.genres, .genre)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardType(_ input: String) -> NSPasteboard.PasteboardType {
	return NSPasteboard.PasteboardType(rawValue: input)
}
