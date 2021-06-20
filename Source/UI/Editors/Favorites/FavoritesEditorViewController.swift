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
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.favoritesDelegate
    
    override var nibName: String? {"FavoritesEditor"}
    
    override func viewDidLoad() {
        
        headerHeight()
        header.wantsLayer = true
        header.layer?.backgroundColor = NSColor.black.cgColor
        
        editorView.tableColumns.forEach {
            
            let col = $0
            let header = AuralTableHeaderCell()
            
            header.stringValue = col.headerCell.stringValue
            header.isBordered = false
            
            col.headerCell = header
        }
    }
    
    private func headerHeight() {

        header.setFrameSize(NSMakeSize(header.frame.size.width, header.frame.size.height + 10))
        clipView.setFrameSize(NSMakeSize(clipView.frame.size.width, clipView.frame.size.height + 10))
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        [btnDelete, btnPlay].forEach {$0.disable()}
    }
    
    @IBAction func deleteSelectedFavoritesAction(_ sender: AnyObject) {
        
        // Descending order
        let sortedSelection = editorView.selectedRowIndexes.sorted(by: Int.descendingIntComparator)
        sortedSelection.forEach {favorites.deleteFavoriteAtIndex($0)}
        
        editorView.reloadData()
        editorView.deselectAll(self)
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = editorView.numberOfSelectedRows
        
        btnDelete.enableIf(selRows > 0)
        btnPlay.enableIf(selRows == 1)
    }
    
    @IBAction func playSelectedFavoriteAction(_ sender: AnyObject) {
        
        if editorView.numberOfSelectedRows == 1 {
            
            let fav = favorites.getFavoriteAtIndex(editorView.selectedRow)
            
            do {
                
                try favorites.playFavorite(fav)
                
            } catch let error {
                
                if let fnfError = error as? FileNotFoundError {
                    
                    // This needs to be done async. Otherwise, other open dialogs could hang.
                    DispatchQueue.main.async {
                        
                        // Position and display an alert with error info
                        _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove favorite"))
                        self.favorites.deleteFavoriteWithFile(fav.file)
                        self.editorView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        UIUtils.dismissDialog(self.view.window!)
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return favorites.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonStates()
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GenericTableRowView()
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        let favorite = favorites.getFavoriteAtIndex(row)
        
        if colID == .uid_favoriteNameColumn {
            
            // Name
            return createTextCell(tableView, tableColumn!, row, favorite.name)
            
        } else {
            
            // Track (file path)
            return createTextCell(tableView, tableColumn!, row, favorite.file.path)
        }
    }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView else {return nil}
        
        cell.isSelectedFunction = {[weak self] (row: Int) -> Bool in
            self?.editorView.selectedRowIndexes.contains(row) ?? false
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
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let uid_favoriteNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FavoriteName")
}
