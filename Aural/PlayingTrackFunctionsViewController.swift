import Cocoa

class PlayingTrackFunctionsViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
    // Button to display more details about the playing track
    @IBOutlet weak var btnMoreInfo: NSButton!
    
    // Button to show the currently playing track within the playlist
    @IBOutlet weak var btnShowPlayingTrackInPlaylist: NSButton!
    
    // Button to add/remove the currently playing track to/from the Favorites list
    @IBOutlet weak var btnFavorite: OnOffImageButton!
    
    // Button to bookmark current track and position
    @IBOutlet weak var btnBookmark: NSButton!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Delegate that provides access to History information
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.getFavoritesDelegate()
    
    // Popover view that displays detailed info for the currently playing track
    private lazy var detailedInfoPopover: PopoverViewDelegate = ViewFactory.getDetailedTrackInfoPopover()
    
    // Popup view that displays a brief notification when the currently playing track is added/removed to/from the Favorites list
    private lazy var favoritesPopup: FavoritesPopupProtocol = ViewFactory.getFavoritesPopup()
    
    override func viewDidLoad() {
        initSubscriptions()
    }
    
    func activate() {
        initSubscriptions()
    }
    
    func deactivate() {
        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        
        AsyncMessenger.subscribe([.addedToFavorites, .removedFromFavorites], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(actionTypes: [.moreInfo], subscriber: self)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.addedToFavorites, .removedFromFavorites], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.moreInfo], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.trackChangedNotification], subscriber: self)
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let playingTrack = player.getPlayingTrack()
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        if (playingTrack != nil) {
            
            // TODO: This should be done through a delegate (TrackDelegate ???)
            playingTrack!.track.loadDetailedInfo()
            detailedInfoPopover.toggle(playingTrack!.track, btnMoreInfo, NSRectEdge.maxX)
        }
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    // Adds/removes the currently playing track to/from the "Favorites" list
    @IBAction func favoriteAction(_ sender: Any) {
        
        // Toggle the button state
        btnFavorite.toggle()
        
        // Assume there is a track playing (this function cannot be invoked otherwise)
        let playingTrack = (player.getPlayingTrack()?.track)!
        
        // Publish an action message to add/remove the item to/from Favorites
        if btnFavorite.isOn() {
            _ = favorites.addFavorite(playingTrack)
        } else {
            favorites.deleteFavoriteWithFile(playingTrack.file)
        }
    }
    
    // Adds/removes the currently playing track to/from the "Favorites" list
    @IBAction func bookmarkAction(_ sender: Any) {
        
        // Publish an action message to add/remove the item to/from Favorites
        SyncMessenger.publishActionMessage(BookmarkActionMessage.instance)
    }
    
    // Responds to a notification that a track has been added to / removed from the Favorites list, by updating the UI to reflect the new state
    private func favoritesUpdated(_ message: FavoritesUpdatedAsyncMessage) {
        
        if let playingTrack = player.getPlayingTrack()?.track {
            
            // Do this only if the track in the message is the playing track
            if message.file.path == playingTrack.file.path {
                
                if (message.messageType == .addedToFavorites) {
                    btnFavorite.on()
                    favoritesPopup.showAddedMessage(btnFavorite, NSRectEdge.maxX)
                } else {
                    btnFavorite.off()
                    favoritesPopup.showRemovedMessage(btnFavorite, NSRectEdge.maxX)
                }
            }
        }
    }
    
    private func newTrackStarted(_ track: Track) {
        
        self.view.isHidden = false
        btnFavorite.onIf(favorites.favoriteWithFileExists(track.file))
    }
    
    private func noTrackPlaying() {
        
        detailedInfoPopover.close()
        self.view.isHidden = true
    }
    
    private func trackChanged(_ notification: TrackChangedNotification) {
        trackChanged(notification.newTrack, notification.errorState)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            newTrackStarted(newTrack!.track)
            
            if (!errorState) {
                
                if (detailedInfoPopover.isShown()) {
                    
                    player.getPlayingTrack()!.track.loadDetailedInfo()
                    detailedInfoPopover.refresh(player.getPlayingTrack()!.track)
                }
                
            }
            
        } else {
            
            // No track playing, clear the info fields
            noTrackPlaying()
        }
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)

        default: return
            
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .addedToFavorites, .removedFromFavorites:
            
            favoritesUpdated(message as! FavoritesUpdatedAsyncMessage)
            
        default: return
            
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .moreInfo: moreInfoAction(self)

         default: return
            
        }
    }
}
