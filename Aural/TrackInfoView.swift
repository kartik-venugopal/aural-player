/*
    Custom view for a single NSTableView row that displays a single piece of track info. Creates table cells with the necessary track information.
*/

import Cocoa

class TrackInfoView: NSTableRowView {
    
    // A single key-value pair
    var key: String?
    var value: String?
    
    // Factory method
    static func fromKeyAndValue(_ key: String, _ value: String) -> TrackInfoView {
        
        let view = TrackInfoView()
        view.key = key
        view.value = value
        
        return view
    }
    
    override func view(atColumn column: Int) -> Any? {
        
        // TODO: Can these values be cached once created ???
        
        if (column == 0) {
            
            // Key
            return createCell(UIConstants.trackInfoKeyColumnID, key! + ":")
            
        } else {
            
            // Value
            return createCell(UIConstants.trackInfoValueColumnID, value!)
        }
    }
    
    private func createCell(_ id: String, _ text: String) -> NSTableCellView? {
        
        if let cell = TrackInfoViewHolder.trackInfoView!.make(withIdentifier: id, owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
}
