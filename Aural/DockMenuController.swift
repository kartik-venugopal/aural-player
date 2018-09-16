import Cocoa

/*
    Provides actions for the dock menu. These are a handful of simple essential functions that would typically be performed by a user running the app in the background.
 
    NOTE:
 
        - No actions are directly handled by this class. Action messages are published to other app components that are responsible for these functions.
 
        - Since the dock menu runs outside the Aural Player process, it does not respond to menu delegate callbacks. For this reason, it needs to listen for model updates and be updated eagerly. It cannot be updated lazily, just in time, as the menu is about to open.
 
 */
class DockMenuController: NSObject, AsyncMessageSubscriber {
    
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
    
    // Delegate that retrieves current playback info (e.g. repeat/shuffle modes)
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Delegate that performs CRUD on the history model
    private let history: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    // Stores a mapping of menu items to their corresponding model objects. This is useful when the items are clicked and track/file information for the item is to be retrieved.
    private var historyItemsMap: [NSMenuItem: HistoryItem] = [:]
    
    // One-time setup. When the menu is loaded for the first time, update the menu item states per the current playback modes
    override func awakeFromNib() {
        
        updateRepeatAndShuffleMenuItemStates()
        
        favoritesMenuItem.off()
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.historyUpdated, .addedToFavorites, .removedFromFavorites, .trackPlayed], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        recreateHistoryMenus()
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        
        // Check if there is a track playing (this function cannot be invoked otherwise)
        if let playingTrack = (playbackInfo.getPlayingTrack()?.track) {
            
            // Toggle the menu item
            favoritesMenuItem.toggle()
            
            // Publish an action message to add/remove the item to/from Favorites
            let action: ActionType = favoritesMenuItem.isOn() ? .addFavorite : .removeFavorite
            SyncMessenger.publishActionMessage(FavoritesActionMessage(action, playingTrack))
        }
    }
    
    // Responds to a notification that a track has either been added to, or removed from, the Favorites list, by updating the Favorites menu item
    private func favoritesUpdated(_ message: FavoritesUpdatedAsyncMessage) {
        favoritesMenuItem.onIf(message.messageType == .addedToFavorites)
    }
    
    // When a "Recently played" or "Favorites" menu item is clicked, the item is played
    @IBAction func playSelectedItemAction(_ sender: NSMenuItem) {
        history.playItem(historyItemsMap[sender]!.file, PlaylistViewState.current)
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
        
        let modes = playbackInfo.getRepeatAndShuffleModes()
        
        shuffleOffMenuItem.state = modes.shuffleMode == .off ? 1 : 0
        shuffleOnMenuItem.state = modes.shuffleMode == .on ? 1 : 0
        
        switch modes.repeatMode {
            
        case .off:
            
            repeatOffMenuItem.state = 1
            [repeatOneMenuItem, repeatAllMenuItem].forEach({$0?.state = 0})
            
        case .one:
            
            repeatOneMenuItem.state = 1
            [repeatOffMenuItem, repeatAllMenuItem].forEach({$0?.state = 0})
            
        case .all:
            
            repeatAllMenuItem.state = 1
            [repeatOffMenuItem, repeatOneMenuItem].forEach({$0?.state = 0})
        }
    }
    
    // Re-creates the History menus from the model
    private func recreateHistoryMenus() {
        
        // Clear the menus
        recentlyPlayedMenu.removeAllItems()
        favoritesMenu.removeAllItems()
        historyItemsMap.removeAll()
        
        // Retrieve the model and re-create all sub-menu items
        history.allRecentlyPlayedItems().forEach({recentlyPlayedMenu.addItem(createMenuItem($0))})
        history.allFavorites().forEach({favoritesMenu.addItem(createMenuItem($0))})
    }
    
    // Factory method to create a single menu item, given a model object (HistoryItem)
    private func createMenuItem(_ item: HistoryItem) -> NSMenuItem {
        
        let menuItem = NSMenuItem(title: "  " + item.displayName, action: #selector(self.playSelectedItemAction(_:)), keyEquivalent: "")
        menuItem.target = self
        
        historyItemsMap[menuItem] = item
        
        return menuItem
    }
    
    // Responds to a track being played, by updating the Favorites menu item
    private func trackPlayed(_ message: TrackPlayedAsyncMessage) {
        favoritesMenuItem.onIf(history.hasFavorite(message.track))
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .historyUpdated: recreateHistoryMenus()
            
        case .addedToFavorites, .removedFromFavorites:
            
            favoritesUpdated(message as! FavoritesUpdatedAsyncMessage)
            
        case .trackPlayed:
            
            trackPlayed(message as! TrackPlayedAsyncMessage)
 
        default: return
            
        }
    }
}
