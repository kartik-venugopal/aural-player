import Cocoa

/*
    Window controller for the playlist window.
 */
class PlaylistWindowController: NSWindowController, ActionMessageSubscriber, AsyncMessageSubscriber, MessageSubscriber, NSTabViewDelegate, NSWindowDelegate {
    
    @IBOutlet weak var btnClose: ColorSensitiveImageButton! {
        
        didSet {
            btnClose.imageMappings[.darkBackground_lightText] = NSImage(named: "Close")
            btnClose.imageMappings[.lightBackground_darkText] = NSImage(named: "Close_1")
        }
    }
    
    @IBOutlet weak var rootContainer: NSBox!
    
    @IBOutlet weak var controlsBox: NSBox!
    
    @IBOutlet weak var btnAdd: ColorSensitiveImageButton! {
        
        didSet {
            btnAdd.imageMappings[.darkBackground_lightText] = NSImage(named: "Add")
            btnAdd.imageMappings[.lightBackground_darkText] = NSImage(named: "Add_1")
        }
    }
    
    @IBOutlet weak var btnRemove: ColorSensitiveImageButton! {
        
        didSet {
            btnRemove.imageMappings[.darkBackground_lightText] = NSImage(named: "Remove")
            btnRemove.imageMappings[.lightBackground_darkText] = NSImage(named: "Remove_1")
        }
    }
    
    @IBOutlet weak var btnSave: ColorSensitiveImageButton! {
        
        didSet {
            btnSave.imageMappings[.darkBackground_lightText] = NSImage(named: "Save")
            btnSave.imageMappings[.lightBackground_darkText] = NSImage(named: "Save_1")
        }
    }
    
    @IBOutlet weak var btnClear: ColorSensitiveImageButton! {
        
        didSet {
            btnClear.imageMappings[.darkBackground_lightText] = NSImage(named: "Clear")
            btnClear.imageMappings[.lightBackground_darkText] = NSImage(named: "Clear_1")
        }
    }
    
    @IBOutlet weak var btnUp: ColorSensitiveImageButton! {
        
        didSet {
            btnUp.imageMappings[.darkBackground_lightText] = NSImage(named: "Up")
            btnUp.imageMappings[.lightBackground_darkText] = NSImage(named: "Up_1")
        }
    }
    
    @IBOutlet weak var btnDown: ColorSensitiveImageButton! {
        
        didSet {
            btnDown.imageMappings[.darkBackground_lightText] = NSImage(named: "Down")
            btnDown.imageMappings[.lightBackground_darkText] = NSImage(named: "Down_1")
        }
    }
    
    @IBOutlet weak var btnSearch: ColorSensitiveImageButton! {
        
        didSet {
            btnSearch.imageMappings[.darkBackground_lightText] = NSImage(named: "Search")
            btnSearch.imageMappings[.lightBackground_darkText] = NSImage(named: "Search_1")
        }
    }
    
    @IBOutlet weak var btnSort: ColorSensitiveImageButton! {
        
        didSet {
            btnSort.imageMappings[.darkBackground_lightText] = NSImage(named: "Sort")
            btnSort.imageMappings[.lightBackground_darkText] = NSImage(named: "Sort_1")
        }
    }
    
    @IBOutlet weak var playlistBox: NSBox!
    @IBOutlet weak var tabButtonsBox: NSBox!
    
    @IBOutlet weak var btnTracksTab: NSButton!
    @IBOutlet weak var btnArtistsTab: NSButton!
    @IBOutlet weak var btnAlbumsTab: NSButton!
    @IBOutlet weak var btnGenresTab: NSButton!
    
    // The different playlist views
    private lazy var tracksView: NSView = ViewFactory.getTracksView()
    private lazy var artistsView: NSView = ViewFactory.getArtistsView()
    private lazy var albumsView: NSView = ViewFactory.getAlbumsView()
    private lazy var genresView: NSView = ViewFactory.getGenresView()
    
    @IBOutlet weak var contextMenu: NSMenu!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: AuralTabView!
    
    // Fields that display playlist summary info
    @IBOutlet weak var lblTracksSummary: VALabel!
    
    @IBOutlet weak var lblDurationSummary: VALabel!
    
    // Spinner that shows progress when tracks are being added to the playlist
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    @IBOutlet weak var viewMenuButton: NSPopUpButton!
    @IBOutlet weak var viewMenuImageItem: ColorSensitiveMenuItem! {
        
        didSet {
            viewMenuImageItem.imageMappings[.darkBackground_lightText] = NSImage(named: "Settings")
            viewMenuImageItem.imageMappings[.lightBackground_darkText] = NSImage(named: "Settings_1")
        }
    }
    
    // Search dialog
    private lazy var playlistSearchDialog: ModalDialogDelegate = WindowFactory.getPlaylistSearchDialog()
    
    // Sort dialog
    private lazy var playlistSortDialog: ModalDialogDelegate = WindowFactory.getPlaylistSortDialog()
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    // For gesture handling
    private var eventMonitor: Any?
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let preferences: ViewPreferences = ObjectGraph.preferencesDelegate.getPreferences().viewPreferences
    
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    private lazy var mainWindow: NSWindow = WindowFactory.getMainWindow()
    
    private lazy var effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    
    override var windowNibName: String? {return "Playlist"}

    override func windowDidLoad() {
        
        WindowState.playlistWindow = theWindow
        theWindow.isMovableByWindowBackground = true
        
        changeTextSize(PlayerViewState.textSize)
        changeColorScheme()
        
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
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .swipe], handler: {(event: NSEvent) -> NSEvent? in
            
            // Fix for system beep
            if PlaylistInputEventHandler.handle(event) {
                return nil
            } else {
                return event
            }
        });
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe([.trackAdded, .trackGrouped, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded, .startedAddingTracks, .doneAddingTracks], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.removeTrackRequest, .playlistTypeChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.addTracks, .savePlaylist, .clearPlaylist, .search, .sort, .shiftTab, .nextPlaylistView, .previousPlaylistView, .changePlaylistTextSize, .changeColorScheme], subscriber: self)
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
        
        SyncMessenger.unsubscribe(actionTypes: [.addTracks, .savePlaylist, .clearPlaylist, .search, .sort, .shiftTab, .nextPlaylistView, .previousPlaylistView, .changePlaylistTextSize, .changeColorScheme], subscriber: self)
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
            startedAddingTracks()
            playlist.addFiles(dialog.urls)
        }
    }
    
    // When a track add operation starts, the progress spinner needs to be initialized
    private func startedAddingTracks() {
        
        playlistWorkSpinner.doubleValue = 0
        playlistWorkSpinner.show()
        playlistWorkSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the progress spinner needs to be de-initialized
    private func doneAddingTracks() {
        
        playlistWorkSpinner.stopAnimation(self)
        playlistWorkSpinner.hide()
        
        updatePlaylistSummary()
        
        sequenceChanged()
    }
    
    // When the playback sequence has changed, the UI needs to show the updated info
    private func sequenceChanged() {
        
        if (playbackInfo.playingTrack != nil) {
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
            if let playingTrackIndex = self.playbackInfo.playingTrack?.index, let updatedTrackIndex = self.playlist.indexOfTrack(message.track)?.index {
            
                if (playingTrackIndex == updatedTrackIndex) {
                    SyncMessenger.publishNotification(PlayingTrackInfoUpdatedNotification.instance)
                }
            }
        }
    }
    
    private func trackGrouped(_ message: TrackGroupedAsyncMessage) {
        
        DispatchQueue.main.async {
            
            // Track duration may have changed, affecting the total playlist duration
            self.updatePlaylistSummary()
            
            // If this is the playing track, tell other views that info has been updated
            if let playingTrackIndex = self.playbackInfo.playingTrack?.index, playingTrackIndex == message.index {
                SyncMessenger.publishNotification(PlayingTrackInfoUpdatedNotification.instance)
            }
        }
    }
    
    // Handles a request to remove a single track from the playlist
    private func removeTrack(_ request: RemoveTrackRequest) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
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
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
        
        sequenceChanged()
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
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
        
        updatePlaylistSummary()
    }
    
    // Moves any selected playlist items up one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Moves any selected playlist items down one row in the playlist. Delegates the action to the appropriate playlist view, because this operation depends on which playlist view is currently shown.
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        if playlist.isBeingModified {
            
            alertDialog.showAlert(.error, "Playlist not modified", "The playlist cannot be modified while tracks are being added", "Please wait till the playlist is done adding tracks ...")
            return
        }
        
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
    
    private func changeTextSize(_ size: TextSizeScheme) {
        
        PlaylistViewState.textSize = size
        
        lblTracksSummary.font = TextSizes.playlistSummaryFont
        lblDurationSummary.font = TextSizes.playlistSummaryFont
        
        tabGroup.items.forEach({$0.tabButton.redraw()})
        
        viewMenuButton.font = TextSizes.playlistMenuFont
    }
    
    private func changeColorScheme() {
        
        btnClose.colorSchemeChanged()
        viewMenuImageItem.colorSchemeChanged()
        
        [btnAdd, btnRemove, btnSave, btnClear, btnUp, btnDown, btnSearch, btnSort].forEach({$0?.colorSchemeChanged()})
        
        [rootContainer, tabButtonsBox, playlistBox, controlsBox].forEach({$0?.fillColor = Colors.windowBackgroundColor})
        
        [btnTracksTab, btnArtistsTab, btnAlbumsTab, btnGenresTab].forEach({$0?.redraw()})
        
        [lblTracksSummary, lblDurationSummary].forEach({
            $0?.backgroundColor = Colors.windowBackgroundColor
            $0?.textColor = Colors.boxTextColor
        })
    }
    
    // Updates the summary in response to a change in the tab group selected tab
    private func playlistTypeChanged(_ notification: PlaylistTypeChangedNotification) {
        updatePlaylistSummary()
    }
    
    var subscriberId: String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .trackGrouped:
            
            trackGrouped(message as! TrackGroupedAsyncMessage)
            
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
            
        case .changePlaylistTextSize: changeTextSize((message as! TextSizeActionMessage).textSize)
            
        case .changeColorScheme:    changeColorScheme()
            
        default: return
            
        }
    }
    
    // MARK - Window delegate functions
    
    func windowDidMove(_ notification: Notification) {
        
        // Check if movement was user-initiated (flag on window)
        if !theWindow.userMovingWindow {
            return
        }
        
        var snapped = false
        
        if preferences.snapToWindows {
            
            // First check if window can be snapped to another app window
            snapped = UIUtils.checkForSnapToWindow(theWindow, mainWindow)
            
            if (!snapped) && WindowState.showingEffects {
                snapped = UIUtils.checkForSnapToWindow(theWindow, effectsWindow)
            }
        }
        
        // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
        if preferences.snapToScreen && !snapped {
            UIUtils.checkForSnapToVisibleFrame(theWindow)
        }
    }
}

// Convenient accessor for information about the current playlist view
class PlaylistViewState {
    
    // The current playlist view type displayed within the playlist tab group
    static var current: PlaylistType = .tracks
    
    // The current playlist view displayed within the playlist tab group
    static var currentView: NSTableView!
    
    static var textSize: TextSizeScheme = .normal
    
    static func initialize(_ appState: PlaylistUIState) {
        textSize = appState.textSize
    }
    
    static func persistentState() -> PlaylistUIState {
        
        let state = PlaylistUIState()
        state.textSize = textSize
        
        return state
    }
    
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
    
    static var selectedItem: SelectedItem {
        
        // Determine which item was clicked, and what kind of item it is
        if let outlineView = currentView as? AuralPlaylistOutlineView {
            
            // Grouping view
            let item = outlineView.item(atRow: outlineView.selectedRow)
            
            if let group = item as? Group {
                return SelectedItem(group: group)
            } else {
                // Track
                return SelectedItem(track: item as! Track)
            }
        } else {
            
            // Tracks view
            return SelectedItem(index: currentView.selectedRow)
        }
    }
    
    static var selectedItems: [SelectedItem] {
        
        let selRows = currentView.selectedRowIndexes
        var items: [SelectedItem] = []
        
        if let outlineView = currentView as? AuralPlaylistOutlineView {
            
            // Grouping view
            for row in selRows {
                
                let item = outlineView.item(atRow: row)
                
                if let group = item as? Group {
                    items.append(SelectedItem(group: group))
                } else {
                    // Track
                    items.append(SelectedItem(track: item as! Track))
                }
            }
            
        } else {
            
            for row in selRows {
                // Tracks view
                items.append(SelectedItem(index: row))
            }
        }
        
        return items
    }
}

class PlaylistViewPopupMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var textSizeNormalMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargerMenuItem: NSMenuItem!
    @IBOutlet weak var textSizeLargestMenuItem: NSMenuItem!
    
    private var textSizes: [NSMenuItem] = []
    
    override func awakeFromNib() {
        textSizes = [textSizeNormalMenuItem, textSizeLargerMenuItem, textSizeLargestMenuItem]
    }
    
    // When the menu is about to open, set the menu item states according to the current window/view state
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        textSizes.forEach({
            $0.off()
        })
        
        switch PlaylistViewState.textSize {
            
        case .normal:   textSizeNormalMenuItem.on()
            
        case .larger:   textSizeLargerMenuItem.on()
            
        case .largest:  textSizeLargestMenuItem.on()
            
        }
    }
    
    @IBAction func changeTextSizeAction(_ sender: NSMenuItem) {
        
        let senderTitle: String = sender.title.lowercased()
        let size = TextSizeScheme(rawValue: senderTitle)!
        
        if TextSizes.playlistScheme != size {

            TextSizes.playlistScheme = size
            PlaylistViewState.textSize = size
            
            SyncMessenger.publishActionMessage(TextSizeActionMessage(.changePlaylistTextSize, size))
        }
    }
}
