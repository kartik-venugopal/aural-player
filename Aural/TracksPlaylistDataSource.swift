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
    private var animationCell: NSTableCellView?
    
    // Signifies an invalid drag/drop operation
    private let invalidDragOperation: NSDragOperation = []
    
    override func viewDidLoad() {
        
        // Subscribe to playbackStateChangedNotifications so that the playing track animation can be paused/resumed, in response to the playing track being paused/resumed
        SyncMessenger.subscribe(messageTypes: [.playbackStateChangedNotification], subscriber: self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
//        NSLog("Playlist size: %d", playlist.size())
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
                    return createTextCell(tableView, UIConstants.trackIndexColumnID, String(format: "%d.", row + 1))
                }
                
            } else if (tableColumn?.identifier == UIConstants.trackNameColumnID) {
                
                // Track name
                return createTextCell(tableView, UIConstants.trackNameColumnID, track.conciseDisplayName)
                
            } else {
                
                // Duration
                return createTextCell(tableView, UIConstants.durationColumnID, StringUtils.formatSecondsToHMS(track.duration))
            }
            
        } else {
            
            // TODO: Figure out why this happens !
            print("WTF ! Row", row, "PlSize:", playlist.size())
            return nil
        }
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ id: String, _ text: String) -> NSTableCellView? {
        
        if let cell = tableView.make(withIdentifier: id, owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            
            // Hide the image view and show the text view
            cell.imageView?.isHidden = true
            cell.textField?.isHidden = false
            
            return cell
        }
        
        return nil
    }
    
    // Creates a cell view containing the animation for the currently playing track
    private func createPlayingTrackAnimationCell(_ tableView: NSTableView, _ animate: Bool) -> NSTableCellView? {
        
        if let cell = tableView.make(withIdentifier: UIConstants.trackIndexColumnID, owner: nil) as? NSTableCellView {
            
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
    
    override func drawBackground(in dirtyRect: NSRect) {
        
        UIConstants.flatPlaylistViewColumnIndexes.forEach({
            
            let cell = self.view(atColumn: $0) as! NSTableCellView
            cell.textField?.textColor = isSelected ? Colors.playlistSelectedTextColor : Colors.playlistTextColor
            cell.textField?.font = isSelected ? UIConstants.playlistSelectedTextFont : UIConstants.playlistTextFont
        })
        
        super.drawBackground(in: dirtyRect)
    }
}
