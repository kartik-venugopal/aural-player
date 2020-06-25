import Cocoa

/*
    Data source for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class TracksPlaylistViewDataSource: NSObject, NSTableViewDataSource {
    
    private static let pasteboardType: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: "public.data")
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Used to determine if a track is currently playing
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlist.size
    }
    
    // MARK: Drag n drop
    
    // Writes source information to the pasteboard
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        
        if playlist.isBeingModified {return false}
        
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        let item = NSPasteboardItem()
        item.setData(data, forType: TracksPlaylistViewDataSource.pasteboardType)
        pboard.writeObjects([item])
        
        return true
    }
    
    // Helper function to retrieve source indexes from the NSDraggingInfo pasteboard
    private func getSourceIndexes(_ draggingInfo: NSDraggingInfo) -> IndexSet? {
        
        let pasteboard = draggingInfo.draggingPasteboard
        
        if let data = pasteboard.pasteboardItems?.first?.data(forType: TracksPlaylistViewDataSource.pasteboardType) {
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? IndexSet
        }
        
        return nil
    }
    
    // Validates the proposed drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        if playlist.isBeingModified {return invalidDragOperation}
        
        // If the source is the tableView, that means playlist tracks are being reordered
        if info.draggingSource is NSTableView {
            
            // Reordering of tracks
            if let sourceIndexSet = getSourceIndexes(info) {
                return validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) ? .move : invalidDragOperation
            }
            
            return invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Given source indexes, a destination index (dropRow), and the drop operation (on/above), determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination indexes)
    private func validateReorderOperation(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableView.DropOperation) -> Bool {
        
        // If all rows are selected, they cannot be moved, and dropRow cannot be one of the source rows
        return operation == .above && sourceIndexSet.count < tableView.numberOfRows && !sourceIndexSet.contains(dropRow)
    }
    
    // Performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        if playlist.isBeingModified {return false}
        
        if info.draggingSource is NSTableView {
            
            if let sourceIndexSet = getSourceIndexes(info) {
                
                // Perform the reordering
                let destination = playlist.dropTracks(sourceIndexSet, row)
                let movingDown = sourceIndexSet.min()! < destination.min()!
                
                // Refresh the playlist view (only the relevant rows), and re-select the source rows that were reordered
                let srcArray = sourceIndexSet.sorted(by: movingDown ? descendingIntComparator : ascendingIntComparator)
                let destArray = destination.sorted(by: movingDown ? descendingIntComparator : ascendingIntComparator)
                
                // Swap source rows with destination rows
                for (sourceIndex, destIndex) in zip(srcArray, destArray) {
                    tableView.moveRow(at: sourceIndex, to: destIndex)
                }
                
                // Reload all source and destination rows, and all rows in between
                let srcDestUnion = sourceIndexSet.union(destination)
                let reloadIndexes = IndexSet(srcDestUnion.min()!...srcDestUnion.max()!)

                // Reload and select all the destination rows (the new locations of the moved tracks)
                tableView.reloadData(forRowIndexes: reloadIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
                tableView.noteHeightOfRows(withIndexesChanged: reloadIndexes)
                tableView.selectRowIndexes(destination, byExtendingSelection: false)
                
                // If a track is playing, the playback sequence may have changed (depending on the location of the playing track)
//                if playbackInfo.currentTrack != nil {
//                    SyncMessenger.publishNotification(SequenceChangedNotification.instance)
//                }
                
                return true
            }
            
        } else if let files = info.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            
            // Files added from Finder, add them to the playlist as URLs
            playlist.addFiles(files)
            return true
        }
        
        return false
    }
}
