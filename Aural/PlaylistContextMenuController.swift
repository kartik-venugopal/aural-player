import Cocoa

/*
    Controller for the contextual menu displayed when a playlist item is right-clicked
 */
class PlaylistContextMenuController: NSObject, NSMenuDelegate {
    
    // Not used within this class, but exposed to playlist view classes
    @IBOutlet weak var contextMenu: NSMenu!
    
    // Track-specific menu items
    
    @IBOutlet weak var playTrackMenuItem: NSMenuItem!
    @IBOutlet weak var playTrackDelayedMenuItem: NSMenuItem!
    
    @IBOutlet weak var insertGapsMenuItem: NSMenuItem!
    @IBOutlet weak var editGapsMenuItem: NSMenuItem!
    @IBOutlet weak var removeGapsMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    @IBOutlet weak var detailedInfoMenuItem: NSMenuItem!
    
    @IBOutlet weak var removeTrackMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveTrackUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveTrackDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveTrackToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveTrackToBottomMenuItem: NSMenuItem!
    
    @IBOutlet weak var showTrackInFinderMenuItem: NSMenuItem!
    
    private var trackMenuItems: [NSMenuItem] = []
    
    // Group-specific menu items
    
    @IBOutlet weak var playGroupMenuItem: NSMenuItem!
    @IBOutlet weak var playGroupDelayedMenuItem: NSMenuItem!
    
    @IBOutlet weak var removeGroupMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupToBottomMenuItem: NSMenuItem!
    
    private var groupMenuItems: [NSMenuItem] = []
    
    // Popover view that displays detailed info for the selected track
    private lazy var detailedInfoPopover: PopoverViewDelegate = ViewFactory.getDetailedTrackInfoPopover()
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    private lazy var favoritesPopup: FavoritesPopupProtocol = ViewFactory.getFavoritesPopup()
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Delegate that provides access to History information
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.getFavoritesDelegate()
    
    private lazy var gapsEditor: ModalDialogDelegate = WindowFactory.getGapsEditorDialog()
    private lazy var delayedPlaybackEditor: ModalDialogDelegate = WindowFactory.getDelayedPlaybackEditorDialog()
    
    // One-time setup
    override func awakeFromNib() {
        
        // Store all track-specific and group-specific menu items in separate arrays for convenient access when setting up the menu prior to display
        
        trackMenuItems = [playTrackMenuItem, playTrackDelayedMenuItem, favoritesMenuItem, detailedInfoMenuItem, removeTrackMenuItem, moveTrackUpMenuItem, moveTrackDownMenuItem, moveTrackToTopMenuItem, moveTrackToBottomMenuItem, showTrackInFinderMenuItem, insertGapsMenuItem, editGapsMenuItem, removeGapsMenuItem]
        
        groupMenuItems = [playGroupMenuItem, playGroupDelayedMenuItem, removeGroupMenuItem, moveGroupUpMenuItem, moveGroupDownMenuItem, moveGroupToTopMenuItem, moveGroupToBottomMenuItem]
        
        // Set up the two possible captions for the favorites menu item
        
        favoritesMenuItem.off()
    }
    
    // Helper to determine the track represented by the clicked item
    private func getClickedTrack() -> Track {
        
        let clickedItem = PlaylistViewContext.clickedItem
        return clickedItem.type == .index ? playlist.trackAtIndex(clickedItem.index!)!.track : clickedItem.track!
    }
    
    // Sets up the menu items that need to be displayed, depending on what type of playlist item was clicked, and the current state of that item
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let clickedItem = PlaylistViewContext.clickedItem
        
        switch clickedItem.type {
            
        case .index, .track:
            
            // Show all track-specific menu items, hide group-specific ones
            trackMenuItems.forEach({$0.show()})
            groupMenuItems.forEach({$0.hide()})
            
            // Update the state of the favorites menu item (based on if the clicked track is already in the favorites list or not)
            let track = getClickedTrack()
            favoritesMenuItem.onIf(favorites.favoriteWithFileExists(track.file))
            
            let gaps = playlist.getGapsAroundTrack(track)
            insertGapsMenuItem.hideIf_elseShow(gaps.hasGaps)
            removeGapsMenuItem.showIf_elseHide(gaps.hasGaps)
            editGapsMenuItem.showIf_elseHide(gaps.hasGaps)
            
        case .group:
            
            // Show all group-specific menu items, hide track-specific ones
            trackMenuItems.forEach({$0.hide()})
            groupMenuItems.forEach({$0.show()})
        }
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    @IBAction func playSelectedItemAfterDelayAction(_ sender: NSMenuItem) {
        
        let delay = sender.tag
        
        if delay == 0 {
            
            // Custom delay ... show dialog
            _ = delayedPlaybackEditor.showDialog()
            
        } else {
            
            SyncMessenger.publishActionMessage(DelayedPlaybackActionMessage(Double(delay), PlaylistViewState.current))
        }
    }
    
    @IBAction func insertGapsAction(_ sender: NSMenuItem) {
        
        // Sender's tag is gap duration in seconds
        let tag = sender.tag
        
        if tag != 0 {
         
            // Negative tag value indicates .beforeTrack, positive value indicates .afterTrack
            let gapPosn: PlaybackGapPosition = tag < 0 ? .beforeTrack: .afterTrack
            let gap = PlaybackGap(Double(abs(tag)), gapPosn)
            
            let gapBefore = gapPosn == .beforeTrack ? gap : nil
            let gapAfter = gapPosn == .afterTrack ? gap : nil
            
            SyncMessenger.publishActionMessage(InsertPlaybackGapsActionMessage(gapBefore, gapAfter, PlaylistViewState.current))
            
        } else {
            
            // Custom gap dialog
            gapsEditor.setDataForKey("gaps", nil)
            
            _ = gapsEditor.showDialog()
        }
    }
    
    @IBAction func editGapsAction(_ sender: NSMenuItem) {
        
        // Custom gap dialog
        let track = getClickedTrack()
        let gaps = playlist.getGapsAroundTrack(track)
        
        gapsEditor.setDataForKey("gaps", gaps)
        
        _ = gapsEditor.showDialog()
    }
    
    @IBAction func removeGapsAction(_ sender: NSMenuItem) {
        SyncMessenger.publishActionMessage(RemovePlaybackGapsActionMessage(PlaylistViewState.current))
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        
        let track = getClickedTrack()
        let rowView = getPlaylistSelectedRowView()
        
        if favoritesMenuItem.isOn() {
        
            // Remove from Favorites list and display notification
            favorites.deleteFavoriteWithFile(track.file)
            favoritesPopup.showRemovedMessage(rowView, NSRectEdge.maxX)
            
        } else {
            
            // Add to Favorites list and display notification
            _ = favorites.addFavorite(track)
            favoritesPopup.showAddedMessage(rowView, NSRectEdge.maxX)
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowState.mainWindow.orderFront(self)
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let track = getClickedTrack()
        track.loadDetailedInfo()
        
        let rowView = getPlaylistSelectedRowView()
        
        detailedInfoPopover.show(track, rowView, NSRectEdge.maxY)
        WindowState.mainWindow.makeKeyAndOrderFront(self)
    }
    
    // Helper to obtain the view for the selected playlist row (used to position popovers)
    private func getPlaylistSelectedRowView() -> NSView {
        
        let playlistView = PlaylistViewContext.clickedView
        return playlistView.rowView(atRow: playlistView.selectedRow, makeIfNecessary: false)!
    }
 
    // Removes the selected playlist item from the playlist
    @IBAction func removeSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemUpAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemToTopAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksToTop, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves the selected playlist item down one row in the playlist
    @IBAction func moveItemDownAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemToBottomAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksToBottom, PlaylistViewState.current))
        sequenceChanged()
    }
    
    @IBAction func showTrackInFinderAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showTrackInFinder, PlaylistViewState.current))
    }
    
    // Publishes a notification that the playback sequence may have changed, so that interested UI observers may update their views if necessary
    private func sequenceChanged() {
        if (playbackInfo.playingTrack != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
    }
}
