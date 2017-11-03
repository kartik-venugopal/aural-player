/*
 Data source and view delegate for the NSTableView that displays the playlist. Creates table cells with the necessary track information.
 */

import Cocoa
import AVFoundation

class TracksPlaylistDragDropDelegate: NSObject, NSOutlineViewDelegate {
    
    // Delegate that performs CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    // Drag n drop - writes source information to the pasteboard
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        let item = NSPasteboardItem()
        item.setData(data, forType: "public.data")
        pboard.writeObjects([item])
        
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
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        // If the source is the tableView, that means playlist tracks are being reordered
        if (info.draggingSource() is NSTableView) {
            
            // Reordering of tracks
            if let sourceIndexSet = getSourceIndexes(info) {
                return validateReorderOperation(tableView, sourceIndexSet, row, dropOperation) ? .move : invalidDragOperation
            }
            
            // Impossible
            return invalidDragOperation
        }
        
        // TODO: What about items added from apps other than Finder ??? From VOX or other audio players ???
        
        // Otherwise, files are being dragged in from outside the app (e.g. tracks/playlists from Finder)
        return .copy
    }
    
    // Drag n drop - Given source indexes, a destination index (dropRow), and the drop operation (on/above), determines if the drop is a valid reorder operation (depending on the bounds of the playlist, and the source and destination indexes)
    private func validateReorderOperation(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableViewDropOperation) -> Bool {
        
        // If all rows are selected, they cannot be moved, and dropRow cannot be one of the source rows
        if (sourceIndexSet.count == tableView.numberOfRows || sourceIndexSet.contains(dropRow)) {
            return false
        }
        
        // Doesn't match any of the invalid cases, it's a valid operation
        return true
    }
    
    // Drag n drop - accepts and performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        if (info.draggingSource() is NSTableView) {
            
            if let sourceIndexSet = getSourceIndexes(info) {
                
                // Calculate the destination rows for the reorder operation, and perform the reordering
                let destination = calculateReorderingDestination(tableView, sourceIndexSet, row, dropOperation)
                performReordering(sourceIndexSet, row, destination)
                
                // Refresh the playlist view (only the relevant rows), and re-select the source rows that were reordered
                
                let src = sourceIndexSet.toArray()
                let dest = destination.toArray()
                
                var cur = 0
                while (cur < src.count) {
                    tableView.moveRow(at: src[cur], to: dest[cur])
                    cur += 1
                }
                
                let minReloadIndex = min(sourceIndexSet.min()!, destination.min()!)
                let maxReloadIndex = max(sourceIndexSet.max()!, destination.max()!)
                
                let reloadIndexes = IndexSet(minReloadIndex...maxReloadIndex)
                tableView.reloadData(forRowIndexes: reloadIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
                
                tableView.selectRowIndexes(destination, byExtendingSelection: false)
                
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
    
    /*
     In response to a playlist reordering by drag and drop, and given source indexes, a destination index, and the drop operation (on/above), determines which indexes the source rows will occupy.
     */
    private func calculateReorderingDestination(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableViewDropOperation) -> IndexSet {
        
        // Find out how many source items are above the dropRow and how many below
        let sourceIndexesAboveDropRow = sourceIndexSet.filter({$0 < dropRow})
        let sourceIndexesBelowDropRow = sourceIndexSet.filter({$0 > dropRow})
        
        // The lowest index in the destination rows
        var minDestinationRow: Int
        
        // The highest index in the destination rows
        var maxDestinationRow: Int
        
        // The destination rows will depend on whether the drop is to be performed above or on the dropRow
        if (operation == .above) {
            
            // All source items above the dropRow will form a contiguous block ending just above (one row above) the dropRow
            // All source items below the dropRow will form a contiguous block starting at the dropRow and extending below it
            
            minDestinationRow = dropRow - sourceIndexesAboveDropRow.count
            maxDestinationRow = dropRow + sourceIndexesBelowDropRow.count - 1
            
        } else {
            
            // On
            
            // If the drop is being performed on the dropRow, the destination rows will further depend on whether there are more source items above or below the dropRow.
            if (sourceIndexesAboveDropRow.count > sourceIndexesBelowDropRow.count) {
                
                // There are more source items above the dropRow than below it
                
                // All source items above the dropRow will form a contiguous block ending at the dropRow
                // All source items below the dropRow will form a contiguous block starting one row below the dropRow and extending below it
                
                minDestinationRow = dropRow - sourceIndexesAboveDropRow.count + 1
                maxDestinationRow = dropRow + sourceIndexesBelowDropRow.count
                
            } else {
                
                // There are more source items below the dropRow than above it
                
                // All source items above the dropRow will form a contiguous block ending just above (one row above) the dropRow
                // All source items below the dropRow will form a contiguous block starting at the dropRow and extending below it
                
                minDestinationRow = dropRow - sourceIndexesAboveDropRow.count
                maxDestinationRow = dropRow + sourceIndexesBelowDropRow.count - 1
            }
        }
        
        return IndexSet(minDestinationRow...maxDestinationRow)
    }
    
    private func performReordering(_ sourceIndexSet: IndexSet, _ dropRow: Int, _ destination: IndexSet) {
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var playlistReorderOperations = [PlaylistReorderOperation]()
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Track]()
        
        // Make sure they the source indexes are iterated in descending order. This will be important later.
        sourceIndexSet.sorted(by: {x, y -> Bool in x > y}).forEach({
            sourceItems.append((playlist.trackAtIndex($0)?.track)!)
            playlistReorderOperations.append(TrackRemoveOperation(index: $0))
        })
        
        var cursor = 0
        
        // Destination rows need to be sorted in ascending order
        let destinationRows = destination.sorted(by: {x, y -> Bool in x < y})
        
        sourceItems = sourceItems.reversed()
        
        destinationRows.forEach({
            
            // For each destination row, copy over a source item into the corresponding destination hole
            let reorderOperation = TrackInsertOperation(srcTrack: sourceItems[cursor], destIndex: $0)
            playlistReorderOperations.append(reorderOperation)
            cursor += 1
        })
        
        // Submit the reorder operations to the playlist
        playlist.reorderTracks(playlistReorderOperations)
    }
}
