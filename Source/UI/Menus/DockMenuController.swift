import Cocoa

/*
    Provides actions for the dock menu. These are a handful of simple essential functions that would typically be performed by a user running the app in the background.
 
    NOTE:
 
        - No actions are directly handled by this class. Action messages are published to other app components that are responsible for these functions.
 
        - Since the dock menu runs outside the Aural Player process, it does not respond to menu delegate callbacks. For this reason, it needs to listen for model updates and be updated eagerly. It cannot be updated lazily, just in time, as the menu is about to open.
 */
class DockMenuController: NSObject, MessageSubscriber, AsyncMessageSubscriber {
    
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
        
        updateRepeatAndShuffleMenuItemStates()
        
        favoritesMenuItem.off()
        
        Messenger.subscribeAsync(self, .trackAddedToFavorites, self.trackAddedToFavorites(_:), queue: DispatchQueue.main)
        Messenger.subscribeAsync(self, .trackRemovedFromFavorites, self.trackRemovedFromFavorites(_:), queue: DispatchQueue.main)
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.historyUpdated, .trackTransition], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        recreateHistoryMenus()
        
        // Fav menu
        favorites.allFavorites.forEach({
            
            let item = FavoritesMenuItem(title: $0.name, action: #selector(self.playSelectedFavoriteAction(_:)), keyEquivalent: "")
            item.target = self
            item.favorite = $0
            favoritesMenu.addItem(item)
        })
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        
        // Check if there is a track playing (this function cannot be invoked otherwise)
        if let playingTrack = playbackInfo.currentTrack {
            
            // Toggle the menu item
            favoritesMenuItem.toggle()
            
            // Add/remove the item to/from Favorites
            favoritesMenuItem.isOn ? _ = favorites.addFavorite(playingTrack) : favorites.deleteFavoriteWithFile(playingTrack.file)
        }
    }
    
    // Responds to a notification that a track has been added to the Favorites list, by updating the Favorites menu
    func trackAddedToFavorites(_ notification: FavoritesUpdatedNotification) {
        
        if let fav = favorites.getFavoriteWithFile(notification.trackFile) {
            
            // Add it to the menu
            let item = FavoritesMenuItem(title: fav.name, action: #selector(self.playSelectedFavoriteAction(_:)), keyEquivalent: "")
            item.target = self
            item.favorite = fav
            
            favoritesMenu.addItem(item)
        }
        
        // Update the toggle menu item
        if let plTrack = playbackInfo.currentTrack, plTrack.file.path == notification.trackFile.path {
            favoritesMenuItem.on()
        }
    }
    
    // Responds to a notification that a track has been removed from the Favorites list, by updating the Favorites menu
    func trackRemovedFromFavorites(_ notification: FavoritesUpdatedNotification) {
        
        // Remove it from the menu
        favoritesMenu.items.forEach({
            
            if let favItem = $0 as? FavoritesMenuItem, favItem.favorite.file.path == notification.trackFile.path {
                
                favoritesMenu.removeItem($0)
                return
            }
        })
        
        // Update the toggle menu item
        if let plTrack = playbackInfo.currentTrack, plTrack.file.path == notification.trackFile.path {
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
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.playOrPause))
    }
    
    // Replays the currently playing track from the beginning, if there is one
    @IBAction func replayTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.replayTrack))
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.previousTrack))
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.nextTrack))
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekBackward))
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekForward))
    }
    
    // Sets the repeat mode to "Off"
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatOff))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the repeat mode to "Repeat One"
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatOne))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the repeat mode to "Repeat All"
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatAll))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the shuffle mode to "Off"
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOff))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the shuffle mode to "On"
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOn))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.muteOrUnmute))
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.decreaseVolume))
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.increaseVolume))
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
    
    private func trackTransitioned(_ msg: TrackTransitionAsyncMessage) {
        
        if let trackFile = msg.endTrack?.file {
            
            favoritesMenuItem.enable()
            favoritesMenuItem.onIf(favorites.favoriteWithFileExists(trackFile))
            
        } else {
            
            // No track playing
            favoritesMenuItem.off()
            favoritesMenuItem.disable()
        }
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is HistoryUpdatedAsyncMessage {

            recreateHistoryMenus()
            
        } else if let trackTransitionMsg = message as? TrackTransitionAsyncMessage, trackTransitionMsg.trackChanged {
            
            trackTransitioned(trackTransitionMsg)
        }
    }
}
