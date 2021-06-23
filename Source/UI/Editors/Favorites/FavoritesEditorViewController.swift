import Cocoa

class FavoritesEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate {
    
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnPlay: NSButton!
    
    // Delegate that relays accessor operations to the bookmarks model
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.favoritesDelegate
    
    override var nibName: String? {"FavoritesEditor"}
    
    override func viewDidLoad() {
        editorView.customizeHeader(heightIncrease: 8, customCellType: AuralTableHeaderCell.self)
    }
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        [btnDelete, btnPlay].forEach {$0.disable()}
    }
    
    @IBAction func deleteSelectedFavoritesAction(_ sender: AnyObject) {
        
        favorites.deleteFavorites(atIndices: editorView.selectedRowIndexes)
        
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
                
            } catch {
                
                if let fnfError = error as? FileNotFoundError {
                    
                    // This needs to be done async. Otherwise, other open dialogs could hang.
                    DispatchQueue.main.async {
                        
                        // Position and display an alert with error info
                        _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove favorite").showModal()
                        self.favorites.deleteFavoriteWithFile(fav.file)
                        self.editorView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.window!.close()
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of favorites rows
    func numberOfRows(in tableView: NSTableView) -> Int {favorites.count}
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateButtonStates()
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {GenericTableRowView()}
    
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
        if text.numberOfLines(font: font, lineWidth: column.width) > 1 {
            cell.toolTip = text
        }
        
        return cell
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let uid_favoriteNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FavoriteName")
}
