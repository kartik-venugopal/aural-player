import Cocoa

/*
    Window controller for the playlist window.
 */
class PlaylistWindowController: NSWindowController, ActionMessageSubscriber, AsyncMessageSubscriber, MessageSubscriber, NSTabViewDelegate, NSWindowDelegate {
    
    // The different playlist views
    private lazy var tracksView: NSView = ViewFactory.getTracksView()
    private lazy var artistsView: NSView = ViewFactory.getArtistsView()
    private lazy var albumsView: NSView = ViewFactory.getAlbumsView()
    private lazy var genresView: NSView = ViewFactory.getGenresView()
    
    @IBOutlet weak var contextMenu: NSMenu!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    // Fields that display playlist summary info
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the playlist
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    // Search dialog
    private lazy var playlistSearchDialog: ModalDialogDelegate = WindowFactory.getPlaylistSearchDialog()
    
    // Sort dialog
    private lazy var playlistSortDialog: ModalDialogDelegate = WindowFactory.getPlaylistSortDialog()
    
    // For gesture handling
    private var eventMonitor: Any?
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    private lazy var mainWindow: NSWindow = WindowFactory.getMainWindow()
    
    private lazy var effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    
    override var windowNibName: String? {return "Playlist"}

    override func windowDidLoad() {
        
        WindowState.playlistWindow = theWindow
        theWindow.isMovableByWindowBackground = true
        
        setUpTabGroup()
        initSubscriptions()
    }
    
    private func setUpTabGroup() {
        
        tabGroup.addViewsForTabs([tracksView, artistsView, albumsView, genresView])

        // Initialize all the tab views (and select the first one to be shown)
        [1, 2, 3, 0].forEach({tabGroup.selectTabViewItem(at: $0)})
        
        tabGroup.delegate = self
    }
    
    private func initSubscriptions() {
        
        // Set up an input handler to handle scrolling and type selection with key events and gestures
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .swipe], handler: {(event: NSEvent!) -> NSEvent in
            PlaylistInputEventHandler.handle(event)
            return event;
        });
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe([.trackAdded, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded, .startedAddingTracks, .doneAddingTracks], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.removeTrackRequest, .playlistTypeChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.addTracks, .savePlaylist, .clearPlaylist, .search, .sort, .shiftTab, .nextPlaylistView, .previousPlaylistView], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
            eventMonitor = nil
        }
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.unsubscribe([.trackAdded, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded, .startedAddingTracks, .doneAddingTracks], subscriber: self)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.unsubscribe(messageTypes: [.removeTrackRequest, .playlistTypeChangedNotification], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.addTracks, .savePlaylist, .clearPlaylist, .search, .sort, .shiftTab, .nextPlaylistView, .previousPlaylistView], subscriber: self)
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        let dialog = DialogsAndAlerts.openDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            startedAddingTracks()
            playlist.addFiles(dialog.urls)
        }
    }
    
    // When a track add operation starts, the progress spinner needs to be initialized
    private func startedAddingTracks() {
        
        playlistWorkSpinner.doubleValue = 0
        playlistWorkSpinner.isHidden = false
        playlistWorkSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the progress spinner needs to be de-initialized
    private func doneAddingTracks() {
        
        playlistWorkSpinner.stopAnimation(self)
        playlistWorkSpinner.isHidden = true
        
        sequenceChanged()
    }
    
    // When the playback sequence has changed, the UI needs to show the updated info
    private func sequenceChanged() {
        
        if (playbackInfo.getPlayingTrack() != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
    }
    
    // Handles an error when tracks could not be added to the playlist
    private func tracksNotAdded(_ message: TracksNotAddedAsyncMessage) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            _ = UIUtils.showAlert(DialogsAndAlerts.tracksNotAddedAlertWithErrors(message.errors))
        }
    }
    
    // Handles a notification that a single track has been added to the playlist
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        DispatchQueue.main.async {
            self.updatePlaylistSummary(message.progress)
        }
    }
    
    // Handles a notification that a single track has been updated
    private func trackInfoUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        DispatchQueue.main.async {
            
            // Track duration may have changed, affecting the total playlist duration
            self.updatePlaylistSummary()
            
            // If this is the playing track, tell other views that info has been updated
            let playingTrackIndex = self.playbackInfo.getPlayingTrack()?.index
            if (playingTrackIndex == message.trackIndex) {
                SyncMessenger.publishNotification(PlayingTrackInfoUpdatedNotification.instance)
            }
        }
    }
    
    // Handles a request to remove a single track from the playlist
    private func removeTrack(_ request: RemoveTrackRequest) {
        
        let indexedTrack = playlist.indexOfTrack(request.track)
        playlist.removeTracks([indexedTrack!.index])
        
        sequenceChanged()
        updatePlaylistSummary()
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    private func updatePlaylistSummary(_ trackAddProgress: TrackAddedMessageProgress? = nil) {
        
        let summary = playlist.summary(PlaylistViewState.current)
        
        if (PlaylistViewState.current == .tracks) {
            
            let numTracks = summary.size
            let duration = StringUtils.formatSecondsToHMS(summary.totalDuration)
            
            lblTracksSummary.stringValue = String(format: "%d %@", numTracks, numTracks == 1 ? "track" : "tracks")
            lblDurationSummary.stringValue = String(format: "%@", duration)
            
        } else {
            
            let groupType = PlaylistViewState.groupType!
            let numGroups = summary.numGroups
            let numTracks = summary.size
            let duration = StringUtils.formatSecondsToHMS(summary.totalDuration)
            
            lblTracksSummary.stringValue = String(format: "%d %@   %d %@", numGroups, groupType.rawValue + (numGroups == 1 ? "" : "s"), numTracks, numTracks == 1 ? "track" : "tracks", duration)
            lblDurationSummary.stringValue = String(format: "%@", duration)
        }
        
        // Update spinner with current progress, if tracks are being added
        if (trackAddProgress != nil) {
            playlistWorkSpinner.doubleValue = trackAddProgress!.percentage
        }
    }
    
    // Removes selected items from the current playlist view. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
        
        sequenceChanged()
        updatePlaylistSummary()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: AnyObject) {
        
        // Make sure there is at least one track to save
        if (playlist.size() > 0) {
            
            let dialog = DialogsAndAlerts.savePlaylistDialog
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSModalResponseOK) {
                playlist.savePlaylist(dialog.url!)
            }
        }
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        playlist.clear()
        
        // Tell all playlist views to refresh themselves
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
        
        updatePlaylistSummary()
    }
    
    // Moves any selected playlist items up one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves any selected playlist items down one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Shows the currently playing track, within the current playlist view. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    func showPlayingTrack() {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    // Cycles between playlist tab group tabs
    private func shiftTab() {
        nextPlaylistView()
    }
    
    private func nextPlaylistView() {
        PlaylistViewState.current == .genres ? tabGroup.selectTabViewItem(at: 0) : tabGroup.selectNextTabViewItem(self)
    }
    
    private func previousPlaylistView() {
        PlaylistViewState.current == .tracks ? tabGroup.selectTabViewItem(at: 3) : tabGroup.selectPreviousTabViewItem(self)
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func searchAction(_ sender: AnyObject) {
        playlistSearchDialog.showDialog()
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func sortAction(_ sender: AnyObject) {
        playlistSortDialog.showDialog()
    }
    
    // MARK: Playlist window actions
    
    // Docks the playlist window to the left of the main window
    @IBAction func dockLeftAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockLeft, nil))
    }
    
    // Docks the playlist window below the main window
    @IBAction func dockBottomAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockBottom, nil))
    }
    
    // Docks the playlist window to the right of the main window
    @IBAction func dockRightAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.dockRight, nil))
    }
    
    // Maximizes the playlist window, both horizontally and vertically
    @IBAction func maximizeAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximize, nil))
    }
    
    // Maximizes the playlist window vertically
    @IBAction func maximizeVerticalAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximizeVertical, nil))
    }
    
    // Maximizes the playlist window horizontally
    @IBAction func maximizeHorizontalAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.maximizeHorizontal, nil))
    }
    
    // Updates the summary in response to a change in the tab group selected tab
    private func playlistTypeChanged(_ notification: PlaylistTypeChangedNotification) {
        updatePlaylistSummary()
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .trackInfoUpdated:
            
            trackInfoUpdated(message as! TrackUpdatedAsyncMessage)
            
        case .tracksRemoved:
            
            updatePlaylistSummary()
            
        case .tracksNotAdded:
            
            tracksNotAdded(message as! TracksNotAddedAsyncMessage)
            
        case .startedAddingTracks:
            
            startedAddingTracks()
            
        case .doneAddingTracks:
            
            doneAddingTracks()
            
        default: return
            
        }
    }
    
    func consumeNotification(_ message: NotificationMessage) {
        
        switch message.messageType {
        
        case .playlistTypeChangedNotification:
        
            playlistTypeChanged(message as! PlaylistTypeChangedNotification)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .removeTrackRequest:
            
            removeTrack(request as! RemoveTrackRequest)
            
        default: break
            
        }
        
        // This class does not return any meaningful responses
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .addTracks: addTracksAction(self)
            
        case .savePlaylist: savePlaylistAction(self)
            
        case .clearPlaylist: clearPlaylistAction(self)
            
        case .search: searchAction(self)
            
        case .sort: sortAction(self)
            
        case .shiftTab: shiftTab()
            
        case .nextPlaylistView: nextPlaylistView()
            
        case .previousPlaylistView: previousPlaylistView()
            
        default: return
            
        }
    }
    
    // MARK - Window delegate functions
    
    func windowDidMove(_ notification: Notification) {
        
        let snapped = UIUtils.checkForSnap(theWindow, mainWindow)
        
        if !snapped {
            _ = UIUtils.checkForSnap(theWindow, effectsWindow)
        }
    }
}

// Convenient accessor for information about the current playlist view
class PlaylistViewState {
    
    // The current playlist view type displayed within the playlist tab group
    static var current: PlaylistType = .tracks
    
    // The current playlist view displayed within the playlist tab group
    static var currentView: NSTableView!
    
    // The group type corresponding to the current playlist view type
    static var groupType: GroupType? {
        
        switch current {
            
        case .albums: return GroupType.album
            
        case .artists: return GroupType.artist
            
        case .genres: return GroupType.genre
            
        // Group type is not applicable to playlist type .tracks
        default: return nil
            
        }
    }
}
