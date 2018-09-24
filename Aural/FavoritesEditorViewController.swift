import Cocoa

class FavoritesEditorViewController: NSViewController, NSTableViewDataSource,  NSTableViewDelegate {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var editorView: NSTableView!
    
    @IBOutlet weak var btnDelete: NSButton!
    @IBOutlet weak var btnPlay: NSButton!
    
    // Delegate that relays accessor operations to the bookmarks model
    private let favorites: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    override var nibName: String? {return "FavoritesEditor"}
    
    override func viewDidAppear() {
        
        editorView.reloadData()
        editorView.deselectAll(self)
        
        [btnDelete, btnPlay].forEach({$0.isEnabled = false})
    }
    
    @IBAction func deleteSelectedFavoritesAction(_ sender: AnyObject) {
        
        // Descending order
        let sortedSelection = editorView.selectedRowIndexes.sorted(by: {x, y -> Bool in x > y})
        let allFavs = favorites.allFavorites()
        
        sortedSelection.forEach({
        
            favorites.removeFavorite(allFavs[$0].file)
        })
        
        editorView.reloadData()
        editorView.deselectAll(self)
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        
        let selRows: Int = editorView.selectedRowIndexes.count
        
        btnDelete.isEnabled = selRows > 0
        btnPlay.isEnabled = selRows == 1
    }
    
    @IBAction func playSelectedFavoriteAction(_ sender: AnyObject) {
        
        if editorView.selectedRowIndexes.count == 1 {
            
            let allFavs = favorites.allFavorites()
            let fav = allFavs[editorView.selectedRow]

            favorites.playItem(fav.file, PlaylistViewState.current)
        }
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        
        WindowState.showingPopover = false
        UIUtils.dismissModalDialog()
    }
    
    // MARK: View delegate functions
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        return favorites.allFavorites().count
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
        
        let favorite = favorites.allFavorites()[row]
        return createTextCell(tableView, tableColumn!, row, favorite.displayName)     }
    
    // Creates a cell view containing text
    private func createTextCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ text: String) -> EditorTableCellView? {
        
        if let cell = tableView.make(withIdentifier: column.identifier, owner: nil) as? EditorTableCellView {
            
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
