/*
    Entry point for the Aural Player application. Performs all interaction with the UI and delegates music player operations to PlayerDelegate.
 */
import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSTabViewDelegate,EventSubscriber {
    
    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var prefsPanel: NSPanel!
    @IBOutlet weak var prefsTabView: NSTabView!
    
    private var prefsTabViewButtons: [NSButton]?
    
    // Player prefs
    @IBOutlet weak var btnPlayerPrefs: NSButton!
    
    @IBOutlet weak var seekLengthField: NSTextField!
    @IBOutlet weak var seekLengthSlider: NSSlider!
    
    @IBOutlet weak var volumeDeltaField: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var btnRememberVolume: NSButton!
    @IBOutlet weak var btnSpecifyVolume: NSButton!
    
    @IBOutlet weak var startupVolumeSlider: NSSlider!
    @IBOutlet weak var lblStartupVolume: NSTextField!
    
    @IBOutlet weak var panDeltaField: NSTextField!
    @IBOutlet weak var panDeltaStepper: NSStepper!
    
    // Playlist prefs
    @IBOutlet weak var btnPlaylistPrefs: NSButton!
    
    @IBOutlet weak var btnEmptyPlaylist: NSButton!
    @IBOutlet weak var btnRememberPlaylist: NSButton!
    
    @IBOutlet weak var btnAutoplayOnStartup: NSButton!
    
    @IBOutlet weak var btnAutoplayAfterAddingTracks: NSButton!
    @IBOutlet weak var btnAutoplayIfNotPlaying: NSButton!
    @IBOutlet weak var btnAutoplayAlways: NSButton!
    
    // View prefs
    @IBOutlet weak var btnViewPrefs: NSButton!
    
    @IBOutlet weak var btnStartWithView: NSButton!
    @IBOutlet weak var startWithViewMenu: NSPopUpButton!
    @IBOutlet weak var btnRememberView: NSButton!
    
    @IBOutlet weak var btnRememberWindowLocation: NSButton!
    @IBOutlet weak var btnStartAtWindowLocation: NSButton!
    @IBOutlet weak var startWindowLocationMenu: NSPopUpButton!
    
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
    
    private var fxTabViewButtons: [NSButton]?
    
    // Pitch controls
    @IBOutlet weak var btnPitchBypass: NSButton!
    @IBOutlet weak var pitchSlider: NSSlider!
    @IBOutlet weak var pitchOverlapSlider: NSSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    // Time controls
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var timeOverlapSlider:
    NSSlider!
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    // Reverb controls
    @IBOutlet weak var btnReverbBypass: NSButton!
    @IBOutlet weak var reverbMenu: NSPopUpButton!
    @IBOutlet weak var reverbSlider: NSSlider!
    @IBOutlet weak var lblReverbAmountValue: NSTextField!
    
    // Delay controls
    @IBOutlet weak var btnDelayBypass: NSButton!
    @IBOutlet weak var delayTimeSlider: NSSlider!
    @IBOutlet weak var delayAmountSlider: NSSlider!
    @IBOutlet weak var btnTimeBypass: NSButton!
    @IBOutlet weak var delayCutoffSlider: NSSlider!
    @IBOutlet weak var delayFeedbackSlider: NSSlider!
    
    @IBOutlet weak var lblDelayTimeValue: NSTextField!
    @IBOutlet weak var lblDelayAmountValue: NSTextField!
    @IBOutlet weak var lblDelayFeedbackValue: NSTextField!
    @IBOutlet weak var lblDelayLowPassCutoffValue: NSTextField!
    
    // Filter controls
    @IBOutlet weak var btnFilterBypass: NSButton!
    @IBOutlet weak var filterBassSlider: RangeSlider!
    @IBOutlet weak var filterMidSlider: RangeSlider!
    @IBOutlet weak var filterTrebleSlider: RangeSlider!
    
    @IBOutlet weak var lblFilterBassRange: NSTextField!
    @IBOutlet weak var lblFilterMidRange: NSTextField!
    @IBOutlet weak var lblFilterTrebleRange: NSTextField!
    
    // Recorder controls
    @IBOutlet weak var btnRecord: NSButton!
    @IBOutlet weak var lblRecorderDuration: NSTextField!
    @IBOutlet weak var lblRecorderFileSize: NSTextField!
    @IBOutlet weak var recordingInfoBox: NSBox!
    
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
    
    var preferences: Preferences = Preferences.instance()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        window.setIsVisible(false)
        
        // Initialize UI with presentation settings (colors, sizes, etc)
        // No app state is needed here
        initStatelessUI()
        
        // Set up key press handler
        KeyPressHandler.initialize(self)
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(evt: NSEvent!) -> NSEvent in
            KeyPressHandler.handle(evt)
            return evt;
        });
        
        // Register self as a subscriber to TrackChangedEvent notifications (published when the player is done playing a track)
        EventRegistry.subscribe(.trackChanged, subscriber: self, dispatchQueue: GCDDispatchQueue(queueType: QueueType.main))
        
        // Register self as a subscriber to TrackAddedEvent notifications (published when new tracks are added to the playlist)
        EventRegistry.subscribe(.trackAdded, subscriber: self, dispatchQueue: GCDDispatchQueue(queueType: QueueType.main))
        
        // Load saved state (sound settings + playlist) from app config file and adjust UI elements according to that state
        
        if (preferences.playlistOnStartup == .rememberFromLastAppLaunch) {
            player.loadPlaylistFromSavedState()
        }
        
        let playerState = player.getPlayerState()
        if (playerState != nil) {
            initStatefulUI(playerState!)
        } else {
            initStatefulUI(SavedPlayerState.defaults)
        }
        
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
        
        positionWindow()
    }
    
    func positionWindow() {
        
        if (preferences.windowLocationOnStartup.option == .rememberFromLastAppLaunch) {
            
            let windowLocation = NSPoint(x: CGFloat(preferences.lastWindowLocationX ?? 0), y: CGFloat(preferences.lastWindowLocationY ?? 0))
            window.setFrameOrigin(windowLocation)
            
        } else {
            
            UIUtils.positionWindowRelativeToScreen(window, preferences.windowLocationOnStartup.windowLocation)
        }
        
        window.setIsVisible(true)
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
        
        recorderTimer = ScheduledTaskExecutor(intervalMillis: UIConstants.recorderTimerIntervalMillis, task: {self.updateRecordingInfo()}, queue: GCDDispatchQueue(queueType: QueueType.main))
        
        searchPanel.titlebarAppearsTransparent = true
        sortPanel.titlebarAppearsTransparent = true
        prefsPanel.titlebarAppearsTransparent = true
        
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
        
        fxTabViewButtons = [eqTabViewButton, pitchTabViewButton, timeTabViewButton, reverbTabViewButton, delayTabViewButton, filterTabViewButton, recorderTabViewButton]
        
        prefsTabViewButtons = [btnPlayerPrefs, btnPlaylistPrefs, btnViewPrefs]
    }
    
    func initStatefulUI(_ playerState: SavedPlayerState) {
        
        // Set sliders to reflect player state
        
        if (preferences.volumeOnStartup == .rememberFromLastAppLaunch) {
            volumeSlider.floatValue = round(playerState.volume * AppConstants.volumeConversion_playerToUI)
        } else {
            volumeSlider.floatValue = round(preferences.startupVolumeValue * AppConstants.volumeConversion_playerToUI)
            player.setVolume(volumeSlider.floatValue)
        }
        setVolumeImage(playerState.muted)
        
        panSlider.floatValue = round(playerState.balance * AppConstants.panConversion_playerToUI)
        
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
        
        (eqTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
        
        btnPitchBypass.image = playerState.pitchBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !playerState.pitchBypass
        
        let octaves = playerState.pitch * AppConstants.pitchConversion_playerToUI
        pitchSlider.floatValue = octaves
        lblPitchValue.stringValue = ValueFormatter.formatPitch(octaves)
        
        pitchOverlapSlider.floatValue = playerState.pitchOverlap
        lblPitchOverlapValue.stringValue = ValueFormatter.formatOverlap(playerState.pitchOverlap)
        
        btnTimeBypass.image = playerState.timeBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !playerState.timeBypass
        
        timeSlider.floatValue = playerState.timeStretchRate
        lblTimeStretchRateValue.stringValue = ValueFormatter.formatTimeStretchRate(playerState.timeStretchRate)
        
        timeOverlapSlider.floatValue = playerState.timeOverlap
        lblTimeOverlapValue.stringValue = ValueFormatter.formatOverlap(playerState.timeOverlap)
        
        btnReverbBypass.image = playerState.reverbBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !playerState.reverbBypass
        
        // TODO: Change this lookup to o(1) instead of o(n) ... HashMap !
        for item in reverbMenu.itemArray {
            
            if item.title == playerState.reverbPreset.description {
                reverbMenu.select(item)
                break;
            }
        }
        reverbSlider.floatValue = playerState.reverbAmount
        lblReverbAmountValue.stringValue = ValueFormatter.formatReverbAmount(playerState.reverbAmount)
        
        btnDelayBypass.image = playerState.delayBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (delayTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !playerState.delayBypass
        
        delayAmountSlider.floatValue = playerState.delayAmount
        lblDelayAmountValue.stringValue = ValueFormatter.formatDelayAmount(playerState.delayAmount)
        
        delayTimeSlider.doubleValue = playerState.delayTime
        lblDelayTimeValue.stringValue = ValueFormatter.formatDelayTime(playerState.delayTime)
        
        delayFeedbackSlider.floatValue = playerState.delayFeedback
        lblDelayFeedbackValue.stringValue = ValueFormatter.formatDelayFeedback(playerState.delayFeedback)
        
        delayCutoffSlider.floatValue = playerState.delayLowPassCutoff
        lblDelayLowPassCutoffValue.stringValue = ValueFormatter.formatDelayLowPassCutoff(playerState.delayLowPassCutoff)
        
        btnFilterBypass.image = playerState.filterBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        (filterTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !playerState.filterBypass
        
        filterBassSlider.start = Double(playerState.filterBassMin)
        filterBassSlider.end = Double(playerState.filterBassMax)
        lblFilterBassRange.stringValue = ValueFormatter.formatFilterFrequencyRange(playerState.filterBassMin, playerState.filterBassMax)
        
        filterMidSlider.start = Double(playerState.filterMidMin)
        filterMidSlider.end = Double(playerState.filterMidMax)
        lblFilterMidRange.stringValue = ValueFormatter.formatFilterFrequencyRange(playerState.filterMidMin, playerState.filterMidMax)
        
        filterTrebleSlider.start = Double(playerState.filterTrebleMin)
        filterTrebleSlider.end = Double(playerState.filterTrebleMax)
        lblFilterTrebleRange.stringValue = ValueFormatter.formatFilterFrequencyRange(playerState.filterTrebleMin, playerState.filterTrebleMax)
        
        for btn in fxTabViewButtons! {
            (btn.cell as! EffectsUnitButtonCell).highlightColor = btn === recorderTabViewButton ? Colors.tabViewRecorderButtonHighlightColor : Colors.tabViewEffectsButtonHighlightColor
            btn.needsDisplay = true
        }

        // Select EQ by default
        eqTabViewAction(self)
        
        // Don't select any items from the EQ presets menu
        eqPresets.selectItem(at: -1)
        
        if (preferences.viewOnStartup.option == .rememberFromLastAppLaunch) {
            
            if (!playerState.showPlaylist) {
                toggleViewPlaylistAction(self)
            }
            
            if (!playerState.showEffects) {
                toggleViewEffectsAction(self)
            }
            
        } else {
            
            let viewType = preferences.viewOnStartup.viewType
            let hidePlaylist = viewType == .effectsOnly || viewType == .compact
            let hideEffects = viewType == .playlistOnly || viewType == .compact
            
            if (hidePlaylist) {
                toggleViewPlaylistAction(self)
            }
            
            if (hideEffects) {
                toggleViewEffectsAction(self)
            }
        }
        
        // Timer interval depends on whether time stretch unit is active
        let interval = playerState.timeBypass ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * playerState.timeStretchRate))
        
        seekTimer = ScheduledTaskExecutor(intervalMillis: interval, task: {self.updatePlayingTime()}, queue: GCDDispatchQueue(queueType: QueueType.main))
        
        resetPreferencesFields()
    }
    
    func updatePlaylistSummary() {
        
        let summary = player.getPlaylistSummary()
        let numTracks = summary.numTracks
        
        lblPlaylistSummary.stringValue = String(format: "%d %@   %@", numTracks, numTracks == 1 ? "track" : "tracks", Utils.formatDuration(summary.totalDuration))
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
        Preferences.persistWindowLocation(Float(window.frame.origin.x), Float(window.frame.origin.y))
    }
    
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        let selRow = playlistView.selectedRow
        let dialog = UIElements.openDialog
        
        // TODO: Clear previous selection of files
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            addFiles(dialog.urls)
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
            trackChange(track)
        }
    }
    
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        
        let trackInfo = player.nextTrack()
        if (trackInfo?.track != nil) {
            trackChange(trackInfo)
        }
    }
    
    @IBAction func prevTrackAction(_ sender: AnyObject) {
        
        let trackInfo = player.previousTrack()
        if (trackInfo?.track != nil) {
            trackChange(trackInfo)
        }
    }
    
    func trackChange(_ newTrack: IndexedTrack?) {
        
        if (newTrack != nil) {
            
            setSeekTimerState(true)
            setPlayPauseImage(UIConstants.imgPause)
            showNowPlayingInfo(newTrack!.track!)
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
        
        let oldSelRow = playlistView.selectedRow
        let selRow = player.moveTrackUp(oldSelRow)
        
        // TODO: Get this to work
        //        let iset = IndexSet(oldSelRow...selRow)
        //        playlistView.reloadData(forRowIndexes: iset, columnIndexes: IndexSet([0,1]))
        
        playlistView.reloadData()
        playlistView.selectRowIndexes(IndexSet(integer: selRow), byExtendingSelection: false)
    }
    
    func shiftPlaylistTrackDown() {
        
        let oldSelRow = playlistView.selectedRow
        let selRow = player.moveTrackDown(oldSelRow)
        
        // TODO: Get this to work
//        let iset = IndexSet(selRow...oldSelRow)
//        playlistView.reloadData(forRowIndexes: iset, columnIndexes: IndexSet([0,1]))
        
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
        
        (pitchTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        pitchTabViewButton.needsDisplay = true
        
        btnPitchBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func pitchAction(_ sender: AnyObject) {
        
        let pitchValueStr = player.setPitch(pitchSlider.floatValue)
        lblPitchValue.stringValue = pitchValueStr
    }
    
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {
        let pitchOverlapValueStr = player.setPitchOverlap(pitchOverlapSlider.floatValue)
        lblPitchOverlapValue.stringValue = pitchOverlapValueStr
    }
    
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleTimeBypass()
        
        (timeTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        timeTabViewButton.needsDisplay = true
        
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
        
        let rateValueStr = player.setTimeStretchRate(timeSlider.floatValue)
        lblTimeStretchRateValue.stringValue = rateValueStr
        
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
    
    @IBAction func timeOverlapAction(_ sender: Any) {
        
        let timeOverlapValueStr = player.setTimeOverlap(timeOverlapSlider.floatValue)
        lblTimeOverlapValue.stringValue = timeOverlapValueStr
    }
    
    @IBAction func reverbBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleReverbBypass()
        
        (reverbTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        reverbTabViewButton.needsDisplay = true
        
        btnReverbBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func reverbAction(_ sender: AnyObject) {
        
        let preset: ReverbPresets = ReverbPresets.fromDescription((reverbMenu.selectedItem?.title)!)
        
        player.setReverb(preset)
    }
    
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        let reverbAmountValueStr = player.setReverbAmount(reverbSlider.floatValue)
        lblReverbAmountValue.stringValue = reverbAmountValueStr
    }
    
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleDelayBypass()
        
        (delayTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        delayTabViewButton.needsDisplay = true
        
        btnDelayBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func delayAmountAction(_ sender: AnyObject) {
        let delayAmountValueStr = player.setDelayAmount(delayAmountSlider.floatValue)
        lblDelayAmountValue.stringValue = delayAmountValueStr
    }
    
    @IBAction func delayTimeAction(_ sender: AnyObject) {
        let delayTimeValueStr = player.setDelayTime(delayTimeSlider.doubleValue)
        lblDelayTimeValue.stringValue = delayTimeValueStr
    }
    
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {
        let delayFeedbackValueStr = player.setDelayFeedback(delayFeedbackSlider.floatValue)
        lblDelayFeedbackValue.stringValue = delayFeedbackValueStr
    }
    
    @IBAction func delayCutoffAction(_ sender: AnyObject) {
        let delayCutoffValueStr = player.setDelayLowPassCutoff(delayCutoffSlider.floatValue)
        lblDelayLowPassCutoffValue.stringValue = delayCutoffValueStr
    }
    
    @IBAction func filterBypassAction(_ sender: AnyObject) {
        
        let newBypassState = player.toggleFilterBypass()
        
        (filterTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = !newBypassState
        filterTabViewButton.needsDisplay = true
        
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
    
    // Playlist info changed, need to reset the UI
    func consumeEvent(_ event: Event) {
        
        if event is TrackChangedEvent {
            setSeekTimerState(false)
            let _event = event as! TrackChangedEvent
            trackChange(_event.newTrack)
        }
        
        if event is TrackAddedEvent {
            playlistView.noteNumberOfRowsChanged()
            updatePlaylistSummary()
        }
        
        // Not being used yet (to be used when duration is updated)
        if event is TrackInfoUpdatedEvent {
            let _event = event as! TrackInfoUpdatedEvent
            playlistView.reloadData(forRowIndexes: IndexSet([_event.trackIndex]), columnIndexes: IndexSet([0,1]))
        }
    }
    
    // Adds a set of files (or directories, i.e. files within them) to the current playlist, if supported
    func addFiles(_ files: [URL]) {
        player.addFiles(files)
    }
    
    // View menu item action
    @IBAction func toggleViewEffectsAction(_ sender: AnyObject) {
        
        if (fxCollapsibleView?.hidden)! {
            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: true, sender !== self)
            fxCollapsibleView!.show()
            btnToggleEffects.state = 1
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = 1
        } else {
            fxCollapsibleView!.hide()
            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: false, sender !== self)
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
            resizeWindow(playlistShown: true, effectsShown: !(fxCollapsibleView?.hidden)!, sender !== self)
            playlistCollapsibleView!.show()
            window.makeFirstResponder(playlistView)
            btnTogglePlaylist.state = 1
            btnTogglePlaylist.image = UIConstants.imgPlaylistOn
            viewPlaylistMenuItem.state = 1
        } else {
            playlistCollapsibleView!.hide()
            resizeWindow(playlistShown: false, effectsShown: !(fxCollapsibleView?.hidden)!, sender !== self)
            btnTogglePlaylist.state = 0
            btnTogglePlaylist.image = UIConstants.imgPlaylistOff
            viewPlaylistMenuItem.state = 0
        }
        
        showPlaylistSelectedRow()
    }
    
    // Called when toggling views
    func resizeWindow(playlistShown: Bool, effectsShown: Bool, _ animate: Bool) {
        
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
        
        window.setFrame(wFrame, display: true, animate: animate)
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
            recorderTimer?.pause()
            
            (recorderTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = false
            recorderTabViewButton.needsDisplay = true
            
            // TODO: Make this wait until the (async) stopping is complete ... respond to an event notification
            saveRecording()
            recordingInfoBox.isHidden = true
            
        } else {
            
            // Only AAC format works for now
            player.startRecording(RecordingFormat.aac)
            btnRecord.image = UIConstants.imgRecorderStop
            recorderTimer?.startOrResume()
            lblRecorderDuration.stringValue = UIConstants.zeroDurationString
            lblRecorderFileSize.stringValue = Size.ZERO.toString()
            recordingInfoBox.isHidden = false
            
            (recorderTabViewButton.cell as! EffectsUnitButtonCell).shouldHighlight = true
            recorderTabViewButton.needsDisplay = true
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
    
    func updateRecordingInfo() {
        
        let recInfo = player.getRecordingInfo()
        lblRecorderDuration.stringValue = Utils.formatDuration(recInfo.duration)
        lblRecorderFileSize.stringValue = recInfo.fileSize.toString()
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
    
    func filterBassChanged() {
        let filterBassRangeStr = player.setFilterBassBand(Float(filterBassSlider.start), Float(filterBassSlider.end))
        lblFilterBassRange.stringValue = filterBassRangeStr
    }
    
    func filterMidChanged() {
        let filterMidRangeStr = player.setFilterMidBand(Float(filterMidSlider.start), Float(filterMidSlider.end))
        lblFilterMidRange.stringValue = filterMidRangeStr
    }
    
    func filterTrebleChanged() {
        let filterTrebleRangeStr = player.setFilterTrebleBand(Float(filterTrebleSlider.start), Float(filterTrebleSlider.end))
        lblFilterTrebleRange.stringValue = filterTrebleRangeStr
    }
    
    @IBAction func eqTabViewAction(_ sender: Any) {
        
        for button in fxTabViewButtons! {
            button.state = 0
        }
        
        eqTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 0)
    }
    
    @IBAction func pitchTabViewAction(_ sender: Any) {
        
        for button in fxTabViewButtons! {
            button.state = 0
        }
        
        pitchTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 1)
    }
    
    @IBAction func timeTabViewAction(_ sender: Any) {
        
        for button in fxTabViewButtons! {
            button.state = 0
        }
        
        timeTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 2)
    }
    
    @IBAction func reverbTabViewAction(_ sender: Any) {
        
        for button in fxTabViewButtons! {
            button.state = 0
        }
        
        reverbTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 3)
    }
    
    @IBAction func delayTabViewAction(_ sender: Any) {
        
        for button in fxTabViewButtons! {
            button.state = 0
        }
        
        delayTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 4)
    }
    
    @IBAction func filterTabViewAction(_ sender: Any) {
        
        for button in fxTabViewButtons! {
            button.state = 0
        }
        
        filterTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 5)
    }
    
    @IBAction func recorderTabViewAction(_ sender: Any) {
        
        for button in fxTabViewButtons! {
            button.state = 0
        }
        
        recorderTabViewButton.state = 1
        fxTabView.selectTabViewItem(at: 6)
    }
    
    @IBAction func userGuideAction(_ sender: Any) {
        NSWorkspace.shared().open(AppConstants.userGuideURL)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        
        let value = volumeDeltaStepper.integerValue
        volumeDeltaField.stringValue = String(format: "%d%%", value)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        
        let value = panDeltaStepper.integerValue
        panDeltaField.stringValue = String(format: "%d%%", value)
    }
    
    @IBAction func preferencesAction(_ sender: Any) {
        
        resetPreferencesFields()
        
        // Position the search modal dialog and show it
        let prefsFrameOrigin = NSPoint(x: window.frame.origin.x - 2, y: min(window.frame.origin.y + 227, window.frame.origin.y + window.frame.height - prefsPanel.frame.height))
        
        prefsPanel.setFrameOrigin(prefsFrameOrigin)
        prefsPanel.setIsVisible(true)
        
        NSApp.runModal(for: prefsPanel)
        prefsPanel.close()
    }
    
    @IBAction func savePreferencesAction(_ sender: Any) {
        
        preferences.seekLength = seekLengthSlider.integerValue
        preferences.volumeDelta = volumeDeltaStepper.floatValue * AppConstants.volumeConversion_UIToPlayer
        
        preferences.volumeOnStartup = btnRememberVolume.state == 1 ? .rememberFromLastAppLaunch : .specific
        preferences.startupVolumeValue = Float(startupVolumeSlider.integerValue) * AppConstants.volumeConversion_UIToPlayer
        
        preferences.panDelta = panDeltaStepper.floatValue * AppConstants.panConversion_UIToPlayer
        preferences.autoplayOnStartup = Bool(btnAutoplayOnStartup.state)
        preferences.autoplayAfterAddingTracks = Bool(btnAutoplayAfterAddingTracks.state)
        preferences.autoplayAfterAddingOption = btnAutoplayIfNotPlaying.state == 1 ? .ifNotPlaying : .always
        
        preferences.playlistOnStartup = btnEmptyPlaylist.state == 1 ? .empty : .rememberFromLastAppLaunch
        
        preferences.viewOnStartup.option = btnStartWithView.state == 1 ? .specific : .rememberFromLastAppLaunch
        
        for viewType in ViewTypes.allValues {
            
            if startWithViewMenu.selectedItem!.title == viewType.description {
                preferences.viewOnStartup.viewType = viewType
                break;
            }
        }
        
        preferences.windowLocationOnStartup.option = btnRememberWindowLocation.state == 1 ? .rememberFromLastAppLaunch : .specific
        
        for location in WindowLocations.allValues {
            
            if startWindowLocationMenu.selectedItem!.title == location.description {
                preferences.windowLocationOnStartup.windowLocation = location
                break;
            }
        }
        
        dismissModalDialog()
        Preferences.persistAsync()
    }
    
    @IBAction func cancelPreferencesAction(_ sender: Any) {
        dismissModalDialog()
    }
    
    @IBAction func seekLengthAction(_ sender: Any) {
        
        let value = seekLengthSlider.integerValue
        seekLengthField.stringValue = Utils.formatDuration_minSec(value)
    }
    
    @IBAction func seekLengthIncrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) < seekLengthSlider.maxValue) {
            seekLengthSlider.integerValue += 1
            seekLengthField.stringValue = Utils.formatDuration_minSec(seekLengthSlider.integerValue)
        }
    }
    
    @IBAction func seekLengthDecrementAction(_ sender: Any) {
        
        if (Double(seekLengthSlider.integerValue) > seekLengthSlider.minValue) {
            seekLengthSlider.integerValue -= 1
            seekLengthField.stringValue = Utils.formatDuration_minSec(seekLengthSlider.integerValue)
        }
    }
    
    @IBAction func playerPrefsTabViewAction(_ sender: Any) {
        
        for button in prefsTabViewButtons! {
            button.state = 0
        }
        
        btnPlayerPrefs.state = 1
        prefsTabView.selectTabViewItem(at: 0)
    }
    
    @IBAction func playlistPrefsTabViewAction(_ sender: Any) {
        
        for button in prefsTabViewButtons! {
            button.state = 0
        }
        
        btnPlaylistPrefs.state = 1
        prefsTabView.selectTabViewItem(at: 1)
    }
    
    @IBAction func viewPrefsTabViewAction(_ sender: Any) {
        
        for button in prefsTabViewButtons! {
            button.state = 0
        }
        
        btnViewPrefs.state = 1
        prefsTabView.selectTabViewItem(at: 2)
    }
    
    @IBAction func startupPlaylistPrefAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func startupViewPrefAction(_ sender: Any) {
        startWithViewMenu.isEnabled = Bool(btnStartWithView.state)
    }
    
    // When the check box for "autoplay after adding tracks" is checked/unchecked, update the enabled state of the 2 option radio buttons
    @IBAction func autoplayAfterAddingAction(_ sender: Any) {
        
        btnAutoplayIfNotPlaying.isEnabled = Bool(btnAutoplayAfterAddingTracks.state)
        btnAutoplayAlways.isEnabled = Bool(btnAutoplayAfterAddingTracks.state)
    }
    
    @IBAction func autoplayAfterAddingRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func resetPreferencesFields() {
        
        // Player preferences
        let seekLength = preferences.seekLength
        seekLengthSlider.integerValue = seekLength
        seekLengthField.stringValue = Utils.formatDuration_minSec(seekLength)
        
        let volumeDelta = Int(round(preferences.volumeDelta * AppConstants.volumeConversion_playerToUI))
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        btnRememberVolume.state = preferences.volumeOnStartup == .rememberFromLastAppLaunch ? 1 : 0
        btnSpecifyVolume.state = preferences.volumeOnStartup == .rememberFromLastAppLaunch ? 0 : 1
        startupVolumeSlider.isEnabled = btnSpecifyVolume.state == 1
        startupVolumeSlider.integerValue = Int(round(preferences.startupVolumeValue * AppConstants.volumeConversion_playerToUI))
        lblStartupVolume.isEnabled = btnSpecifyVolume.state == 1
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        let panDelta = Int(round(preferences.panDelta * AppConstants.panConversion_playerToUI))
        panDeltaStepper.integerValue = panDelta
        panDeltaField.stringValue = String(format: "%d%%", panDelta)
        
        btnAutoplayOnStartup.state = preferences.autoplayOnStartup ? 1 : 0
        
        btnAutoplayAfterAddingTracks.state = preferences.autoplayAfterAddingTracks ? 1 : 0
        btnAutoplayIfNotPlaying.isEnabled = preferences.autoplayAfterAddingTracks
        btnAutoplayIfNotPlaying.state = preferences.autoplayAfterAddingOption == .ifNotPlaying ? 1 : 0
        btnAutoplayAlways.isEnabled = preferences.autoplayAfterAddingTracks
        btnAutoplayAlways.state = preferences.autoplayAfterAddingOption == .always ? 1 : 0
        
        // Playlist preferences
        if (preferences.playlistOnStartup == .empty) {
            btnEmptyPlaylist.state = 1
        } else {
            btnRememberPlaylist.state = 1
        }
        
        // View preferences
        if (preferences.viewOnStartup.option == .specific) {
            btnStartWithView.state = 1
        } else {
            btnRememberView.state = 1
        }
        
        for item in startWithViewMenu.itemArray {
            
            if item.title == preferences.viewOnStartup.viewType.description {
                startWithViewMenu.select(item)
                break;
            }
        }
        
        startWithViewMenu.isEnabled = Bool(btnStartWithView.state)
        
        btnRememberWindowLocation.state = preferences.windowLocationOnStartup.option == .rememberFromLastAppLaunch ? 1 : 0
        
        btnStartAtWindowLocation.state = preferences.windowLocationOnStartup.option == .specific ? 1 : 0
        
        startWindowLocationMenu.isEnabled = Bool(btnStartAtWindowLocation.state)
        
        for item in startWindowLocationMenu.itemArray {
            
            if item.title == preferences.windowLocationOnStartup.windowLocation.description {
                startWindowLocationMenu.select(item)
            }
        }
        
        // Select the player prefs tab
        playerPrefsTabViewAction(self)
    }
    
    @IBAction func startupVolumeButtonAction(_ sender: Any) {
        startupVolumeSlider.isEnabled = btnSpecifyVolume.state == 1
        lblStartupVolume.isEnabled = btnSpecifyVolume.state == 1
    }
    
    @IBAction func startupVolumeSliderAction(_ sender: Any) {
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
    }
    
    @IBAction func windowLocationOnStartupAction(_ sender: Any) {
        
        startWindowLocationMenu.isEnabled = Bool(btnStartAtWindowLocation.state)
    }
    
}

// Int to Bool conversion
extension Bool {
    init<T: Integer>(_ num: T) {
        self.init(num != 0)
    }
}
