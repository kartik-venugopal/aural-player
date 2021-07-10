//
//  PlaylistWindowController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Window controller for the playlist window.
 */
class PlaylistWindowController: NSWindowController, NSTabViewDelegate, NotificationSubscriber, Destroyable {
    
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
    
    @IBOutlet weak var btnPageUp: TintedImageButton!
    @IBOutlet weak var btnPageDown: TintedImageButton!
    @IBOutlet weak var btnScrollToTop: TintedImageButton!
    @IBOutlet weak var btnScrollToBottom: TintedImageButton!
    
    // The different playlist views
    private let tracksViewController: TracksPlaylistViewController = TracksPlaylistViewController()
    private let artistsViewController: ArtistsPlaylistViewController = ArtistsPlaylistViewController()
    private let albumsViewController: AlbumsPlaylistViewController = AlbumsPlaylistViewController()
    private let genresViewController: GenresPlaylistViewController = GenresPlaylistViewController()
    
    @IBOutlet weak var contextMenu: NSMenu!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    // Fields that display playlist summary info
    @IBOutlet weak var lblTracksSummary: VALabel!
    @IBOutlet weak var lblDurationSummary: VALabel!
    
    // Spinner that shows progress when tracks are being added to the playlist
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    
    // Search dialog
    private lazy var playlistSearchDialogLoader: LazyWindowLoader<PlaylistSearchWindowController> = LazyWindowLoader()
    
    // Sort dialog
    private lazy var playlistSortDialogLoader: LazyWindowLoader<PlaylistSortWindowController> = LazyWindowLoader()
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    // For gesture handling
    private var eventMonitor: EventMonitor! = EventMonitor()
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let playlistPreferences: PlaylistPreferences = ObjectGraph.preferences.playlistPreferences
    private lazy var gesturesPreferences: GesturesControlsPreferences = ObjectGraph.preferences.controlsPreferences.gestures
    
    private let fontSchemesManager: FontSchemesManager = ObjectGraph.fontSchemesManager
    private let colorSchemesManager: ColorSchemesManager = ObjectGraph.colorSchemesManager
    
    override var windowNibName: String? {"Playlist"}
    
    private var childContainerBoxes: [NSBox] = []
    private var functionButtons: [TintedImageButton] = []
    private var tabButtons: [NSButton] = []

    override func windowDidLoad() {
        
        theWindow.isMovableByWindowBackground = true
        
        btnClose.tintFunction = {return Colors.viewControlButtonColor}
        
        setUpTabGroup()
        
        childContainerBoxes = [playlistContainerBox, tabButtonsBox, controlsBox]
        functionButtons = [btnPageUp, btnPageDown, btnScrollToTop, btnScrollToBottom] + controlButtonsSuperview.subviews.compactMap {$0 as? TintedImageButton}
        tabButtons = [btnTracksTab, btnArtistsTab, btnAlbumsTab, btnGenresTab]

        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
        rootContainerBox.cornerRadius = WindowAppearanceState.cornerRadius
        
        setUpEventHandling()
        initSubscriptions()
    }
    
    // Initialize all the tab views (and select the one preferred by the user)
    private func setUpTabGroup() {
        
        let allViews = [tracksViewController, artistsViewController, albumsViewController, genresViewController].map {$0.view}
        
        tabGroup.addViewsForTabs(allViews)
        [1, 2, 3, 0].forEach({tabGroup.selectTabViewItem(at: $0)})
        
        allViews.forEach {$0.anchorToView($0.superview!)}
        
        if playlistPreferences.viewOnStartup.option == .specific {
            tabGroup.selectTabViewItem(at: playlistPreferences.viewOnStartup.viewIndex)
            
        } else {    // Remember the view from the last app launch
            tabGroup.selectTabViewItem(at: PlaylistViewState.currentView.index)
        }
        
        tabGroup.delegate = self
        
        tracksViewController.contextMenu = self.contextMenu
        [artistsViewController, albumsViewController, genresViewController].forEach {$0.contextMenu = self.contextMenu}
    }
    
    // Registers handlers for keyboard events and trackpad/mouse gestures (NSEvent).
    private func setUpEventHandling() {
        
        eventMonitor.registerHandler(forEventType: .swipe, self.handleSwipe(_:))
        eventMonitor.startMonitoring()
    }
    
    private func initSubscriptions() {
        
        Messenger.subscribeAsync(self, .playlist_startedAddingTracks, self.startedAddingTracks, queue: .main)
        Messenger.subscribeAsync(self, .playlist_doneAddingTracks, self.doneAddingTracks, queue: .main)
        
        Messenger.subscribeAsync(self, .playlist_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .playlist_tracksRemoved, self.tracksRemoved, queue: .main)
        Messenger.subscribeAsync(self, .playlist_tracksNotAdded, self.tracksNotAdded(_:), queue: .main)
        
        // Respond only if track duration has changed (affecting the summary)
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:),
                                 filter: {msg in msg.updatedFields.contains(.duration)},
                                 queue: .main)
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackChanged, queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackChanged, queue: .main)
        
        Messenger.subscribe(self, .playlist_viewChanged, self.playlistTypeChanged)
        
        // MARK: Commands -------------------------------------------------------------------------------------
        
        Messenger.subscribe(self, .playlist_addTracks, self.addTracks)
        Messenger.subscribe(self, .playlist_savePlaylist, self.savePlaylist)
        Messenger.subscribe(self, .playlist_clearPlaylist, self.clearPlaylist)
        
        Messenger.subscribe(self, .playlist_search, self.search)
        Messenger.subscribe(self, .playlist_sort, self.sort)
        
        Messenger.subscribe(self, .playlist_previousView, self.previousView)
        Messenger.subscribe(self, .playlist_nextView, self.nextView)
        
        Messenger.subscribe(self, .playlist_viewChaptersList, self.viewChaptersList)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        Messenger.subscribe(self, .windowAppearance_changeCornerRadius, self.changeWindowCornerRadius(_:))
        
        Messenger.subscribe(self, .changeViewControlButtonColor, self.changeViewControlButtonColor(_:))
        Messenger.subscribe(self, .changeFunctionButtonColor, self.changeFunctionButtonColor(_:))
        
        Messenger.subscribe(self, .changeTabButtonTextColor, self.changeTabButtonTextColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonColor, self.changeSelectedTabButtonColor(_:))
        Messenger.subscribe(self, .changeSelectedTabButtonTextColor, self.changeSelectedTabButtonTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changeSummaryInfoColor, self.changeSummaryInfoColor(_:))
    }
    
    func destroy() {
        
        eventMonitor.stopMonitoring()
        eventMonitor = nil
        
        ([tracksViewController, artistsViewController, albumsViewController, genresViewController] as? [Destroyable])?.forEach {$0.destroy()}
        
        playlistSearchDialogLoader.destroy()
        playlistSortDialogLoader.destroy()
        
        close()
        Messenger.unsubscribeAll(for: self)
        
        AuralPlaylistOutlineView.destroy()
    }
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        Messenger.publish(.windowManager_togglePlaylistWindow)
    }
    
    private func checkIfPlaylistIsBeingModified() -> Bool {
        
        let playlistBeingModified = playlist.isBeingModified
        
        if playlistBeingModified {
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
        }
        
        return playlistBeingModified
    }
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        guard !checkIfPlaylistIsBeingModified() else {return}
        
        let fileOpenDialog = DialogsAndAlerts.openFilesAndFoldersDialog
        
        if fileOpenDialog.runModal() == NSApplication.ModalResponse.OK {
            playlist.addFiles(fileOpenDialog.urls)
        }
    }
    
    private func addTracks() {
        addTracksAction(self)
    }
    
    // When a track add operation starts, the progress spinner needs to be initialized
    func startedAddingTracks() {
        
        progressSpinner.doubleValue = 0
        progressSpinner.show()
        progressSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the progress spinner needs to be de-initialized
    func doneAddingTracks() {
        
        progressSpinner.stopAnimation(self)
        progressSpinner.hide()
        updatePlaylistSummary()
    }
    
    // Handles an error when tracks could not be added to the playlist
    func tracksNotAdded(_ errors: [DisplayableError]) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            _ = DialogsAndAlerts.tracksNotAddedAlert(errors: errors).showModal()
        }
    }
    
    // Handles a notification that a single track has been added to the playlist
    func trackAdded(_ notification: TrackAddedNotification) {
        updatePlaylistSummary(notification.addOperationProgress)
    }
    
    func tracksRemoved() {
        updatePlaylistSummary()
    }
    
    // Track duration may have changed, affecting the total playlist duration (i.e. summary)
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        updatePlaylistSummary()
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    private func updatePlaylistSummary(_ trackAddProgress: TrackAddOperationProgress? = nil) {
        
        let summary = playlist.summary(PlaylistViewState.currentView)
        lblDurationSummary.stringValue = ValueFormatter.formatSecondsToHMS(summary.totalDuration)
        
        let numTracks = summary.size
        
        if PlaylistViewState.currentView == .tracks {
            
            lblTracksSummary.stringValue = String(format: "%d %@",
                                                  numTracks, numTracks == 1 ? "track" : "tracks")
            
        } else if let groupType = PlaylistViewState.groupType {

            let numGroups = summary.numGroups
            
            lblTracksSummary.stringValue = String(format: "%d %@   %d %@",
                                                  numGroups, groupType.rawValue + (numGroups == 1 ? "" : "s"),
                                                  numTracks, numTracks == 1 ? "track" : "tracks")
        }
        
        // Update spinner with current progress, if tracks are being added
        if let progressPercentage = trackAddProgress?.percentage {
            progressSpinner.doubleValue = progressPercentage
        }
    }
    
    // Removes selected items from the current playlist view. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        guard !checkIfPlaylistIsBeingModified() else {return}
        
        Messenger.publish(.playlist_removeTracks, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
        updatePlaylistSummary()
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: AnyObject) {

        // Make sure there is at least one track to save.
        guard playlist.size > 0, !checkIfPlaylistIsBeingModified() else {return}
        
        let saveDialog = DialogsAndAlerts.savePlaylistDialog
        
        if saveDialog.runModal() == NSApplication.ModalResponse.OK,
           let newFileURL = saveDialog.url {
            
            playlist.savePlaylist(newFileURL)
        }
    }
    
    private func savePlaylist() {
        savePlaylistAction(self)
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        guard !checkIfPlaylistIsBeingModified() else {return}
        
        playlist.clear()
        
        // Tell all playlist views to refresh themselves
        Messenger.publish(.playlist_refresh, payload: PlaylistViewSelector.allViews)
        
        updatePlaylistSummary()
    }
    
    private func clearPlaylist() {
        clearPlaylistAction(self)
    }
    
    // Moves any selected playlist items up one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        if !checkIfPlaylistIsBeingModified() {
            Messenger.publish(.playlist_moveTracksUp, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
        }
    }
    
    // Moves any selected playlist items down one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        if !checkIfPlaylistIsBeingModified() {
            Messenger.publish(.playlist_moveTracksDown, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
        }
    }
    
    private func nextView() {
        PlaylistViewState.currentView == .genres ? tabGroup.selectFirstTabViewItem(self) : tabGroup.selectNextTabViewItem(self)
    }
    
    private func previousView() {
        PlaylistViewState.currentView == .tracks ? tabGroup.selectLastTabViewItem(self) : tabGroup.selectPreviousTabViewItem(self)
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func searchAction(_ sender: AnyObject) {
        search()
    }
    
    private func search() {
        _ = playlistSearchDialogLoader.controller.showDialog()
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func sortAction(_ sender: AnyObject) {
        sort()
    }
    
    private func sort() {
        
        if !checkIfPlaylistIsBeingModified() {
            _ = playlistSortDialogLoader.controller.showDialog()
        }
    }
    
    // MARK: Playlist window actions
    
    // Scrolls the playlist view to the top
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_scrollToTop, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
    }
    
    // Scrolls the playlist view to the bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_scrollToBottom, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
    }
    
    @IBAction func pageUpAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_pageUp, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
    }
    
    @IBAction func pageDownAction(_ sender: AnyObject) {
        Messenger.publish(.playlist_pageDown, payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
        changeWindowCornerRadius(WindowAppearanceState.cornerRadius)
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        lblTracksSummary.font = fontSchemesManager.systemScheme.playlist.summaryFont
        lblDurationSummary.font = fontSchemesManager.systemScheme.playlist.summaryFont
        
        redrawTabButtons()
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        changeViewControlButtonColor(scheme.general.viewControlButtonColor)
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        changeSummaryInfoColor(scheme.playlist.summaryInfoColor)
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        rootContainerBox.fillColor = color
     
        for box in childContainerBoxes {
            
            box.fillColor = color
            box.isTransparent = !color.isOpaque
        }
        
        redrawTabButtons()
    }
    
    private func changeViewControlButtonColor(_ color: NSColor) {
        btnClose.reTint()
    }
    
    private func changeFunctionButtonColor(_ color: NSColor) {
        functionButtons.forEach {$0.reTint()}
    }
    
    private func changeSummaryInfoColor(_ color: NSColor) {
        [lblTracksSummary, lblDurationSummary].forEach {$0.textColor = color}
    }
    
    private func redrawTabButtons() {
        tabButtons.forEach {$0.redraw()}
    }
    
    func changeSelectedTabButtonColor(_ color: NSColor) {
        redrawSelectedTabButton()
    }
    
    private func changeTabButtonTextColor(_ color: NSColor) {
        redrawTabButtons()
    }
    
    private func changeSelectedTabButtonTextColor(_ color: NSColor) {
        redrawSelectedTabButton()
    }
    
    private func redrawSelectedTabButton() {
        (tabGroup.selectedTabViewItem as? AuralTabViewItem)?.tabButton.redraw()
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox.cornerRadius = radius
    }
    
    func trackChanged() {
        
        // New track has no chapters, or there is no new track
        if playbackInfo.chapterCount == 0 {
            WindowManager.instance.hideChaptersList()
            
        } // Only show chapters list if preferred by user
        else if playlistPreferences.showChaptersList {
            viewChaptersList()
        }
    }
    
    private func viewChaptersList() {
        WindowManager.instance.showChaptersList()
    }
    
    // MARK: Message handling
    
    // Updates the summary in response to a change in the tab group selected tab
    func playlistTypeChanged() {
        updatePlaylistSummary()
    }
    
    // MARK: Event handling (keyboard and gestures) ---------------------------------------
    
    // Handles a single swipe event.
    private func handleSwipe(_ event: NSEvent) -> NSEvent? {
        
        // If a modal dialog is open, don't do anything
        // Also, ignore any swipe events that weren't performed over the playlist window
        // (they trigger other functions if performed over the main window)
        
        // TODO: Enable top/bottom gestures for chapters list window too !!!
        
        if event.type == .swipe, !WindowManager.instance.isShowingModalComponent && event.window === WindowManager.instance.playlistWindow,
           let swipeDirection = event.gestureDirection {
            
            swipeDirection.isHorizontal ? handleTabToggle(swipeDirection) : handleScrolling(swipeDirection)
        }
        
        return event
    }
    
    private func handleTabToggle(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlaylistTabToggle {
            Messenger.publish(swipeDirection == .left ? .playlist_previousView : .playlist_nextView)
        }
    }
    
    private func handleScrolling(_ swipeDirection: GestureDirection) {
        
        if gesturesPreferences.allowPlaylistNavigation {
        
            Messenger.publish(swipeDirection == .up ? .playlist_scrollToTop : .playlist_scrollToBottom,
                              payload: PlaylistViewSelector.forView(PlaylistViewState.currentView))
        }
    }
}
