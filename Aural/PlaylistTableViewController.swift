/*
    Data source and view delegate for the NSTableView that displays the playlist. Creates table cells with the necessary track information.
*/

import Cocoa
import AVFoundation

class PlaylistTracksViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MessageSubscriber {
    
    // Delegate that performs CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Used to pause/resume the playing track animation
    private var animationCell: PlaylistCellView?
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    override func viewDidLoad() {
        
        // Subscribe to playbackStateChangedNotifications so that the playing track animation can be paused/resumed, in response to the playing track being paused/resumed
        SyncMessenger.subscribe(.playbackStateChangedNotification, subscriber: self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
//        NSLog("Playlist size: %d", playlist.size())
        return playlist.size()
    }
    
    // Each playlist view row contains one track, with display name and duration
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        if (tableColumn?.identifier != UIConstants.trackNameColumnID) {
            return nil
        }
        
        // Track name is used for type select comparisons
        return playlist.peekTrackAt(row)?.track.conciseDisplayName
    }
    
    // Returns a view for a single playlist row
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let track = (playlist.peekTrackAt(row)?.track)!
        
        if (tableColumn?.identifier == UIConstants.trackIndexColumnID) {
            
            // Track index
            
            let playingTrackIndex = playbackInfo.getPlayingTrack()?.index
            
            // If this row contains the playing track, display an animation, instead of the track index
            if (playingTrackIndex != nil && playingTrackIndex == row) {
                
                let playbackState = playbackInfo.getPlaybackState()
                let cell = createPlayingTrackAnimationCell(tableView, playbackState == .playing)
                animationCell = cell
                return cell
                
            } else {
                
                // Otherwise, create a text cell with the track index
                return createTextCell(tableView, UIConstants.trackIndexColumnID, String(format: "%d.", row + 1))
            }
        
        } else if (tableColumn?.identifier == UIConstants.trackNameColumnID) {
            
            // Track name
            return createTextCell(tableView, UIConstants.trackNameColumnID, track.conciseDisplayName)
            
        } else {
            
            // Duration
            return createTextCell(tableView, UIConstants.durationColumnID, StringUtils.formatSecondsToHMS(track.duration))
        }
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ id: String, _ text: String) -> PlaylistCellView? {
        
        if let cell = tableView.make(withIdentifier: id, owner: nil) as? PlaylistCellView {
            
            cell.textField?.stringValue = text
            
            // Hide the image view and show the text view
            cell.imageView?.isHidden = true
            cell.textField?.isHidden = false
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing the animation for the currently playing track
    private func createPlayingTrackAnimationCell(_ tableView: NSTableView, _ animate: Bool) -> PlaylistCellView? {
        
        if let cell = tableView.make(withIdentifier: UIConstants.trackIndexColumnID, owner: nil) as? PlaylistCellView {
            
            // Configure and show the image view
            let imgView = cell.imageView!
            
            imgView.canDrawSubviewsIntoLayer = true
            imgView.imageScaling = .scaleProportionallyDown
            imgView.animates = animate
            imgView.image = UIConstants.imgPlayingTrack
            imgView.isHidden = false
            
            // Hide the text view
            cell.textField?.isHidden = true
            
            return cell
        }
        
        return nil
    }
    
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
                performReordering(sourceIndexSet, row, destination, dropOperation)
                
                // Refresh the playlist view (only the relevant rows), and re-select the source rows that were reordered
                let minReloadIndex = min(sourceIndexSet.min()!, destination.rows.min()!)
                let maxReloadIndex = max(sourceIndexSet.max()!, destination.rows.max()!)
                
                let reloadIndexes = IndexSet(minReloadIndex...maxReloadIndex)
                tableView.reloadData(forRowIndexes: reloadIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
                
                tableView.selectRowIndexes(IndexSet(destination.rows), byExtendingSelection: false)
                
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
    private func calculateReorderingDestination(_ tableView: NSTableView, _ sourceIndexSet: IndexSet, _ dropRow: Int, _ operation: NSTableViewDropOperation) -> (rows: IndexSet, partitionPoint: Int, sourceIndexesAboveDropRow: [Int], sourceIndexesBelowDropRow: [Int]) {
        
        // Find out how many source items are above the dropRow and how many below
        let sourceIndexesAboveDropRow = sourceIndexSet.filter({$0 < dropRow})
        let sourceIndexesBelowDropRow = sourceIndexSet.filter({$0 > dropRow})
        
        // The lowest index in the destination rows
        var minDestinationRow: Int
        
        // The highest index in the destination rows
        var maxDestinationRow: Int
        
        // Partition point for source items (explained in function comments above)
        var partitionPoint: Int = 0
        
        // The destination rows will depend on whether the drop is to be performed above or on the dropRow
        if (operation == .above) {
            
            // All source items above the dropRow will form a contiguous block ending just above (one row above) the dropRow
            // All source items below the dropRow will form a contiguous block starting at the dropRow and extending below it
            
            minDestinationRow = dropRow - sourceIndexesAboveDropRow.count
            maxDestinationRow = dropRow + sourceIndexesBelowDropRow.count - 1
            
            partitionPoint = dropRow - 1
            
        } else {
            
            // On
            
            // If the drop is being performed on the dropRow, the destination rows will further depend on whether there are more source items above or below the dropRow.
            if (sourceIndexesAboveDropRow.count > sourceIndexesBelowDropRow.count) {
                
                // There are more source items above the dropRow than below it
                
                // All source items above the dropRow will form a contiguous block ending at the dropRow
                // All source items below the dropRow will form a contiguous block starting one row below the dropRow and extending below it
                
                minDestinationRow = dropRow - sourceIndexesAboveDropRow.count + 1
                maxDestinationRow = dropRow + sourceIndexesBelowDropRow.count
                
                partitionPoint = dropRow
                
            } else {
                
                // There are more source items below the dropRow than above it
                
                // All source items above the dropRow will form a contiguous block ending just above (one row above) the dropRow
                // All source items below the dropRow will form a contiguous block starting at the dropRow and extending below it
                
                minDestinationRow = dropRow - sourceIndexesAboveDropRow.count
                maxDestinationRow = dropRow + sourceIndexesBelowDropRow.count - 1
                
                partitionPoint = dropRow - 1
            }
        }
        
        return (IndexSet(minDestinationRow...maxDestinationRow), partitionPoint, sourceIndexesAboveDropRow, sourceIndexesBelowDropRow)
    }
    
    /* 
        Performs reordering of playlist tracks, in response to a drag and drop within the tableView.
     
        This procedure can be broken down into 4 logical steps:
        
        1 - Store all source items (items being reordered) in a temporary location. This is needed because these rows will be overwritten with other items in later steps. The source rows are now considered "holes", i.e. empty array locations that are now able to store other items that will be moved.
     
        2 - "Percolation" above dropRow: Starting at the partition point (explained above, in the comments for calculateReorderingDestination()) within the destination rows, move all non-source items sitting between the partition point and the topmost (lowest index) source item up, until they occupy the holes created in step 1. This will make room for the source items collected in step 1. If there are no source items above the dropRow, this step will be skipped.
     
        3 - "Percolation" below dropRow: Starting below the partition point within the destination rows, move all non-source items sitting between the partition point and the bottommost (highest index) source item down, until they occupy the holes created in step 1. This will make room for the source items collected in step 1. If there are no source items below the dropRow, this step will be skipped.
     
        Steps 2 and 3 will ensure that there are n empty rows (or "holes") around the partition point, where n is the number of source items being reordered. These are the destination rows. There will be no other holes above or below the destination rows.
     
        4 - Simply copy over the source items into the destination rows or holes. The reordering is then complete.
     
        NOTE - The playlist is not directly manipulated in this function. Reorder operations are noted down and submitted to the playlist, which then performs all the requested operations in sequence.
 
     */
    private func performReordering(_ sourceIndexSet: IndexSet, _ dropRow: Int, _ destination: (rows: IndexSet, partitionPoint: Int, sourceIndexesAboveDropRow: [Int], sourceIndexesBelowDropRow: [Int]), _ operation: NSTableViewDropOperation) {
        
        // Step 1 - Store all source items (tracks) that are being reordered, in a temporary location.
        var sourceItems = [Track]()
        
        // Make sure they the source indexes are iterated in ascending order. This will be important in Step 4.
        sourceIndexSet.sorted(by: {x, y -> Bool in x < y}).forEach({sourceItems.append((playlist.peekTrackAt($0)?.track)!)})
        
        let sourceIndexesAboveDropRow = destination.sourceIndexesAboveDropRow
        
        // Source rows below the drop row need to be sorted in descending order for iteration during percolation
        let sourceIndexesBelowDropRow = destination.sourceIndexesBelowDropRow.sorted(by: {x, y -> Bool in x > y})
        
        // Collect all reorder operations, in sequence, for later submission to the playlist
        var playlistReorderOperations = [PlaylistReorderOperation]()
        
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
                    
                    let reorderOperation = PlaylistCopyOperation(srcIndex: cursor, destIndex: cursor - holes)
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
                    
                    let reorderOperation = PlaylistCopyOperation(srcIndex: cursor, destIndex: cursor + holes)
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
            let reorderOperation = PlaylistOverwriteOperation(srcTrack: sourceItems[cursor], destIndex: $0)
            playlistReorderOperations.append(reorderOperation)
            cursor += 1
        })
        
        // Submit the reorder operations to the playlist
        playlist.reorderTracks(playlistReorderOperations)
    }
    
    // Whenever the playing track is paused/resumed, the animation needs to be paused/resumed.
    private func playbackStateChanged(_ state: PlaybackState) {
        
        switch (state) {
            
        case .playing:
            
            animationCell?.imageView?.animates = true
            
        case .paused:
            
            animationCell?.imageView?.animates = false
            
        default:
            
            // Release the animation cell because the track is no longer playing
            animationCell?.imageView?.animates = false
            animationCell = nil
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
    
        if (notification is PlaybackStateChangedNotification) {
            
            let msg = notification as! PlaybackStateChangedNotification
            playbackStateChanged(msg.newPlaybackState)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track. Customizes the selection look and feel.
 */
class PlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableViewSelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            Colors.playlistSelectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class PlaylistCellView: NSTableCellView {
    
    // When the background changes (as a result of selection/deselection) switch appropriate colours
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            if let field = self.textField {
                
                if (backgroundStyle == NSBackgroundStyle.dark) {
                    
                    // Selected
                    
                    field.textColor = Colors.playlistSelectedTextColor
                    field.font = UIConstants.playlistSelectedTextFont
                    
                } else {
                    
                    // Not selected
                    
                    field.textColor = Colors.playlistTextColor
                    field.font = UIConstants.playlistTextFont
                }
            }
        }
    }
}
