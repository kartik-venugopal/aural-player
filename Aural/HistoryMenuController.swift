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
    private let history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
    
    // Before the menu opens, re-create the menu items from the model
    func menuWillOpen(_ menu: NSMenu) {
        
        print("\nHIST will open ...")
        
        // Clear the menus
        recentlyAddedMenu.removeAllItems()
        recentlyPlayedMenu.removeAllItems()
        
        // Retrieve the model and re-create all sub-menu items
        createChronologicalMenu(history.allRecentlyAddedItems(), recentlyAddedMenu)
        createChronologicalMenu(history.allRecentlyPlayedItems(), recentlyPlayedMenu)
        
        // Recently Added menu items are only accessible in "regular" mode
        recentlyAddedMenu.items.forEach({$0.enableIf(AppModeManager.mode == .regular)})
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
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let art = self.artForFile(item.file)
            
            DispatchQueue.main.async {
                
                art?.size = Images.historyMenuItemImageSize
                menuItem.image = art
            }
        }
        
        menuItem.historyItem = item
        
        return menuItem
    }
    
    private func artForFile(_ _file: URL) -> NSImage? {
        
        // Resolve sym links and aliases
        let resolvedFileInfo = FileSystemUtils.resolveTruePath(_file)
        let file = resolvedFileInfo.resolvedURL
        
        if (resolvedFileInfo.isDirectory) {
            
            // Display name is last path component
            // Art is folder icon
            return Images.imgGroup
            
        } else {
            
            // Single file - playlist or track
            let fileExtension = file.pathExtension.lowercased()
            
            if (AppConstants.SupportedTypes.playlistExtensions.contains(fileExtension)) {
                
                // Playlist
                // Display name is last path component
                // Art is playlist icon
                return Images.imgHistory_playlist_padded
                
            } else if (AppConstants.SupportedTypes.allAudioExtensions.contains(fileExtension)) {
                
                if let img = MetadataUtils.artForFile(file), let imgCopy = img.copy() as? NSImage {
                    return imgCopy
                } else {
                    return Images.imgPlayedTrack
                }
            }
        }
        
        return Images.imgPlayedTrack
    }
    
    // When a "Recently added" menu item is clicked, the item is added to the playlist
    @IBAction fileprivate func addSelectedItemAction(_ sender: HistoryMenuItem) {
        
        if let item = sender.historyItem as? AddedItem {
            
            do {
                
                try history.addItem(item.file)
                
            } catch let error {
                
                if let fnfError = error as? FileNotFoundError {
                    
                    // This needs to be done async. Otherwise, other open dialogs could hang.
                    DispatchQueue.main.async {
                        
                        // Position and display an alert with error info
                        _ = UIUtils.showAlert(DialogsAndAlerts.historyItemNotAddedAlertWithError(fnfError, "Remove item from history"))
                        self.history.deleteItem(item)
                    }
                }
            }
        }
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: HistoryMenuItem) {
        
        if let item = sender.historyItem as? PlayedItem {
            
            do {
                
                try history.playItem(item.file, PlaylistViewState.current)
                
            } catch let error {
                
                if let fnfError = error as? FileNotFoundError {
                    
                    // This needs to be done async. Otherwise, other open dialogs could hang.
                    DispatchQueue.main.async {
                        
                        // Position and display an alert with error info
                        _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove item"))
                        self.history.deleteItem(item)
                    }
                }
            }
        }
    }
    
    @IBAction fileprivate func clearHistoryAction(_ sender: NSMenuItem) {
        history.clearAllHistory()
    }
}

// A menu item that stores an associated history item (used when executing the menu item action)
class HistoryMenuItem: NSMenuItem {
    
    var historyItem: HistoryItem!
}
