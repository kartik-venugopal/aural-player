import Cocoa

/*
    Window controller for the playlist window.
 */
class PlaylistWindowController: NSWindowController, MessageSubscriber, ActionMessageSubscriber, NSTabViewDelegate {
    
    @IBOutlet weak var rootContainerBox: NSBox!
    @IBOutlet weak var playlistContainerBox: NSBox!
    
    @IBOutlet weak var tabButtonsBox: NSBox!
    @IBOutlet weak var btnTracksTab: NSButton!
    @IBOutlet weak var btnArtistsTab: NSButton!
    @IBOutlet weak var btnAlbumsTab: NSButton!
    @IBOutlet weak var btnGenresTab: NSButton!
    
    @IBOutlet weak var controlsBox: NSBox!
    
    @IBOutlet weak var controlButtonsSuperview: NSView!
    @IBOutlet weak var btnClose: TintedImageButton!
    @IBOutlet weak var viewMenuIconItem: TintedIconMenuItem!
    @IBOutlet weak var btnPageUp: TintedImageButton!
    @IBOutlet weak var btnPageDown: TintedImageButton!
    @IBOutlet weak var btnScrollToTop: TintedImageButton!
    @IBOutlet weak var btnScrollToBottom: TintedImageButton!
    
    // The different playlist views
    private lazy var tracksView: NSView = ViewFactory.tracksView
    private lazy var artistsView: NSView = ViewFactory.artistsView
    private lazy var albumsView: NSView = ViewFactory.albumsView
    private lazy var genresView: NSView = ViewFactory.genresView
    
    @IBOutlet weak var contextMenu: NSMenu!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    // Fields that display playlist summary info
    @IBOutlet weak var lblTracksSummary: VALabel!
    
    @IBOutlet weak var lblDurationSummary: VALabel!
    
    // Spinner that shows progress when tracks are being added to the playlist
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    @IBOutlet weak var viewMenuButton: NSPopUpButton!
    
    // Search dialog
    private lazy var playlistSearchDialog: ModalDialogDelegate = WindowFactory.playlistSearchDialog
    
    // Sort dialog
    private lazy var playlistSortDialog: ModalDialogDelegate = WindowFactory.playlistSortDialog
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    // For gesture handling
    private var eventMonitor: Any?
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let viewPreferences: ViewPreferences = ObjectGraph.preferencesDelegate.preferences.viewPreferences
    private let playlistPreferences: PlaylistPreferences = ObjectGraph.preferencesDelegate.preferences.playlistPreferences
    
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    override var windowNibName: String? {return "Playlist"}

    override func windowDidLoad() {
        
        theWindow.isMovableByWindowBackground = true
        theWindow.delegate = WindowManager.windowDelegate
        
        btnClose.tintFunction = {return Colors.viewControlButtonColor}
        
        setUpTabGroup()
        
        changeTextSize()
        applyColorScheme(ColorSchemes.systemScheme)
        
        initSubscriptions()
    }
    
    private func setUpTabGroup() {
        
        tabGroup.addViewsForTabs([tracksView, artistsView, albumsView, genresView])

        // Initialize all the tab views (and select the one preferred by the user)
        [1, 2, 3, 0].forEach({tabGroup.selectTabViewItem(at: $0)})
        
        if (playlistPreferences.viewOnStartup.option == .specific) {
            
            tabGroup.selectTabViewItem(at: playlistPreferences.viewOnStartup.viewIndex)
            
        } else {
            
            // Remember
            tabGroup.selectTabViewItem(at: PlaylistViewState.current.index)
        }
        
        tabGroup.delegate = self
    }
    
    private func initSubscriptions() {
        
        // Set up an input handler to handle scrolling and gestures
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.swipe], handler: {(event: NSEvent) -> NSEvent? in
            
            PlaylistInputEventHandler.handle(event)
            return event
        });
        
        Messenger.subscribeAsync(self, .startedAddingTracks, self.startedAddingTracks, queue: .main)
        Messenger.subscribeAsync(self, .doneAddingTracks, self.doneAddingTracks, queue: .main)
        
        Messenger.subscribeAsync(self, .trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .tracksRemoved, self.tracksRemoved, queue: .main)
        Messenger.subscribeAsync(self, .tracksNotAdded, self.tracksNotAdded(_:), queue: .main)
        
        // Respond only if track duration has changed (affecting the summary)
        Messenger.subscribeAsync(self, .trackInfoUpdated, self.trackInfoUpdated(_:),
                                 filter: {msg in msg.updatedFields.contains(.duration)},
                                 queue: .main)
        
        Messenger.subscribeAsync(self, .trackTransition, self.trackChanged, queue: .main)
        
        Messenger.subscribe(self, .playlistTypeChanged, self.playlistTypeChanged(_:))
        
        SyncMessenger.subscribe(actionTypes: [.addTracks, .savePlaylist, .clearPlaylist, .search, .sort, .nextPlaylistView, .previousPlaylistView, .changePlaylistTextSize, .applyColorScheme, .changeBackgroundColor, .changeViewControlButtonColor, .changeFunctionButtonColor, .changePlaylistSummaryInfoColor, .changeSelectedTabButtonColor, .changeTabButtonTextColor, .changeSelectedTabButtonTextColor, .viewChapters], subscriber: self)
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.togglePlaylist))
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        let dialog = DialogsAndAlerts.openDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSApplication.ModalResponse.OK) {
            playlist.addFiles(dialog.urls)
        }
    }
    
    // When a track add operation starts, the progress spinner needs to be initialized
    func startedAddingTracks() {
        
        playlistWorkSpinner.doubleValue = 0
        playlistWorkSpinner.show()
        playlistWorkSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the progress spinner needs to be de-initialized
    func doneAddingTracks() {
        
        playlistWorkSpinner.stopAnimation(self)
        playlistWorkSpinner.hide()
        
        updatePlaylistSummary()
        
//        sequenceChanged()
    }
    
    // When the playback sequence has changed, the UI needs to show the updated info
//    private func sequenceChanged() {
//
//        if playbackInfo.currentTrack != nil {
//            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
//        }
//    }
    
    // Handles an error when tracks could not be added to the playlist
    func tracksNotAdded(_ notification: TracksNotAddedNotification) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            _ = UIUtils.showAlert(DialogsAndAlerts.tracksNotAddedAlertWithErrors(notification.errors))
        }
    }
    
    // Handles a notification that a single track has been added to the playlist
    func trackAdded(_ notification: TrackAddedNotification) {
        
        DispatchQueue.main.async {
            self.updatePlaylistSummary(notification.addOperationProgress)
        }
    }
    
    func tracksRemoved() {
        updatePlaylistSummary()
    }
    
    // Handles a notification that a single track has been updated
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        // Track duration may have changed, affecting the total playlist duration
        self.updatePlaylistSummary()
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    private func updatePlaylistSummary(_ trackAddProgress: TrackAddOperationProgressNotification? = nil) {
        
        let summary = playlist.summary(PlaylistViewState.current)
        
        let numTracks = summary.size
        let duration = ValueFormatter.formatSecondsToHMS(summary.totalDuration)
        
        lblDurationSummary.stringValue = String(format: "%@", duration)
        
        if (PlaylistViewState.current == .tracks) {
            
            lblTracksSummary.stringValue = String(format: "%d %@", numTracks, numTracks == 1 ? "track" : "tracks")
            
        } else if let groupType = PlaylistViewState.groupType {

            let numGroups = summary.numGroups
            
            lblTracksSummary.stringValue = String(format: "%d %@   %d %@", numGroups, groupType.rawValue + (numGroups == 1 ? "" : "s"), numTracks, numTracks == 1 ? "track" : "tracks", duration)
        }
        
        // Update spinner with current progress, if tracks are being added
        if let progressPercentage = trackAddProgress?.percentage {
            playlistWorkSpinner.doubleValue = progressPercentage
        }
    }
    
    // Removes selected items from the current playlist view. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_removeTracks, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
        
//        sequenceChanged()
        updatePlaylistSummary()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        // Make sure there is at least one track to save
        if (playlist.size > 0) {
            
            let dialog = DialogsAndAlerts.savePlaylistDialog
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSApplication.ModalResponse.OK) {
                playlist.savePlaylist(dialog.url!)
            }
        }
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        playlist.clear()
        
        // Tell all playlist views to refresh themselves
        Messenger.publish(.playlist_refresh, payload: PlaylistViewSelector.allViews)
        
        updatePlaylistSummary()
    }
    
    // Moves any selected playlist items up one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_moveTracksUp, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
    }
    
    // Moves any selected playlist items down one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        Messenger.publish(.playlist_moveTracksDown, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
//        sequenceChanged()
    }
    
    // Shows the currently playing track, within the current playlist view. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    func showPlayingTrack() {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    private func nextPlaylistView() {
        PlaylistViewState.current == .genres ? tabGroup.selectTabViewItem(at: 0) : tabGroup.selectNextTabViewItem(self)
    }
    
    private func previousPlaylistView() {
        PlaylistViewState.current == .tracks ? tabGroup.selectTabViewItem(at: 3) : tabGroup.selectPreviousTabViewItem(self)
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func searchAction(_ sender: AnyObject) {
        _ = playlistSearchDialog.showDialog()
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func sortAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        _ = playlistSortDialog.showDialog()
    }
    
    // MARK: Playlist window actions
    
    // Scrolls the playlist view to the top
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToTop, PlaylistViewState.current))
    }
    
    // Scrolls the playlist view to the bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToBottom, PlaylistViewState.current))
    }
    
    @IBAction func pageUpAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.pageUp, PlaylistViewState.current))
    }
    
    @IBAction func pageDownAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.pageDown, PlaylistViewState.current))
    }
    
    private func changeTextSize() {
        
        lblTracksSummary.font = Fonts.Playlist.summaryFont
        lblDurationSummary.font = Fonts.Playlist.summaryFont
        
        tabGroup.items.forEach({$0.tabButton.redraw()})
        
        viewMenuButton.font = Fonts.Playlist.menuFont
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        changeSummaryInfoColor(scheme.playlist.summaryInfoColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
     
        [playlistContainerBox, tabButtonsBox, controlsBox].forEach({
            $0!.fillColor = color
            $0!.isTransparent = !color.isOpaque
        })
        
        redrawTabButtons()
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        
        [btnClose, viewMenuIconItem].forEach({
            ($0 as? Tintable)?.reTint()
        })
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        
        [btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom].forEach({
            $0?.reTint()
        })
        
        controlButtonsSuperview.subviews.forEach({
            ($0 as? TintedImageButton)?.reTint()
        })
    }
    
    private func changeSummaryInfoColor(_ color: NSColor) {
        
        [lblTracksSummary, lblDurationSummary].forEach({
            $0?.textColor = color
        })
    }
    
    private func redrawTabButtons() {
        [btnTracksTab, btnArtistsTab, btnAlbumsTab, btnGenresTab].forEach({$0?.redraw()})
    }
    
    private func redrawSelectedTabButton() {
        (tabGroup.selectedTabViewItem as? AuralTabViewItem)?.tabButton.redraw()
    }
    
    func trackChanged() {
        
        if playbackInfo.chapterCount > 0 {
            
            // Only show chapters list if preferred by user
            if playlistPreferences.showChaptersList {
                viewChapters()
            }
            
        } else {
            
            // New track has no chapters, or there is no new track
            WindowManager.hideChaptersList()
        }
    }
    
    private func viewChapters() {
        WindowManager.showChaptersList()
    }
    
    // MARK: Message handling
    
    // Updates the summary in response to a change in the tab group selected tab
    func playlistTypeChanged(_ notification: PlaylistTypeChangedNotification) {
        updatePlaylistSummary()
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .addTracks: addTracksAction(self)
            
        case .savePlaylist: savePlaylistAction(self)
            
        case .clearPlaylist: clearPlaylistAction(self)
            
        case .search: searchAction(self)
            
        case .sort: sortAction(self)
            
        case .nextPlaylistView: nextPlaylistView()
            
        case .previousPlaylistView: previousPlaylistView()
            
        case .changePlaylistTextSize:
            
            changeTextSize()
            
        case .applyColorScheme:
            
            if let scheme = (message as? ColorSchemeActionMessage)?.scheme {
                applyColorScheme(scheme)
            }
            
        case .changeBackgroundColor:
            
            if let bkColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeBackgroundColor(bkColor)
            }
            
        case .changeViewControlButtonColor:
            
            if let ctrlColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeViewControlButtonColor(ctrlColor)
            }
            
        case .changeFunctionButtonColor:
            
            if let ctrlColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeFunctionButtonColor(ctrlColor)
            }
            
        case .changePlaylistSummaryInfoColor:
            
            if let summaryColor = (message as? ColorSchemeComponentActionMessage)?.color {
                changeSummaryInfoColor(summaryColor)
            }
            
        case .changeTabButtonTextColor:
            
            redrawTabButtons()
            
        case .changeSelectedTabButtonTextColor, .changeSelectedTabButtonColor:
            
            redrawSelectedTabButton()
            
        case .viewChapters:
            
            viewChapters()
            
        default: return
            
        }
    }
}
