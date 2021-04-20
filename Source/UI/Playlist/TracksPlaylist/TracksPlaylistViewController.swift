import Cocoa

/*
    View controller for the flat ("Tracks") playlist view
 */
class TracksPlaylistViewController: NSViewController, NotificationSubscriber, Destroyable {
    
//    deinit {
//        print("\nDeinited \(self.className)")
//    }
    
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var playlistViewDelegate: TracksPlaylistViewDelegate!
    
    var contextMenu: NSMenu! {
        
        didSet {
            playlistView.menu = contextMenu
        }
    }
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let preferences: PlaylistPreferences = ObjectGraph.preferences.playlistPreferences
    
    override var nibName: String? {"Tracks"}
    
    override func viewDidLoad() {
        
        playlistView.enableDragDrop()
        
        initSubscriptions()
        
        doApplyColorScheme(ColorSchemes.systemScheme, false)
        
        if PlaylistViewState.current == .tracks, preferences.showNewTrackInPlaylist {
            showPlayingTrack()
        }
    }
    
    private func initSubscriptions() {
        
        Messenger.subscribeAsync(self, .playlist_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .playlist_tracksRemoved, self.tracksRemoved(_:), queue: .main)

        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackNotPlayed(_:), queue: .main)
        
        // Don't bother responding if only album art was updated
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:),
                                 filter: {msg in msg.updatedFields.contains(.duration) || msg.updatedFields.contains(.displayInfo)},
                                 queue: .main)
        
        // MARK: Command handling -------------------------------------------------------------------------------------------------
        
        Messenger.subscribe(self, .playlist_selectSearchResult, self.selectSearchResult(_:),
                            filter: {cmd in cmd.viewSelector.includes(.tracks)})
        
        let viewSelectionFilter: (PlaylistViewSelector) -> Bool = {selector in selector.includes(.tracks)}
        
        Messenger.subscribe(self, .playlist_refresh, {(PlaylistViewSelector) in self.refresh()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_removeTracks, {(PlaylistViewSelector) in self.removeTracks()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_moveTracksUp, {(PlaylistViewSelector) in self.moveTracksUp()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_moveTracksDown, {(PlaylistViewSelector) in self.moveTracksDown()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_moveTracksToTop, {(PlaylistViewSelector) in self.moveTracksToTop()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_moveTracksToBottom, {(PlaylistViewSelector) in self.moveTracksToBottom()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_clearSelection, {(PlaylistViewSelector) in self.clearSelection()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_invertSelection, {(PlaylistViewSelector) in self.invertSelection()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_cropSelection, {(PlaylistViewSelector) in self.cropSelection()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_scrollToTop, {(PlaylistViewSelector) in self.scrollToTop()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_scrollToBottom, {(PlaylistViewSelector) in self.scrollToBottom()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_pageUp, {(PlaylistViewSelector) in self.pageUp()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_pageDown, {(PlaylistViewSelector) in self.pageDown()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_showPlayingTrack, {(PlaylistViewSelector) in self.showPlayingTrack()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_showTrackInFinder, {(PlaylistViewSelector) in self.showTrackInFinder()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_playSelectedItem, {(PlaylistViewSelector) in self.playSelectedTrack()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .applyTheme, self.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        
        Messenger.subscribe(self, .playlist_changeTrackNameTextColor, self.changeTrackNameTextColor(_:))
        Messenger.subscribe(self, .playlist_changeIndexDurationTextColor, self.changeIndexDurationTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changeTrackNameSelectedTextColor, self.changeTrackNameSelectedTextColor(_:))
        Messenger.subscribe(self, .playlist_changeIndexDurationSelectedTextColor, self.changeIndexDurationSelectedTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changePlayingTrackIconColor, self.changePlayingTrackIconColor(_:))
        Messenger.subscribe(self, .playlist_changeSelectionBoxColor, self.changeSelectionBoxColor(_:))
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    private var selectedRows: IndexSet {playlistView.selectedRowIndexes}
    
    private var selectedRowCount: Int {playlistView.numberOfSelectedRows}
    
    private var rowCount: Int {playlistView.numberOfRows}
    
    private var atLeastOneRow: Bool {playlistView.numberOfRows > 0}
    
    private var lastRow: Int {rowCount - 1}
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        PlaylistViewState.current = .tracks
        PlaylistViewState.currentView = playlistView
        
        Messenger.publish(.playlist_viewChanged, payload: PlaylistType.tracks)
    }
    
    // Plays the track selected within the playlist, if there is one. If multiple tracks are selected, the first one will be chosen.
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        
        if let firstSelectedRow = playlistView.selectedRowIndexes.min() {
            Messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow))
        }
    }
    
    private func removeTracks() {
        
        if selectedRowCount > 0 {
            
            playlist.removeTracks(selectedRows)
            clearSelection()
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ index: Int) {
        
        if index >= 0 && index < rowCount {
            
            playlistView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            playlistView.scrollRowToVisible(index)
        }
    }
    
    func refresh() {
        self.playlistView.reloadData()
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksUp() {

        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksUp(selectedRows).results as? [TrackMoveResult] {
            
            moveAndReloadItems(results.sorted(by: TrackMoveResult.compareAscending))
            playlistView.scrollRowToVisible(selectedRows.min()!)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksDown() {
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksDown(selectedRows).results as? [TrackMoveResult] {
            
            moveAndReloadItems(results.sorted(by: TrackMoveResult.compareDescending))
            playlistView.scrollRowToVisible(selectedRows.min()!)
        }
    }
    
    // Rearranges tracks within the view that have been reordered
    private func moveAndReloadItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playlistView.moveRow(at: result.sourceIndex, to: result.destinationIndex)
            playlistView.reloadData(forRowIndexes: IndexSet([result.sourceIndex, result.destinationIndex]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksToTop() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = selectedRows.count
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksToTop(selectedRows).results as? [TrackMoveResult] {
            
            // Move the rows
            removeAndInsertItems(results.sorted(by: TrackMoveResult.compareAscending))
            
            // Refresh the relevant rows
            playlistView.reloadData(forRowIndexes: IndexSet(0...selectedRows.max()!), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            
            // Select all the same rows but now at the top
            playlistView.scrollRowToVisible(0)
            playlistView.selectRowIndexes(IndexSet(0..<selectedRowCount), byExtendingSelection: false)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksToBottom() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = selectedRows.count
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksToBottom(selectedRows).results as? [TrackMoveResult] {

            // Move the rows
            removeAndInsertItems(results.sorted(by: TrackMoveResult.compareDescending))

            // Refresh the relevant rows
            playlistView.reloadData(forRowIndexes: IndexSet(selectedRows.min()!...lastRow), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            
            // Select all the same items but now at the bottom
            let firstSelectedRow = lastRow - selectedRowCount + 1
            playlistView.scrollRowToVisible(lastRow)
            playlistView.selectRowIndexes(IndexSet(firstSelectedRow...lastRow), byExtendingSelection: false)
        }
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playlistView.removeRows(at: IndexSet(integer: result.sourceIndex), withAnimation: result.movedUp ? .slideUp : .slideDown)
            playlistView.insertRows(at: IndexSet(integer: result.destinationIndex), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    // Scrolls the playlist view to the very top
    private func scrollToTop() {
        
        if atLeastOneRow {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    private func scrollToBottom() {
        
        if atLeastOneRow {
            playlistView.scrollRowToVisible(lastRow)
        }
    }
    
    private func pageUp() {
        playlistView.pageUp()
    }
    
    private func pageDown() {
        playlistView.pageDown()
    }
    
    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.currentTrack, let playingTrackIndex = playlist.indexOfTrack(playingTrack) {
            selectTrack(playingTrackIndex)
        }
    }
    
    func trackAdded(_ notification: TrackAddedNotification) {
        self.playlistView.insertRows(at: IndexSet(integer: notification.trackIndex), withAnimation: .slideDown)
    }
    
    private func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        DispatchQueue.main.async {
            
            if let updatedTrackIndex = self.playlist.indexOfTrack(notification.updatedTrack) {
                self.playlistView.reloadData(forRowIndexes: IndexSet(integer: updatedTrackIndex), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            }
        }
    }
    
    private func tracksRemoved(_ results: TrackRemovalResults) {
        
        let indexes = results.flatPlaylistResults
        guard !indexes.isEmpty else {return}
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        playlistView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        let firstRemovedRow = indexes.min()!
        let lastPlaylistRowAfterRemove = playlist.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playlist.
        if firstRemovedRow <= lastPlaylistRowAfterRemove {
            
            let refreshIndexes = IndexSet(firstRemovedRow...lastPlaylistRowAfterRemove)
            playlistView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        let refreshIndexes: IndexSet = IndexSet(Set([notification.beginTrack, notification.endTrack].compactMap {$0}).compactMap {playlist.indexOfTrack($0)})
        let needToShowTrack: Bool = PlaylistViewState.current == .tracks && preferences.showNewTrackInPlaylist

        if let newTrack = notification.endTrack {
            
            if needToShowTrack {

                if let newTrackIndex = playlist.indexOfTrack(newTrack), newTrackIndex >= playlistView.numberOfRows {

                    // This means the track is in the playlist but has not yet been added to the playlist view (Bookmark/Recently played/Favorite item), and will be added shortly (this is a race condition). So, dispatch an async delayed handler to show the track in the playlist, after it is expected to be added.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.showPlayingTrack()
                    })

                } else {
                    showPlayingTrack()
                }
            }

        } else if needToShowTrack {
            clearSelection()
        }

        // If this is not done async, the row view could get garbled.
        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        DispatchQueue.main.async {
            self.playlistView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        let errTrack = notification.errorTrack
        
        let refreshIndexes: IndexSet = IndexSet(Set([notification.oldTrack, errTrack].compactMap {$0}).compactMap {playlist.indexOfTrack($0)})

        if let errTrackIndex = playlist.indexOfTrack(errTrack), PlaylistViewState.current == .tracks {
            selectTrack(errTrackIndex)
        }

        playlistView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
    }
    
    // Selects an item within the playlist view, to show a single search result
    func selectSearchResult(_ command: SelectSearchResultCommandNotification) {
        
        if let trackIndex = command.searchResult.location.trackIndex {
            selectTrack(trackIndex)
        }
    }
    
    // Show the selected track in Finder
    private func showTrackInFinder() {
        
        if let selTrack = playlist.trackAtIndex(playlistView.selectedRow) {
            FileSystemUtils.showFileInFinder(selTrack.file)
        }
    }
    
    private func clearSelection() {
        playlistView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
    }
    
    private func invertSelection() {
        playlistView.selectRowIndexes(invertedSelection, byExtendingSelection: false)
    }
    
    private var invertedSelection: IndexSet {
        IndexSet((0..<playlist.size).filter {!selectedRows.contains($0)})
    }
    
    private func cropSelection() {
        
        let tracksToDelete: IndexSet = invertedSelection
        
        if tracksToDelete.count > 0 {
            
            playlist.removeTracks(tracksToDelete)
            playlistView.reloadData()
        }
    }
    
    private func applyTheme() {
        
        applyFontScheme(FontSchemes.systemScheme)
        applyColorScheme(ColorSchemes.systemScheme)
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        
        let selectedRows = self.selectedRows
        playlistView.reloadData()
        playlistView.selectRowIndexes(selectedRows, byExtendingSelection: false)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        doApplyColorScheme(scheme)
    }
    
    private func doApplyColorScheme(_ scheme: ColorScheme, _ mustReloadRows: Bool = true) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        
        if mustReloadRows {
            
            let selectedRows = self.selectedRows
            playlistView.reloadData()
            playlistView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        scrollView.backgroundColor = color
        clipView.backgroundColor = color
        playlistView.backgroundColor = color
    }
    
    private var allRows: IndexSet {IndexSet(integersIn: 0..<rowCount)}
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet(integer: 1))
    }
    
    private func changeIndexDurationTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet([0, 2]))
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: selectedRows, columnIndexes: IndexSet(integer: 1))
    }
    
    private func changeIndexDurationSelectedTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: selectedRows, columnIndexes: IndexSet([0, 2]))
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        
        // Note down the selected rows, clear the selection, and re-select the originally selected rows (to trigger a repaint of the selection boxes)
        let selectedRows = self.selectedRows
        
        if !selectedRows.isEmpty {
            
            clearSelection()
            playlistView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingTrack = self.playbackInfo.currentTrack, let playingTrackIndex = self.playlist.indexOfTrack(playingTrack) {
            playlistView.reloadData(forRowIndexes: IndexSet(integer: playingTrackIndex), columnIndexes: IndexSet(integer: 0))
        }
    }
}
