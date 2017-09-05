/*
    View controller for the player/playlist
 */

import Cocoa

class PlaylistViewController: NSViewController, EventSubscriber, MessageSubscriber {
    
    // Displays the playlist and summary
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var lblPlaylistSummary: NSTextField!
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    private let player: PlayerDelegateProtocol = ObjectGraph.getPlayerDelegate()
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    override func viewDidLoad() {
        
        // Initialize UI with presentation settings (colors, sizes, etc)
        // No app state is needed here
        initStatelessUI()
        
        // Register self as a subscriber to various event notifications
        EventRegistry.subscribe(.trackChanged, subscriber: self, dispatchQueue: DispatchQueue.main)
        EventRegistry.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        EventRegistry.subscribe(.trackNotPlayed, subscriber: self, dispatchQueue: DispatchQueue.main)
        EventRegistry.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        EventRegistry.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        EventRegistry.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various message notifications
        SyncMessenger.subscribe(.playlistScrollUpNotification, subscriber: self)
        SyncMessenger.subscribe(.playlistScrollDownNotification, subscriber: self)
        
        // Load saved state (sound settings + playlist) from app config file and adjust UI elements according to that state
        let appState = ObjectGraph.getUIAppState()
        initStatefulUI(appState)
    }
    
    func initStatelessUI() {
        
        // Set up a mouse listener (for double clicks -> play selected track)
        playlistView.doubleAction = #selector(self.playlistDoubleClickAction(_:))
        playlistView.target = self
        
        // Enable drag n drop into the playlist view
        playlistView.register(forDraggedTypes: [String(kUTTypeFileURL)])
    }
    
    func initStatefulUI(_ appState: UIAppState) {
        
        // Set controls to reflect player state
        
        switch appState.repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
        
        switch appState.shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
            
        }
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    func updatePlaylistSummary(_ trackAddProgress: TrackAddedEventProgress? = nil) {
        
        let summary = playlist.getPlaylistSummary()
        let numTracks = summary.numTracks
        
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
            
            let oldPlayingTrackIndex = player.getPlayingTrack()?.index
            let newTrackIndex = playlist.removeTrack(index)
            
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
                setPlayPauseImage(UIConstants.imgPlay)
                let trackChgMsg = TrackChangedNotification(nil)
                SyncMessenger.publishNotification(trackChgMsg)
            }
        }
        
        showPlaylistSelectedRow()
    }
    
    // Play / Pause / Resume
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        do {
            
            let playbackInfo = try player.togglePlayPause()
            let playbackState = playbackInfo.playbackState
            
            switch playbackState {
                
            case .noTrack, .paused: setPlayPauseImage(UIConstants.imgPlay)
                SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                
            case .playing:
                
                if (playbackInfo.trackChanged) {
                    trackChange(playbackInfo.playingTrack)
                } else {
                    // Resumed the same track
                    setPlayPauseImage(UIConstants.imgPause)
                    SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                }
            }
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(error as! InvalidTrackError)
            }
        }
    }
    
    private func setPlayPauseImage(_ image: NSImage) {
        btnPlayPause.image = image
    }
    
    func playlistDoubleClickAction(_ sender: AnyObject) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        
        if (playlistView.selectedRow >= 0) {
            
            do {
                let track = try player.play(playlistView.selectedRow)
                trackChange(track)
                
            } catch let error as Error {
                
                if (error is InvalidTrackError) {
                    handleTrackNotPlayedError(error as! InvalidTrackError)
                }
            }
        }
    }
    
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        
        do {
            let trackInfo = try player.nextTrack()
            if (trackInfo?.track != nil) {
                trackChange(trackInfo)
            }
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(error as! InvalidTrackError)
            }
        }
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
    
    func handleTrackNotPlayedError(_ error: InvalidTrackError) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        DispatchQueue.main.async {
            
            // First, select the problem track and update the now playing info
            let playingTrack = self.player.getPlayingTrack()
            self.trackChange(playingTrack, true)
            
            // Position and display the dialog with info
            let alert = UIElements.trackNotPlayedAlertWithError(error)
            let window = WindowState.window!
            
            let orig = NSPoint(x: window.frame.origin.x, y: min(window.frame.origin.y + 227, window.frame.origin.y + window.frame.height - alert.window.frame.height))
            
            alert.window.setFrameOrigin(orig)
            alert.window.setIsVisible(true)
            
            alert.runModal()
            
            // Remove the bad track from the playlist and update the UI
            
            let playingTrackIndex = playingTrack!.index!
            self.removeSingleTrack(playingTrackIndex)
        }
    }
    
    @IBAction func prevTrackAction(_ sender: AnyObject) {
        
        do {
            
            let trackInfo = try player.previousTrack()
            if (trackInfo?.track != nil) {
                trackChange(trackInfo)
            }
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(error as! InvalidTrackError)
            }
        }
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    func trackChange(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            if (!errorState) {
                setPlayPauseImage(UIConstants.imgPause)
                
            } else {
                
                // Error state
                setPlayPauseImage(UIConstants.imgPlay)
            }
            
        } else {
            
            setPlayPauseImage(UIConstants.imgPlay)
        }
        
        selectTrack(newTrack == nil ? nil : newTrack!.index)
        
        let trackChgNotification = TrackChangedNotification(newTrack)
        SyncMessenger.publishNotification(trackChgNotification)
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
    
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        player.seekBackward()
//        updatePlayingTime()
    }
    
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        player.seekForward()
//        updatePlayingTime()
    }
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        playlist.clearPlaylist()
        playlistView.reloadData()
        updatePlaylistSummary()
        
        trackChange(nil)
    }
    
    @IBAction func repeatAction(_ sender: AnyObject) {
        
        let modes = playlist.toggleRepeatMode()
        
        switch modes.repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
        
        switch modes.shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
            
        }
    }
    
    @IBAction func shuffleAction(_ sender: AnyObject) {
        
        let modes = playlist.toggleShuffleMode()
        
        switch modes.shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
            
        }
        
        switch modes.repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
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
        if (playlist.getPlaylistSummary().numTracks > 0) {
            
            let dialog = UIElements.savePlaylistDialog
            
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSModalResponseOK) {
                
                let file = dialog.url
                playlist.savePlaylist(file!)
            }
        }
    }
    
    // Playlist info changed, need to reset the UI
    func consumeEvent(_ event: Event) {
        
        if event is TrackChangedEvent {
//            setSeekTimerState(false)
            let _event = event as! TrackChangedEvent
            trackChange(_event.newTrack)
            return
        }
        
        if event is TrackAddedEvent {
            let _evt = event as! TrackAddedEvent
            playlistView.noteNumberOfRowsChanged()
            updatePlaylistSummary(_evt.progress)
            return
        }
        
        if event is TrackNotPlayedEvent {
            let _evt = event as! TrackNotPlayedEvent
            handleTrackNotPlayedError(_evt.error)
            return
        }
        
        if event is TracksNotAddedEvent {
            let _evt = event as! TracksNotAddedEvent
            handleTracksNotAddedError(_evt.errors)
            return
        }
        
        if event is StartedAddingTracksEvent {
            startedAddingTracks()
            return
        }
        
        if event is DoneAddingTracksEvent {
            doneAddingTracks()
            return
        }
        
        // Not being used yet (to be used when duration is updated)
        if event is TrackInfoUpdatedEvent {
            let _event = event as! TrackInfoUpdatedEvent
            playlistView.reloadData(forRowIndexes: IndexSet([_event.trackIndex]), columnIndexes: UIConstants.playlistViewColumnIndexes)
            return
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
    
    @IBAction func playSelectedTrackMenuItemAction(_ sender: Any) {
        playSelectedTrack()
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
    
    @IBAction func togglePlayPauseMenuItemAction(_ sender: Any) {
        playPauseAction(sender as AnyObject)
    }
    
    @IBAction func nextTrackMenuItemAction(_ sender: Any) {
        nextTrackAction(sender as AnyObject)
    }
    
    @IBAction func previousTrackMenuItemAction(_ sender: Any) {
        prevTrackAction(sender as AnyObject)
    }
    
    @IBAction func seekForwardMenuItemAction(_ sender: Any) {
        seekForwardAction(sender as AnyObject)
    }
    
    @IBAction func seekBackwardMenuItemAction(_ sender: Any) {
        seekBackwardAction(sender as AnyObject)
    }
    
    @IBAction func toggleRepeatModeMenuItemAction(_ sender: Any) {
        repeatAction(sender as AnyObject)
    }
    
    @IBAction func toggleShuffleModeMenuItemAction(_ sender: Any) {
        shuffleAction(sender as AnyObject)
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
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
        return EmptyResponse.instance
    }
}
