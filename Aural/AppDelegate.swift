/*
    Entry point for the Aural Player application. Performs all interaction with the UI and delegates music player operations to PlayerDelegate.
 */
import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, EventSubscriber {
    
    @IBOutlet weak var window: NSWindow!
    
    // Playlist search modal dialog fields
    @IBOutlet weak var searchPanel: NSPanel!
    @IBOutlet weak var searchField: ColoredCursorSearchField!
    
    @IBOutlet weak var searchResultsSummaryLabel: NSTextField!
    @IBOutlet weak var searchResultMatchInfo: NSTextField!
    
    @IBOutlet weak var btnNextSearch: NSButton!
    @IBOutlet weak var btnPreviousSearch: NSButton!
    
    @IBOutlet weak var searchByName: NSButton!
    @IBOutlet weak var searchByArtist: NSButton!
    @IBOutlet weak var searchByTitle: NSButton!
    @IBOutlet weak var searchByAlbum: NSButton!
    
    @IBOutlet weak var comparisonTypeContains: NSButton!
    @IBOutlet weak var comparisonTypeEquals: NSButton!
    @IBOutlet weak var comparisonTypeBeginsWith: NSButton!
    @IBOutlet weak var comparisonTypeEndsWith: NSButton!
    
    @IBOutlet weak var searchCaseSensitive: NSButton!
    
    // Playlist sort modal dialog fields
    @IBOutlet weak var sortPanel: NSPanel!
    
    @IBOutlet weak var sortByName: NSButton!
    @IBOutlet weak var sortByDuration: NSButton!
    
    @IBOutlet weak var sortAscending: NSButton!
    @IBOutlet weak var sortDescending: NSButton!
    
    // Displays the playlist and summary
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var lblPlaylistSummary: NSTextField!
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Now playing track info
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var bigLblTrack: NSTextField!
    
    @IBOutlet weak var lblPlayingTime: NSTextField!
    @IBOutlet weak var musicArtView: NSImageView!
    @IBOutlet weak var seekSlider: NSSlider!
    
    @IBOutlet weak var btnMoreInfo: NSButton!
    
    // Popover view that displays detailed track info
    lazy var popover: NSPopover = {
        let popover = NSPopover()
        popover.behavior = .semitransient
        let ctrlr = PopoverController(nibName: "PopoverController", bundle: Bundle.main)
        popover.contentViewController = ctrlr
        return popover
    }()
    
    // PlayerDelegate accepts all requests originating from the UI
    let player: PlayerDelegate = PlayerDelegate.instance()
    
    // Timer that periodically updates the seek bar
    var seekTimer: ScheduledTaskExecutor? = nil
    
    // Current playlist search results
    var searchResults: SearchResults?
    
    var preferences: Preferences = Preferences.instance()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Initialize UI with presentation settings (colors, sizes, etc)
        // No app state is needed here
        initStatelessUI()
        
        // Set up key press handler
        KeyPressHandler.initialize(self)
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(evt: NSEvent!) -> NSEvent in
            KeyPressHandler.handle(evt)
            return evt;
        });
        
        // Register self as a subscriber to various event notifications
        EventRegistry.subscribe(.trackChanged, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        EventRegistry.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        EventRegistry.subscribe(.trackNotPlayed, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        EventRegistry.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        EventRegistry.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        EventRegistry.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Load saved state (sound settings + playlist) from app config file and adjust UI elements according to that state
        let appState = AppInitializer.getUIAppState()
        initStatefulUI(appState)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        
        // TODO: Change this to a notification
        player.appExiting()
        
        SyncMessenger.publishNotification(AppExitNotification.instance)
        AppStateIO.save(AppInitializer.getAppState())
    }
    
    func initStatelessUI() {
        
        // Set up a mouse listener (for double clicks -> play selected track)
        playlistView.doubleAction = #selector(self.playlistDoubleClickAction(_:))
        
        // Enable drag n drop into the playlist view
        playlistView.register(forDraggedTypes: [String(kUTTypeFileURL)])
        
        searchPanel.titlebarAppearsTransparent = true
        sortPanel.titlebarAppearsTransparent = true
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
        
        // Timer interval depends on whether time stretch unit is active
        seekTimer = ScheduledTaskExecutor(intervalMillis: appState.seekTimerInterval, task: {self.updatePlayingTime()}, queue: DispatchQueue.main)
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    func updatePlaylistSummary(_ trackAddProgress: TrackAddedEventProgress? = nil) {
        
        let summary = player.getPlaylistSummary()
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
            
            let newTrackIndex = player.removeTrack(index)
            
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
            
            if (newTrackIndex == nil) {
                clearNowPlayingInfo()
            }
        }
        
        showPlaylistSelectedRow()
    }
    
    func hidePopover() {
        if (popover.isShown) {
            popover.performClose(nil)
        }
    }
    
    // Play / Pause / Resume
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        do {
            
            let playbackInfo = try player.togglePlayPause()
            
            switch playbackInfo.playbackState {
                
            case .noTrack, .paused: setSeekTimerState(false)
            setPlayPauseImage(UIConstants.imgPlay)
                
            case .playing:
                
                if (playbackInfo.trackChanged) {
                    trackChange(playbackInfo.playingTrack)
                } else {
                    // Resumed the same track
                    setSeekTimerState(true)
                    setPlayPauseImage(UIConstants.imgPause)
                }
            }
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(error as! InvalidTrackError)
            }
        }
    }
    
    func showNowPlayingInfo(_ track: Track) {
        
        if (track.longDisplayName != nil) {
            
            if (track.longDisplayName!.artist != nil) {
                
                // Both title and artist
                lblTrackArtist.stringValue = "Artist:  " + track.longDisplayName!.artist!
                lblTrackTitle.stringValue = "Title:  " + track.longDisplayName!.title!
                
                bigLblTrack.isHidden = true
                lblTrackArtist.isHidden = false
                lblTrackTitle.isHidden = false
                
            } else {
                
                // Title only
                bigLblTrack.isHidden = false
                lblTrackArtist.isHidden = true
                lblTrackTitle.isHidden = true
                
                bigLblTrack.stringValue = track.longDisplayName!.title!
            }
            
        } else {
            
            // Short display name
            bigLblTrack.isHidden = false
            lblTrackArtist.isHidden = true
            lblTrackTitle.isHidden = true
            
            bigLblTrack.stringValue = track.shortDisplayName!
        }
        
        if (track.metadata!.art != nil) {
            musicArtView.image = track.metadata!.art!
        } else {
            musicArtView.image = UIConstants.imgMusicArt
        }
    }
    
    func clearNowPlayingInfo() {
        lblTrackArtist.stringValue = ""
        lblTrackTitle.stringValue = ""
        bigLblTrack.stringValue = ""
        lblPlayingTime.stringValue = UIConstants.zeroDurationString
        seekSlider.floatValue = 0
        musicArtView.image = UIConstants.imgMusicArt
        btnMoreInfo.isHidden = true
        setPlayPauseImage(UIConstants.imgPlay)
        hidePopover()
    }
    
    private func setPlayPauseImage(_ image: NSImage) {
        btnPlayPause.image = image
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        
        if (timerOn) {
            seekSlider.isEnabled = true
            seekTimer?.startOrResume()
        } else {
            seekTimer?.pause()
            seekSlider.isEnabled = false
        }
    }
    
    func updatePlayingTime() {
        
        if (player.getPlaybackState() == .playing) {
            
            let seekPosn = player.getSeekSecondsAndPercentage()
            
            lblPlayingTime.stringValue = Utils.formatDuration(seekPosn.seconds)
            seekSlider.doubleValue = seekPosn.percentage
        }
    }
    
    func resetPlayingTime() {
        
        lblPlayingTime.stringValue = UIConstants.zeroDurationString
        seekSlider.floatValue = 0
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
            
            let orig = NSPoint(x: self.window.frame.origin.x, y: min(self.window.frame.origin.y + 227, self.window.frame.origin.y + self.window.frame.height - alert.window.frame.height))
            
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
            
            let orig = NSPoint(x: self.window.frame.origin.x, y: min(self.window.frame.origin.y + 227, self.window.frame.origin.y + self.window.frame.height - alert.window.frame.height))
            
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
            
            showNowPlayingInfo(newTrack!.track!)
            
            if (!errorState) {
                setSeekTimerState(true)
                setPlayPauseImage(UIConstants.imgPause)
                btnMoreInfo.isHidden = false
                
                if (popover.isShown) {
                    player.getMoreInfo()
                    (popover.contentViewController as! PopoverController).refresh()
                }
                
            } else {
                
                // Error state
                
                setSeekTimerState(false)
                setPlayPauseImage(UIConstants.imgPlay)
                btnMoreInfo.isHidden = true
                
                if (popover.isShown) {
                    hidePopover()
                }
            }
            
        } else {
            
            setSeekTimerState(false)
            clearNowPlayingInfo()
        }
        
        resetPlayingTime()
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
    
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        player.seekBackward()
        updatePlayingTime()
    }
    
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        player.seekForward()
        updatePlayingTime()
    }
    
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
        updatePlayingTime()
    }
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        player.clearPlaylist()
        playlistView.reloadData()
        updatePlaylistSummary()
        
        trackChange(nil)
    }
    
    @IBAction func repeatAction(_ sender: AnyObject) {
        
        let modes = player.toggleRepeatMode()
        
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
        
        let modes = player.toggleShuffleMode()
        
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
    
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let playingTrack = player.getMoreInfo()
        if (playingTrack == nil) {
            return
        }
        
        if (popover.isShown) {
            popover.performClose(nil)
            
        } else {
            
            let positioningRect = NSZeroRect
            let preferredEdge = NSRectEdge.maxX
            
            (popover.contentViewController as! PopoverController).refresh()
            popover.show(relativeTo: positioningRect, of: btnMoreInfo as NSView, preferredEdge: preferredEdge)
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
        let selRow = player.moveTrackUp(oldSelRow)
        
        // Reload data in the two affected rows
        let rowIndexes = IndexSet([selRow, oldSelRow])
        playlistView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
        
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    func shiftPlaylistTrackDown() {
        
        let oldSelRow = playlistView.selectedRow
        let selRow = player.moveTrackDown(oldSelRow)
        
        // Reload data in the two affected rows
        let rowIndexes = IndexSet([selRow, oldSelRow])
        playlistView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
        
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    @IBAction func savePlaylistAction(_ sender: AnyObject) {
        
        // Make sure there is at least one track to save
        if (player.getPlaylistSummary().numTracks > 0) {
            
            let dialog = UIElements.savePlaylistDialog
            
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSModalResponseOK) {
                
                let file = dialog.url
                player.savePlaylist(file!)
            }
        }
    }
    
    // Playlist info changed, need to reset the UI
    func consumeEvent(_ event: Event) {
        
        if event is TrackChangedEvent {
            setSeekTimerState(false)
            let _event = event as! TrackChangedEvent
            trackChange(_event.newTrack)
        }
        
        if event is TrackAddedEvent {
            let _evt = event as! TrackAddedEvent
            playlistView.noteNumberOfRowsChanged()
            updatePlaylistSummary(_evt.progress)
        }
        
        if event is TrackNotPlayedEvent {
            let _evt = event as! TrackNotPlayedEvent
            handleTrackNotPlayedError(_evt.error)
        }
        
        if event is TracksNotAddedEvent {
            let _evt = event as! TracksNotAddedEvent
            handleTracksNotAddedError(_evt.errors)
        }
        
        if event is StartedAddingTracksEvent {
            startedAddingTracks()
        }
        
        if event is DoneAddingTracksEvent {
            doneAddingTracks()
        }
        
        // Not being used yet (to be used when duration is updated)
        if event is TrackInfoUpdatedEvent {
            let _event = event as! TrackInfoUpdatedEvent
            playlistView.reloadData(forRowIndexes: IndexSet([_event.trackIndex]), columnIndexes: UIConstants.playlistViewColumnIndexes)
        }
    }
    
    // Adds a set of files (or directories, i.e. files within them) to the current playlist, if supported
    func addFiles(_ files: [URL]) {
        startedAddingTracks()
        player.addFiles(files)
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
    
    @IBAction func trackInfoMenuItemAction(_ sender: Any) {
        moreInfoAction(sender as AnyObject)
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
    
    @IBAction func searchPlaylistAction(_ sender: Any) {
        
        // Don't do anything if no tracks in playlist
        if (playlistView.numberOfRows == 0) {
            return
        }
        
        // Position the search modal dialog and show it
        let searchFrameOrigin = NSPoint(x: window.frame.origin.x + 16, y: min(window.frame.origin.y + 227, window.frame.origin.y + window.frame.height - searchPanel.frame.height))
        
        searchField.stringValue = ""
        resetSearchFields()
        
        searchPanel.setFrameOrigin(searchFrameOrigin)
        searchPanel.setIsVisible(true)
        
        searchPanel.makeFirstResponder(searchField)
        
        NSApp.runModal(for: searchPanel)
        searchPanel.close()
    }
    
    // Called when any of the search criteria have changed, performs a new search
    func searchQueryChanged() {
        
        let searchText = searchField.stringValue
        
        if (searchText == "") {
            resetSearchFields()
            return
        }
        
        let searchFields = SearchFields()
        searchFields.name = Bool(searchByName.state)
        searchFields.artist = Bool(searchByArtist.state)
        searchFields.title = Bool(searchByTitle.state)
        searchFields.album = Bool(searchByAlbum.state)
        
        // No fields to compare, don't do the search
        if (searchFields.noFieldsSelected()) {
            resetSearchFields()
            return
        }
        
        let searchOptions = SearchOptions()
        searchOptions.caseSensitive = Bool(searchCaseSensitive.state)
        
        let query = SearchQuery(text: searchText)
        query.fields = searchFields
        query.options = searchOptions
        
        if (comparisonTypeEquals.state == 1) {
            query.type = .equals
        } else if (comparisonTypeContains.state == 1) {
            query.type = .contains
        } else if (comparisonTypeBeginsWith.state == 1) {
            query.type = .beginsWith
        } else {
            query.type = .endsWith
        }
        
        searchResults = player.searchPlaylist(searchQuery: query)
        
        if ((searchResults?.count)! > 0) {
            
            // Show the first result
            nextSearchAction(self)
            
        } else {
            resetSearchFields()
        }
    }
    
    func resetSearchFields() {
        
        if (searchField.stringValue.isEmpty) {
            searchResultsSummaryLabel.stringValue = "No results"
        } else {
            searchResultsSummaryLabel.stringValue = "No results found"
        }
        searchResultMatchInfo.stringValue = ""
        btnNextSearch.isHidden = true
        btnPreviousSearch.isHidden = true
    }
    
    // Iterates to the previous search result
    @IBAction func previousSearchAction(_ sender: Any) {
        updateSearchPanelWithResult(searchResult: (searchResults?.previous())!)
    }
    
    // Iterates to the next search result
    @IBAction func nextSearchAction(_ sender: Any) {
        updateSearchPanelWithResult(searchResult: (searchResults?.next())!)
    }
    
    // Updates displayed search results info with the current search result
    func updateSearchPanelWithResult(searchResult: SearchResult) {
        
        // Select the track in the playlist view, to show the user where the track is
        selectTrack(searchResult.index)
        
        let resultsText = (searchResults?.count)! == 1 ? "result found" : "results found"
        searchResultsSummaryLabel.stringValue = String(format: "%d %@. Selected %d / %d", (searchResults?.count)!, resultsText, (searchResults?.cursor)! + 1, (searchResults?.count)!)
        
        searchResultMatchInfo.stringValue = String(format: "Matched %@: '%@'", searchResult.match.fieldKey.lowercased(), searchResult.match.fieldValue)
        
        btnNextSearch.isHidden = !searchResult.hasNext
        btnPreviousSearch.isHidden = !searchResult.hasPrevious
    }

    @IBAction func searchDoneAction(_ sender: Any) {
        dismissModalDialog()
    }

    @IBAction func searchPlaylistMenuItemAction(_ sender: Any) {
        searchPlaylistAction(sender)
    }
    
    @IBAction func searchQueryChangedAction(_ sender: Any) {
        searchQueryChanged()
    }
    
    // Called by KeyPressHandler to determine if any modal dialog is open
    func modalDialogOpen() -> Bool {
        
        return searchPanel.isVisible || sortPanel.isVisible || UIElements.openDialog.isVisible || UIElements.savePlaylistDialog.isVisible || UIElements.saveRecordingDialog.isVisible
    }
    
    @IBAction func sortPlaylistAction(_ sender: Any) {
        
        // Don't do anything if no tracks in playlist
        if (playlistView.numberOfRows == 0) {
            return
        }
        
        // Position the sort modal dialog and show it
        let sortFrameOrigin = NSPoint(x: window.frame.origin.x + 73, y: min(window.frame.origin.y + 227, window.frame.origin.y + window.frame.height - sortPanel.frame.height))
        
        sortPanel.setFrameOrigin(sortFrameOrigin)
        sortPanel.setIsVisible(true)
        
        NSApp.runModal(for: sortPanel)
        sortPanel.close()
    }
    
    @IBAction func sortOptionsChangedAction(_ sender: Any) {
        // Do nothing ... this action function is just to get the radio button groups to work
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        // Gather field values
        let sortOptions = Sort()
        sortOptions.field = sortByName.state == 1 ? SortField.name : SortField.duration
        sortOptions.order = sortAscending.state == 1 ? SortOrder.ascending : SortOrder.descending
        
        player.sortPlaylist(sort: sortOptions)
        dismissModalDialog()
        
        playlistView.reloadData()
        selectTrack(player.getPlayingTrack()?.index)
        showPlaylistSelectedRow()
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        dismissModalDialog()
    }
    
    func dismissModalDialog() {
        NSApp.stopModal()
    }
    
    @IBAction func sortPlaylistMenuItemAction(_ sender: Any) {
        sortPlaylistAction(sender)
    }
}
