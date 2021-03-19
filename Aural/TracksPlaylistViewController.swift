import Cocoa

/*
 View controller for the flat ("Tracks") playlist view
 */
class TracksPlaylistViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playlistView: NSTableView!
    private lazy var contextMenu: NSMenu! = WindowFactory.getPlaylistContextMenu()
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    private let playbackPreferences: PlaybackPreferences = ObjectGraph.preferencesDelegate.getPreferences().playbackPreferences
    
    private lazy var layoutManager: LayoutManager = ObjectGraph.layoutManager
    
    override var nibName: String? {return "Tracks"}
    
    var rows: Int = 0
    
    convenience init() {
        self.init(nibName: "Tracks", bundle: Bundle.main)
    }
    
    override func viewDidLoad() {
        
        // Enable drag n drop
        playlistView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([String(kUTTypeFileURL), "public.data"]))
        
        // Register for key press and gesture events
        PlaylistInputEventHandler.registerViewForPlaylistType(.tracks, self.playlistView)
        
        // Register as a subscriber to various message notifications
        AsyncMessenger.subscribe([.trackAdded, .trackGrouped, .tracksRemoved, .trackInfoUpdated, .gapStarted, .trackNotPlayed, .transcodingStarted, .transcodingCancelled], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .searchResultSelectionRequest, .gapUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.removeTracks, .moveTracksUp, .moveTracksToTop, .moveTracksToBottom, .moveTracksDown, .clearSelection, .invertSelection, .cropSelection, .scrollToTop, .scrollToBottom, .pageUp, .pageDown, .refresh, .showPlayingTrack, .playSelectedItem, .playSelectedItemWithDelay, .showTrackInFinder, .insertGaps, .removeGaps, .changePlaylistTextSize, .changeColorScheme], subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
        
        playlistView.menu = contextMenu
        
        changeColorScheme()
    }
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        
        PlaylistViewState.current = .tracks
        PlaylistViewState.currentView = playlistView
        SyncMessenger.publishNotification(PlaylistTypeChangedNotification(newPlaylistType: .tracks))
    }
    
    // Plays the track selected within the playlist, if there is one. If multiple tracks are selected, the first one will be chosen.
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
        playSelectedTrackWithDelay(nil)
    }
    
    private func playSelectedTrackWithDelay(_ delay: Double?) {
        
        let selRowIndexes = playlistView.selectedRowIndexes
        
        if (!selRowIndexes.isEmpty) {
            
            var request = PlaybackRequest(index: selRowIndexes.min()!)
            request.delay = delay
            
            _ = SyncMessenger.publishRequest(request)
        }
    }
    
    private func clearPlaylist() {
        
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
    }
    
    private func removeTracks() {
        
        let selectedIndexes = playlistView.selectedRowIndexes
        if (!selectedIndexes.isEmpty) {
            
            // Special case: If all tracks were removed, this is the same as clearing the playlist, delegate to that (simpler and more efficient) function instead.
            if (selectedIndexes.count == playlistView.numberOfRows) {
                clearPlaylist()
                return
            }
            
            playlist.removeTracks(selectedIndexes)
            
            // Clear the playlist selection
            clearSelection()
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ selIndex: Int?) {
        
        if let index = selIndex, playlistView.numberOfRows > 0, index >= 0 {
            
            playlistView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            playlistView.scrollRowToVisible(index)
        }
    }
    
    private func refresh() {
        
        DispatchQueue.main.async {
            self.playlistView.reloadData()
        }
    }
    
    private func moveTracksUp() {
        
        let selRows = playlistView.selectedRowIndexes
        let numRows = playlistView.numberOfRows
        
        /*
         If playlist empty or has only 1 row OR
         no tracks selected OR
         all tracks selected, don't do anything
         */
        if (numRows > 1 && selRows.count > 0 && selRows.count < numRows) {
            
            moveItems(playlist.moveTracksUp(selRows))
            playlistView.scrollRowToVisible(selRows.min()!)
        }
    }
    
    private func moveTracksToTop() {
        
        let selRows = playlistView.selectedRowIndexes
        let numRows = playlistView.numberOfRows
        
        /*
         If playlist empty or has only 1 row OR
         no tracks selected OR
         all tracks selected, don't do anything
         */
        if (numRows > 1 && selRows.count > 0 && selRows.count < numRows) {
            
            let results = playlist.moveTracksToTop(selRows)
            removeAndInsertItems(results)
            
            let updatedRows = IndexSet(integersIn: 0...selRows.max()!)
            playlistView.reloadData(forRowIndexes: updatedRows, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            
            // Select all the same items but now at the top
            playlistView.scrollRowToVisible(0)
            playlistView.selectRowIndexes(IndexSet(0..<selRows.count), byExtendingSelection: false)
        }
    }
    
    private func moveTracksDown() {
        
        let selRows = playlistView.selectedRowIndexes
        let numRows = playlistView.numberOfRows
        
        /*
         If playlist empty or has only 1 row OR
         no tracks selected OR
         all tracks selected, don't do anything
         */
        if (numRows > 1 && selRows.count > 0 && selRows.count < numRows) {
            
            moveItems(playlist.moveTracksDown(selRows))
            playlistView.scrollRowToVisible(selRows.min()!)
        }
    }
    
    private func moveTracksToBottom() {
        
        let selRows = playlistView.selectedRowIndexes
        let numRows = playlistView.numberOfRows
        
        /*
         If playlist empty or has only 1 row OR
         no tracks selected OR
         all tracks selected, don't do anything
         */
        if (numRows > 1 && selRows.count > 0 && selRows.count < numRows) {
            
            let lastIndex = playlistView.numberOfRows - 1
            
            let results = playlist.moveTracksToBottom(selRows)
            removeAndInsertItems(results)
            
            let updatedRows = IndexSet(integersIn: selRows.min()!...lastIndex)
            playlistView.reloadData(forRowIndexes: updatedRows, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            
            // Select all the same items but now at the bottom
            playlistView.scrollRowToVisible(lastIndex)
            let firstSel = lastIndex - selRows.count + 1
            playlistView.selectRowIndexes(IndexSet(firstSel...lastIndex), byExtendingSelection: false)
        }
    }
    
    // Scrolls the playlist view to the very top
    private func scrollToTop() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    private func scrollToBottom() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.numberOfRows - 1)
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
    private func removeAndInsertItems(_ results: ItemMoveResults) {
        
        for result in results.results {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.removeRows(at: IndexSet([trackMovedResult.oldTrackIndex]), withAnimation: trackMovedResult.movedUp ? .slideUp : .slideDown)
                playlistView.insertRows(at: IndexSet([trackMovedResult.newTrackIndex]), withAnimation: trackMovedResult.movedUp ? .slideDown : .slideUp)
            }
        }
    }
    
    // Rearranges tracks within the view that have been reordered
    private func moveItems(_ results: ItemMoveResults) {
        
        for result in results.results as! [TrackMoveResult] {
            
            playlistView.moveRow(at: result.oldTrackIndex, to: result.newTrackIndex)
            playlistView.reloadData(forRowIndexes: IndexSet([result.oldTrackIndex, result.newTrackIndex]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        selectTrack(playbackInfo.playingTrack?.index)
    }
    
    private func showSelectedTrackInfo() {
        
        let track = playlist.trackAtIndex(playlistView.selectedRow)!.track
        track.loadDetailedInfo()
    }
    
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        self.playlistView.insertRows(at: IndexSet([message.trackIndex]), withAnimation: .slideDown)
    }
    
    private func trackGrouped(_ message: TrackGroupedAsyncMessage) {
        self.playlistView.reloadData(forRowIndexes: IndexSet(integer: message.index), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
    }
    
    private func trackInfoUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        DispatchQueue.main.async {
            
            // NOTE - In the future, if gap info is updated, also need to update row height
            if let updatedTrackIndex = self.playlist.indexOfTrack(message.track)?.index {
                self.playlistView.reloadData(forRowIndexes: IndexSet(integer: updatedTrackIndex), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
            }
        }
    }
    
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        let indexes = message.results.flatPlaylistResults
        
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
    
    private func trackChanged(_ message: TrackChangedNotification) {
        trackChanged(message.oldTrack, message.newTrack)
    }
    
    private func trackChanged(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?) {
        
        var refreshIndexes = [Int]()
        
        if (oldTrack != nil) {
            refreshIndexes.append(oldTrack!.index)
        }
        
        let needToShowTrack: Bool = layoutManager.isShowingPlaylist() && PlaylistViewState.current == .tracks && playbackPreferences.showNewTrackInPlaylist
        
        if (newTrack != nil) {
            
            // If new and old are the same, don't refresh the same row twice
            if !newTrack!.equals(oldTrack) {
                refreshIndexes.append(newTrack!.index)
            }
            
            if needToShowTrack {
                
                let plIndex = playbackInfo.playingTrack!.index
                if (plIndex == playlistView.numberOfRows) {
                    
                    // This means the track is in the playlist but has not yet been added to the playlist view (Bookmark/Recently played/Favorite item), and will be added shortly (this is a race condition). So, dispatch an async delayed handler to show the track in the playlist, after it is expected to be added.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.showPlayingTrack()
                    })
                    
                } else {
                    showPlayingTrack()
                }
            }
            
        } else {
            
            if needToShowTrack {
                clearSelection()
            }
        }
        
        // Gaps may have been removed, so row heights need to be updated too
        let indexSet: IndexSet = IndexSet(refreshIndexes)
        
        playlistView.reloadData(forRowIndexes: indexSet, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        playlistView.noteHeightOfRows(withIndexesChanged: indexSet)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        
        let oldTrack = message.oldTrack
        let errTrack = playlist.indexOfTrack(message.error.track)!
        
        var refreshIndexes = [Int]()
        
        if (oldTrack != nil) {
            refreshIndexes.append(oldTrack!.index)
        }
        
        // If new and old are the same, don't refresh the same row twice
        if !errTrack.equals(oldTrack) {
            refreshIndexes.append(errTrack.index)
        }
        
        if PlaylistViewState.current == .tracks {
            selectTrack(errTrack.index)
        }
        
        let indexSet: IndexSet = IndexSet(refreshIndexes)
        playlistView.reloadData(forRowIndexes: indexSet, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
    }
    
    // Selects an item within the playlist view, to show a single result of a search
    private func handleSearchResultSelection(_ request: SearchResultSelectionRequest) {
        
        if PlaylistViewState.current == .tracks {
            
            // Select (show) the search result within the playlist view
            selectTrack(request.searchResult.location.trackIndex)
        }
    }
    
    // Show the selected track in Finder
    private func showTrackInFinder() {
        
        let selTrack = playlist.trackAtIndex(playlistView.selectedRow)
        FileSystemUtils.showFileInFinder((selTrack?.track.file)!)
    }
    
    private func clearSelection() {
        playlistView.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
    }
    
    private func invertSelection() {
        playlistView.selectRowIndexes(getInvertedSelection(), byExtendingSelection: false)
    }
    
    private func getInvertedSelection() -> IndexSet {
        
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
        
        let tracksToDelete = getInvertedSelection()
        
        if (tracksToDelete.count > 0) {
            
            playlist.removeTracks(tracksToDelete)
            playlistView.reloadData()
        }
    }
    
    private func insertGap(_ gapBefore: PlaybackGap?, _ gapAfter: PlaybackGap?) {
        
        let track = playlist.trackAtIndex(playlistView.selectedRow)
        playlist.setGapsForTrack(track!.track, gapBefore, gapAfter)
        
        SyncMessenger.publishNotification(PlaybackGapUpdatedNotification(track!.track))
    }
    
    private func removeGaps() {
        
        let track = playlist.trackAtIndex(playlistView.selectedRow)
        playlist.removeGapsForTrack(track!.track)
        
        // This should also refresh this view
        SyncMessenger.publishNotification(PlaybackGapUpdatedNotification(track!.track))
    }
    
    private func gapStarted(_ message: PlaybackGapStartedAsyncMessage) {
        
        var refreshIndexes: [Int] = [message.nextTrack.index]
        
        if let oldTrackIndex = message.lastPlayedTrack?.index, oldTrackIndex != message.nextTrack.index {
            refreshIndexes.append(oldTrackIndex)
        }
        
        let refreshIndexSet: IndexSet = IndexSet(refreshIndexes)
        
        // Last playing track is no longer playing. Also, one-time gaps may have been removed, so need to update the table view
        playlistView.reloadData(forRowIndexes: refreshIndexSet, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        playlistView.noteHeightOfRows(withIndexesChanged: refreshIndexSet)
        
        // Select the next track
        let needToShowTrack: Bool = layoutManager.isShowingPlaylist() && PlaylistViewState.current == .tracks && playbackPreferences.showNewTrackInPlaylist
        if needToShowTrack {
            selectTrack(message.nextTrack.index)
        }
    }
    
    private func gapUpdated(_ message: PlaybackGapUpdatedNotification) {
        
        // Find track and refresh it
        if let updatedRow = playlist.indexOfTrack(message.updatedTrack)?.index {
            
            if updatedRow >= 0 {
                refreshRow(updatedRow)
            }
        }
    }
    
    private func refreshRow(_ row: Int) {
        
        playlistView.reloadData(forRowIndexes: IndexSet([row]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
    }
    
    private func transcodingStarted(_ track: Track) {
        
        let lastPlayedTrack = history.lastPlayedTrack
        let oldTrack = lastPlayedTrack == nil ? nil : playlist.indexOfTrack(lastPlayedTrack!)
        
        var refreshIndexes = [Int]()
        
        if (oldTrack != nil) {
            refreshIndexes.append(oldTrack!.index)
        }
        
        let newTrack = playlist.indexOfTrack(track)!
        
        if oldTrack == nil || !oldTrack!.equals(newTrack) {
            refreshIndexes.append(newTrack.index)
        }
        
        selectTrack(newTrack.index)
        
        let indexSet: IndexSet = IndexSet(refreshIndexes)
        playlistView.reloadData(forRowIndexes: indexSet, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
    }
    
    private func transcodingCancelled(_ track: Track) {
        
        if let index = playlist.indexOfTrack(track)?.index {
            playlistView.reloadData(forRowIndexes: IndexSet([index]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    private func changeTextSize() {
        
        let selRows = playlistView.selectedRowIndexes
        playlistView.reloadData()
        playlistView.selectRowIndexes(selRows, byExtendingSelection: false)
    }
    
    private func changeColorScheme() {
        
//        [rootContainer, tabButtonsBox, playlistBox, controlsBox].forEach({$0?.fillColor = Colors.windowBackgroundColor})
//        [lblTracksSummary, lblDurationSummary].forEach({
//            $0?.backgroundColor = Colors.windowBackgroundColor
//            $0?.textColor = Colors.boxTextColor
//        })
        playlistView.backgroundColor = Colors.windowBackgroundColor
        
        // TODO: Redraw tab buttons, playlist views
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    // MARK: Message handlers
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .trackGrouped:
            
            trackGrouped(message as! TrackGroupedAsyncMessage)
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        case .trackInfoUpdated:
            
            trackInfoUpdated(message as! TrackUpdatedAsyncMessage)
            
        case .gapStarted:
            
            gapStarted(message as! PlaybackGapStartedAsyncMessage)
            
        case .trackNotPlayed:
            
            trackNotPlayed(message as! TrackNotPlayedAsyncMessage)
            
        case .transcodingStarted:
            
            transcodingStarted((message as! TranscodingStartedAsyncMessage).track)
            
        case .transcodingCancelled:
            
            transcodingCancelled((message as! TranscodingCancelledAsyncMessage).track)
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        case .gapUpdatedNotification:
            
            gapUpdated(notification as! PlaybackGapUpdatedNotification)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .searchResultSelectionRequest:
            
            handleSearchResultSelection(request as! SearchResultSelectionRequest)
            
        default: break
            
        }
        
        // No meaningful response to return
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? PlaylistActionMessage {
            
            // Check if this message is intended for this playlist view
            if (msg.playlistType != nil && msg.playlistType != .tracks) {
                return
            }
            
            switch (msg.actionType) {
                
            case .refresh:
                
                refresh()
                
            case .removeTracks:
                
                removeTracks()
                
            case .showPlayingTrack:
                
                showPlayingTrack()
                
            case .playSelectedItem:
                
                playSelectedTrackAction(self)
                
            case .moveTracksUp:
                
                moveTracksUp()
                
            case .moveTracksDown:
                
                moveTracksDown()
                
            case .moveTracksToTop:
                
                moveTracksToTop()
                
            case .moveTracksToBottom:
                
                moveTracksToBottom()
                
            case .scrollToTop:
                
                scrollToTop()
                
            case .scrollToBottom:
                
                scrollToBottom()
                
            case .pageUp:
                
                pageUp()
                
            case .pageDown:
                
                pageDown()
                
            case .selectedTrackInfo:
                
                showSelectedTrackInfo()
                
            case .showTrackInFinder:
                
                showTrackInFinder()
                
            case .clearSelection:
                
                clearSelection()
                
            case .invertSelection:
                
                invertSelection()
                
            case .cropSelection:
                
                cropSelection()
                
            default: return
                
            }
            
            return
        }
        
        if message is TextSizeActionMessage {
            changeTextSize()
        }
        
        if message is ColorSchemeActionMessage {
            changeColorScheme()
        }
        
        if let delayedPlaybackMsg = message as? DelayedPlaybackActionMessage {
            
            playSelectedTrackWithDelay(delayedPlaybackMsg.delay)
            return
        }
        
        if let insertGapsMsg = message as? InsertPlaybackGapsActionMessage {
            
            // Check if this message is intended for this playlist view
            if (insertGapsMsg.playlistType == nil || insertGapsMsg.playlistType == .tracks) {
                insertGap(insertGapsMsg.gapBeforeTrack, insertGapsMsg.gapAfterTrack)
            }
            
            return
        }
        
        if let removeGapMsg = message as? RemovePlaybackGapsActionMessage {
            
            if removeGapMsg.playlistType == nil || removeGapMsg.playlistType == .tracks {
                removeGaps()
            }
            
            return
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
    return input.map { key in NSPasteboard.PasteboardType(key) }
}
