/*
    View controller for the playlist
 */

import Cocoa

class PlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber {
    
    // Displays the playlist and summary
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var lblPlaylistSummary: NSTextField!
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func viewDidLoad() {
        
        // Enable drag n drop into the playlist view
        playlistView.register(forDraggedTypes: [String(kUTTypeFileURL)])
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various message notifications
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.playlistScrollUpNotification, subscriber: self)
        SyncMessenger.subscribe(.playlistScrollDownNotification, subscriber: self)
        SyncMessenger.subscribe(.removeTrackRequest, subscriber: self)
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    func updatePlaylistSummary(_ trackAddProgress: TrackAddedAsyncMessageProgress? = nil) {
        
        let summary = playlist.summary()
        let numTracks = summary.size
        
        lblPlaylistSummary.stringValue = String(format: "%d %@   %@", numTracks, numTracks == 1 ? "track" : "tracks", Utils.formatDuration(summary.totalDuration))
        
        // Update spinner
        if (trackAddProgress != nil) {
            repositionSpinner()
            playlistWorkSpinner.doubleValue = trackAddProgress!.percentage
        }
    }
    
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        let selRow = playlistView.selectedRow
        let dialog = UIElements.openDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            addFiles(dialog.urls)
        }
        
        playlistView.reloadData()
        updatePlaylistSummary()
        
        selectTrack(selRow)
    }
    
    func startedAddingTracks() {
        
        playlistWorkSpinner.doubleValue = 0
        repositionSpinner()
        playlistWorkSpinner.isHidden = false
        playlistWorkSpinner.startAnimation(self)
    }
    
    func doneAddingTracks() {
        playlistWorkSpinner.stopAnimation(self)
        playlistWorkSpinner.isHidden = true
    }
    
    // Move the spinner so it is adjacent to the summary text, on the left
    func repositionSpinner() {
        
        let summaryString: NSString = lblPlaylistSummary.stringValue as NSString
        let size: CGSize = summaryString.size(withAttributes: [NSFontAttributeName: lblPlaylistSummary.font as AnyObject])
        let lblWidth = size.width
        
        let newX = 381 - lblWidth - 10 - playlistWorkSpinner.frame.width
        playlistWorkSpinner.frame.origin.x = newX
    }
    
    @IBAction func removeSingleTrackAction(_ sender: AnyObject) {
        removeSingleTrack(playlistView.selectedRow)
    }
    
    func removeSingleTrack(_ index: Int) {
        
        if (index >= 0) {
            
            let oldPlayingTrackIndex = playbackInfo.getPlayingTrack()?.index
            playlist.removeTrack(index)
            
            let newTrackIndex = playbackInfo.getPlayingTrack()?.index
            
            // The new number of rows (after track removal) is one less than the size of the playlist view, because the view has not yet been updated
            let numRows = playlistView.numberOfRows - 1
            
            if (numRows > index) {
                
                // Update all rows from the selected row down to the end of the playlist
                let rowIndexes = IndexSet(index...(numRows - 1))
                playlistView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
            }
            
            // Tell the playlist view to remove one row
            playlistView.noteNumberOfRowsChanged()
            updatePlaylistSummary()
            selectTrack(newTrackIndex)
            
            if (oldPlayingTrackIndex == index) {
                let stopPlaybackRequest = StopPlaybackRequest.instance
                SyncMessenger.publishRequest(stopPlaybackRequest)
            }
        }
        
        showPlaylistSelectedRow()
    }
    
    func handleTracksNotAddedError(_ errors: [InvalidTrackError]) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            
            let alert = UIElements.tracksNotAddedAlertWithErrors(errors)
            let window = WindowState.window!
            
            let orig = NSPoint(x: window.frame.origin.x, y: min(window.frame.origin.y + 227, window.frame.origin.y + window.frame.height - alert.window.frame.height))
            
            alert.window.setFrameOrigin(orig)
            alert.window.setIsVisible(true)
            
            alert.runModal()
        }
    }
    
    // The "errorState" arg indicates whether the playbackInfo is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    func trackChange(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        selectTrack(newTrack == nil ? nil : newTrack!.index)
    }
    
    func selectTrack(_ index: Int?) {
        
        if index != nil && index! >= 0 {
            
            playlistView.selectRowIndexes(IndexSet(integer: index!), byExtendingSelection: false)
            showPlaylistSelectedRow()
            
        } else {
            // Select first track in list, if list not empty
            if (playlistView.numberOfRows > 0) {
                playlistView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            }
        }
    }
    
    func showPlaylistSelectedRow() {
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.selectedRow)
        }
    }
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        playlist.clear()
        playlistView.reloadData()
        updatePlaylistSummary()
        
        let stopPlaybackRequest = StopPlaybackRequest.instance
        SyncMessenger.publishRequest(stopPlaybackRequest)
    }
    
    private func scrollPlaylistUp() {
        
        let selRow = playlistView.selectedRow
        if (selRow > 0) {
            playlistView.selectRowIndexes(IndexSet(integer: selRow - 1), byExtendingSelection: false)
            showPlaylistSelectedRow()
        }
    }
    
    private func scrollPlaylistDown() {
        
        let selRow = playlistView.selectedRow
        if (selRow < (playlistView.numberOfRows - 1)) {
            playlistView.selectRowIndexes(IndexSet(integer: selRow + 1), byExtendingSelection: false)
            showPlaylistSelectedRow()
        }
    }
    
    @IBAction func moveTrackDownAction(_ sender: AnyObject) {
        shiftPlaylistTrackDown()
        showPlaylistSelectedRow()
    }
    
    @IBAction func moveTrackUpAction(_ sender: AnyObject) {
        shiftPlaylistTrackUp()
        showPlaylistSelectedRow()
    }
    
    func shiftPlaylistTrackUp() {
        
        let oldSelRow = playlistView.selectedRow
        let selRow = playlist.moveTrackUp(oldSelRow)
        
        // Reload data in the two affected rows
        let rowIndexes = IndexSet([selRow, oldSelRow])
        playlistView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
        
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    func shiftPlaylistTrackDown() {
        
        let oldSelRow = playlistView.selectedRow
        let selRow = playlist.moveTrackDown(oldSelRow)
        
        // Reload data in the two affected rows
        let rowIndexes = IndexSet([selRow, oldSelRow])
        playlistView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
        
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    @IBAction func savePlaylistAction(_ sender: AnyObject) {
        
        // Make sure there is at least one track to save
        if (playlist.summary().size > 0) {
            
            let dialog = UIElements.savePlaylistDialog
            
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSModalResponseOK) {
                
                let file = dialog.url
                playlist.savePlaylist(file!)
            }
        }
    }
    
    // Adds a set of files (or directories, i.e. files within them) to the current playlist, if supported
    func addFiles(_ files: [URL]) {
        startedAddingTracks()
        playlist.addFiles(files)
    }
    
    @IBAction func addFilesMenuItemAction(_ sender: Any) {
        addTracksAction(sender as AnyObject)
    }
    
    @IBAction func savePlaylistMenuItemAction(_ sender: Any) {
        savePlaylistAction(sender as AnyObject)
    }
    
    @IBAction func moveTrackUpMenuItemAction(_ sender: Any) {
        moveTrackUpAction(sender as AnyObject)
    }
    
    @IBAction func moveTrackDownMenuItemAction(_ sender: Any) {
        moveTrackDownAction(sender as AnyObject)
    }
    
    @IBAction func removeTrackMenuItemAction(_ sender: Any) {
        removeSingleTrackAction(sender as AnyObject)
    }
    
    @IBAction func clearPlaylistMenuItemAction(_ sender: Any) {
        clearPlaylistAction(sender as AnyObject)
    }
    
    // Playlist info changed, need to reset the UI
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is TrackAddedAsyncMessage {
            let _msg = message as! TrackAddedAsyncMessage
            playlistView.noteNumberOfRowsChanged()
            updatePlaylistSummary(_msg.progress)
            return
        }
        
        if message is TracksNotAddedAsyncMessage {
            let _msg = message as! TracksNotAddedAsyncMessage
            handleTracksNotAddedError(_msg.errors)
            return
        }
        
        if message is StartedAddingTracksAsyncMessage {
            startedAddingTracks()
            return
        }
        
        if message is DoneAddingTracksAsyncMessage {
            doneAddingTracks()
            return
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is TrackChangedNotification) {
            let msg = notification as! TrackChangedNotification
            trackChange(msg.newTrack)
        }
        
        if (notification is PlaylistScrollUpNotification) {
            scrollPlaylistUp()
            return
        }
        
        if (notification is PlaylistScrollDownNotification) {
            scrollPlaylistDown()
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is RemoveTrackRequest) {
            let req = request as! RemoveTrackRequest
            removeSingleTrack(req.index)
        }
        
        return EmptyResponse.instance
    }
}
