import Cocoa

class BookmarksEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate, NSTextFieldDelegate {

    @IBOutlet weak var editorView: NSTableView!
    @IBOutlet weak var header: NSTableHeaderView!
    
    // Used to adjust the header height
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnPlay: NSButton!
    @IBOutlet weak var btnRename: NSButton!
    
    // Delegate that relays accessor operations to the bookmarks model
    private let bookmarks: BookmarksDelegateProtocol = ObjectGraph.bookmarksDelegate
    
    override var nibName: String? {return "BookmarksEditor"}
    
    override func viewDidLoad() {
        
        headerHeight()
        header.wantsLayer = true
        header.layer?.backgroundColor = NSColor.black.cgColor
        
        editorView.tableColumns.forEach({
            
            let col = $0
            let header = AuralTableHeaderCell()
            
            header.stringValue = col.headerCell.stringValue
            header.isBordered = false
            
            col.headerCell = header
        })
    }
    
    private func headerHeight() {
        
        header.setFrameSize(NSMakeSize(header.frame.size.width, header.frame.size.height + 10))
        clipView.setFrameSize(NSMakeSize(clipView.frame.size.width, clipView.frame.size.height + 10))
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        [btnDelete, btnPlay, btnRename].forEach({$0.disable()})
    }
    
    @IBAction func deleteSelectedBookmarksAction(_ sender: AnyObject) {
        
        // Descending order
        let sortedSelection = editorView.selectedRowIndexes.sorted(by: {x, y -> Bool in x > y})
        
        sortedSelection.forEach({
            bookmarks.deleteBookmarkAtIndex($0)
        })
        
        editorView.reloadData()
        editorView.deselectAll(self)
        updateButtonStates()
    }
    
    @IBAction func playSelectedBookmarkAction(_ sender: AnyObject) {
        
        if editorView.numberOfSelectedRows == 1 {
            
            let bookmark = bookmarks.getBookmarkAtIndex(editorView.selectedRow)
            
            do {

                try bookmarks.playBookmark(bookmark)
                
            } catch let error {
                
                if let fnfError = error as? FileNotFoundError {
                    
                    // This needs to be done async. Otherwise, other open dialogs could hang.
                    DispatchQueue.main.async {
                        
                        // Position and display an alert with error info
                        _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove bookmark"))
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
        UIUtils.dismissDialog(self.view.window!)
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bookmarks.count
    }
    
    // Enables type selection, allowing the user to conveniently and efficiently find a playlist track by typing its display name, which results in the track, if found, being selected within the playlist
    func tableView(_ tableView: NSTableView, typeSelectStringFor tableColumn: NSTableColumn?, row: Int) -> String? {
        
        // Only the bookmark name column is used for type selection
        let colID = tableColumn?.identifier.rawValue ?? ""
        if colID != UIConstants.bookmarkNameColumnID {
            return nil
        }
        
        return bookmarks.getBookmarkAtIndex(row).name
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = editorView.numberOfSelectedRows
        
        btnDelete.enableIf(selRows > 0)
        [btnPlay, btnRename].forEach({$0.enableIf(selRows == 1)})
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let bookmark = bookmarks.getBookmarkAtIndex(row)
        
        switch tableColumn!.identifier.rawValue {
            
        case UIConstants.bookmarkNameColumnID:
            
            return createTextCell(tableView, tableColumn!, row, bookmark.name, true)
            
        case UIConstants.bookmarkTrackColumnID:
            
            return createTextCell(tableView, tableColumn!, row, bookmark.file.path, false)
            
        case UIConstants.bookmarkStartPositionColumnID:
            
            let formattedPosition = ValueFormatter.formatSecondsToHMS(bookmark.startPosition)
            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
            
        case UIConstants.bookmarkEndPositionColumnID:
            
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
        
        if let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView {
            
            cell.isSelectedFunction = {
                
                (row: Int) -> Bool in
                
                return self.editorView.selectedRowIndexes.contains(row)
            }
            
            cell.textField?.stringValue = text
            cell.textField?.textColor = Colors.playlistTextColor
            cell.row = row
            
            // Set tool tip on name/track only if text wider than column width
            let font = cell.textField!.font!
            if StringUtils.numberOfLines(text, font, column.width) > 1 {
                cell.toolTip = text
            }
            
            // Name column is editable
            if editable {
                cell.textField?.delegate = self
            }
            
            return cell
        }
        
        return nil
    }
    
    func tableViewColumnDidResize(_ notification: Notification) {
     
        // Update tool tips as some may no longer be needed or some new ones may be needed
        
        if let column = notification.userInfo?["NSTableColumn"] as? NSTableColumn {
        
            let count = bookmarks.count
            if count > 0 {
                
                for index in 0..<count {
                    
                    let cell = tableView(editorView, viewFor: column, row: index) as! NSTableCellView
                    
                    let text = cell.textField!.stringValue
                    let font = cell.textField!.font!
                    
                    if StringUtils.numberOfLines(text, font, column.width) > 1 {
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
        if (StringUtils.isStringEmpty(newBookmarkName)) {
            editedTextField.stringValue = bookmark.name
            
        } else {
            
            // Update the bookmark name
            bookmarks.renameBookmarkAtIndex(rowIndex, newBookmarkName)
        }
        
        // Update the tool tip

        let font = editedTextField.font!
        let nameColumn = editorView.tableColumns[0]
        
        if StringUtils.numberOfLines(newBookmarkName, font, nameColumn.width) > 1 {
            cell.toolTip = newBookmarkName
        } else {
            cell.toolTip = nil
        }
    }
}
