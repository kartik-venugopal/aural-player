import Cocoa

/*
    View controller for the flat ("Tracks") playlist view
 */
class PlaylistTracksViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playlistView: NSTableView!
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    override func viewDidLoad() {
        
        // Register as a subscriber to various message notifications
        AsyncMessenger.subscribe([.trackAdded, .tracksRemoved, .trackInfoUpdated], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .searchResultSelectionRequest], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.removeTracks, .moveTracksUp, .moveTracksDown, .refresh, .showPlayingTrack, .playSelectedItem], subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
    }
    
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
       
        let selRow = playlistView.selectedRow
        if (selRow >= 0) {
            _ = SyncMessenger.publishRequest(PlaybackRequest(index: selRow))
            
            // Clear the selection and reload those rows
            let selIndexes = playlistView.selectedRowIndexes
            playlistView.deselectAll(self)
            playlistView.reloadData(forRowIndexes: selIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    private func clearPlaylist() {
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
    }
    
    private func removeTracks() {
        
        let selectedIndexes = playlistView.selectedRowIndexes
        if (selectedIndexes.count > 0) {
            
            // Special case: If all tracks were removed, this is the same as clearing the playlist, delegate to that (simpler and more efficient) function instead.
            if (selectedIndexes.count == playlistView.numberOfRows) {
                clearPlaylist()
                return
            }
            
            if (!selectedIndexes.isEmpty) {
                playlist.removeTracks(selectedIndexes)
                
                // Clear the playlist selection
                playlistView.deselectAll(self)
            }
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ index: Int?) {
        
        if (playlistView.numberOfRows > 0 && index != nil && index! >= 0) {

            playlistView.selectRowIndexes(IndexSet(integer: index!), byExtendingSelection: false)
            playlistView.scrollRowToVisible(index!)
        }
    }
    
    private func refresh() {
        playlistView.reloadData()
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
    
    private func moveItems(_ results: ItemMoveResults) {
        
        for result in results.results as! [TrackMoveResult] {
            
            playlistView.moveRow(at: result.oldTrackIndex, to: result.newTrackIndex)
            
            playlistView.reloadData(forRowIndexes: IndexSet([result.oldTrackIndex, result.newTrackIndex]), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }

    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        selectTrack(playbackInfo.getPlayingTrack()?.index)
    }
    
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        DispatchQueue.main.async {
            self.playlistView.noteNumberOfRowsChanged()
        }
    }
    
    private func trackInfoUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        DispatchQueue.main.async {
            self.playlistView.reloadData(forRowIndexes: IndexSet(integer: message.trackIndex), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        let indexes = message.results.flatPlaylistResults
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        let minIndex = (indexes.min())!
        let maxIndex = playlist.size() - 1
        
        // If not all removed rows are contiguous and at the end of the playlist
        if (minIndex <= maxIndex) {
            
            playlistView.reloadData(forRowIndexes: IndexSet(minIndex...maxIndex), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
        
        // Tell the playlist view that the number of rows has changed
        playlistView.noteNumberOfRowsChanged()
    }
    
    private func trackChanged(_ message: TrackChangedNotification) {
        
        let oldTrack = message.oldTrack
        let newTrack = message.newTrack
        
        var refreshIndexes = [Int]()
        
        if (oldTrack != nil) {
            refreshIndexes.append(oldTrack!.index)
        }
        
        if (newTrack != nil) {
            refreshIndexes.append(newTrack!.index)
        }
        
        playlistView.reloadData(forRowIndexes: IndexSet(refreshIndexes), columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
    }
    
    private func handleSearchResultSelection(_ request: SearchResultSelectionRequest) {
        
        if PlaylistViewState.current == .tracks {
            
            // Select (show) the search result within the playlist view
            selectTrack(request.searchResult.location.trackIndex)
        }
    }
    
    // MARK: Message handlers
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        case .trackInfoUpdated:
            
            trackInfoUpdated(message as! TrackUpdatedAsyncMessage)
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
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
        
        let msg = message as! PlaylistActionMessage
        
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
        }
    }
}
