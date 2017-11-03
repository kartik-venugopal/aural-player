import Cocoa

class PlaylistTracksViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber, ActionMessageSubscriber {
    
    // Displays the playlist and summary
    
    @IBOutlet weak var tracksView: NSTableView!
    
    // Delegate that performs CRUD actions on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private let plAcc: PlaylistAccessorProtocol = ObjectGraph.getPlaylistAccessor()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    override func viewDidLoad() {
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksRemoved, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackInfoUpdated, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.playingTrackInfoUpdatedNotification, subscriber: self)
        SyncMessenger.subscribe(.searchResultSelectionRequest, subscriber: self)
        
        SyncMessenger.subscribe(actionType: .removeTracks, subscriber: self)
        SyncMessenger.subscribe(actionType: .clearPlaylist, subscriber: self)
        SyncMessenger.subscribe(actionType: .moveTracksUp, subscriber: self)
        SyncMessenger.subscribe(actionType: .moveTracksDown, subscriber: self)
        SyncMessenger.subscribe(actionType: .refresh, subscriber: self)
        SyncMessenger.subscribe(actionType: .scrollToTop, subscriber: self)
        SyncMessenger.subscribe(actionType: .scrollToBottom, subscriber: self)
        SyncMessenger.subscribe(actionType: .showPlayingTrack, subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
    }
    
    func clearPlaylist() {
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
    }
    
    func removeTracks() {
        
        let selectedIndexes = tracksView.selectedRowIndexes
        if (selectedIndexes.count > 0) {
            
            // Special case: If all tracks were removed, this is the same as clearing the playlist, delegate to that (simpler and more efficient) function instead.
            if (selectedIndexes.count == tracksView.numberOfRows) {
                clearPlaylist()
                return
            }
            
            if (!selectedIndexes.isEmpty) {
                removeTracks(selectedIndexes)
            }
            
            // Clear the playlist selection
            tracksView.deselectAll(self)
        }
    }
    
    // Assume non-empty array and valid indexes
    private func removeTracks(_ indexes: IndexSet) {
        
        // Note down the index of the playing track, if there is one
        let oldPlayingTrackIndex = playbackInfo.getPlayingTrack()?.index
        
        // Remove the tracks from the playlist
        _ = playlist.removeTracks(indexes.toArray())
        
        if (oldPlayingTrackIndex != nil && indexes.contains(oldPlayingTrackIndex!)) {
            _ = SyncMessenger.publishRequest(StopPlaybackRequest.instance)
        }
    }
    
    func tracksRemoved(_ results: RemoveOperationResults) {
        
        let indexes = results.flatPlaylistResults
        
        // Update all rows from the first (i.e. smallest number) selected row, down to the end of the playlist
        let newPlaylistSize = playlist.size()
        let minIndex = (indexes.min())!
        let newLastIndex = newPlaylistSize - 1
        
        // If not all selected rows are contiguous and at the end of the playlist
        if (minIndex <= newLastIndex) {
            let rowIndexes = IndexSet(minIndex...newLastIndex)
            tracksView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
        }
        
        // Tell the playlist view that the number of rows has changed, and update the playlist summary
        tracksView.noteNumberOfRowsChanged()
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        var rowsArr = [Int]()
        
        if (oldTrack != nil) {
            rowsArr.append(oldTrack!.index)
        }
        
        if (newTrack != nil) {
            rowsArr.append(newTrack!.index)
        }
        
        tracksView.reloadData(forRowIndexes: IndexSet(rowsArr), columnIndexes: UIConstants.playlistViewColumnIndexes)
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ index: Int?) {
        
        if (tracksView.numberOfRows > 0) {

            if (index != nil && index! >= 0) {
                tracksView.selectRowIndexes(IndexSet(integer: index!), byExtendingSelection: false)
            }
            
            showPlaylistSelectedRow()
        }
    }
    
    // Scrolls the playlist to show its selected row
    private func showPlaylistSelectedRow() {
        
        if (tracksView.numberOfRows > 0 && tracksView.selectedRow >= 0) {
            tracksView.scrollRowToVisible(tracksView.selectedRow)
        }
    }
    
    // Scrolls the playlist view to the very top
    func scrollToTop() {
        
        if (tracksView.numberOfRows > 0) {
            tracksView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    func scrollToBottom() {
        
        if (tracksView.numberOfRows > 0) {
            tracksView.scrollRowToVisible(tracksView.numberOfRows - 1)
        }
    }
    
    func refresh() {
        tracksView.reloadData()
    }
    
    func moveTracksUp() {
        
        let selRows = tracksView.selectedRowIndexes
        let numRows = tracksView.numberOfRows
        
        /*
            If playlist empty or has only 1 row OR
            no tracks selected OR
            all tracks selected, don't do anything
         */
        if (numRows > 1 && selRows.count > 0 && selRows.count < numRows) {
            moveItems(playlist.moveTracksUp(selRows))
            tracksView.scrollRowToVisible(tracksView.selectedRow)
        }
    }
    
    func moveTracksDown() {
        
        let selRows = tracksView.selectedRowIndexes
        let numRows = tracksView.numberOfRows
        
        /*
            If playlist empty or has only 1 row OR
            no tracks selected OR
            all tracks selected, don't do anything
         */
        if (numRows > 1 && selRows.count > 0 && selRows.count < numRows) {
            moveItems(playlist.moveTracksDown(selRows))
            tracksView.scrollRowToVisible(tracksView.selectedRow)
        }
    }
    
    private func moveItems(_ results: ItemMovedResults) {
        
        for result in results.results {
            
            let trackMovedResult = result as! TrackMovedResult
            tracksView.moveRow(at: trackMovedResult.oldTrackIndex, to: trackMovedResult.newTrackIndex)
            
            let inx = [trackMovedResult.oldTrackIndex, trackMovedResult.newTrackIndex]
            tracksView.reloadData(forRowIndexes: IndexSet(inx), columnIndexes: UIConstants.playlistViewColumnIndexes)
        }
    }

    // Shows the currently playing track, within the playlist view
    func showPlayingTrack() {
        selectTrack(playbackInfo.getPlayingTrack()?.index)
    }
    
    private func showSearchResult(_ result: SearchResult) {
        selectTrack(result.location.trackIndex)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is TrackAddedAsyncMessage {
            
            let updateOp = BlockOperation(block: {
                self.tracksView.noteNumberOfRowsChanged()
            })
            
            playlistUpdateQueue.addOperation(updateOp)
            
            return
        }
        
        if let msg = message as? TracksRemovedAsyncMessage {
            
            let updateOp = BlockOperation(block: {
                self.tracksRemoved(msg.results)
            })
            
            playlistUpdateQueue.addOperation(updateOp)
        }
        
        if (message is TrackUpdatedAsyncMessage) {
            
            // Perform task serially wrt other such tasks
            
            let updateOp = BlockOperation(block: {
                
                let _msg = (message as! TrackUpdatedAsyncMessage)
                let index = _msg.trackIndex
                
                self.tracksView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: UIConstants.playlistViewColumnIndexes)
            })
            
            playlistUpdateQueue.addOperation(updateOp)
            
            return
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is TrackChangedNotification) {
            
            let msg = notification as! TrackChangedNotification
            trackChange(msg.oldTrack, msg.newTrack, msg.errorState)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if PlaylistViewState.current == .tracks, let req = request as? SearchResultSelectionRequest {
            showSearchResult(req.searchResult)
            
            return EmptyResponse.instance
        }
        
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? PlaylistActionMessage {
            
            if (msg.playlistType != nil && msg.playlistType != .tracks) {
                return
            }
            
            switch (msg.actionType) {
                
            case .refresh: refresh()
                
            case .removeTracks: removeTracks()
                
            case .showPlayingTrack: showPlayingTrack()

            case .moveTracksUp: moveTracksUp()
                
            case .moveTracksDown: moveTracksDown()
                
            case .scrollToTop: scrollToTop()
                
            case .scrollToBottom: scrollToBottom()
                
            default: return
                
            }
            
            return
        }
    }
}
