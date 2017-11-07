/*
    Data source and view delegate for the NSTableView that displays the playlist. Creates table cells with the necessary track information.
*/

import Cocoa
import AVFoundation

class TracksPlaylistDataSource: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MessageSubscriber {
    
    // Delegate that performs CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Handles all drag/drop operations
    private let dragDropDelegate: TracksPlaylistDragDropDelegate = TracksPlaylistDragDropDelegate()
    
    // Used to pause/resume the playing track animation
    private var animationCell: PlaylistCellView?
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    override func viewDidLoad() {
        
        // Subscribe to playbackStateChangedNotifications so that the playing track animation can be paused/resumed, in response to the playing track being paused/resumed
        SyncMessenger.subscribe(messageTypes: [.playbackStateChangedNotification], subscriber: self)
        
        TableViewHolder.instance = self.view as! NSTableView
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlist.size()
    }
    
    // Each playlist view row contains one track, with display name and duration
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return FlatPlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        if (tableColumn?.identifier != UIConstants.trackNameColumnID) {
            return nil
        }
        
        // Track name is used for type select comparisons
        return playlist.trackAtIndex(row)?.track.conciseDisplayName
    }
    
    // Returns a view for a single playlist row
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let track = playlist.trackAtIndex(row)?.track {
            
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
                    return createTextCell(tableView, UIConstants.trackIndexColumnID, String(format: "%d.", row + 1), row)
                }
                
            } else if (tableColumn?.identifier == UIConstants.trackNameColumnID) {
                
                // Track name
                return createTextCell(tableView, UIConstants.trackNameColumnID, track.conciseDisplayName, row)
                
            } else {
                
                // Duration
                return createTextCell(tableView, UIConstants.durationColumnID, StringUtils.formatSecondsToHMS(track.duration), row)
            }
        }
        
        return nil
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ id: String, _ text: String, _ row: Int) -> PlaylistCellView? {
        
        if let cell = tableView.make(withIdentifier: id, owner: nil) as? PlaylistCellView {
            
            cell.textField?.stringValue = text
            
            // Hide the image view and show the text view
            cell.imageView?.isHidden = true
            cell.textField?.isHidden = false

            cell.row = row
            
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
        
        return dragDropDelegate.tableView(tableView, writeRowsWith: rowIndexes, to: pboard)
    }
    
    // Drag n drop - determines the drag/drop operation
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        return dragDropDelegate.tableView(tableView, validateDrop: info, proposedRow: row, proposedDropOperation: dropOperation)
    }
    
    // Drag n drop - accepts and performs the drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        return dragDropDelegate.tableView(tableView, acceptDrop: info, row: row, dropOperation: dropOperation)
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
class FlatPlaylistRowView: NSTableRowView {
    
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
    
    // Used to determine whether or not this cell is selected
    var row: Int = -1

    // When the background changes (as a result of selection/deselection) switch appropriate colours
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            let isSelRow = TableViewHolder.instance!.selectedRowIndexes.contains(row)
            
            if let field = self.textField {
                
                if isSelRow {
                    
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

// Utility class to hold an NSTableView instance for convenient access
fileprivate class TableViewHolder {
    
    static var instance: NSTableView?
}
