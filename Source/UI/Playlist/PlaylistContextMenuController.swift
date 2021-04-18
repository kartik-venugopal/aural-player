import Cocoa

/*
    Controller for the contextual menu displayed when a playlist item is right-clicked
 */
class PlaylistContextMenuController: NSObject, NSMenuDelegate {
    
    // Not used within this class, but exposed to playlist view classes
    @IBOutlet weak var contextMenu: NSMenu!
    
    // Track-specific menu items
    
    @IBOutlet weak var playTrackMenuItem: NSMenuItem!
    
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    @IBOutlet weak var detailedInfoMenuItem: NSMenuItem!
    
    @IBOutlet weak var removeTrackMenuItem: NSMenuItem!
    
    @IBOutlet weak var moveTrackUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveTrackDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveTrackToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveTrackToBottomMenuItem: NSMenuItem!
    
    @IBOutlet weak var showTrackInFinderMenuItem: NSMenuItem!
    
    @IBOutlet weak var viewChaptersMenuItem: NSMenuItem!
    
    private var trackMenuItems: [NSMenuItem] = []
    
    // Group-specific menu items
    
    @IBOutlet weak var playGroupMenuItem: NSMenuItem!
    
    @IBOutlet weak var removeGroupMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupUpMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupDownMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupToTopMenuItem: NSMenuItem!
    @IBOutlet weak var moveGroupToBottomMenuItem: NSMenuItem!
    
    private var groupMenuItems: [NSMenuItem] = []
    
    // Popover view that displays detailed info for the selected track
    private lazy var detailedInfoPopover: PopoverViewDelegate = ViewFactory.detailedTrackInfoPopover
    
    // Popup view that displays a brief notification when a selected track is added/removed to/from the Favorites list
    private lazy var infoPopup: InfoPopupProtocol = ViewFactory.infoPopup
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    // Delegate that provides access to History information
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.favoritesDelegate
    
    private lazy var trackReader: TrackReader = ObjectGraph.trackReader
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    // One-time setup
    override func awakeFromNib() {
        
        // Store all track-specific and group-specific menu items in separate arrays for convenient access when setting up the menu prior to display
        
        trackMenuItems = [playTrackMenuItem, favoritesMenuItem, detailedInfoMenuItem, removeTrackMenuItem, moveTrackUpMenuItem, moveTrackDownMenuItem, moveTrackToTopMenuItem, moveTrackToBottomMenuItem, showTrackInFinderMenuItem,  viewChaptersMenuItem]
        
        groupMenuItems = [playGroupMenuItem, removeGroupMenuItem, moveGroupUpMenuItem, moveGroupDownMenuItem, moveGroupToTopMenuItem, moveGroupToBottomMenuItem]
        
        // Set up the two possible captions for the favorites menu item
        
        favoritesMenuItem.off()
    }
    
    // Helper to determine the track represented by the clicked item
    private var clickedTrack: Track? {
        
        guard let clickedItem = PlaylistViewState.clickedItem else {return nil}
        
        if clickedItem.type == .index, let index = clickedItem.index {
            return playlist.trackAtIndex(index)
        }
        
        return clickedItem.track
    }
    
    // Sets up the menu items that need to be displayed, depending on what type of playlist item was clicked, and the current state of that item
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        guard let clickedItem = PlaylistViewState.clickedItem else {return}
        
        switch clickedItem.type {
            
        case .index, .track:
            
            // Show all track-specific menu items, hide group-specific ones
            trackMenuItems.forEach({$0.show()})
            groupMenuItems.forEach({$0.hide()})
            
            guard let theClickedTrack = clickedTrack else {return}
            
            // Update the state of the favorites menu item (based on if the clicked track is already in the favorites list or not)
            favoritesMenuItem.onIf(favorites.favoriteWithFileExists(theClickedTrack.file))
            
            let isPlayingTrack: Bool = playbackInfo.playingTrack == theClickedTrack
            viewChaptersMenuItem.showIf_elseHide(isPlayingTrack && theClickedTrack.hasChapters && !WindowManager.instance.isShowingChaptersList)
            
        case .group:
            
            // Show all group-specific menu items, hide track-specific ones
            trackMenuItems.forEach({$0.hide()})
            groupMenuItems.forEach({$0.show()})
        }
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        Messenger.publish(.playlist_playSelectedItem, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        
        guard let theClickedTrack = clickedTrack else {return}
        
        WindowManager.instance.playlistWindow?.makeKeyAndOrderFront(self)
        
        if favoritesMenuItem.isOn {
        
            // Remove from Favorites list and display notification
            favorites.deleteFavoriteWithFile(theClickedTrack.file)
            infoPopup.showMessage("Track removed from Favorites !", playlistSelectedRowView, NSRectEdge.maxX)
            
        } else {
            
            // Add to Favorites list and display notification
            _ = favorites.addFavorite(theClickedTrack)
            infoPopup.showMessage("Track added to Favorites !", playlistSelectedRowView, NSRectEdge.maxX)
        }
        
        // If this isn't done, the app windows are hidden when the popover is displayed
        WindowManager.instance.mainWindow.orderFront(self)
    }
    
    // Shows a popover with detailed information for the track that was right-clicked to bring up this context menu
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        guard let theClickedTrack = clickedTrack else {return}
        
        DetailedTrackInfoViewController.attachedToPlayer = false
        
        trackReader.loadAuxiliaryMetadata(for: theClickedTrack)
        
        WindowManager.instance.playlistWindow?.makeKeyAndOrderFront(self)
        detailedInfoPopover.show(theClickedTrack, playlistSelectedRowView, NSRectEdge.maxY)   // Display the popover below the selected row
        WindowManager.instance.mainWindow.makeKeyAndOrderFront(self)
    }
    
    // Helper to obtain the view for the selected playlist row (used to position popovers)
    // Defaults to the content view of the playlist window
    private var playlistSelectedRowView: NSView {PlaylistViewState.selectedRowView ?? WindowManager.instance.playlistWindow!.contentView!}
 
    // Removes the selected playlist item from the playlist
    @IBAction func removeSelectedItemAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            Messenger.publish(.playlist_removeTracks, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemUpAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            Messenger.publish(.playlist_moveTracksUp, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemToTopAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            Messenger.publish(.playlist_moveTracksToTop, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    // Moves the selected playlist item down one row in the playlist
    @IBAction func moveItemDownAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            Messenger.publish(.playlist_moveTracksDown, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    // Moves the selected playlist item up one row in the playlist
    @IBAction func moveItemToBottomAction(_ sender: Any) {
        
        if !checkIfPlaylistIsBeingModified() {
            Messenger.publish(.playlist_moveTracksToBottom, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        }
    }
    
    @IBAction func showTrackInFinderAction(_ sender: Any) {
        Messenger.publish(.playlist_showTrackInFinder, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func viewChaptersAction(_ sender: Any) {
        Messenger.publish(.playlist_viewChaptersList)
    }
    
    private func checkIfPlaylistIsBeingModified() -> Bool {
        
        let playlistBeingModified = playlist.isBeingModified
        
        if playlistBeingModified {
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
        }
        
        return playlistBeingModified
    }
}
