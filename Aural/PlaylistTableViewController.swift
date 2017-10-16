/*
    Data source and view delegate for the NSTableView that displays the playlist. Creates table cells with the necessary track information.
*/

import Cocoa
import AVFoundation

class PlaylistTableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MessageSubscriber {
    
    // Delegate that performs CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Used to determine the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Used to pause/resume the playing track animation
    private var animationCell: PlaylistCellView?
    
    override func viewDidLoad() {
        SyncMessenger.subscribe(.playbackStateChangedNotification, subscriber: self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlist.size()
    }
    
    // Each playlist view row contains one track, with display name and duration
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the track name column is used for type selection
        if (tableColumn?.identifier.rawValue != UIConstants.trackNameColumnID) {
            return nil
        }
        
        // Track name is used for type select comparisons
        return playlist.peekTrackAt(row)?.track.conciseDisplayName
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let track = (playlist.peekTrackAt(row)?.track)!
        
        if (tableColumn?.identifier.rawValue == UIConstants.trackIndexColumnID) {
            
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
        
        } else if (tableColumn?.identifier.rawValue == UIConstants.trackNameColumnID) {
            
            // Track name
            return createTextCell(tableView, UIConstants.trackNameColumnID, track.conciseDisplayName)
            
        } else {
            
            // Duration
            return createTextCell(tableView, UIConstants.durationColumnID, StringUtils.formatSecondsToHMS(track.duration))
        }
    }
    
    private func createTextCell(_ tableView: NSTableView, _ id: String, _ text: String) -> PlaylistCellView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: nil) as? PlaylistCellView {
            
            cell.textField?.stringValue = text
            
            cell.imageView?.isHidden = true
            cell.textField?.isHidden = false
            
            return cell
        }
        
        return nil
    }
    
    private func createPlayingTrackAnimationCell(_ tableView: NSTableView, _ animate: Bool) -> PlaylistCellView? {
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: UIConstants.trackIndexColumnID), owner: nil) as? PlaylistCellView {
            
            // Configure and show the image view
            let imgView = cell.imageView!
            
            imgView.canDrawSubviewsIntoLayer = true
            imgView.imageScaling = .scaleProportionallyDown
            imgView.animates = animate
            //imgView.image = UIConstants.imgPlayingTrack
            imgView.isHidden = false
            
            // Hide the text view
            cell.textField?.isHidden = true
            
            return cell
        }
        
        return nil
    }
    
    // Drag n drop
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        
        // No validation required here
        return NSDragOperation.copy;
    }
    
    // Drag n drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        
        let objects = info.draggingPasteboard().readObjects(forClasses: [NSURL.self], options: nil)
        
        playlist.addFiles(objects! as! [URL])
        
        return true
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
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
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
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            if let field = self.textField {
                
                if (backgroundStyle == NSView.BackgroundStyle.dark) {
                    
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
