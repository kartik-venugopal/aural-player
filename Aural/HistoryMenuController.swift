import Cocoa

/*
    Manages and provides actions for the History menu that displays historical information about the usage of the app.
 */
class HistoryMenuController: NSObject, NSMenuDelegate {

    // The sub-menus that categorize and display historical information
    
    // Sub-menu that displays recently added files/folders. Clicking on any of these items will result in the item being added to the playlist if not already present.
    @IBOutlet weak var recentlyAddedMenu: NSMenu!
    
    // Sub-menu that displays recently played tracks. Clicking on any of these items will result in the track being played.
    @IBOutlet weak var recentlyPlayedMenu: NSMenu!
    
    // Delegate that performs CRUD on the history model
    private let history: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Clear the menus
        recentlyAddedMenu.removeAllItems()
        recentlyPlayedMenu.removeAllItems()
        
        // Retrieve the model and re-create all sub-menu items
        createChronologicalMenu(history.allRecentlyAddedItems(), recentlyAddedMenu)
        createChronologicalMenu(history.allRecentlyPlayedItems(), recentlyPlayedMenu)
        
        // Recently Added menu items are only accessible in "regular" mode
        let enable = AppModeManager.mode == .regular
        recentlyAddedMenu.items.forEach({$0.isEnabled = enable})
    }
    
    // Populates the given menu with items corresponding to the given historical item info, grouped by timestamp into categories like "Past 24 hours", "Past 7 days", etc.
    private func createChronologicalMenu(_ items: [HistoryItem], _ menu: NSMenu) {
        
        // Keeps track of which time categories have already been created
        var timeCategories = Set<TimeElapsed>()
        
        items.forEach({
            
            let menuItem = createHistoryMenuItem($0)
            
            // Figure out how old this item is
            let timeElapsed = DateUtils.timeElapsedSinceDate($0.time)
            
            // If this category doesn't already exist, create it
            if !timeCategories.contains(timeElapsed) {
                
                timeCategories.insert(timeElapsed)
                
                // Add a descriptor menu item that describes the time category, between 2 separators
                menu.addItem(NSMenuItem.separator())
                menu.addItem(createDescriptor(timeElapsed))
                menu.addItem(NSMenuItem.separator())
            }
            
            // Add the history menu item to the menu
            menu.addItem(menuItem)
        })
    }
    
    // Creates a menu item that describes a time category like "Past hour". The item will have no action.
    private func createDescriptor(_ timeElapsed: TimeElapsed) -> NSMenuItem {
        return NSMenuItem(title: timeElapsed.rawValue, action: nil, keyEquivalent: "")
    }
    
    // Factory method to create a single history menu item, given a model object (HistoryItem)
    private func createHistoryMenuItem(_ item: HistoryItem) -> NSMenuItem {
        
        // The action for the menu item will depend on whether it is a playable item
        let action = item is PlayableHistoryItem ? #selector(self.playSelectedItemAction(_:)) : #selector(self.addSelectedItemAction(_:))
        
        let menuItem = HistoryMenuItem(title: "  " + item.displayName, action: action, keyEquivalent: "")
        menuItem.target = self
        
        menuItem.image = item.art
        menuItem.image?.size = Images.historyMenuItemImageSize
        
        menuItem.historyItem = item
        
        return menuItem
    }
    
    // When a "Recently added" menu item is clicked, the item is added to the playlist
    @IBAction fileprivate func addSelectedItemAction(_ sender: HistoryMenuItem) {
        history.addItem(sender.historyItem.file)
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: HistoryMenuItem) {
        
//        let item = sender.historyItem!
//        
//        if item.validateFile() {
        
            history.playItem(sender.historyItem!.file, PlaylistViewState.current)
            
//        } else {
//            
//            // Display an error alert
//            
//            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(FileNotFoundError(item.file), "Ok"))
//            
//            // TODO: Remove from Recently Played list (add function to HistoryDelegate)
//            
//            // TODO: Offer more options like "Point to the new location of the file". See RecorderViewController for reference.
//        }
    }
}

// A menu item that stores an associated history item (used when executing the menu item action)
class HistoryMenuItem: NSMenuItem {
    
    var historyItem: HistoryItem!
}
