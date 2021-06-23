import Cocoa

class FavoritesPresetsManagerViewController: GenericPresetsManagerViewController {
    
    // Delegate that relays accessor operations to the bookmarks model
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.favoritesDelegate
    
    override var nibName: String? {"FavoritesPresetsManager"}
    
    override var numberOfPresets: Int {favorites.count}
    
    override func nameOfPreset(atIndex index: Int) -> String {favorites.getFavoriteAtIndex(index).name}
    
    override func deletePresets(atIndices indices: IndexSet) {
        favorites.deleteFavorites(atIndices: presetsTableView.selectedRowIndexes)
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let fav = favorites.getFavoriteAtIndex(index)
        
        do {
            
            try favorites.playFavorite(fav)
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove favorite").showModal()
                    self.favorites.deleteFavoriteWithFile(fav.file)
                    self.presetsTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: View delegate functions
    
    // Returns a view for a single column
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn else {return nil}
        
        let colID = column.identifier
        let favorite = favorites.getFavoriteAtIndex(row)
        
        return createTextCell(tableView, column, row, colID == .uid_favoriteNameColumn ? favorite.name : favorite.file.path, false)
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let uid_favoriteNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FavoriteName")
}
