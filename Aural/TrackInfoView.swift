/*
    Custom view for a single NSTableView row that displays a single piece of track info. Creates table cells with the necessary track information.
*/

import Cocoa

class TrackInfoView: NSTableRowView {
    
    var track: Track?
    
    // Used for creating new cells with makeViewWithIdentifier()
    var trackInfoView: NSTableView?
    
    // A single key-value pair
    var key: String?
    var value: String?
    
    override func view(atColumn column: Int) -> Any? {
        
        if (column == 0) {
            // Key
            
            if let cell = trackInfoView!.make(withIdentifier: "cv_trackInfoKey", owner: nil) as? NSTableCellView {
                
                cell.textField?.stringValue = key! + ":"
                return cell
            }
            
        } else {
            // Value
            
            if let cell = trackInfoView!.make(withIdentifier: "cv_trackInfoValue", owner: nil) as? NSTableCellView {
                
                cell.textField?.stringValue = value!
                return cell
            }
        }
        
        return nil
    }
}
