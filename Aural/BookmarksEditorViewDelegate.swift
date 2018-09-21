import Cocoa

/*
 Delegate for the NSTableView that displays the "Tracks" (flat) playlist view.
 */
class BookmarksEditorViewDelegate: NSObject, NSTableViewDataSource,  NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var editorView: NSTableView!
    
    // Delegate that relays accessor operations to the bookmarks model
    private let bookmarks: BookmarksDelegateProtocol = ObjectGraph.getBookmarksDelegate()
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bookmarks.countBookmarks()
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the bookmark name column is used for type selection
        if (tableColumn?.identifier != UIConstants.bookmarkNameColumnID) {
            return nil
        }

        return bookmarks.getBookmarkAtIndex(row)?.name
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if let bookmark = bookmarks.getBookmarkAtIndex(row) {
            
            switch tableColumn!.identifier {
                
            case UIConstants.bookmarkNameColumnID:
                
                return createTextCell(tableView, tableColumn!, bookmark.name, true)
                
            case UIConstants.bookmarkTrackColumnID:
                
                return createTextCell(tableView, tableColumn!, bookmark.file.path, false)
                
            case UIConstants.bookmarkPositionColumnID:
                
                let formattedPosition = StringUtils.formatSecondsToHMS(bookmark.position)
                return createTextCell(tableView, tableColumn!, formattedPosition, false)
                
            default:    return nil
                
            }
        }
        
        return nil
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ text: String, _ editable: Bool) -> NSTableCellView? {
        
        if let cell = tableView.make(withIdentifier: column.identifier, owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            
            // TODO: Doesn't update tool tips when columns are resized
            // Set tool tip on name/track only if text wider than column width
            let font = cell.textField!.font!
            if StringUtils.numberOfLines(text, font, column.width) > 1 {
                cell.toolTip = text
            }
            
            // Name column is editable
            if editable {
                cell.textField?.isEditable = true
                cell.textField?.delegate = self
            }
            
            return cell
        }
        
        return nil
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = editorView.selectedRow
        
        // Get the row containing the text field that was edited
        
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        
        // Name column is at index 0
        let editedTextField = (rowView?.view(atColumn: 0) as! NSTableCellView).textField!
        
        // TODO: Validate the new value (e.g. can't be empty string or too long)
        
        let bookmark = bookmarks.getBookmarkAtIndex(rowIndex)!
        
        let newBookmarkName = editedTextField.stringValue
        
        if (StringUtils.isStringEmpty(newBookmarkName)) {
            editedTextField.stringValue = bookmark.name
            
        } else {
            
            // Update the bookmark name
            bookmark.name = newBookmarkName
        }
    }
}
