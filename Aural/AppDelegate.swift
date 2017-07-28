/*
 Entry point for the Aural Player application. Performs all interaction with the UI and delegates music player operations to PlayerDelegate.
 */

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTabViewDelegate, EventSubscriber {
    
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
    
    // Buttons to toggle (collapsible) playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
    @IBOutlet weak var viewPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var viewEffectsMenuItem: NSMenuItem!
    
    // Views that are collapsible (hide/show)
    @IBOutlet weak var playlistControlsBox: NSBox!
    @IBOutlet weak var fxTabView: NSTabView!
    @IBOutlet weak var fxBox: NSBox!
    @IBOutlet weak var playlistBox: NSBox!
    
    // Displays the playlist and summary
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var lblPlaylistSummary: NSTextField!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Volume/pan controls
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    // Effects panel tab view buttons
    @IBOutlet weak var eqTabViewButton: NSButton!
    @IBOutlet weak var pitchTabViewButton: NSButton!
    @IBOutlet weak var timeTabViewButton: NSButton!
    @IBOutlet weak var reverbTabViewButton: NSButton!
    @IBOutlet weak var delayTabViewButton: NSButton!
    @IBOutlet weak var filterTabViewButton: NSButton!
    @IBOutlet weak var recorderTabViewButton: NSButton!
    
    private var tabViewButtons: [NSButton]?
    
    // Pitch controls
    @IBOutlet weak var btnPitchBypass: NSButton!
    @IBOutlet weak var pitchSlider: NSSlider!
    @IBOutlet weak var pitchOverlapSlider: NSSlider!
    
    // Time controls
    @IBOutlet weak var timeSlider: NSSlider!
    
    // Reverb controls
    @IBOutlet weak var btnReverbBypass: NSButton!
    @IBOutlet weak var reverbMenu: NSPopUpButton!
    @IBOutlet weak var reverbSlider: NSSlider!
    
    // Delay controls
    @IBOutlet weak var btnDelayBypass: NSButton!
    @IBOutlet weak var delayTimeSlider: NSSlider!
    @IBOutlet weak var delayAmountSlider: NSSlider!
    @IBOutlet weak var btnTimeBypass: NSButton!
    @IBOutlet weak var delayCutoffSlider: NSSlider!
    @IBOutlet weak var delayFeedbackSlider: NSSlider!
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: NSButton!
    @IBOutlet weak var filterBassSlider: RangeSlider!
    @IBOutlet weak var filterMidSlider: RangeSlider!
    @IBOutlet weak var filterTrebleSlider: RangeSlider!
    
    // Recorder controls
    @IBOutlet weak var btnRecord: NSButton!
    @IBOutlet weak var lblRecorderDuration: NSTextField!
    
    // Parametric equalizer controls
    @IBOutlet weak var eqGlobalGainSlider: NSSlider!
    @IBOutlet weak var eqSlider1k: NSSlider!
    @IBOutlet weak var eqSlider64: NSSlider!
    @IBOutlet weak var eqSlider16k: NSSlider!
    @IBOutlet weak var eqSlider8k: NSSlider!
    @IBOutlet weak var eqSlider4k: NSSlider!
    @IBOutlet weak var eqSlider2k: NSSlider!
    @IBOutlet weak var eqSlider32: NSSlider!
    @IBOutlet weak var eqSlider512: NSSlider!
    @IBOutlet weak var eqSlider256: NSSlider!
    @IBOutlet weak var eqSlider128: NSSlider!
    @IBOutlet weak var eqPresets: NSPopUpButton!
    
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
    
    var playlistCollapsibleView: CollapsibleView?
    var fxCollapsibleView: CollapsibleView?
    
    // Timer that periodically updates the recording duration (only when recorder is active)
    var recorderTimer: ScheduledTaskExecutor?
    
    // Current playlist search results
    var searchResults: SearchResults?
    
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
        
        // Load saved state (sound settings + playlist) from app config file and adjust UI elements according to that state
        let playerState = player.getPlayerState()
        if (playerState != nil) {
            initStatefulUI(playerState!)
        } else {
            initStatefulUI(SavedPlayerState.defaults)
        }
        
        // Register self as a subscriber to TrackChangedEvent notifications (published when the player is done playing a track)
        EventRegistry.subscribe(.trackChanged, subscriber: self, dispatchQueue: GCDDispatchQueue(queueType: QueueType.main))
        
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        tearDown()
    }
    
    func initStatelessUI() {
        
        // Set up a mouse listener (for double clicks -> play selected track)
        playlistView.doubleAction = #selector(self.playlistDoubleClickAction(_:))
        
        // Enable drag n drop into the playlist view
        playlistView.register(forDraggedTypes: [String(kUTTypeFileURL)])
        
        playlistCollapsibleView = CollapsibleView(views: [playlistBox, playlistControlsBox])
        fxCollapsibleView = CollapsibleView(views: [fxBox])
        
        recorderTimer = ScheduledTaskExecutor(intervalMillis: UIConstants.recorderTimerIntervalMillis, task: {self.updateRecordingTime()}, queue: GCDDispatchQueue(queueType: QueueType.main))
        
        searchPanel.titlebarAppearsTransparent = true
        sortPanel.titlebarAppearsTransparent = true
        
        // Set up the filter control sliders
        
        filterBassSlider.minValue = Double(AppConstants.bass_min)
        filterBassSlider.maxValue = Double(AppConstants.bass_max)
        filterBassSlider.onControlChanged = {
            (slider: RangeSlider) -> Void in
            
            self.filterBassChanged()
        }
        
        filterMidSlider.minValue = Double(AppConstants.mid_min)
        filterMidSlider.maxValue = Double(AppConstants.mid_max)
        filterMidSlider.onControlChanged = {
            (slider: RangeSlider) -> Void in
            
            self.filterMidChanged()
        }
        
        filterTrebleSlider.minValue = Double(AppConstants.treble_min)
        filterTrebleSlider.maxValue = Double(AppConstants.treble_max)
        filterTrebleSlider.onControlChanged = {
            (slider: RangeSlider) -> Void in
            
            self.filterTrebleChanged()
        }
        
        tabViewButtons = [eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        // Select EQ by default
        eqTabViewAction(self)
    }
    
    func initStatefulUI(_ playerState: SavedPlayerState) {
        
        if (!playerState.showPlaylist) {
            toggleViewPlaylistAction(self)
        }
        
        if (!playerState.showEffects) {
            toggleViewEffectsAction(self)
        }
        
        // Set sliders to reflect player state
        volumeSlider.floatValue = playerState.volume * 100
        setVolumeImage(playerState.muted)
        panSlider.floatValue = playerState.balance
        
        switch playerState.repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
        
        switch playerState.shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
            
        }
        
        eqGlobalGainSlider.floatValue = playerState.eqGlobalGain
        updateEQSliders(playerState.eqBands)
        
        btnPitchBypass.image = playerState.pitchBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        pitchSlider.floatValue = playerState.pitch / 1200
        pitchOverlapSlider.floatValue = playerState.pitchOverlap
        
        btnTimeBypass.image = playerState.timeBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        timeSlider.floatValue = playerState.timeStretchRate
        
        btnReverbBypass.image = playerState.reverbBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        
        // TODO: Change this lookup to o(1) instead of o(n) ... HashMap !
        for item in reverbMenu.itemArray {
            
            if item.title == playerState.reverbPreset.description {
                reverbMenu.select(item)
            }
        }
        reverbSlider.floatValue = playerState.reverbAmount
        
        btnDelayBypass.image = playerState.delayBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        delayAmountSlider.floatValue = playerState.delayAmount
        delayTimeSlider.doubleValue = playerState.delayTime
        delayFeedbackSlider.floatValue = playerState.delayFeedback
        delayCutoffSlider.floatValue = playerState.delayLowPassCutoff
        
        btnFilterBypass.image = playerState.filterBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        filterBassSlider.start = Double(playerState.filterBassMin)
        filterBassSlider.end = Double(playerState.filterBassMax)
        filterMidSlider.start = Double(playerState.filterMidMin)
        filterMidSlider.end = Double(playerState.filterMidMax)
        filterTrebleSlider.start = Double(playerState.filterTrebleMin)
        filterTrebleSlider.end = Double(playerState.filterTrebleMax)
        
        eqPresets.selectItem(at: -1)
        
        fxTabView.selectTabViewItem(at: 0)
        
        playlistView.reloadData()
        updatePlaylistSummary()
        
        // Timer interval depends on whether time stretch unit is active
        let interval = playerState.timeBypass ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * playerState.timeStretchRate))
        
        seekTimer = ScheduledTaskExecutor(intervalMillis: interval, task: {self.updatePlayingTime()}, queue: GCDDispatchQueue(queueType: QueueType.main))
    }
    
    func updatePlaylistSummary() {
        
        let summary = player.getPlaylistSummary()
        let numTracks = summary.numTracks
        
        let numTracksStr = String(numTracks) + (numTracks == 1 ? " track   " : " tracks   ")
        let durationStr = Utils.formatDuration(summary.totalDuration)
        
        lblPlaylistSummary.stringValue = numTracksStr + durationStr
    }
    
    fileprivate func updateEQSliders(_ eqBands: [Int: Float]) {
        
        eqSlider32.floatValue = eqBands[32]!
        eqSlider64.floatValue = eqBands[64]!
        eqSlider128.floatValue = eqBands[128]!
        eqSlider256.floatValue = eqBands[256]!
        eqSlider512.floatValue = eqBands[512]!
        eqSlider1k.floatValue = eqBands[1024]!
        eqSlider2k.floatValue = eqBands[2048]!
        eqSlider4k.floatValue = eqBands[4096]!
        eqSlider8k.floatValue = eqBands[8192]!
        eqSlider16k.floatValue = eqBands[16384]!
    }
    
    func tearDown() {
        player.tearDown()
    }
    
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        let selRow = playlistView.selectedRow
        let dialog = UIElements.openDialog
        
        // TODO: Clear previous selection of files
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            addTracks(dialog.urls)
        }
        
        selectTrack(selRow)
    }
    
    @IBAction func removeSingleTrackAction(_ sender: AnyObject) {
        
        let selRow = playlistView.selectedRow
        
        if (selRow >= 0) {
            
            let newTrackIndex = player.removeTrack(selRow)
            playlistView.reloadData()
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
        
        let playbackInfo = player.togglePlayPause()
        
        switch playbackInfo.playbackState {
            
        case .no_FILE, .paused: setSeekTimerState(false)
        setPlayPauseImage(UIConstants.imgPlay)
            
        case .playing:
            
            if (playbackInfo.trackChanged) {
                trackChange(playbackInfo.playingTrack!, newTrackIndex: playbackInfo.playingTrackIndex!)
            } else {
                setSeekTimerState(true)
                setPlayPauseImage(UIConstants.imgPause)
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
    
    fileprivate func setPlayPauseImage(_ image: NSImage) {
        btnPlayPause.image = image
    }
    
    fileprivate func setSeekTimerState(_ timerOn: Bool) {
        
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
            let track = player.play(playlistView.selectedRow)
            trackChange(track, newTrackIndex: playlistView.selectedRow)
        }
    }
    
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        let trackInfo = player.nextTrack()
        if (trackInfo.playingTrack != nil) {
            trackChange(trackInfo.playingTrack!, newTrackIndex: trackInfo.playingTrackIndex!)
        }
    }
    
    @IBAction func prevTrackAction(_ sender: AnyObject) {
        let trackInfo = player.previousTrack()
        if (trackInfo.playingTrack != nil) {
            trackChange(trackInfo.playingTrack!, newTrackIndex: trackInfo.playingTrackIndex!)
        }
    }
    
    func trackChange(_ newTrack: Track?, newTrackIndex: Int?) {
        
        if (newTrack != nil) {
            
            setSeekTimerState(true)
            setPlayPauseImage(UIConstants.imgPause)
            showNowPlayingInfo(newTrack!)
            btnMoreInfo.isHidden = false
            
            if (popover.isShown) {
                player.getMoreInfo()
                (popover.contentViewController as! PopoverController).refresh()
            }
            
        } else {
            
            setSeekTimerState(false)
            clearNowPlayingInfo()
        }
        
        resetPlayingTime()
        selectTrack(newTrackIndex)
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
    
    @IBAction func volumeAction(_ sender: AnyObject) {
        player.setVolume(volumeSlider.floatValue)
        setVolumeImage(player.isMuted())
    }
    
    @IBAction func volumeBtnAction(_ sender: AnyObject) {
        setVolumeImage(player.toggleMute())
    }
    
    func increaseVolume() {
        volumeSlider.floatValue = player.increaseVolume()
        setVolumeImage(player.isMuted())
    }
    
    func decreaseVolume() {
        volumeSlider.floatValue = player.decreaseVolume()
        setVolumeImage(player.isMuted())
    }
    
    fileprivate func setVolumeImage(_ muted: Bool) {
        
        if (muted) {
            btnVolume.image = UIConstants.imgMute
        } else {
            let vol = player.getVolume()
            
            // Zero / Low / Medium / High (different images)
            if (vol > 200/3) {
                btnVolume.image = UIConstants.imgVolumeHigh
            } else if (vol > 100/3) {
                btnVolume.image = UIConstants.imgVolumeMedium
            } else if (vol > 0) {
                btnVolume.image = UIConstants.imgVolumeLow
            } else {
                btnVolume.image = UIConstants.imgVolumeZero
            }
        }
    }
    
    @IBAction func panAction(_ sender: AnyObject) {
        player.setBalance(panSlider.floatValue)
    }
    
    func panRight() {
        panSlider.floatValue = player.panRight()
    }
    
    func panLeft() {
        panSlider.floatValue = player.panLeft()
    }
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        player.clearPlaylist()
        playlistView.reloadData()
        updatePlaylistSummary()
        
        trackChange(nil, newTrackIndex: nil)
    }
    
    @IBAction func repeatAction(_ sender: AnyObject) {
        
        let repeatMode = player.toggleRepeatMode()
        
        switch repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
    }
    
    @IBAction func shuffleAction(_ sender: AnyObject) {
        
        let shuffleMode = player.toggleShuffleMode()
        
        switch shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
            
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
    
    @IBAction func eqPresetsAction(_ sender: AnyObject) {
        
        // TODO: Change this lookup to o(1) instead of o(n) ... HashMap !
        let preset = EQPresets.fromDescription((eqPresets.selectedItem?.title)!)
        
        let eqBands: [Int: Float] = preset.bands
        player.setEQBands(eqBands)
        updateEQSliders(eqBands)
        
        eqPresets.selectItem(at: -1)
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
        
        let selRow = player.moveTrackUp(playlistView.selectedRow)
        playlistView.reloadData()
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    func shiftPlaylistTrackDown() {
        
        let selRow = player.moveTrackDown(playlistView.selectedRow)
        playlistView.reloadData()
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    @IBAction func savePlaylistAction(_ sender: AnyObject) {
        
        // Make sure there is at least one track to save
        if (player.getPlaylistSummary().numTracks > 0) {
            
            let dialog = UIElements.savePlaylistDialog
            
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSModalResponseOK) {
                
                let file = dialog.url // Path of the file
                player.savePlaylist(file!)
            }
        }
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        tearDown()
        exit(0)
    }
    
    @IBAction func hideAction(_ sender: AnyObject) {
        window.miniaturize(self)
    }
    
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.togglePitchBypass()
        
        btnPitchBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func pitchAction(_ sender: AnyObject) {
        player.setPitch(pitchSlider.floatValue)
    }
    
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {
        player.setPitchOverlap(pitchOverlapSlider.floatValue)
    }
    
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleTimeBypass()
        
        btnTimeBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        
        let interval = newBypassState ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * timeSlider.floatValue))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            
            seekTimer = ScheduledTaskExecutor(intervalMillis: interval, task: {self.updatePlayingTime()}, queue: GCDDispatchQueue(queueType: QueueType.main))
            
            if (player.getPlaybackState() == .playing) {
                setSeekTimerState(true)
            }
        }
    }
    
    @IBAction func timeStretchAction(_ sender: AnyObject) {
        
        player.setTimeStretchRate(timeSlider.floatValue)
        
        let timeStretchActive = !player.isTimeBypass()
        if (timeStretchActive) {
            
            let interval = Int(1000 / (2 * timeSlider.floatValue))
            
            seekTimer?.stop()
            
            seekTimer = ScheduledTaskExecutor(intervalMillis: interval, task: {self.updatePlayingTime()}, queue: GCDDispatchQueue(queueType: QueueType.main))
            
            if (player.getPlaybackState() == .playing) {
                setSeekTimerState(true)
            }
        }
    }
    
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleReverbBypass()
        
        btnReverbBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func reverbAction(_ sender: AnyObject) {
        
        let preset: ReverbPresets = ReverbPresets.fromDescription((reverbMenu.selectedItem?.title)!)
        
        player.setReverb(preset)
    }
    
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        player.setReverbAmount(reverbSlider.floatValue)
    }
    
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleDelayBypass()
        
        btnDelayBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func delayAmountAction(_ sender: AnyObject) {
        player.setDelayAmount(delayAmountSlider.floatValue)
    }
    
    @IBAction func delayTimeAction(_ sender: AnyObject) {
        player.setDelayTime(delayTimeSlider.doubleValue)
    }
    
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {
        player.setDelayFeedback(delayFeedbackSlider.floatValue)
    }
    
    @IBAction func delayCutoffAction(_ sender: AnyObject) {
        player.setDelayLowPassCutoff(delayCutoffSlider.floatValue)
    }
    
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleFilterBypass()
        
        btnFilterBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    
    
    @IBAction func eqGlobalGainAction(_ sender: AnyObject) {
        player.setEQGlobalGain(eqGlobalGainSlider.floatValue)
    }
    
    @IBAction func eqSlider32Action(_ sender: AnyObject) {
        player.setEQBand(32, gain: eqSlider32.floatValue)
    }
    
    @IBAction func eqSlider64Action(_ sender: AnyObject) {
        player.setEQBand(64, gain: eqSlider64.floatValue)
    }
    
    @IBAction func eqSlider128Action(_ sender: AnyObject) {
        player.setEQBand(128, gain: eqSlider128.floatValue)
    }
    
    @IBAction func eqSlider256Action(_ sender: AnyObject) {
        player.setEQBand(256, gain: eqSlider256.floatValue)
    }
    
    @IBAction func eqSlider512Action(_ sender: AnyObject) {
        player.setEQBand(512, gain: eqSlider512.floatValue)
    }
    
    @IBAction func eqSlider1kAction(_ sender: AnyObject) {
        player.setEQBand(1024, gain: eqSlider1k.floatValue)
    }
    
    @IBAction func eqSlider2kAction(_ sender: AnyObject) {
        player.setEQBand(2048, gain: eqSlider2k.floatValue)
    }
    
    @IBAction func eqSlider4kAction(_ sender: AnyObject) {
        player.setEQBand(4096, gain: eqSlider4k.floatValue)
    }
    
    @IBAction func eqSlider8kAction(_ sender: AnyObject) {
        player.setEQBand(8192, gain: eqSlider8k.floatValue)
    }
    
    @IBAction func eqSlider16kAction(_ sender: AnyObject) {
        player.setEQBand(16384, gain: eqSlider16k.floatValue)
    }
    
    // Track changed in player, need to reset the UI
    func consumeEvent(_ event: Event) {
        
        setSeekTimerState(false)
        
        let _event = event as! TrackChangedEvent
        trackChange(_event.newTrack, newTrackIndex: _event.newTrackIndex)
    }
    
    // Adds a set of files (or directories, i.e. files within them) to the current playlist, if supported
    func addTracks(_ files: [URL]) {
        
        player.addTracks(files)
        
        // Refresh the playlist view with the new files
        playlistView.reloadData()
        updatePlaylistSummary()
    }
    
    // View menu item action
    @IBAction func toggleViewEffectsAction(_ sender: AnyObject) {
        
        if (fxCollapsibleView?.hidden)! {
            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: true)
            fxCollapsibleView!.show()
            btnToggleEffects.state = 1
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = 1
        } else {
            fxCollapsibleView!.hide()
            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: false)
            btnToggleEffects.state = 0
            btnToggleEffects.image = UIConstants.imgEffectsOff
            viewEffectsMenuItem.state = 0
        }
        
        showPlaylistSelectedRow()
    }
    
    // View menu item action
    @IBAction func toggleViewPlaylistAction(_ sender: AnyObject) {
        
        // Set focus on playlist view if it's visible after the toggle
        
        if (playlistCollapsibleView?.hidden)! {
            resizeWindow(playlistShown: true, effectsShown: !(fxCollapsibleView?.hidden)!)
            playlistCollapsibleView!.show()
            window.makeFirstResponder(playlistView)
            btnTogglePlaylist.state = 1
            btnTogglePlaylist.image = UIConstants.imgPlaylistOn
            viewPlaylistMenuItem.state = 1
        } else {
            playlistCollapsibleView!.hide()
            resizeWindow(playlistShown: false, effectsShown: !(fxCollapsibleView?.hidden)!)
            btnTogglePlaylist.state = 0
            btnTogglePlaylist.image = UIConstants.imgPlaylistOff
            viewPlaylistMenuItem.state = 0
        }
        
        showPlaylistSelectedRow()
    }
    
    // Called when toggling views
    func resizeWindow(playlistShown: Bool, effectsShown: Bool) {
        
        var wFrame = window.frame
        let oldOrigin = wFrame.origin
        
        var newHeight: CGFloat
        
        if (effectsShown && playlistShown) {
            newHeight = UIConstants.windowHeight_playlistAndEffects
        } else if (effectsShown) {
            newHeight = UIConstants.windowHeight_effectsOnly
        } else if (playlistShown) {
            newHeight = UIConstants.windowHeight_playlistOnly
        } else {
            newHeight = UIConstants.windowHeight_compact
        }
        
        let oldHeight = wFrame.height
        let shrinking: Bool = newHeight < oldHeight
        
        wFrame.size = NSMakeSize(window.frame.width, newHeight)
        wFrame.origin = NSMakePoint(oldOrigin.x, shrinking ? oldOrigin.y + (oldHeight - newHeight) : oldOrigin.y - (newHeight - oldHeight))
        
        window.setFrame(wFrame, display: true, animate: true)
    }
    
    // Toggle button action
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        toggleViewPlaylistAction(sender)
    }
    
    // Toggle button action
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleViewEffectsAction(sender)
    }
    
    func isEffectsShown() -> Bool {
        return fxCollapsibleView?.hidden == false
    }
    
    func isPlaylistShown() -> Bool {
        return playlistCollapsibleView?.hidden == false
    }
    
    @IBAction func recorderAction(_ sender: Any) {
        
        let isRecording: Bool = btnRecord.image == UIConstants.imgRecorderStop
        
        if (isRecording) {
            player.stopRecording()
            btnRecord.image = UIConstants.imgRecord
            lblRecorderDuration.stringValue = UIConstants.zeroDurationString
            recorderTimer?.pause()
            
            // TODO: Make this wait until the (async) stopping is complete ... respond to an event notification
            saveRecording()
        } else {
            
            // Only AAC format works for now
            player.startRecording(RecordingFormat.aac)
            btnRecord.image = UIConstants.imgRecorderStop
            recorderTimer?.startOrResume()
        }
    }
    
    func saveRecording() {
        
        let dialog = UIElements.saveRecordingDialog
        dialog.allowedFileTypes = [RecordingFormat.aac.fileExtension]
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            player.saveRecording(dialog.url!)
        } else {
            player.deleteRecording()
        }
    }
    
    func updateRecordingTime() {
        
        let recDuration = player.getRecordingDuration()
        lblRecorderDuration.stringValue = Utils.formatDuration(recDuration)
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
    
    @IBAction func decreaseVolumeMenuItemAction(_ sender: Any) {
        decreaseVolume()
    }
    
    @IBAction func increaseVolumeMenuItemAction(_ sender: Any) {
        increaseVolume()
    }
    
    @IBAction func panLeftMenuItemAction(_ sender: Any) {
        panLeft()
    }
    
    @IBAction func panRightMenuItemAction(_ sender: Any) {
        panRight()
    }
    
    @IBAction func toggleRepeatModeMenuItemAction(_ sender: Any) {
        repeatAction(sender as AnyObject)
    }
    
    @IBAction func toggleShuffleModeMenuItemAction(_ sender: Any) {
        shuffleAction(sender as AnyObject)
    }
    
    @IBAction func muteUnmuteMenuItemAction(_ sender: Any) {
        volumeBtnAction(sender as AnyObject)
    }
    
    @IBAction func searchPlaylistAction(_ sender: Any) {
        
        // Don't do anything if no tracks in playlist
        if (playlistView.numberOfRows == 0) {
            return
        }
        
        // Position the search modal dialog and show it
        let searchFrameOrigin = NSPoint(x: window.frame.origin.x + 16, y: window.frame.origin.y + 227)
        
        searchField.stringValue = ""
        resetSearchInfo()
        
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
            resetSearchInfo()
            return
        }
        
        let searchFields = SearchFields()
        searchFields.name = Bool(searchByName.state)
        searchFields.artist = Bool(searchByArtist.state)
        searchFields.title = Bool(searchByTitle.state)
        searchFields.album = Bool(searchByAlbum.state)
        
        // No fields to compare, don't do the search
        if (searchFields.noFieldsSelected()) {
            resetSearchInfo()
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
            resetSearchInfo()
        }
    }
    
    func resetSearchInfo() {
        
        if (searchField.stringValue == "") {
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
        dismissSearchDialog()
    }
    
    func dismissSearchDialog() {
        NSApp.stopModal()
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
        let sortFrameOrigin = NSPoint(x: window.frame.origin.x + 73, y: window.frame.origin.y + 227)
        
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
        dismissSortDialog()
        
        playlistView.reloadData()
        selectTrack(player.getPlayingTrackIndex())
        showPlaylistSelectedRow()
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        dismissSortDialog()
    }
    
    func dismissSortDialog() {
        NSApp.stopModal()
    }
    
    @IBAction func sortPlaylistMenuItemAction(_ sender: Any) {
        sortPlaylistAction(sender)
    }
    
    func filterBassChanged() {
        player.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
    }
    
    func filterMidChanged() {
        player.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
    }
    
    func filterTrebleChanged() {
        player.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
    }
    
    @IBAction func eqTabViewAction(_ sender: Any) {
        
        for button in tabViewButtons! {
            button.state = 0
        }
        
        eqTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 0)
    }
    
    @IBAction func pitchTabViewAction(_ sender: Any) {
        
        for button in tabViewButtons! {
            button.state = 0
        }
        
        pitchTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 1)
    }
    
    
    @IBAction func timeTabViewAction(_ sender: Any) {
        
        for button in tabViewButtons! {
            button.state = 0
        }
        
        timeTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 2)
    }
    
    @IBAction func reverbTabViewAction(_ sender: Any) {
        
        for button in tabViewButtons! {
            button.state = 0
        }
        
        reverbTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 3)
    }
    
    @IBAction func delayTabViewAction(_ sender: Any) {
        
        for button in tabViewButtons! {
            button.state = 0
        }
        
        delayTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 4)
    }
    
    @IBAction func filterTabViewAction(_ sender: Any) {
        
        for button in tabViewButtons! {
            button.state = 0
        }
        
        filterTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 5)
    }
    
    @IBAction func recorderTabViewAction(_ sender: Any) {
        
        for button in tabViewButtons! {
            button.state = 0
        }
        
        recorderTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 6)
    }
}

// Int to Bool conversion
extension Bool {
    init<T: Integer>(_ num: T) {
        self.init(num != 0)
    }
}
