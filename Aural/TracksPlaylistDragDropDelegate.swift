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
                
                // Perform the reordering
                let destination = playlist.dropTracks(sourceIndexSet, row, DropType.fromDropOperation(dropOperation))
                
                // Refresh the playlist view (only the relevant rows), and re-select the source rows that were reordered
                
                let srcArray = sourceIndexSet.toArray()
                let destArray = destination.toArray()
                
                // Swap source rows with destination rows
                var cur = 0
                while (cur < sourceIndexSet.count) {
                    tableView.moveRow(at: srcArray[cur], to: destArray[cur])
                    cur += 1
                }
                
                // Reload all source and destination rows, and all rows in between
                let srcDestUnion = sourceIndexSet.union(destination)
                let reloadIndexes = IndexSet(srcDestUnion.min()!...srcDestUnion.max()!)
                tableView.reloadData(forRowIndexes: reloadIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
                
                tableView.selectRowIndexes(destination, byExtendingSelection: false)
                
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
}

enum DropType {
    
    case on
    case above
    
    static func fromDropOperation(_ dropOp: NSTableViewDropOperation) -> DropType {
        
        switch dropOp {
            
        case .on: return .on
            
        case .above: return .above
            
        }
    }
}
