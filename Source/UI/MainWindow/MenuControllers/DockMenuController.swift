import Cocoa

/*
    Provides actions for the dock menu. These are a handful of simple essential functions that would typically be performed by a user running the app in the background.
 
    NOTE:
 
        - No actions are directly handled by this class. Command notifications are published to other app components that are responsible for these functions.
 
        - Since the dock menu runs outside the Aural Player process, it does not respond to menu delegate callbacks. For this reason, it needs to listen for model updates and be updated eagerly. It cannot be updated lazily, just in time, as the menu is about to open.
 */
class DockMenuController: NSObject, NSMenuDelegate, NotificationSubscriber {
    
    // TODO: Add Bookmarks sub-menu under Favorites sub-menu
    
    // Menu items whose states are toggled when they (or others) are clicked
    
    // Playback repeat modes
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    // Playback shuffle modes
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    
    // Favorites menu item (needs to be toggled)
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    
    // Sub-menu that displays recently played tracks. Clicking on any of these items will result in the track being played.
    @IBOutlet weak var recentlyPlayedMenu: NSMenu!
    
    // Sub-menu that displays tracks marked "favorites". Clicking on any of these items will result in the track being  played.
    @IBOutlet weak var favoritesMenu: NSMenu!
    
    // Delegate that retrieves current playback info (e.g. currently playing track)
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Delegate that retrieves current playback sequence info (e.g. repeat/shuffle modes)
    private lazy var sequenceInfo: SequencerInfoDelegateProtocol = ObjectGraph.sequencerInfoDelegate
    
    // Delegate that performs CRUD on the history model
    private let history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.favoritesDelegate
    
    // One-time setup. When the menu is loaded for the first time, update the menu item states per the current playback modes
    override func awakeFromNib() {
        
        favoritesMenuItem.off()
        
        Messenger.subscribeAsync(self, .favoritesList_trackAdded, self.trackAddedToFavorites(_:), queue: .main)
        Messenger.subscribeAsync(self, .favoritesList_trackRemoved, self.trackRemovedFromFavorites(_:), queue: .main)
        Messenger.subscribeAsync(self, .history_updated, self.recreateHistoryMenus, queue: .main)
        
        // Subscribe to notifications
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in msg.trackChanged},
                                 queue: .main)
        
        recreateHistoryMenus()
        
        // Fav menu
        favorites.allFavorites.forEach({
            
            let item = FavoritesMenuItem(title: $0.name, action: #selector(self.playSelectedFavoriteAction(_:)), keyEquivalent: "")
            item.target = self
            item.favorite = $0
            favoritesMenu.addItem(item)
        })
    }
    
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // TODO: Recreate history and favorites menus here ???
        
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        Messenger.publish(.favoritesList_addOrRemove)
    }
    
    // Responds to a notification that a track has been added to the Favorites list, by updating the Favorites menu
    func trackAddedToFavorites(_ trackFile: URL) {
        
        if let fav = favorites.getFavoriteWithFile(trackFile) {
            
            // Add it to the menu
            let item = FavoritesMenuItem(title: fav.name, action: #selector(self.playSelectedFavoriteAction(_:)), keyEquivalent: "")
            item.target = self
            item.favorite = fav
            
            favoritesMenu.addItem(item)
        }
        
        // Update the toggle menu item
        if let plTrack = playbackInfo.currentTrack, plTrack.file.path == trackFile.path {
            favoritesMenuItem.on()
        }
    }
    
    // Responds to a notification that a track has been removed from the Favorites list, by updating the Favorites menu
    func trackRemovedFromFavorites(_ trackFile: URL) {
        
        // Remove it from the menu
        favoritesMenu.items.forEach({
            
            if let favItem = $0 as? FavoritesMenuItem, favItem.favorite.file.path == trackFile.path {
                
                favoritesMenu.removeItem($0)
                return
            }
        })
        
        // Update the toggle menu item
        if let plTrack = playbackInfo.currentTrack, plTrack.file.path == trackFile.path {
            favoritesMenuItem.off()
        }
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction func playSelectedHistoryItemAction(_ sender: HistoryMenuItem) {
        
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
    
    @IBAction func playSelectedFavoriteAction(_ sender: FavoritesMenuItem) {
        
        let fav = sender.favorite!
        
        do {
            
            try favorites.playFavorite(fav)
            
        } catch let error {
            
            if let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove favorite"))
                    self.favorites.deleteFavoriteWithFile(fav.file)
                }
            }
        }
    }
    
    // Pauses or resumes playback
    @IBAction func playOrPauseAction(_ sender: AnyObject) {
        Messenger.publish(.player_playOrPause)
    }
    
    @IBAction func stopAction(_ sender: AnyObject) {
        Messenger.publish(.player_stop)
    }
    
    // Replays the currently playing track from the beginning, if there is one
    @IBAction func replayTrackAction(_ sender: AnyObject) {
        Messenger.publish(.player_replayTrack)
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        Messenger.publish(.player_previousTrack)
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        Messenger.publish(.player_nextTrack)
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        Messenger.publish(.player_seekBackward, payload: UserInputMode.discrete)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        Messenger.publish(.player_seekForward, payload: UserInputMode.discrete)
    }
    
    // Sets the repeat mode to "Off"
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        Messenger.publish(.player_setRepeatMode, payload: RepeatMode.off)
    }
    
    // Sets the repeat mode to "Repeat One"
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        Messenger.publish(.player_setRepeatMode, payload: RepeatMode.one)
    }
    
    // Sets the repeat mode to "Repeat All"
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        Messenger.publish(.player_setRepeatMode, payload: RepeatMode.all)
    }
    
    // Sets the shuffle mode to "Off"
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        Messenger.publish(.player_setShuffleMode, payload: ShuffleMode.off)
    }
    
    // Sets the shuffle mode to "On"
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        Messenger.publish(.player_setShuffleMode, payload: ShuffleMode.on)
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        Messenger.publish(.player_muteOrUnmute)
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        Messenger.publish(.player_decreaseVolume, payload: UserInputMode.discrete)
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        Messenger.publish(.player_increaseVolume, payload: UserInputMode.discrete)
    }
    
    // Updates the menu item states per the current playback modes
    private func updateRepeatAndShuffleMenuItemStates() {
        
        let modes = sequenceInfo.repeatAndShuffleModes
        
        shuffleOffMenuItem.onIf(modes.shuffleMode == .off)
        shuffleOnMenuItem.onIf(modes.shuffleMode == .on)
        
        switch modes.repeatMode {
            
        case .off:
            
            repeatOffMenuItem.on()
            [repeatOneMenuItem, repeatAllMenuItem].forEach({$0?.off()})
            
        case .one:
            
            repeatOneMenuItem.on()
            [repeatOffMenuItem, repeatAllMenuItem].forEach({$0?.off()})
            
        case .all:
            
            repeatAllMenuItem.on()
            [repeatOffMenuItem, repeatOneMenuItem].forEach({$0?.off()})
        }
    }
    
    // Re-creates the History menus from the model
    private func recreateHistoryMenus() {
        
        // Clear the menus
        recentlyPlayedMenu.removeAllItems()
        
        // Retrieve the model and re-create all sub-menu items
        history.allRecentlyPlayedItems().forEach({recentlyPlayedMenu.addItem(createHistoryMenuItem($0))})
    }
    
    // Factory method to create a single menu item, given a model object (HistoryItem)
    private func createHistoryMenuItem(_ item: HistoryItem) -> NSMenuItem {
        
        let menuItem = HistoryMenuItem(title: "  " + item.displayName, action: #selector(self.playSelectedHistoryItemAction(_:)), keyEquivalent: "")
        menuItem.target = self
        menuItem.historyItem = item
        
        return menuItem
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if let trackFile = notification.endTrack?.file {
            
            favoritesMenuItem.enable()
            favoritesMenuItem.onIf(favorites.favoriteWithFileExists(trackFile))
            
        } else {
            
            // No track playing
            favoritesMenuItem.off()
            favoritesMenuItem.disable()
        }
    }
}
