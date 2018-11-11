import Cocoa

class FavoritesMenuController: NSObject, NSMenuDelegate {
    
    // Menu that displays tracks marked "favorites". Clicking on any of these items will result in the track being  played.
    @IBOutlet weak var favoritesMenu: NSMenu!
    
    @IBOutlet weak var addRemoveFavoritesMenuItem: ToggleMenuItem!
    @IBOutlet weak var manageFavoritesMenuItem: NSMenuItem!    

    // Delegate that performs CRUD on the favorites model
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.getFavoritesDelegate()
    
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.getEditorWindowController()
    
    // One-time setup, when the menu loads
    override func awakeFromNib() {
        addRemoveFavoritesMenuItem.off()
    }
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Recreate the custom layout items
        let itemCount = favoritesMenu.items.count
        
        let favsCount = itemCount - 3  // 1 separator, 2 static items
        
        if favsCount > 0 {
            
            let lastIndex = 2 + favsCount
            
            // Need to traverse in descending order because items are going to be removed
            for index in (3...lastIndex).reversed() {
                favoritesMenu.removeItem(at: index)
            }
        }
        
        // Recreate the menu
        favorites.getAllFavorites().forEach({favoritesMenu.addItem(createFavoritesMenuItem($0))})
        
        if let playingTrackFile = playbackInfo.playingTrack?.track.file {
            addRemoveFavoritesMenuItem.onIf(favorites.favoriteWithFileExists(playingTrackFile))
        } else {
            addRemoveFavoritesMenuItem.off()
        }
        
        // These menu item actions are only available when a track is currently playing/paused
        addRemoveFavoritesMenuItem.enableIf(playbackInfo.state.playingOrPaused())
        
        // Menu has 3 static items
        manageFavoritesMenuItem.enableIf(favoritesMenu.items.count > 3)
    }
    
    // Factory method to create a single Favorites menu item, given a model object (FavoritesItem)
    private func createFavoritesMenuItem(_ item: Favorite) -> NSMenuItem {
        
        // The action for the menu item will depend on whether it is a playable item
        let action = #selector(self.playSelectedItemAction(_:))
        
        let menuItem = FavoritesMenuItem(title: "  " + item.name, action: action, keyEquivalent: "")
        menuItem.target = self
        
        menuItem.image = item.art
        menuItem.image?.size = Images.historyMenuItemImageSize
        
        menuItem.favorite = item
        
        return menuItem
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        
        // Check if there is a track playing (this function cannot be invoked otherwise)
        if let playingTrack = (playbackInfo.playingTrack?.track) {
            
            // Publish an action message to add/remove the item to/from Favorites
            if favorites.favoriteWithFileExists(playingTrack.file) {
                favorites.deleteFavoriteWithFile(playingTrack.file)
            } else {
                _ = favorites.addFavorite(playingTrack)
            }
        }
    }
    
    // When a "Favorites" menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: FavoritesMenuItem) {
        
//        let fav = sender.favorite!
//        
//        if fav.validateFile() {
        
            favorites.playFavorite(sender.favorite!)
            
//        } else {
//            
//            // Display an error alert
//            
//            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(FileNotFoundError(fav.file), "Remove track from Favorites list"))
//            
//            favorites.deleteFavoriteWithFile(fav.file)
//            
//            // TODO: Offer more options like "Point to the new location of the file". See RecorderViewController for reference.
//        }
    }
    
    // Opens the editor to manage favorites
    @IBAction func manageFavoritesAction(_ sender: Any) {
        editorWindowController.showFavoritesEditor()
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
}

class FavoritesMenuItem: NSMenuItem {
    
    var favorite: Favorite!
}
