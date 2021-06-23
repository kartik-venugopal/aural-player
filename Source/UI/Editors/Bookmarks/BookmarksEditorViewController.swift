import Cocoa

class BookmarksEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate, NSTextFieldDelegate {

    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnPlay: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    // Delegate that relays accessor operations to the bookmarks model
    private let bookmarks: BookmarksDelegateProtocol = ObjectGraph.bookmarksDelegate
    
    override var nibName: String? {"BookmarksEditor"}
    
    override func viewDidLoad() {
        editorView.customizeHeader(heightIncrease: 8, customCellType: AuralTableHeaderCell.self)
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        [btnDelete, btnPlay, btnRename].forEach {$0.disable()}
    }
    
    @IBAction func deleteSelectedBookmarksAction(_ sender: AnyObject) {
        
        bookmarks.deleteBookmarks(atIndices: editorView.selectedRowIndexes)
        
        editorView.reloadData()
        editorView.deselectAll(self)
        updateButtonStates()
    }
    
    @IBAction func playSelectedBookmarkAction(_ sender: AnyObject) {
        
        if editorView.numberOfSelectedRows == 1 {
            
            let bookmark = bookmarks.getBookmarkAtIndex(editorView.selectedRow)
            
            do {

                try bookmarks.playBookmark(bookmark)
                
            } catch {
                
                if let fnfError = error as? FileNotFoundError {
                    
                    // This needs to be done async. Otherwise, other open dialogs could hang.
                    DispatchQueue.main.async {
                        
                        // Position and display an alert with error info
                        _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove bookmark").showModal()
                        self.bookmarks.deleteBookmarkWithName(bookmark.name)
                        self.editorView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func renameBookmarkAction(_ sender: AnyObject) {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let editedTextField = (rowView?.view(atColumn: 0) as! NSTableCellView).textField!
        
        self.view.window?.makeFirstResponder(editedTextField)
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.window!.close()
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bookmarks.count
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the bookmark name column is used for type selection
        if let colID = tableColumn?.identifier, colID == .uid_bookmarkNameColumn {
            return bookmarks.getBookmarkAtIndex(row).name
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = editorView.numberOfSelectedRows
        
        btnDelete.enableIf(selRows > 0)
        [btnPlay, btnRename].forEach {$0.enableIf(selRows == 1)}
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
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
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String, _ editable: Bool) -> EditorTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView else {return nil}
        
        cell.isSelectedFunction = {[weak self] (row: Int) -> Bool in
            self?.editorView.selectedRowIndexes.contains(row) ?? false
        }
        
        cell.textField?.stringValue = text
        cell.textField?.textColor = Colors.playlistTextColor
        cell.row = row
        
        // Set tool tip on name/track only if text wider than column width
        let font = cell.textField!.font!
        if text.numberOfLines(font: font, lineWidth: column.width) > 1 {
            cell.toolTip = text
        }
        
        // Name column is editable
        if editable {
            cell.textField?.delegate = self
        }
        
        return cell
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
     
        // Update tool tips as some may no longer be needed or some new ones may be needed
        
        if let column = notification.userInfo?["NSTableColumn", NSTableColumn.self] {
        
            let count = bookmarks.count
            if count > 0 {
                
                for index in 0..<count {
                    
                    guard let cell = tableView(editorView, viewFor: column, row: index) as? NSTableCellView,
                          let textField = cell.textField else {continue}
                    
                    let text = textField.stringValue
                    let font = textField.font!
                    
                    if text.numberOfLines(font: font, lineWidth: column.width) > 1 {
                        cell.toolTip = text
                    } else {
                        cell.toolTip = nil
                    }
                }
            }
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = editorView.selectedRow
        let rowView = editorView.rowView(atRow: rowIndex, makeIfNecessary: true)
        let cell = rowView?.view(atColumn: 0) as! NSTableCellView
        let editedTextField = cell.textField!
        
        let bookmark = bookmarks.getBookmarkAtIndex(rowIndex)
        let newBookmarkName = editedTextField.stringValue
        
        editedTextField.textColor = Colors.playlistSelectedTextColor
        
        // TODO: What if the string is too long ?
        
        // Empty string is invalid, revert to old value
        if (String.isEmpty(newBookmarkName)) {
            editedTextField.stringValue = bookmark.name
            
        } else {
            
            // Update the bookmark name
            bookmarks.renameBookmarkAtIndex(rowIndex, newBookmarkName)
        }
        
        // Update the tool tip

        let font = editedTextField.font!
        let nameColumn = editorView.tableColumns[0]
        
        if newBookmarkName.numberOfLines(font: font, lineWidth: nameColumn.width) > 1 {
            cell.toolTip = newBookmarkName
        } else {
            cell.toolTip = nil
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
