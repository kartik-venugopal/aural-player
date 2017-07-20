/*
    Custom view for a single NSTableView row that displays a single track. Creates table cells with the necessary track information, and customizes the look and feel of cells (in selected rows).
*/

import Cocoa

class PlaylistSongView: NSTableRowView {
    
    var trackName: String?
    var duration: String?
    
    // Used for creating new cells with makeViewWithIdentifier()
    var tableView: NSTableView?
    
    override func view(atColumn column: Int) -> Any? {

        if (column == 0) {
            // Track name
            
            if let cell = tableView!.make(withIdentifier: "cv_trackName", owner: nil) as? PlaylistCellView {
            
                cell.textField?.stringValue = trackName!
                return cell
            }
        
        } else {
            // Duration
            
            if let cell = tableView!.make(withIdentifier: "cv_duration", owner: nil) as? PlaylistCellView {
                
                cell.textField?.stringValue = duration!
                return cell
            }
        }
        
        return nil
    }
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableViewSelectionHighlightStyle.none {
            
            let selectionRect = NSInsetRect(self.bounds, 0, 0)
            
            NSColor(calibratedWhite: 0.65, alpha: 1).setStroke()
            
            UIConstants.colorScheme.playlistSelectionBoxColor.setFill()
            
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 3, yRadius: 3)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
}
