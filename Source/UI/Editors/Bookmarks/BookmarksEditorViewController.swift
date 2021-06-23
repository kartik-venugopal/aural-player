import Cocoa

class BookmarksEditorViewController: GenericPresetsManagerViewController {

    // Delegate that relays accessor operations to the bookmarks model
    private let bookmarks: BookmarksDelegateProtocol = ObjectGraph.bookmarksDelegate
    
    override var nibName: String? {"BookmarksEditor"}
    
    override var numberOfPresets: Int {bookmarks.count}
    
    override func nameOfPreset(atIndex index: Int) -> String {bookmarks.getBookmarkAtIndex(index).name}
    
    override func presetExists(named name: String) -> Bool {
        bookmarks.bookmarkWithNameExists(name)
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        bookmarks.deleteBookmarks(atIndices: presetsTableView.selectedRowIndexes)
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let bookmark = bookmarks.getBookmarkAtIndex(index)
        
        do {
            try bookmarks.playBookmark(bookmark)
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove bookmark").showModal()
                    self.bookmarks.deleteBookmarkWithName(bookmark.name)
                    self.presetsTableView.reloadData()
                }
            }
        }
    }
    
    override func renamePreset(named name: String, to newName: String) {
        bookmarks.renameBookmark(named: name, to: newName)
    }
    
    // MARK: View delegate functions
    
    // Returns a view for a single column
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        
        let bookmark = bookmarks.getBookmarkAtIndex(row)
        
        switch colID {
            
        case .uid_bookmarkNameColumn:
            
            return createTextCell(tableView, tableColumn!, row, bookmark.name, true)
            
        case .uid_bookmarkTrackColumn:
            
            return createTextCell(tableView, tableColumn!, row, bookmark.file.path, false)
            
        case .uid_bookmarkStartPositionColumn:
            
            let formattedPosition = ValueFormatter.formatSecondsToHMS(bookmark.startPosition)
            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
            
        case .uid_bookmarkEndPositionColumn:
            
            var formattedPosition: String = ""
            
            if let endPos = bookmark.endPosition {
                formattedPosition = ValueFormatter.formatSecondsToHMS(endPos)
            } else {
                formattedPosition = "-"
            }
            
            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
            
        default:    return nil
            
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    
    static let uid_bookmarkNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkName")
    static let uid_bookmarkTrackColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkTrack")
    static let uid_bookmarkStartPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkStartPosition")
    static let uid_bookmarkEndPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkEndPosition")
}
