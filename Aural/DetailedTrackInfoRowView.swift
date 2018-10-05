/*
    Custom view for a single NSTableView row that displays a single piece of track info. Creates table cells with the necessary track information.
*/

import Cocoa

class DetailedTrackInfoRowView: NSTableRowView {
    
    // A single key-value pair
    var key: String?
    var value: String?
    
    // Factory method
    static func fromKeyAndValue(_ key: String, _ value: String) -> DetailedTrackInfoRowView {
        
        let view = DetailedTrackInfoRowView()
        view.key = key
        view.value = value
        
        return view
    }
    
    override func view(atColumn column: Int) -> Any? {
        
        if (column == 0) {
            
            // Key
            return createCell(UIConstants.trackInfoKeyColumnID, key! + ":")
            
        } else {
            
            // Value
            return createCell(UIConstants.trackInfoValueColumnID, value!)
        }
    }
    
    private func createCell(_ id: String, _ text: String) -> NSTableCellView? {
        
        if let cell = TrackInfoViewHolder.trackInfoView!.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(id), owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
