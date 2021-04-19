/*
    Custom view for a single NSTableView row that displays a single piece of track info. Creates table cells with the necessary track information.
*/

import Cocoa

class DetailedTrackInfoRowView: NSTableRowView {
    
    // A single key-value pair
    var key: String?
    var value: String?
    var tableId: TrackInfoTab?
    
    var keyTextAlignment: NSTextAlignment?
    var valueTextAlignment: NSTextAlignment?
    
    // Factory method
    static func fromKeyAndValue(_ key: String, _ value: String, _ tableId: TrackInfoTab, _ keyTextAlignment: NSTextAlignment? = nil, _ valueTextAlignment: NSTextAlignment? = nil) -> DetailedTrackInfoRowView {
        
        let view = DetailedTrackInfoRowView()
        view.key = key
        view.value = value
        view.tableId = tableId
        view.keyTextAlignment = keyTextAlignment
        view.valueTextAlignment = valueTextAlignment
        
        return view
    }
    
    override func view(atColumn column: Int) -> Any? {
        
        if (column == 0) {
            
            // Key
            return createCell(UIConstants.trackInfoKeyColumnID, key! + ":", keyTextAlignment)
            
        } else {
            
            // Value
            return createCell(UIConstants.trackInfoValueColumnID, value!, valueTextAlignment)
        }
    }
    
    private func createCell(_ id: String, _ text: String, _ alignment: NSTextAlignment?) -> NSTableCellView? {
        
        if let cell = TrackInfoViewHolder.tablesMap[tableId!]?.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            
            if let alignment = alignment {
                cell.textField?.alignment = alignment
            }
            
            return cell
        }
        
        return nil
    }
}
