import Cocoa

/*
    Manages and provides actions for the History menu that displays historical information about the usage of the app.
 */
class HistoryMenuController: NSObject, NSMenuDelegate, ActionMessageSubscriber {

    // The sub-menus that categorize and display historical information
    
    // Sub-menu that displays recently added files/folders. Clicking on any of these items will result in the item being added to the playlist if not already present.
    @IBOutlet weak var recentlyAddedMenu: NSMenu!
    
    // Sub-menu that displays recently played tracks. Clicking on any of these items will result in the track being played.
    @IBOutlet weak var recentlyPlayedMenu: NSMenu!
    
    // Sub-menu that displays tracks marked "favorites". Clicking on any of these items will result in the track being  played.
    @IBOutlet weak var favoritesMenu: NSMenu!
    
    // Delegate that performs CRUD on the history model
    private let history: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    // Stores a mapping of menu items to their corresponding model objects. This is useful when the items are clicked and track/file information for the item is to be retrieved.
    private var itemsMap: [NSMenuItem: HistoryItem] = [:]
    
    // One-time setup, when the menu loads
    override func awakeFromNib() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.addFavorite, .removeFavorite], subscriber: self)
    }
    
    // Before the menu opens, re-create the menu items from the model
    func menuWillOpen(_ menu: NSMenu) {
        
        // Clear the menus
        recentlyAddedMenu.removeAllItems()
        recentlyPlayedMenu.removeAllItems()
        favoritesMenu.removeAllItems()
        itemsMap.removeAll()
        
        // Retrieve the model and re-create all sub-menu items
        history.allRecentlyAddedItems().forEach({recentlyAddedMenu.addItem(createMenuItem($0))})
        history.allRecentlyPlayedItems().forEach({recentlyPlayedMenu.addItem(createMenuItem($0))})
        history.allFavorites().forEach({favoritesMenu.addItem(createMenuItem($0))})
    }
    
    // Factory method to create a single menu item, given a model object (HistoryItem)
    private func createMenuItem(_ item: HistoryItem) -> NSMenuItem {
        
        // The action for the menu item will depend on whether it is a playable item
        let action = item is PlayableHistoryItem ? #selector(self.playSelectedItemAction(_:)) : #selector(self.addSelectedItemAction(_:))
        
        let menuItem = NSMenuItem(title: "  " + item.displayName, action: action, keyEquivalent: "")
        menuItem.target = self
        
        menuItem.image = item.art
        menuItem.image?.size = Images.historyMenuItemImageSize
        
        itemsMap[menuItem] = item
        
        return menuItem
    }
    
    // When a "Recently added" menu item is clicked, the item is added to the playlist
    @IBAction func addSelectedItemAction(_ sender: NSMenuItem) {
        history.addItem(itemsMap[sender]!.file)
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction func playSelectedItemAction(_ sender: NSMenuItem) {
        history.playItem(itemsMap[sender]!.file, PlaylistViewState.current)
    }
    
    // Adds a track to the "Favorites" list
    private func addFavorite(_ message: FavoritesActionMessage) {
        history.addFavorite(message.track)
    }
    
    // Removes a track from the "Favorites" list
    private func removeFavorite(_ message: FavoritesActionMessage) {
        history.removeFavorite(message.track)
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        let message = message as! FavoritesActionMessage
        
        switch message.actionType {
            
        case .addFavorite:
            
            addFavorite(message)
            
        case .removeFavorite:
            
            removeFavorite(message)
            
        default: return
            
        }
    }
}
