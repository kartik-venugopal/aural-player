import Cocoa

class MenuBarPlayerViewController: NSViewController, MenuBarMenuObserver, NotificationSubscriber, Destroyable {

    override var nibName: String? {"MenuBarPlayer"}
    
    @IBOutlet weak var appLogo: TintedImageView!
    @IBOutlet weak var btnQuit: TintedImageButton!
    @IBOutlet weak var btnRegularMode: TintedImageButton!
    
    @IBOutlet weak var infoBox: NSBox!
    @IBOutlet weak var trackInfoView: MenuBarPlayingTrackTextView!
    @IBOutlet weak var imgArt: NSImageView!
    @IBOutlet weak var artOverlayBox: NSBox!
    
    @IBOutlet weak var btnPlayPause: OnOffImageButton!
    @IBOutlet weak var btnSeekBackward: TintedImageButton!
    @IBOutlet weak var btnSeekForward: TintedImageButton!
    
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnLoop: MultiStateImageButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: TrackPeekingButton!
    @IBOutlet weak var btnNextTrack: TrackPeekingButton!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    var seekSliderValue: Double {
        return seekSlider.doubleValue
    }
    
    // A clone of the seek slider, used to render the segment playback loop
    @IBOutlet weak var seekSliderClone: NSSlider!
    @IBOutlet weak var seekSliderCloneCell: SeekSliderCell!
    
    // Timer that periodically updates the seek position slider and label
    private var seekTimer: RepeatingTaskExecutor?
    
    @IBOutlet weak var lblTimeElapsed: VALabel!
    @IBOutlet weak var lblTimeRemaining: VALabel!
    
    @IBOutlet weak var btnVolume: TintedImageButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var lblVolume: VALabel!
    private var autoHidingVolumeLabel: AutoHidingView!
    
    @IBOutlet weak var btnSettings: TintedImageButton!
    @IBOutlet weak var settingsBox: NSBox!
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
//    private var gestureHandler: GestureHandler?
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let sequencer: SequencerDelegateProtocol = ObjectGraph.sequencerDelegate
    
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    
    // Numerical ranges
    private let highVolumeRange: ClosedRange<Float> = 200.0/3...100
    private let mediumVolumeRange: Range<Float> = 100.0/3..<200.0/3
    private let lowVolumeRange: Range<Float> = 1..<100.0/3
    
    override func awakeFromNib() {
        
        btnPlayPause.off()
        btnLoop.switchState(LoopState.none)

        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {Colors.Constants.white40Percent}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {Colors.Constants.white70Percent}
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]

        btnLoop.stateImageMappings = [(LoopState.none, (Images.imgLoopOff, offStateTintFunction)), (LoopState.started, (Images.imgLoopStarted, onStateTintFunction)), (LoopState.complete, (Images.imgLoopComplete, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        [btnRepeat, btnShuffle, btnLoop].forEach {
            $0?.reTint()
        }

        // Play/pause button does not really have an "off" state
        btnPlayPause.onStateTintFunction = onStateTintFunction
        btnPlayPause.offStateTintFunction = onStateTintFunction
        
        // Button tool tips
        btnPreviousTrack.toolTipFunction = {[weak self] () -> String? in

            if let prevTrack = self?.sequencer.peekPrevious() {
                return String(format: "Previous track: '%@'", prevTrack.displayName)
            }

            return nil
        }
        
        btnNextTrack.toolTipFunction = {[weak self] () -> String? in

            if let nextTrack = self?.sequencer.peekNext() {
                return String(format: "Next track: '%@'", nextTrack.displayName)
            }

            return nil
        }
        
        [btnQuit, btnRegularMode, btnSettings, btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward, btnVolume].forEach {$0?.tintFunction = {Colors.Constants.white70Percent}}
        
        appLogo.tintFunction = {Colors.Constants.white70Percent}

        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        
        // MARK: Notification subscriptions
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:), queue: .main)
        
        Messenger.subscribe(self, .player_playbackLoopChanged, self.playbackLoopChanged)
        
        Messenger.subscribe(self, .player_chapterChanged, self.chapterChanged(_:))
        
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackNotPlayed(_:), queue: .main)
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
    }
    
    override func viewDidLoad() {
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        
        volumeSlider.floatValue = audioGraph.volume
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        let seekTimerInterval = roundedInt(1000 / (2 * audioGraph.timeUnit.effectiveRate))
        
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval, task: {[weak self] in
            self?.updateSeekPosition()
        }, queue: .main)
        
        updateTrackInfo()
        btnPlayPause.onIf(player.state == .playing)
        setSeekTimerState(false)
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        playOrPause()
    }
    
    func playOrPause() {
        
        player.togglePlayPause()
        stateChanged(player.state)
        updateTrackInfo()
    }
    
    func stateChanged(_ newState: PlaybackState) {
        
        btnPlayPause.onIf(newState == .playing)
        setSeekTimerState(newState == .playing)
    }
    
    private func updateTrackInfo() {
        
        if let theTrack = player.playingTrack {
            
            trackInfoView.trackInfo = PlayingTrackInfo(theTrack, player.playingChapter?.chapter.title)
            
            seekSlider.enable()
            seekSlider.show()
            
            [lblTimeElapsed, lblTimeRemaining].forEach {$0?.show()}
            
            if theTrack.hasChapters {
                beginPollingForChapterChange()
            }
            
        } else {
            
            trackInfoView.trackInfo = nil
            stopPollingForChapterChange()
            
            NSView.hideViews(lblTimeElapsed, lblTimeRemaining, seekSlider)
            
            seekSliderCell.removeLoop()
            seekSlider.doubleValue = 0
            seekSlider.disable()
        }
        
        imgArt.image = player.playingTrack?.art?.image
        [imgArt, artOverlayBox].forEach {$0?.showIf(imgArt.image != nil && MenuBarPlayerViewState.showAlbumArt)}
        
        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
        playbackLoopChanged()
        
        infoBox.bringToFront()
    }
    
    private var curChapter: IndexedChapter? = nil
    
    // Creates a recurring task that polls the player to detect a change in the currently playing track chapter.
    // This only occurs when the currently playing track actually has chapters.
    private func beginPollingForChapterChange() {
        
        SeekTimerTaskQueue.enqueueTask("ChapterChangePollingTask", {[weak self] () -> Void in
            
            guard let nonNilSelf = self else {return}
            
            let playingChapter: IndexedChapter? = nonNilSelf.player.playingChapter
            
            // Compare the current chapter with the last known value of current chapter
            if nonNilSelf.curChapter != playingChapter, let theTrack = nonNilSelf.player.playingTrack {
                
                // There has been a change ... notify observers and update the variable
                nonNilSelf.trackInfoView.trackInfo = PlayingTrackInfo(theTrack, playingChapter?.chapter.title)
                nonNilSelf.curChapter = playingChapter
            }
        })
    }
    
    // Disables the chapter change polling task
    private func stopPollingForChapterChange() {
        SeekTimerTaskQueue.dequeueTask("ChapterChangePollingTask")
    }
   
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        previousTrack()
    }
    
    func previousTrack() {
        
        player.previousTrack()
        updateTrackInfo()
        stateChanged(player.state)
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        nextTrack()
    }

    func nextTrack() {
        
        player.nextTrack()
        updateTrackInfo()
        stateChanged(player.state)
    }
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        
        player.seekToPercentage(seekSliderValue)
        updateSeekPosition()
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        seekBackward(.discrete)
    }
    
    func seekBackward(_ inputMode: UserInputMode) {
        
        player.seekBackward(inputMode)
        updateSeekPosition()
    }
    
    func updateSeekPosition() {
        
        let seekPosn = player.seekPosition
        seekSlider.doubleValue = seekPosn.percentageElapsed
        
        let trackTimes = ValueFormatter.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, .formatted, .formatted)
        
        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemaining.stringValue = trackTimes.remaining
        
        for task in SeekTimerTaskQueue.tasksArray {
            task()
        }
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        seekForward(.discrete)
    }
    
    func seekForward(_ inputMode: UserInputMode) {
        
        player.seekForward(inputMode)
        updateSeekPosition()
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        timerOn ? seekTimer?.startOrResume() : seekTimer?.pause()
    }
    
    func stop() {
        player.stop()
    }
    
    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleRepeatMode())
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        updateRepeatAndShuffleControls(sequencer.toggleShuffleMode())
    }
    
    private func updateRepeatAndShuffleControls(_ modes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode)) {

        btnShuffle.switchState(modes.shuffleMode)
        btnRepeat.switchState(modes.repeatMode)
    }
    
    // Toggles the state of the segment playback loop for the currently playing track
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
        toggleLoop()
    }
    
    func toggleLoop() {
        
        if player.state.isPlayingOrPaused {
            
            _ = player.toggleLoop()
            playbackLoopChanged()
            
            Messenger.publish(.player_playbackLoopChanged)
        }
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged() {
        
        if let playingTrack = player.playingTrack {
            
            // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
            if let loop = player.playbackLoop {
                
                btnLoop.switchState(loop.isComplete ? LoopState.complete: LoopState.started)
                
                // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
                
                seekSliderClone.doubleValue = loop.startTime * 100 / playingTrack.duration
                seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
                
                // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
                if let loopEndTime = loop.endTime {
                    
                    seekSliderClone.doubleValue = loopEndTime * 100 / playingTrack.duration
                    seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
                }
                
            } else {
                
                btnLoop.switchState(LoopState.none)
                seekSliderCell.removeLoop()
            }
        }
        
        seekSlider.redraw()
        updateSeekPosition()
    }
    
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        audioGraph.volume = volumeSlider.floatValue
        volumeChanged(audioGraph.volume, audioGraph.muted, false)
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        muteOrUnmute()
    }
    
    private func muteOrUnmute() {
        
        audioGraph.muted.toggle()
        updateVolumeMuteButtonImage(audioGraph.volume, audioGraph.muted)
    }
    
    // updateSlider should be true if the action was not triggered by the slider in the first place.
    private func volumeChanged(_ volume: Float, _ muted: Bool, _ updateSlider: Bool = true, _ showFeedback: Bool = true) {
        
        if updateSlider {
            volumeSlider.floatValue = volume
        }
        
        lblVolume.stringValue = ValueFormatter.formatVolume(volume)
        
        updateVolumeMuteButtonImage(volume, muted)
        
        // Shows and automatically hides the volume label after a preset time interval
        if showFeedback {
            autoHidingVolumeLabel.showView()
        }
    }
    
    private func updateVolumeMuteButtonImage(_ volume: Float, _ muted: Bool) {

        if muted {
            
            btnVolume.baseImage = Images.imgMute
            
        } else {

            // Zero / Low / Medium / High (different images)
            
            switch volume {
                
            case highVolumeRange:
                
                btnVolume.baseImage = Images.imgVolumeHigh
                
            case mediumVolumeRange:
                
                btnVolume.baseImage = Images.imgVolumeMedium
                
            case lowVolumeRange:
                
                btnVolume.baseImage = Images.imgVolumeLow
                
            default:
                
                btnVolume.baseImage = Images.imgVolumeZero
            }
        }
    }
    
    @IBAction func showOrHideSettingsAction(_ sender: NSButton) {
        
        if settingsBox.isHidden {

            settingsBox.show()
            settingsBox.bringToFront()

        } else {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
    }
    
    func menuBarMenuOpened() {
        
        if settingsBox.isShown {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
        
        if player.state == .playing {
            
            updateSeekPosition()
            setSeekTimerState(true)
        }
    }
    
    func menuBarMenuClosed() {
        
        if settingsBox.isShown {
            
            settingsBox.hide()
            infoBox.bringToFront()
        }
        
        // Updating seek position is not necessary when the view has been closed.
        setSeekTimerState(false)
    }
    
    // MARK: Message handling

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        updateTrackInfo()
        stateChanged(player.state)
        
        if let newTrack = notification.endTrack, audioGraph.soundProfiles.hasFor(newTrack) {
            
            // As a result of a sound profile for this track, volume may have changed.
            volumeSlider.floatValue = audioGraph.volume
            volumeChanged(audioGraph.volume, audioGraph.muted, true, true)
        }
    }
    
    // When track info for the playing track changes, display fields need to be updated
    func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        if notification.updatedTrack == player.playingTrack {
            updateTrackInfo()
        }
    }
    
    func chapterChanged(_ notification: ChapterChangedNotification) {
        
        if let playingTrack = player.playingTrack {
            trackInfoView.trackInfo = PlayingTrackInfo(playingTrack, notification.newChapter?.chapter.title)
        }
    }
    
    // TODO: How to display errors in menu bar mode ???
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        updateTrackInfo()
        stateChanged(player.state)
        
        if let invalidTrackError = notification.error as? InvalidTrackError {
            alertDialog.showAlert(.error, "Track not played", invalidTrackError.file.lastPathComponent, notification.error.message)
        } else {
            alertDialog.showAlert(.error, "Track not played", "", notification.error.message)
        }
    }
    
    @IBAction func windowedModeAction(_ sender: AnyObject) {
        AppModeManager.presentMode(.windowed)
    }

    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
}
