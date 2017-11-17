import Cocoa

class PlaylistContextMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var contextMenu: NSMenu!
    
    @IBOutlet weak var playMenuItem: NSMenuItem!
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    @IBOutlet weak var detailedInfoMenuItem: NSMenuItem!
    
    @IBOutlet weak var removeMenuItem: NSMenuItem!
    @IBOutlet weak var moveUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveDownMenuItem: NSMenuItem!
    
    // TODO: Expose through protocol
    private lazy var favoritesPopup: FavoritesPopupViewController = ViewFactory.getFavoritesPopup()
    
    private lazy var detailedInfoPopover: PopoverViewDelegate = ViewFactory.getDetailedTrackInfoPopover()
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Delegate that provides access to History information
    private let history: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    func menuWillOpen(_ menu: NSMenu) {
        
        favoritesMenuItem.offStateTitle = Strings.favoritesAddCaption_contextMenu
        favoritesMenuItem.onStateTitle = Strings.favoritesRemoveCaption_contextMenu
        
        let clickedItem = PlaylistViewContext.getClickedItem()
        
        switch clickedItem.type {
            
        case .index, .track:
            
            playMenuItem.title = Strings.playThisTrackCaption
            removeMenuItem.title = Strings.removeThisTrackCaption
            moveUpMenuItem.title = Strings.moveThisTrackUpCaption
            moveDownMenuItem.title = Strings.moveThisTrackDownCaption
            
            [favoritesMenuItem, detailedInfoMenuItem].forEach({$0?.isHidden = false})
            
            let track = clickedItem.type == .index ? playlist.trackAtIndex(clickedItem.index!)!.track : clickedItem.track!
            favoritesMenuItem.onIf(history.hasFavorite(track))
            
        case .group:
            
            playMenuItem.title = Strings.playThisGroupCaption
            removeMenuItem.title = Strings.removeThisGroupCaption
            moveUpMenuItem.title = Strings.moveThisGroupUpCaption
            moveDownMenuItem.title = Strings.moveThisGroupDownCaption
            
            [favoritesMenuItem, detailedInfoMenuItem].forEach({$0?.isHidden = true})
        }
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        
        let clickedItem = PlaylistViewContext.getClickedItem()
        let track = clickedItem.type == .index ? playlist.trackAtIndex(clickedItem.index!)!.track : clickedItem.track!
        
        let plView = PlaylistViewContext.clickedView!
        let row = plView.selectedRow
        
        let view = plView.view(atColumn: plView.numberOfColumns - 1, row: row, makeIfNecessary: false)!
        
        // TODO: Need to send out notification (for now playing star button ?) ? Maybe. Maybe HistDelegate already does send it out.
        if favoritesMenuItem.isOn() {
            
            history.removeFavorite(track)
            favoritesPopup.showRemovedMessage(view, NSRectEdge.maxX)
            WindowState.window.makeKeyAndOrderFront(self)
            
        } else {
            
            history.addFavorite(track)
            favoritesPopup.showAddedMessage(view, NSRectEdge.maxX)
            WindowState.window.makeKeyAndOrderFront(self)
        }
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let clickedItem = PlaylistViewContext.getClickedItem()
        let track = clickedItem.type == .index ? playlist.trackAtIndex(clickedItem.index!)!.track : clickedItem.track!
        track.loadDetailedInfo()
        
        let plView = PlaylistViewContext.clickedView!
        let row = plView.selectedRow
        let view = plView.view(atColumn: plView.numberOfColumns - 2, row: row, makeIfNecessary: false)!
        
        detailedInfoPopover.show(track, view, NSRectEdge.maxY)
        WindowState.window.makeKeyAndOrderFront(self)
    }
 
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves any selected playlist items up one row in the playlist
    @IBAction func moveItemsUpAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves any selected playlist items down one row in the playlist
    @IBAction func moveItemsDownAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Publishes a notification that the playback sequence may have changed, so that interested UI observers may update their views if necessary
    private func sequenceChanged() {
        if (playbackInfo.getPlayingTrack() != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
    }
}
