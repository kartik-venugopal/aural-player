/*
    View controller for playlist controls (adding/removing/reordering tracks)
 */

import Cocoa

class PlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber {
    
    // Displays the playlist and summary
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var lblPlaylistSummary: NSTextField!
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    // Box that encloses the playlist controls. Used to position the spinner.
    @IBOutlet weak var controlsBox: NSBox!
    
    // Delegate that performs CRUD actions on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    // Needed for playlist scrolling with arrow keys
    private var playlistKeyPressHandler: PlaylistKeyPressHandler?
    
    override func viewDidLoad() {
        
        // Enable drag n drop into the playlist view
        playlistView.register(forDraggedTypes: [String(kUTTypeFileURL)])
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackInfoUpdated, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.removeTrackRequest, subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
        
        // Set up key press handler to enable natural scrolling of the playlist view with arrow keys
        playlistKeyPressHandler = PlaylistKeyPressHandler(playlistView)
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(event: NSEvent!) -> NSEvent in
            self.playlistKeyPressHandler?.handle(event)
            return event;
        });
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    private func updatePlaylistSummary(_ trackAddProgress: TrackAddedAsyncMessageProgress? = nil) {
        
        let summary = playlist.summary()
        let numTracks = summary.size
        
        lblPlaylistSummary.stringValue = String(format: "%d %@   %@", numTracks, numTracks == 1 ? "track" : "tracks", StringUtils.formatSecondsToHMS(summary.totalDuration))
        
        // Update spinner
        if (trackAddProgress != nil) {
            repositionSpinner()
            playlistWorkSpinner.doubleValue = trackAddProgress!.percentage
        }
    }
    
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        let dialog = UIElements.openDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            addFiles(dialog.urls)
        }
    }
    
    // When a track add operation starts, the spinner needs to be initialized
    private func startedAddingTracks() {
        
        playlistWorkSpinner.doubleValue = 0
        repositionSpinner()
        playlistWorkSpinner.isHidden = false
        playlistWorkSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the spinner needs to be de-initialized
    private func doneAddingTracks() {
        playlistWorkSpinner.stopAnimation(self)
        playlistWorkSpinner.isHidden = true
    }
    
    // Move the spinner so it is adjacent to the summary text, on the left
    private func repositionSpinner() {
        
        let summaryString: NSString = lblPlaylistSummary.stringValue as NSString
        let size: CGSize = summaryString.size(withAttributes: [NSFontAttributeName: lblPlaylistSummary.font as AnyObject])
        let lblWidth = size.width
        
        let controlsBoxWidth = controlsBox.frame.width
        let newX = controlsBoxWidth - lblWidth - 10 - playlistWorkSpinner.frame.width
        playlistWorkSpinner.frame.origin.x = newX
    }
    
    @IBAction func removeSingleTrackAction(_ sender: AnyObject) {
        removeSingleTrack(playlistView.selectedRow)
    }
    
    private func removeSingleTrack(_ index: Int) {
        
        if (index >= 0) {
            
            let oldPlayingTrackIndex = playbackInfo.getPlayingTrack()?.index
            playlist.removeTrack(index)
            
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
            
            if (oldPlayingTrackIndex == index) {
                // Request the player to stop playback, if the playing track was removed
                SyncMessenger.publishRequest(StopPlaybackRequest.instance)
            }
        }
    }
    
    private func handleTracksNotAddedError(_ errors: [InvalidTrackError]) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            UIUtils.showAlert(UIElements.tracksNotAddedAlertWithErrors(errors))
        }
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
        
        playlistView.reloadData(forRowIndexes: IndexSet(rowsArr), columnIndexes: UIConstants.playlistViewColumnIndexes)
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ index: Int?) {
        
        if (playlistView.numberOfRows > 0) {
            
            if (index != nil && index! >= 0) {
                playlistView.selectRowIndexes(IndexSet(integer: index!), byExtendingSelection: false)
            } else {
                // Select first track in list
                playlistView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            }
            
            showPlaylistSelectedRow()
        }
    }
    
    // Scrolls the playlist to show its selected row
    private func showPlaylistSelectedRow() {
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.selectedRow)
        }
    }
    
    // Scrolls the playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.numberOfRows - 1)
        }
    }
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        playlist.clear()
        playlistView.reloadData()
        updatePlaylistSummary()
        
        // Request the player to stop playback, if there is a track playing
        SyncMessenger.publishRequest(StopPlaybackRequest.instance)
    }
    
    @IBAction func moveTrackDownAction(_ sender: AnyObject) {
        movePlaylistTrackDown()
        showPlaylistSelectedRow()
    }
    
    @IBAction func moveTrackUpAction(_ sender: AnyObject) {
        movePlaylistTrackUp()
        showPlaylistSelectedRow()
    }
    
    private func movePlaylistTrackUp() {
        
        let oldSelRow = playlistView.selectedRow
        let selRow = playlist.moveTrackUp(oldSelRow)
        
        // Reload data in the two affected rows
        let rowIndexes = IndexSet([selRow, oldSelRow])
        playlistView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
        
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    private func movePlaylistTrackDown() {
        
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
    private func addFiles(_ files: [URL]) {
        startedAddingTracks()
        playlist.addFiles(files)
    }
    
    // Shows the currently playing track, within the playlist view
    @IBAction func showInPlaylistAction(_ sender: Any) {
        
        if let playingTrackIndex = playbackInfo.getPlayingTrack()?.index {
            selectTrack(playingTrackIndex)
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is TrackAddedAsyncMessage {
            
            // Perform task serially wrt other such tasks
            
            let updateOp = BlockOperation(block: {
            
                let _msg = message as! TrackAddedAsyncMessage
                self.playlistView.noteNumberOfRowsChanged()
                self.updatePlaylistSummary(_msg.progress)
            })
                
            playlistUpdateQueue.addOperation(updateOp)
            
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
        
        if (message is TrackInfoUpdatedAsyncMessage) {
            
            // Perform task serially wrt other such tasks
            
            let updateOp = BlockOperation(block: {
                
                let index = (message as! TrackInfoUpdatedAsyncMessage).trackIndex
                
                self.playlistView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: UIConstants.playlistViewColumnIndexes)
                self.updatePlaylistSummary()
                
                // If this is the playing track, tell other views that info has been updated
                let playingTrackIndex = self.playbackInfo.getPlayingTrack()?.index
                if (playingTrackIndex == index) {
                    SyncMessenger.publishNotification(PlayingTrackInfoUpdatedNotification.instance)
                }
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
        
        if (request is RemoveTrackRequest) {
            let req = request as! RemoveTrackRequest
            removeSingleTrack(req.index)
        }
        
        return EmptyResponse.instance
    }
}
