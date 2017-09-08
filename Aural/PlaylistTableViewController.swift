/*
    Custom view controller for the NSTableView that displays the playlist. Creates table cells with the necessary track information.
*/

import Cocoa
import AVFoundation

class PlaylistTableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    // TODO: Merge these two variables into one, use protocols
    private let playlist: PlaylistAccessorProtocol = ObjectGraph.getPlaylistAccessor()
    private let playlistDelegate: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return playlist.size()
    }
    
    // Each playlist view row contains one track, with name and duration
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return PlaylistRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let track = (playlist.peekTrackAt(row)?.track)!
        
        if (tableColumn?.identifier == UIConstants.trackNameColumnID) {
            
            // Track name
            let trackName = (track.shortDisplayName)!
        
            if let cell = tableView.make(withIdentifier: UIConstants.trackNameColumnID, owner: nil) as? PlaylistCellView {
                cell.textField?.stringValue = trackName
                return cell
            }
        
        } else if (tableColumn?.identifier == UIConstants.durationColumnID) {
            
            // Duration
            let duration = Utils.formatDuration((track.duration)!)
            
            if let cell = tableView.make(withIdentifier: UIConstants.durationColumnID, owner: nil) as? PlaylistCellView {
                cell.textField?.stringValue = duration
                return cell
            }
        }
        
        return nil
    }
    
    // Drag n drop
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        // No validation required here
        return NSDragOperation.copy;
    }
    
    // Drag n drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        let objects = info.draggingPasteboard().readObjects(forClasses: [NSURL.self], options: nil)
        
        playlistDelegate.addFiles(objects! as! [URL])
        
        return true
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
            
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 3, yRadius: 3)
            Colors.playlistSelectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and color.
 */
class PlaylistCellView: NSTableCellView {
    
    // When the background changes (as a result of selection/deselection) switch appropriate colours
    override var backgroundStyle: NSBackgroundStyle {
        
        didSet {
            
            if let field = self.textField {
                
                field.font = UIConstants.playlistBoldFont
                
                if (backgroundStyle == NSBackgroundStyle.dark) {
                    // Selected
                    field.textColor = Colors.playlistSelectedTextColor
                } else {
                    // Not selected
                    field.textColor = Colors.playlistTextColor
                }
            }
        }
    }
}
