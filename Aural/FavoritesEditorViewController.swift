import Cocoa

class FavoritesEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate {
    
    @IBOutlet weak var editorView: NSTableView!
    @IBOutlet weak var header: NSTableHeaderView!
    
    // Used to adjust the header height
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnPlay: NSButton!
    
    // Delegate that relays accessor operations to the bookmarks model
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.getFavoritesDelegate()
    
    override var nibName: String? {return "FavoritesEditor"}
    
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
        
        [btnDelete, btnPlay].forEach({$0.isEnabled = false})
    }
    
    @IBAction func deleteSelectedFavoritesAction(_ sender: AnyObject) {
        
        // Descending order
        let sortedSelection = editorView.selectedRowIndexes.sorted(by: {x, y -> Bool in x > y})
        sortedSelection.forEach({favorites.deleteFavoriteAtIndex($0)})
        
        editorView.reloadData()
        editorView.deselectAll(self)
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = editorView.numberOfSelectedRows
        
        btnDelete.isEnabled = selRows > 0
        btnPlay.isEnabled = selRows == 1
    }
    
    @IBAction func playSelectedFavoriteAction(_ sender: AnyObject) {
        
        if editorView.numberOfSelectedRows == 1 {
            
            let fav = favorites.getFavoriteAtIndex(editorView.selectedRow)
            favorites.playFavorite(fav)
        }
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        
        WindowState.showingPopover = false
        UIUtils.dismissModalDialog()
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return favorites.countFavorites()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonStates()
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return AuralTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let favorite = favorites.getFavoriteAtIndex(row)
        let colID = tableColumn?.identifier.rawValue ?? ""
        
        if colID == UIConstants.favoriteNameColumnID {
            
            // Name
            return createTextCell(tableView, tableColumn!, row, favorite.name)
            
        } else {
            
            // Track (file path)
            return createTextCell(tableView, tableColumn!, row, favorite.file.path)
        }
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
        if let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView {
            
            cell.isSelectedFunction = {
                
                (row: Int) -> Bool in
                
                return self.editorView.selectedRowIndexes.contains(row)
            }
            
            cell.textField?.stringValue = text
            cell.row = row
            
            // TODO: Doesn't update tool tips when columns are resized
            // Set tool tip on name/track only if text wider than column width
            let font = cell.textField!.font!
            if StringUtils.numberOfLines(text, font, column.width) > 1 {
                cell.toolTip = text
            }
            
            return cell
        }
        
        return nil
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSUserInterfaceItemIdentifier(_ input: NSUserInterfaceItemIdentifier) -> String {
	return input.rawValue
}
