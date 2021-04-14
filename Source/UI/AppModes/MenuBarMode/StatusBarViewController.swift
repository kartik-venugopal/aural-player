/*
 View controller for the popover that displays a brief information message when a track is added to or removed from the Favorites list
 */
import Cocoa

// TODO: Can this be a general info popup ? "Tracks are being added ... (progress)" ?
class StatusBarViewController: NSViewController, NSMenuDelegate, NotificationSubscriber {

    @IBOutlet weak var trackInfoView: PlayingTrackTextView!
    @IBOutlet weak var imgArt: NSImageView!
    
    @IBOutlet weak var btnPlayPause: OnOffImageButton!
    
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
    
    var statusItem: NSStatusItem!

    override var nibName: String? {return "StatusBar"}

    private var globalMouseClickMonitor: GlobalMouseClickMonitor!

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
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]

        btnLoop.stateImageMappings = [(LoopState.none, (Images.imgLoopOff, offStateTintFunction)), (LoopState.started, (Images.imgLoopStarted, onStateTintFunction)), (LoopState.complete, (Images.imgLoopComplete, onStateTintFunction))]
        
        updateRepeatAndShuffleControls(sequencer.repeatAndShuffleModes)
        [btnRepeat, btnShuffle, btnLoop].forEach {
            $0?.reTint()
        }

        // Play/pause button does not really have an "off" state
        btnPlayPause.offStateTintFunction = onStateTintFunction
        
        // Button tool tips
        btnPreviousTrack.toolTipFunction = {
            () -> String? in

            if let prevTrack = self.sequencer.peekPrevious() {
                return String(format: "Previous track: '%@'", prevTrack.displayName)
            }

            return nil
        }

        btnNextTrack.toolTipFunction = {
            () -> String? in

            if let nextTrack = self.sequencer.peekNext() {
                return String(format: "Next track: '%@'", nextTrack.displayName)
            }

            return nil
        }

        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
    }
    
    override func viewDidLoad() {
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        
        volumeSlider.floatValue = audioGraph.volume
        volumeChanged(audioGraph.volume, audioGraph.muted, true, false)
        
        seekTimer = RepeatingTaskExecutor(intervalMillis: 500, task: {
            self.updateSeekPosition()
        }, queue: .main)
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        playOrPause()
    }
    
    func playOrPause() {
        
        player.togglePlayPause()
        btnPlayPause.onIf(player.state == .playing)
        updateTrackInfo()
    }
    
    private func updateTrackInfo() {

        if let theTrack = player.playingTrack {
            
            trackInfoView.trackInfo = PlayingTrackInfo(theTrack, player.playingChapter?.chapter.title)
            
            seekSlider.enable()
            seekSlider.show()
            
            [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
            setSeekTimerState(true)
            
        } else {
            trackInfoView.trackInfo = nil
        }
        
        imgArt.image = player.playingTrack?.art?.image
        [btnPreviousTrack, btnNextTrack].forEach {$0?.updateTooltip()}
    }
   
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        previousTrack()
    }
    
    func previousTrack() {
        
        player.previousTrack()
        updateTrackInfo()
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        nextTrack()
    }

    func nextTrack() {
        
        player.nextTrack()
        updateTrackInfo()
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
        
        let trackTimes = ValueFormatter.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)
        
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
    
//    // Replays the currently playing track, from the beginning, if there is one
//    func replayTrack() {
//
//        let wasPaused: Bool = player.state == .paused
//
//        player.replay()
//        playbackView.updateSeekPosition()
//
//        if wasPaused {
//            playbackView.playbackStateChanged(player.state)
//        }
//    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
//    private func trackChanged(_ newTrack: Track?) {
//
//        playbackView.trackChanged(player.state, player.playbackLoop, newTrack)
//
////        if let track = newTrack, track.hasChapters {
////            beginPollingForChapterChange()
////        } else {
////            stopPollingForChapterChange()
////        }
//    }
    
//    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
//
//        self.trackChanged(nil)
//
//        let error = notification.error
//        alertDialog.showAlert(.error, "Track not played", error.track?.displayName ?? "<Unknown>", error.message)
//    }
//
    func dismiss() {

//        close()
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    @IBAction func regularModeAction(_ sender: AnyObject) {

        globalMouseClickMonitor.stop()

//        SyncMessenger.publishActionMessage(AppModeActionMessage(.regularAppMode))
    }

    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }

    func popoverDidShow(_ notification: Notification) {

        NSApp.activate(ignoringOtherApps: true)
        globalMouseClickMonitor.start()
    }

    func popoverDidClose(_ notification: Notification) {
        globalMouseClickMonitor.stop()
    }

    var subscriberId: String {
        return self.className
    }
}

fileprivate class GlobalMouseClickMonitor {

    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    public init(_ mask: NSEvent.EventTypeMask, _ handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {

        if (monitor == nil) {
            monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
        }
    }

    public func stop() {

        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}

//
//        globalMouseClickMonitor = GlobalMouseClickMonitor([.leftMouseDown, .rightMouseDown], {(event: NSEvent!) -> Void in
//
//            // If window is non-nil, it means it's the popover window (first time after launching)
//            if event.window == nil {
//                self.close()
//            }
//        })
//
////        SyncMessenger.subscribe(messageTypes: [.appResignedActiveNotification], subscriber: self)
//
//        NSApp.unhide(self)
//    }
