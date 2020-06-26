import Cocoa

/*
 View controller for the flat ("Tracks") playlist view
 */
class TracksPlaylistViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var playlistViewDelegate: TracksPlaylistViewDelegate!
    private lazy var contextMenu: NSMenu! = WindowFactory.playlistContextMenu
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
    
    private let preferences: PlaylistPreferences = ObjectGraph.preferencesDelegate.preferences.playlistPreferences
    
    override var nibName: String? {return "Tracks"}
    
    convenience init() {
        self.init(nibName: "Tracks", bundle: Bundle.main)
    }
    
    override func viewDidLoad() {
        
        // Enable drag n drop
        playlistView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([String(kUTTypeFileURL), "public.data"]))
        
        initSubscriptions()
        
        playlistView.menu = contextMenu
        
        doApplyColorScheme(ColorSchemes.systemScheme, false)
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
        
        Messenger.subscribe(self, .playlist_playbackGapUpdated, self.gapUpdated(_:))
        
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
        
        Messenger.subscribe(self, .playlist_playSelectedItemWithDelay,
                            {(notif: DelayedPlaybackCommandNotification) in self.playSelectedTrackWithDelay(notif.delay)},
                            filter: {(notif: DelayedPlaybackCommandNotification) in notif.viewSelector.includes(.tracks)})
        
        Messenger.subscribe(self, .playlist_insertGaps,
                            {(notif: InsertPlaybackGapsCommandNotification) in self.insertGaps(notif.gapBeforeTrack, notif.gapAfterTrack)},
                            filter: {(notif: InsertPlaybackGapsCommandNotification) in notif.viewSelector.includes(.tracks)})
        
        Messenger.subscribe(self, .playlist_removeGaps, {(PlaylistViewSelector) in self.removeGaps()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_changeTextSize, self.changeTextSize(_:))
        
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        
        Messenger.subscribe(self, .playlist_changeTrackNameTextColor, self.changeTrackNameTextColor(_:))
        Messenger.subscribe(self, .playlist_changeIndexDurationTextColor, self.changeIndexDurationTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changeTrackNameSelectedTextColor, self.changeTrackNameSelectedTextColor(_:))
        Messenger.subscribe(self, .playlist_changeIndexDurationSelectedTextColor, self.changeIndexDurationSelectedTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changePlayingTrackIconColor, self.changePlayingTrackIconColor(_:))
        Messenger.subscribe(self, .playlist_changeSelectionBoxColor, self.changeSelectionBoxColor(_:))
    }
    
    private var selectedRows: IndexSet {playlistView.selectedRowIndexes}
    
    private var selectedRowsArr: [Int] {playlistView.selectedRowIndexes.toArray()}
    
    private var selectedRowCount: Int {playlistView.selectedRowIndexes.count}
    
    private var rowCount: Int {playlistView.numberOfRows}
    
    private var atLeastOneRow: Bool {playlistView.numberOfRows > 0}
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        
        PlaylistViewState.current = .tracks
        PlaylistViewState.currentView = playlistView

        Messenger.publish(.playlist_viewChanged, payload: PlaylistType.tracks)
    }
    
    // Plays the track selected within the playlist, if there is one. If multiple tracks are selected, the first one will be chosen.
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
        playSelectedTrackWithDelay(nil)
    }
    
    func playSelectedTrack() {
        playSelectedTrackWithDelay(nil)
    }
    
    func playSelectedTrackWithDelay(_ delay: Double?) {
        
        if let firstSelectedRow = playlistView.selectedRowIndexes.min() {
            Messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow, delay: delay))
        }
    }
    
    private func clearPlaylist() {
        
        playlist.clear()
        Messenger.publish(.playlist_refresh, payload: PlaylistViewSelector.allViews)
    }
    
    private func removeTracks() {
        
        let selectedIndexes = playlistView.selectedRowIndexes
        if (!selectedIndexes.isEmpty) {
            
            playlist.removeTracks(selectedIndexes)
            
            // Clear the playlist selection
            clearSelection()
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ selIndex: Int?) {
        
        // TODO: Check if index is within the bounds ( < numRows)
        
        if let index = selIndex, atLeastOneRow, index >= 0 {
            
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
    private func moveTracksToTop() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = selectedRows.count
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksToTop(selectedRows).results as? [TrackMoveResult] {
            
            // Move the rows
            removeAndInsertItems(results.sorted(by: TrackMoveResult.compareAscending))
            
            // Refresh the relevant rows
            playlistView.reloadData(forRowIndexes: IndexSet(0...selectedRows.max()!), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            
            // Select all the same items but now at the top
            playlistView.scrollRowToVisible(0)
            playlistView.selectRowIndexes(IndexSet(0..<selectedRowCount), byExtendingSelection: false)
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
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksToBottom() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = selectedRows.count
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksToBottom(selectedRows).results as? [TrackMoveResult] {

            // Move the rows
            removeAndInsertItems(results.sorted(by: TrackMoveResult.compareDescending))

            // Refresh the relevant rows
            let lastIndex = rowCount - 1
            playlistView.reloadData(forRowIndexes: IndexSet(selectedRows.min()!...lastIndex), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            
            // Select all the same items but now at the bottom
            let firstSelectedRow = lastIndex - selectedRowCount + 1
            playlistView.scrollRowToVisible(lastIndex)
            playlistView.selectRowIndexes(IndexSet(firstSelectedRow...lastIndex), byExtendingSelection: false)
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
            playlistView.scrollRowToVisible(rowCount - 1)
        }
    }
    
    private func pageUp() {
        
        // Determine if the first row currently displayed has been truncated so it is not fully visible
        
        let firstRowShown = playlistView.rows(in: playlistView.visibleRect).lowerBound
        let firstRowShown_height = playlistView.rect(ofRow: firstRowShown).height
        let firstRowShown_minY = playlistView.rect(ofRow: firstRowShown).minY
        
        let visibleRect_minY = playlistView.visibleRect.minY
        
        let truncationAmount =  visibleRect_minY - firstRowShown_minY
        let truncationRatio = truncationAmount / firstRowShown_height
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let lastRowToShow = truncationRatio > 0.1 ? firstRowShown : firstRowShown - 1
        let lastRowToShow_maxY = playlistView.rect(ofRow: lastRowToShow).maxY
        
        let visibleRect_maxY = playlistView.visibleRect.maxY
        
        // Calculate the scroll amount, as a function of the last row to show next, using the visible rect origin (i.e. the top of the first row in the playlist) as the stopping point
        
        let scrollAmount = min(playlistView.visibleRect.origin.y, visibleRect_maxY - lastRowToShow_maxY)
        
        if scrollAmount > 0 {
            
            let up = playlistView.visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: -scrollAmount))
            scrollView.contentView.scroll(to: up)
        }
    }
    
    private func pageDown() {
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        
        let visibleRows = playlistView.rows(in: playlistView.visibleRect)
        
        let lastRowShown = visibleRows.lowerBound + visibleRows.length - 1
        let lastRowShown_maxY = playlistView.rect(ofRow: lastRowShown).maxY
        let lastRowShown_height = playlistView.rect(ofRow: lastRowShown).height
        
        let lastRowInPlaylist = playlistView.numberOfRows - 1
        let lastRowInPlaylist_maxY = playlistView.rect(ofRow: lastRowInPlaylist).maxY
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let visibleRect_maxY = playlistView.visibleRect.maxY
        
        let truncationAmount = lastRowShown_maxY - visibleRect_maxY
        let truncationRatio = truncationAmount / lastRowShown_height
        
        let firstRowToShow = truncationRatio > 0.1 ? lastRowShown : lastRowShown + 1
        
        let visibleRect_originY = playlistView.visibleRect.origin.y
        let firstRowToShow_originY = playlistView.rect(ofRow: firstRowToShow).origin.y
        
        // Calculate the scroll amount, as a function of the first row to show next, using the visible rect maxY (i.e. the bottom of the last row in the playlist) as the stopping point
        
        let scrollAmount = min(firstRowToShow_originY - visibleRect_originY, lastRowInPlaylist_maxY - playlistView.visibleRect.maxY)
        
        if scrollAmount > 0 {
            
            let down = playlistView.visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: scrollAmount))
            scrollView.contentView.scroll(to: down)
        }
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playlistView.removeRows(at: IndexSet([result.sourceIndex]), withAnimation: result.movedUp ? .slideUp : .slideDown)
            playlistView.insertRows(at: IndexSet([result.destinationIndex]), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    // Rearranges tracks within the view that have been reordered
    private func moveAndReloadItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playlistView.moveRow(at: result.sourceIndex, to: result.destinationIndex)
            playlistView.reloadData(forRowIndexes: IndexSet([result.sourceIndex, result.destinationIndex]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = self.playbackInfo.currentTrack,
            let playingTrackIndex = self.playlist.indexOfTrack(playingTrack) {
            
            selectTrack(playingTrackIndex)
            
        } else {
            selectTrack(nil)
        }
    }
    
    private func showSelectedTrackInfo() {
        
        // TODO: Is this method even being used ???
        
        if let track = playlist.trackAtIndex(playlistView.selectedRow) {
            track.loadDetailedInfo()
        }
    }
    
    func trackAdded(_ notification: TrackAddedNotification) {
        self.playlistView.insertRows(at: IndexSet([notification.trackIndex]), withAnimation: .slideDown)
    }
    
    private func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        DispatchQueue.main.async {
            
            if let updatedTrackIndex = self.playlist.indexOfTrack(notification.updatedTrack) {
                
                self.playlistView.reloadData(forRowIndexes: IndexSet(integer: updatedTrackIndex), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            }
        }
    }
    
    private func tracksRemoved(_ results: TrackRemovalResults) {
        
        // TODO: Can we simply use playlistView.removeRows() here ??? Analogous to playlistView.insertRows on tracksAdded.
        
        let indexes = results.flatPlaylistResults
        
        if indexes.isEmpty {
            return
        }
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        let minIndex = (indexes.min())!
        let maxIndex = playlist.size - 1
        
        // If not all removed rows are contiguous and at the end of the playlist
        if (minIndex <= maxIndex) {
            
            let refreshIndexes = IndexSet(minIndex...maxIndex)
            playlistView.reloadData(forRowIndexes: refreshIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            playlistView.noteHeightOfRows(withIndexesChanged: refreshIndexes)
        }
        
        // Tell the playlist view that the number of rows has changed
        playlistView.noteNumberOfRowsChanged()
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackTransitioned(notification.beginTrack, notification.endTrack)
    }
    
    private func trackTransitioned(_ oldTrack: Track?, _ newTrack: Track?) {
        
        var refreshIndexes = [Int]()

        if let track = oldTrack, let sourceIndex = playlist.indexOfTrack(track) {
            refreshIndexes.append(sourceIndex)
        }

        let needToShowTrack: Bool = PlaylistViewState.current == .tracks && preferences.showNewTrackInPlaylist

        if let _newTrack = newTrack {
            
            let newTrackIndex = playlist.indexOfTrack(_newTrack)

            // If new and old are the same, don't refresh the same row twice
            if _newTrack != oldTrack, let index = newTrackIndex {
                refreshIndexes.append(index)
            }

            if needToShowTrack {

                if let index = newTrackIndex, index >= playlistView.numberOfRows {

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

        // Gaps may have been removed, so row heights need to be updated too
        let indexSet: IndexSet = IndexSet(refreshIndexes)

        // If this is not done async, the row view could get garbled.
        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        DispatchQueue.main.async {
            
            self.playlistView.reloadData(forRowIndexes: indexSet, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            self.playlistView.noteHeightOfRows(withIndexesChanged: indexSet)
        }
    }
    
    // TODO: Test with one-time gap before bad track (see if playlist updates properly after receiving this notif)
    // If not, call this code from main.async()
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        let oldTrack = notification.oldTrack
        var refreshIndexes = [Int]()

        if let _oldTrack = oldTrack, let sourceIndex = playlist.indexOfTrack(_oldTrack) {
            refreshIndexes.append(sourceIndex)
        }

        if let errTrack = notification.error.track, let errTrackIndex = playlist.indexOfTrack(errTrack) {

            // If new and old are the same, don't refresh the same row twice
            if errTrack != oldTrack {
                refreshIndexes.append(errTrackIndex)
            }

            if PlaylistViewState.current == .tracks {
                selectTrack(errTrackIndex)
            }
        }

        playlistView.reloadData(forRowIndexes: IndexSet(refreshIndexes), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
    }
    
    // Selects an item within the playlist view, to show a single search result
    func selectSearchResult(_ command: SelectSearchResultCommandNotification) {
        selectTrack(command.searchResult.location.trackIndex)
    }
    
    // Show the selected track in Finder
    private func showTrackInFinder() {
        
        let selTrack = playlist.trackAtIndex(playlistView.selectedRow)
        FileSystemUtils.showFileInFinder((selTrack?.file)!)
    }
    
    private func clearSelection() {
        playlistView.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
    }
    
    private func invertSelection() {
        playlistView.selectRowIndexes(invertedSelection, byExtendingSelection: false)
    }
    
    private var invertedSelection: IndexSet {
        
        let selRows = playlistView.selectedRowIndexes
        let playlistSize = playlist.size
        var targetSelRows = IndexSet()
        
        for index in 0..<playlistSize {
            
            if !selRows.contains(index) {
                targetSelRows.insert(index)
            }
        }
        
        return targetSelRows
    }
    
    private func cropSelection() {
        
        let tracksToDelete: IndexSet = invertedSelection
        
        if (tracksToDelete.count > 0) {
            
            playlist.removeTracks(tracksToDelete)
            playlistView.reloadData()
        }
    }
    
    private func insertGaps(_ gapBefore: PlaybackGap?, _ gapAfter: PlaybackGap?) {
        
        if let track = playlist.trackAtIndex(playlistView.selectedRow) {
            
            playlist.setGapsForTrack(track, gapBefore, gapAfter)
            
            // This should also refresh this view
            Messenger.publish(.playlist_playbackGapUpdated, payload: track)
        }
    }
    
    private func removeGaps() {
        
        if let track = playlist.trackAtIndex(playlistView.selectedRow) {
            
            playlist.removeGapsForTrack(track)
            
            // This should also refresh this view
            Messenger.publish(.playlist_playbackGapUpdated, payload: track)
        }
    }
    
    func gapUpdated(_ updatedTrack: Track) {
        
        // Find track and refresh it
        if let updatedRow = playlist.indexOfTrack(updatedTrack), updatedRow >= 0 {
            
            refreshRow(updatedRow)
            
            // TODO
//            playlistView.scrollRowToVisible(updatedRow)
        }
    }
    
    private func refreshRow(_ row: Int) {
        
        playlistView.reloadData(forRowIndexes: IndexSet([row]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
    }
    
    private func changeTextSize(_ textSize: TextSize) {
        
        let selRows = playlistView.selectedRowIndexes
        playlistView.reloadData()
        playlistView.selectRowIndexes(selRows, byExtendingSelection: false)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        doApplyColorScheme(scheme)
    }
    
    private func doApplyColorScheme(_ scheme: ColorScheme, _ mustReloadRows: Bool = true) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        
        if mustReloadRows {
            
            playlistViewDelegate.changeGapIndicatorColor(scheme.playlist.indexDurationSelectedTextColor)
            
            let selRows = playlistView.selectedRowIndexes
            playlistView.reloadData()
            playlistView.selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        scrollView.backgroundColor = color
        scrollView.drawsBackground = color.isOpaque
        
        clipView.backgroundColor = color
        clipView.drawsBackground = color.isOpaque
        
        playlistView.backgroundColor = color.isOpaque ? color : NSColor.clear
    }
    
    private var allRows: IndexSet {
        return IndexSet(integersIn: 0..<playlistView.numberOfRows)
    }
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        
        playlistViewDelegate.changeGapIndicatorColor(color)
        playlistView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet([1]))
    }
    
    private func changeIndexDurationTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet([0, 2]))
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: playlistView.selectedRowIndexes, columnIndexes: IndexSet([1]))
    }
    
    private func changeIndexDurationSelectedTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: playlistView.selectedRowIndexes, columnIndexes: IndexSet([0, 2]))
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        
        // Note down the selected rows, clear the selection, and re-select the originally selected rows (to trigger a repaint of the selection boxes)
        let selRows = playlistView.selectedRowIndexes
        
        if !selRows.isEmpty {
            clearSelection()
            playlistView.selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingTrack = self.playbackInfo.currentTrack, let playingTrackIndex = self.playlist.indexOfTrack(playingTrack) {
            
            playlistView.reloadData(forRowIndexes: IndexSet([playingTrackIndex]), columnIndexes: IndexSet([0]))
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
    return input.map { key in NSPasteboard.PasteboardType(key) }
}
