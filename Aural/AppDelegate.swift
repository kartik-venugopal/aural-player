/*
Entry point for the Aural Player application. Performs all interaction with the UI and delegates music player operations to PlayerDelegate.
*/

import Cocoa
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, EventSubscriber {
    
    @IBOutlet weak var window: NSWindow!
    
    // Buttons to toggle (collapsible) playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
    // Views that are collapsible (hide/show)
    @IBOutlet weak var playlistControlsBox: NSBox!
    @IBOutlet weak var fxTabView: NSTabView!
    @IBOutlet weak var fxBox: NSBox!
    @IBOutlet weak var playlistBox: NSBox!
    
    // Playlist summary labels
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Displays the playlist
    @IBOutlet weak var playlistView: NSTableView!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Volume/pan/effects controls
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    @IBOutlet weak var btnPitchBypass: NSButton!
    @IBOutlet weak var pitchSlider: NSSlider!
    @IBOutlet weak var pitchOverlapSlider: NSSlider!
    
    @IBOutlet weak var timeSlider: NSSlider!
    
    @IBOutlet weak var btnReverbBypass: NSButton!
    @IBOutlet weak var reverbMenu: NSPopUpButton!
    @IBOutlet weak var reverbSlider: NSSlider!
    
    @IBOutlet weak var btnDelayBypass: NSButton!
    @IBOutlet weak var delayTimeSlider: NSSlider!
    @IBOutlet weak var delayAmountSlider: NSSlider!
    @IBOutlet weak var btnTimeBypass: NSButton!
    @IBOutlet weak var delayCutoffSlider: NSSlider!
    @IBOutlet weak var delayFeedbackSlider: NSSlider!
    
    @IBOutlet weak var btnFilterBypass: NSButton!
    @IBOutlet weak var filterLowPassSlider: NSSlider!
    @IBOutlet weak var filterHighPassSlider: NSSlider!
    
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
        popover.behavior = .Semitransient
        let ctrlr = PopoverController(nibName: "PopoverController", bundle: NSBundle.mainBundle())
        popover.contentViewController = ctrlr
        return popover
        }()
    
    // PlayerDelegate accepts all requests originating from the UI
    let player: PlayerDelegate = PlayerDelegate.instance()
    
    // Timer that periodically updates the seek bar
    var seekTimer: ScheduledTaskExecutor? = nil
    
    // Indicates whether the open/save dialog is currently open
    // Used in KeyPressHandler
    var modalDialogOpen: Bool = false
    
    var playlistCollapsibleView: CollapsibleView?
    var fxCollapsibleView: CollapsibleView?
    var windowManager: WindowManager?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        // Initialize UI with presentation settings (colors, sizes, etc)
        // No app state is needed here
        initStatelessUI()
        
        // Set up key press handler
        KeyPressHandler.initialize(self)
        NSEvent.addLocalMonitorForEventsMatchingMask(NSEventMask.KeyDownMask, handler: {(evt: NSEvent!) -> NSEvent in
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
        EventRegistry.subscribe(.TrackChanged, subscriber: self, dispatchQueue: DispatchQueue(queueType: QueueType.MAIN))
        
        window.movableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        tearDown()
    }

    func initStatelessUI() {
        
        // Set up a mouse listener (for double clicks -> play selected track)
        playlistView.doubleAction = Selector("playlistDoubleClickAction:")
        
        // Enable drag n drop into the playlist view
        playlistView.registerForDraggedTypes([String(kUTTypeFileURL)])
        
        seekTimer = ScheduledTaskExecutor(intervalMillis: UIConstants.seekTimerIntervalMillis, task: {self.updatePlayingTime()}, queue: DispatchQueue(queueType: QueueType.MAIN))
        
        playlistCollapsibleView = CollapsibleView(views: [playlistBox, playlistControlsBox])
        fxCollapsibleView = CollapsibleView(views: [fxBox, fxTabView])
        
        let collapsibleViews = [playlistCollapsibleView!, fxCollapsibleView!]
        windowManager = WindowManager(window: window, views: collapsibleViews)
    }
    
    func initStatefulUI(playerState: SavedPlayerState) {
        
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
            
        case .OFF: btnRepeat.image = UIConstants.imgRepeatOff
        case .ONE: btnRepeat.image = UIConstants.imgRepeatOne
        case .ALL: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
        
        switch playerState.shuffleMode {
            
        case .OFF: btnShuffle.image = UIConstants.imgShuffleOff
        case .ON: btnShuffle.image = UIConstants.imgShuffleOn
            
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
                reverbMenu.selectItem(item)
            }
        }
        reverbSlider.floatValue = playerState.reverbAmount
        
        btnDelayBypass.image = playerState.delayBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        delayAmountSlider.floatValue = playerState.delayAmount
        delayTimeSlider.doubleValue = playerState.delayTime
        delayFeedbackSlider.floatValue = playerState.delayFeedback
        delayCutoffSlider.floatValue = playerState.delayLowPassCutoff
        
        btnFilterBypass.image = playerState.filterBypass ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        filterHighPassSlider.floatValue = playerState.filterHighPassCutoff
        filterLowPassSlider.floatValue = playerState.filterLowPassCutoff
        
        eqPresets.selectItemAtIndex(-1)
        
        fxTabView.selectFirstTabViewItem(self)
        
        playlistView.reloadData()
        updatePlaylistSummary()
    }
    
    func updatePlaylistSummary() {
        let summary = player.getPlaylistSummary()
        let numTracks = summary.numTracks
        lblTracksSummary.stringValue = String(numTracks) + (numTracks == 1 ? " track" : " tracks")
        lblDurationSummary.stringValue = Utils.formatDuration(summary.totalDuration)
    }
    
    private func updateEQSliders(eqBands: [Int: Float]) {
        
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
    
    @IBAction func addTracksAction(sender: AnyObject) {
        
        let dialog = UIElements.openDialog
        
        // TODO: Clear previous selection of files
        
        modalDialogOpen = true
        let modalResponse = dialog.runModal()
        modalDialogOpen = false
        
        if (modalResponse == NSModalResponseOK) {
            addTracks(dialog.URLs)
        }
    }
    
    @IBAction func removeSingleTrackAction(sender: AnyObject) {
        
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
        if (popover.shown) {
            popover.performClose(nil)
        }
    }
    
    // Play / Pause / Resume
    @IBAction func playPauseAction(sender: AnyObject) {
        
        let playbackInfo = player.togglePlayPause()
        
        switch playbackInfo.playbackState {
            
        case .NO_FILE, .PAUSED: setSeekTimerState(false)
        setPlayPauseImage(UIConstants.imgPlay)
            
        case .PLAYING:
            
            if (playbackInfo.trackChanged) {
                trackChange(playbackInfo.playingTrack!, newTrackIndex: playbackInfo.playingTrackIndex!)
            } else {
                setSeekTimerState(true)
                setPlayPauseImage(UIConstants.imgPause)
            }
        }
    }
    
    func showNowPlayingInfo(track: Track) {
        
        if (track.longDisplayName != nil) {
            
            if (track.longDisplayName!.artist != nil) {
                
                // Both title and artist
                lblTrackArtist.stringValue = "Artist: " + track.longDisplayName!.artist!
                lblTrackTitle.stringValue = "Title: " + track.longDisplayName!.title!
                
                bigLblTrack.hidden = true
                lblTrackArtist.hidden = false
                lblTrackTitle.hidden = false
                
            } else {
                
                // Title only
                bigLblTrack.hidden = false
                lblTrackArtist.hidden = true
                lblTrackTitle.hidden = true
                
                bigLblTrack.stringValue = track.longDisplayName!.title!
            }
            
        } else {
            
            // Short display name
            bigLblTrack.hidden = false
            lblTrackArtist.hidden = true
            lblTrackTitle.hidden = true
            
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
        btnMoreInfo.hidden = true
        setPlayPauseImage(UIConstants.imgPlay)
        hidePopover()
    }
    
    private func setPlayPauseImage(image: NSImage) {
        btnPlayPause.image = image
    }
    
    private func setSeekTimerState(timerOn: Bool) {
        
        if (timerOn) {
            seekTimer?.startOrResume()
        } else {
            seekTimer?.pause()
        }
    }
    
    func updatePlayingTime() {
        
        if (player.getPlaybackState() == .PLAYING) {
            let seekPosn = player.getSeekSecondsAndPercentage()
            
            lblPlayingTime.stringValue = Utils.formatDuration(seekPosn.seconds)
            seekSlider.doubleValue = seekPosn.percentage
        }
    }
    
    func resetPlayingTime() {
        
        lblPlayingTime.stringValue = UIConstants.zeroDurationString
        seekSlider.floatValue = 0
    }
    
    // Needed for timer selector
    func updatePlayingTime(sender: AnyObject) {
        updatePlayingTime()
    }
    
    func playlistDoubleClickAction(sender: AnyObject) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        if (playlistView.selectedRow >= 0) {
            let track = player.play(playlistView.selectedRow)
            trackChange(track, newTrackIndex: playlistView.selectedRow)
        }
    }
    
    @IBAction func nextTrackAction(sender: AnyObject) {
        let trackInfo = player.nextTrack()
        if (trackInfo.playingTrack != nil) {
            trackChange(trackInfo.playingTrack!, newTrackIndex: trackInfo.playingTrackIndex!)
        }
    }
    
    @IBAction func prevTrackAction(sender: AnyObject) {
        let trackInfo = player.previousTrack()
        if (trackInfo.playingTrack != nil) {
            trackChange(trackInfo.playingTrack!, newTrackIndex: trackInfo.playingTrackIndex!)
        }
    }
    
    func trackChange(newTrack: Track?, newTrackIndex: Int?) {
        
        if (newTrack != nil) {
            
            setSeekTimerState(true)
            setPlayPauseImage(UIConstants.imgPause)
            showNowPlayingInfo(newTrack!)
            btnMoreInfo.hidden = false
            
            if (popover.shown) {
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
    
    func selectTrack(index: Int?) {
        
        if index != nil {
            
            playlistView.selectRowIndexes(NSIndexSet(index: index!), byExtendingSelection: false)
            showPlaylistSelectedRow()
            
        } else {
            // Select first track in list, if list not empty
            if (playlistView.numberOfRows > 0) {
                playlistView.selectRowIndexes(NSIndexSet(index: 0), byExtendingSelection: false)
            }
        }
    }
    
    func showPlaylistSelectedRow() {
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.selectedRow)
        }
    }
    
    @IBAction func seekBackwardAction(sender: AnyObject) {
        player.seekBackward()
        updatePlayingTime()
    }
    
    @IBAction func seekForwardAction(sender: AnyObject) {
        player.seekForward()
        updatePlayingTime()
    }
    
    @IBAction func seekSliderAction(sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
        updatePlayingTime()
    }
    
    @IBAction func volumeAction(sender: AnyObject) {
        player.setVolume(volumeSlider.floatValue)
        setVolumeImage(player.isMuted())
    }
    
    @IBAction func volumeBtnAction(sender: AnyObject) {
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
    
    private func setVolumeImage(muted: Bool) {
        
        if (muted) {
            btnVolume.image = UIConstants.imgMute
        } else {
            let vol = player.getVolume()
            
            // Low / Medium / High (different images)
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
    
    @IBAction func panAction(sender: AnyObject) {
        player.setBalance(panSlider.floatValue)
    }
    
    func panRight() {
        panSlider.floatValue = player.panRight()
    }
    
    func panLeft() {
        panSlider.floatValue = player.panLeft()
    }
    
    @IBAction func clearPlaylistAction(sender: AnyObject) {
        
        player.clearPlaylist()
        playlistView.reloadData()
        updatePlaylistSummary()
        
        trackChange(nil, newTrackIndex: nil)
    }
    
    @IBAction func repeatAction(sender: AnyObject) {
        
        let repeatMode = player.toggleRepeatMode()
        
        switch repeatMode {
            
        case .OFF: btnRepeat.image = UIConstants.imgRepeatOff
        case .ONE: btnRepeat.image = UIConstants.imgRepeatOne
        case .ALL: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
    }
    
    @IBAction func shuffleAction(sender: AnyObject) {
        
        let shuffleMode = player.toggleShuffleMode()
        
        switch shuffleMode {
            
        case .OFF: btnShuffle.image = UIConstants.imgShuffleOff
        case .ON: btnShuffle.image = UIConstants.imgShuffleOn
            
        }
    }
    
    @IBAction func moreInfoAction(sender: AnyObject) {
        
        let playingTrack = player.getMoreInfo()
        if (playingTrack == nil) {
            return
        }
        
        if (popover.shown) {
            popover.performClose(nil)
            
        } else {
            
            let positioningRect = NSZeroRect
            let preferredEdge = NSRectEdge.MaxX
            
            (popover.contentViewController as! PopoverController).refresh()
            popover.showRelativeToRect(positioningRect, ofView: btnMoreInfo as NSView, preferredEdge: preferredEdge)
        }
    }
    
    @IBAction func eqPresetsAction(sender: AnyObject) {
        
        // TODO: Change this lookup to o(1) instead of o(n) ... HashMap !
        let preset = EQPresets.fromDescription((eqPresets.selectedItem?.title)!)
        
        let eqBands: [Int: Float] = preset.bands
        player.setEQBands(eqBands)
        updateEQSliders(eqBands)
        
        eqPresets.selectItemAtIndex(-1)
    }
    
    @IBAction func moveTrackDownAction(sender: AnyObject) {
        shiftPlaylistTrackDown()
        showPlaylistSelectedRow()
    }
    
    @IBAction func moveTrackUpAction(sender: AnyObject) {
        shiftPlaylistTrackUp()
        showPlaylistSelectedRow()
    }
    
    func shiftPlaylistTrackUp() {
        
        let selRow = player.moveTrackUp(playlistView.selectedRow)
        playlistView.reloadData()
        playlistView.selectRowIndexes(NSIndexSet(index: selRow), byExtendingSelection: false)
    }
    
    func shiftPlaylistTrackDown() {
        
        let selRow = player.moveTrackDown(playlistView.selectedRow)
        playlistView.reloadData()
        playlistView.selectRowIndexes(NSIndexSet(index: selRow), byExtendingSelection: false)
    }
    
    @IBAction func savePlaylistAction(sender: AnyObject) {
        
        // Make sure there is at least one track to save
        if (player.getPlaylistSummary().numTracks > 0) {
        
            let dialog = UIElements.saveDialog
            
            modalDialogOpen = true
            let modalResponse = dialog.runModal()
            modalDialogOpen = false
            
            if (modalResponse == NSModalResponseOK) {
                
                let file = dialog.URL // Path of the file
                player.savePlaylist(file!)
            }
        }
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        tearDown()
        exit(0)
    }
    
    @IBAction func hideAction(sender: AnyObject) {
        window.miniaturize(self)
    }
    
    @IBAction func pitchBypassAction(sender: AnyObject) {
        
        let newBypassState = player.togglePitchBypass()
        
        btnPitchBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func pitchAction(sender: AnyObject) {
        player.setPitch(pitchSlider.floatValue)
    }
    
    @IBAction func pitchOverlapAction(sender: AnyObject) {
        player.setPitchOverlap(pitchOverlapSlider.floatValue)
    }
    
    @IBAction func timeBypassAction(sender: AnyObject) {
        
        let newBypassState = player.toggleTimeBypass()
        
        btnTimeBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
        
        let interval = UInt32(newBypassState ? 500 : 1000 / (2 * timeSlider.floatValue))
        
        if (interval != seekTimer?.getInterval()) {
        
            seekTimer?.stop()
            
            seekTimer = ScheduledTaskExecutor(intervalMillis: interval, task: {self.updatePlayingTime()}, queue: DispatchQueue(queueType: QueueType.MAIN))
            
            if (player.getPlaybackState() == .PLAYING) {
                setSeekTimerState(true)
            }
        }
    }
    
    @IBAction func timeStretchAction(sender: AnyObject) {
        
        player.setTimeStretchRate(timeSlider.floatValue)
        
        let interval = 1000 / (2 * timeSlider.floatValue)
        
        seekTimer?.stop()
        
        seekTimer = ScheduledTaskExecutor(intervalMillis: UInt32(interval), task: {self.updatePlayingTime()}, queue: DispatchQueue(queueType: QueueType.MAIN))
        
        if (player.getPlaybackState() == .PLAYING) {
            setSeekTimerState(true)
        }
    }
    
    @IBAction func reverbBypassAction(sender: AnyObject) {

        let newBypassState = player.toggleReverbBypass()
        
        btnReverbBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func reverbAction(sender: AnyObject) {
        
        let preset: ReverbPresets = ReverbPresets.fromDescription((reverbMenu.selectedItem?.title)!)
        
        player.setReverb(preset)
    }
    
    @IBAction func reverbAmountAction(sender: AnyObject) {
        player.setReverbAmount(reverbSlider.floatValue)
    }
    
    @IBAction func delayBypassAction(sender: AnyObject) {
        
        let newBypassState = player.toggleDelayBypass()
        
        btnDelayBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func delayAmountAction(sender: AnyObject) {
        player.setDelayAmount(delayAmountSlider.floatValue)
    }
    
    @IBAction func delayTimeAction(sender: AnyObject) {
        player.setDelayTime(delayTimeSlider.doubleValue)
    }
    
    @IBAction func delayFeedbackAction(sender: AnyObject) {
        player.setDelayFeedback(delayFeedbackSlider.floatValue)
    }
    
    @IBAction func delayCutoffAction(sender: AnyObject) {
        player.setDelayLowPassCutoff(delayCutoffSlider.floatValue)
    }
    
    @IBAction func filterBypassAction(sender: AnyObject) {
        
        let newBypassState = player.toggleFilterBypass()
        
        btnFilterBypass.image = newBypassState ? UIConstants.imgSwitchOff : UIConstants.imgSwitchOn
    }
    
    @IBAction func filterHighPassAction(sender: AnyObject) {
        player.setFilterHighPassCutoff(filterHighPassSlider.floatValue)
    }
    
    @IBAction func filterLowPassAction(sender: AnyObject) {
        player.setFilterLowPassCutoff(filterLowPassSlider.floatValue)
    }
    
    @IBAction func eqGlobalGainAction(sender: AnyObject) {
        player.setEQGlobalGain(eqGlobalGainSlider.floatValue)
    }
    
    @IBAction func eqSlider32Action(sender: AnyObject) {
        player.setEQBand(32, gain: eqSlider32.floatValue)
    }
    
    @IBAction func eqSlider64Action(sender: AnyObject) {
        player.setEQBand(64, gain: eqSlider64.floatValue)
    }
    
    @IBAction func eqSlider128Action(sender: AnyObject) {
        player.setEQBand(128, gain: eqSlider128.floatValue)
    }
    
    @IBAction func eqSlider256Action(sender: AnyObject) {
        player.setEQBand(256, gain: eqSlider256.floatValue)
    }
    
    @IBAction func eqSlider512Action(sender: AnyObject) {
        player.setEQBand(512, gain: eqSlider512.floatValue)
    }
    
    @IBAction func eqSlider1kAction(sender: AnyObject) {
        player.setEQBand(1024, gain: eqSlider1k.floatValue)
    }
    
    @IBAction func eqSlider2kAction(sender: AnyObject) {
        player.setEQBand(2048, gain: eqSlider2k.floatValue)
    }
    
    @IBAction func eqSlider4kAction(sender: AnyObject) {
        player.setEQBand(4096, gain: eqSlider4k.floatValue)
    }
    
    @IBAction func eqSlider8kAction(sender: AnyObject) {
        player.setEQBand(8192, gain: eqSlider8k.floatValue)
    }
    
    @IBAction func eqSlider16kAction(sender: AnyObject) {
        player.setEQBand(16384, gain: eqSlider16k.floatValue)
    }
    
    // Track changed in player, need to reset the UI
    func consumeEvent(event: Event) {
        
        setSeekTimerState(false)
        
        let _event = event as! TrackChangedEvent
        trackChange(_event.newTrack, newTrackIndex: _event.newTrackIndex)
    }
    
    // Adds a set of files (or directories, i.e. files within them) to the current playlist, if supported
    func addTracks(files: [NSURL]) {
        
        player.addTracks(files)
        
        // Refresh the playlist view with the new files
        playlistView.reloadData()
        updatePlaylistSummary()
    }

    // View menu item action
    @IBAction func toggleViewEffectsAction(sender: AnyObject) {
        
        windowManager?.toggleView(fxCollapsibleView!)
        
        if (fxCollapsibleView?.hidden == false) {
            btnToggleEffects.state = 1
        } else {
            btnToggleEffects.state = 0
        }
    }
    
    // View menu item action
    @IBAction func toggleViewPlaylistAction(sender: AnyObject) {
        
        // Set focus on playlist view if it's visible after the toggle
        
        windowManager?.toggleView(playlistCollapsibleView!)
        
        if (playlistCollapsibleView?.hidden == false) {
            window.makeFirstResponder(playlistView)
            btnTogglePlaylist.state = 1
        } else {
            btnTogglePlaylist.state = 0
        }
    }
    
    // Toggle button action
    @IBAction func togglePlaylistAction(sender: AnyObject) {
        toggleViewPlaylistAction(sender)
    }
    
    // Toggle button action
    @IBAction func toggleEffectsAction(sender: AnyObject) {
        toggleViewEffectsAction(sender)
    }
    
    func isEffectsShown() -> Bool {
        return fxCollapsibleView?.hidden == false
    }
    
    func isPlaylistShown() -> Bool {
        return playlistCollapsibleView?.hidden == false
    }
}