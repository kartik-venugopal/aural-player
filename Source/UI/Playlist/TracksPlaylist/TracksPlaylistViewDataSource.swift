import Cocoa

/*
    Data source for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class TracksPlaylistViewDataSource: NSObject, NSTableViewDataSource {
    
    // Delegate that relays accessor operations to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
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
        
        let item = NSPasteboardItem()
        item.setData(NSKeyedArchiver.archivedData(withRootObject: rowIndexes), forType: .data)
        pboard.writeObjects([item])
        
        return true
    }
    
    // Helper function to retrieve source indexes from the NSDraggingInfo pasteboard
    private func getSourceIndexes(_ draggingInfo: NSDraggingInfo) -> IndexSet? {
        
        if let data = draggingInfo.draggingPasteboard.pasteboardItems?.first?.data(forType: .data) {
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
            if let sourceIndexSet = getSourceIndexes(info), validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) {
                return .move
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
        return operation == .above && (sourceIndexSet.count < tableView.numberOfRows) && !sourceIndexSet.contains(dropRow)
    }
    
    // Performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        if playlist.isBeingModified {return false}
        
        if info.draggingSource is NSTableView {
            
            if let sourceIndices = getSourceIndexes(info),
                let results = playlist.dropTracks(sourceIndices, row).results as? [TrackMoveResult] {
                
                let sortedMoves = results.filter({$0.movedDown}).sorted(by: ItemMoveResultComparators.compareDescending) +
                    results.filter({$0.movedUp}).sorted(by: ItemMoveResultComparators.compareAscending)
                
                var allIndices: [Int] = []
                var destinationIndices: [Int] = []
                
                for move in sortedMoves {
                    
                    tableView.moveRow(at: move.sourceIndex, to: move.destinationIndex)
                    
                    // Collect source and destination indices for later
                    allIndices += [move.sourceIndex, move.destinationIndex]
                    destinationIndices.append(move.destinationIndex)
                }
                
                // Reload all source and destination rows, and all rows in between
                let reloadIndices: IndexSet = IndexSet(allIndices.min()!...allIndices.max()!)
                tableView.reloadData(forRowIndexes: reloadIndices, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
                
                // Select all the destination rows (the new locations of the moved tracks)
                tableView.selectRowIndexes(IndexSet(destinationIndices), byExtendingSelection: false)
                
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
