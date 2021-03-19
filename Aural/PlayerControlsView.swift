import Cocoa

class PlayerControlsView: NSView {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTimeElapsed: VALabel!
    @IBOutlet weak var lblTimeRemaining: VALabel!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    // A clone of the seek slider, used to render the segment playback loop
    @IBOutlet weak var seekSliderClone: NSSlider!
    @IBOutlet weak var seekSliderCloneCell: SeekSliderCell!
    
    // Used to display the bookmark name prompt popover
    @IBOutlet weak var seekPositionMarker: NSView!
    
    // Timer that periodically updates the seek position slider and label
    private var seekTimer: RepeatingTaskExecutor?
    
    // Volume/pan controls
    @IBOutlet weak var btnVolume: NSButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    // These are feedback labels that are shown briefly and automatically hidden
    @IBOutlet weak var lblVolume: VALabel!
    @IBOutlet weak var lblPan: VALabel!
    @IBOutlet weak var lblPanCaption: VALabel!
    
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    private var autoHidingVolumeLabel: AutoHidingView!
    private var autoHidingPanLabel: AutoHidingView!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: ColorSensitiveOnOffImageButton! {
        
        didSet {
            
            btnPlayPause.offStateImageMappings[.darkBackground_lightText] = NSImage(named: "Play")
            btnPlayPause.offStateImageMappings[.lightBackground_darkText] = NSImage(named: "Play_1")
            
            btnPlayPause.onStateImageMappings[.darkBackground_lightText] = NSImage(named: "Pause")
            btnPlayPause.onStateImageMappings[.lightBackground_darkText] = NSImage(named: "Pause_1")
        }
    }
    
    @IBOutlet weak var btnRepeat: ColorSensitiveMultiStateImageButton!
    @IBOutlet weak var btnShuffle: ColorSensitiveMultiStateImageButton!
    @IBOutlet weak var btnLoop: ColorSensitiveMultiStateImageButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: TrackPeekingButton! {
    
        didSet {
            btnPreviousTrack.imageMappings[.darkBackground_lightText] = NSImage(named: "PreviousTrack")
            btnPreviousTrack.imageMappings[.lightBackground_darkText] = NSImage(named: "PreviousTrack_1")
        }
    }
    
    @IBOutlet weak var btnNextTrack: TrackPeekingButton! {
        
        didSet {
            btnNextTrack.imageMappings[.darkBackground_lightText] = NSImage(named: "NextTrack")
            btnNextTrack.imageMappings[.lightBackground_darkText] = NSImage(named: "NextTrack_1")
        }
    }
    
    @IBOutlet weak var btnSeekBackward: ColorSensitiveImageButton! {
        
        didSet {
            btnSeekBackward.imageMappings[.darkBackground_lightText] = NSImage(named: "SeekBackward")
            btnSeekBackward.imageMappings[.lightBackground_darkText] = NSImage(named: "SeekBackward_1")
        }
    }
    
    @IBOutlet weak var btnSeekForward: ColorSensitiveImageButton! {
        
        didSet {
            btnSeekForward.imageMappings[.darkBackground_lightText] = NSImage(named: "SeekForward")
            btnSeekForward.imageMappings[.lightBackground_darkText] = NSImage(named: "SeekForward_1")
        }
    }
    
    var seekPositionFunction: (() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double)) = {() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) in
        return (0, 0, 0)
    }
    
    // TODO: Remove this dependency and instead pass in a closure
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let playbackSequence: PlaybackSequencerInfoDelegateProtocol = ObjectGraph.playbackSequencerInfoDelegate
    
    private let appState: PlayerUIState = ObjectGraph.appState.ui.player
    
    var seekSliderValue: Double {
        return seekSlider.doubleValue
    }
    
    var volumeSliderValue: Float {
        return volumeSlider.floatValue
    }
    
    var panSliderValue: Float {
        return panSlider.floatValue
    }
    
    override func awakeFromNib() {
        oneTimeSetup()
    }

    private func oneTimeSetup() {

        autoHidingVolumeLabel = AutoHidingView(lblVolume, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        autoHidingPanLabel = AutoHidingView(lblPan, UIConstants.feedbackLabelAutoHideIntervalSeconds)

        btnRepeat.stateImageMappings = [(RepeatMode.off, {return Images.imgRepeatOff}), (RepeatMode.one, {return Images.imgRepeatOne}), (RepeatMode.all, {return Images.imgRepeatAll})]
        
        btnShuffle.stateImageMappings = [(ShuffleMode.off, {return Images.imgShuffleOff}), (ShuffleMode.on, {return Images.imgShuffleOn})]

        btnLoop.stateImageMappings = [(LoopState.none, {return Images.imgLoopOff}), (LoopState.started, {return Images.imgLoopStarted}), (LoopState.complete, {return Images.imgLoopComplete})]
        
        // TODO: BUG - When tracks are added/removed from the playlist, tool tip needs to be updated bcoz playback sequence might have changed

        // Button tool tips
        btnPreviousTrack.toolTipFunction = {
            () -> String? in

            if let prevTrack = self.playbackSequence.peekPrevious() {
                return String(format: "Previous track: '%@'", prevTrack.track.conciseDisplayName)
            }

            return nil
        }

        btnNextTrack.toolTipFunction = {
            () -> String? in

            if let nextTrack = self.playbackSequence.peekNext() {
                return String(format: "Next track: '%@'", nextTrack.track.conciseDisplayName)
            }

            return nil
        }

        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})

        // Allow clicks on the seek time display labels to switch to different display formats

        PlayerViewState.timeElapsedDisplayType = appState.timeElapsedDisplayType
        PlayerViewState.timeRemainingDisplayType = appState.timeRemainingDisplayType

        let elapsedTimeGestureRecognizer: NSGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeElapsedDisplayAction))
        lblTimeElapsed.addGestureRecognizer(elapsedTimeGestureRecognizer)

        let remainingTimeGestureRecognizer: NSGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeRemainingDisplayAction))
        lblTimeRemaining.addGestureRecognizer(remainingTimeGestureRecognizer)
        
        changeTextSize(PlayerViewState.textSize)
    }

    func initialize(_ volume: Float, _ muted: Bool, _ pan: Float, _ playbackState: PlaybackState, _ playbackRate: Float, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode, seekPositionFunction: @escaping (() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double))) {

        initVolumeAndPan(volume, muted, pan)
        btnPlayPause.onIf(playbackState == .playing)

        updateRepeatAndShuffleControls(repeatMode, shuffleMode)
        
        // TODO: What if switching to regular mode from bar mode ?
        seekSliderCell.removeLoop()
        btnLoop.switchState(LoopState.none)
        
        self.seekPositionFunction = seekPositionFunction
        
        let seekTimerInterval = Int(1000 / (2 * playbackRate))
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval, task: {
            self.updateSeekPosition()
        }, queue: DispatchQueue.main)
    }

    private func initVolumeAndPan(_ volume: Float, _ muted: Bool, _ pan: Float) {

        volumeSlider.floatValue = volume
        setVolumeImage(volume, muted)
        panSlider.floatValue = pan
    }

    @IBAction func switchTimeElapsedDisplayAction(_ sender: Any) {

        PlayerViewState.timeElapsedDisplayType = PlayerViewState.timeElapsedDisplayType.toggle()
        updateSeekPosition()
    }

    @IBAction func switchTimeRemainingDisplayAction(_ sender: Any) {

        PlayerViewState.timeRemainingDisplayType = PlayerViewState.timeRemainingDisplayType.toggle()
        updateSeekPosition()
    }

    func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {

        PlayerViewState.timeElapsedDisplayType = format
        updateSeekPosition()
    }

    func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {

        PlayerViewState.timeRemainingDisplayType = format
        updateSeekPosition()
    }

    func showNowPlayingInfo(_ track: Track) {

        initSeekPosition()
        seekSlider.enable()
        updateSeekPosition()
        setSeekTimerState(true)
    }

    func clearNowPlayingInfo() {

        lblTimeElapsed.hide()
        lblTimeRemaining.hide()
        seekSlider.floatValue = 0
        seekSlider.disable()
        seekSlider.hide()
        setSeekTimerState(false)
    }

    func initSeekPosition() {

        seekSlider.show()
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf_elseHide(PlayerViewState.showTimeElapsedRemaining)})
    }

    func updateSeekPosition() {

        let seekPosn = seekPositionFunction()
        seekSlider.doubleValue = seekPosn.percentageElapsed

        let trackTimes = StringUtils.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)

        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemaining.stringValue = trackTimes.remaining
    }

    // Resets the seek slider and time elapsed/remaining labels when playback of a track begins
    func resetSeekPosition(_ track: Track) {

        let trackTimes = StringUtils.formatTrackTimes(0, track.duration, 0, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)

        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemaining.stringValue = trackTimes.remaining

        lblTimeElapsed.show()
        lblTimeRemaining.show()

        seekSlider.floatValue = 0
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        timerOn ? seekTimer?.startOrResume() : seekTimer?.pause()
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    func playbackStateChanged(_ newState: PlaybackState) {
        btnPlayPause.onIf(newState == .playing)
        setSeekTimerState(newState == .playing)
    }

    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {

        if let loop = playbackLoop {

            // Update loop button image
            btnLoop.switchState(loop.isComplete() ? LoopState.complete: LoopState.started)

            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if (loop.isComplete()) {

                seekSliderClone.doubleValue = loop.endTime! * 100 / trackDuration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)

            } else {

                seekSliderClone.doubleValue = loop.startTime * 100 / trackDuration
                seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            }

        } else {

            seekSliderCell.removeLoop()
            btnLoop.switchState(LoopState.none)
        }
        
        updateSeekPosition()
    }

    func renderLoop(_ playbackLoop: PlaybackLoop?, _ trackDuration: Double) {

        if let loop = playbackLoop {

            // Update loop button image
            btnLoop.switchState(loop.isComplete() ? LoopState.complete: LoopState.started)

            // Mark start
            seekSliderClone.doubleValue = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)

            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if (loop.isComplete()) {

                seekSliderClone.doubleValue = loop.endTime! * 100 / trackDuration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
            }

        } else {

            seekSliderCell.removeLoop()
            btnLoop.switchState(LoopState.none)
        }
        
        updateSeekPosition()
    }
    
    func volumeChanged(_ volume: Float, _ muted: Bool) {
        
        volumeSlider.floatValue = volume
        setVolumeImage(volume, muted)
        showAndAutoHideVolumeLabel()
    }
    
    func panChanged(_ pan: Float) {
        
        panSlider.floatValue = pan
        showAndAutoHidePanLabel()
    }
    
    func mutedOrUnmuted(_ volume: Float, _ muted: Bool) {
        setVolumeImage(volume, muted)
    }

    // Shows and automatically hides the volume label after a preset time interval
    private func showAndAutoHideVolumeLabel() {

        // Format the text and show the feedback label
        lblVolume.stringValue = ValueFormatter.formatVolume(volumeSlider.floatValue)
        autoHidingVolumeLabel.showView()
    }

    func setVolumeImage(_ volume: Float, _ muted: Bool) {

        if (muted) {
            btnVolume.image = Images.imgMute
        } else {

            // Zero / Low / Medium / High (different images)
            if (volume > 200/3) {
                btnVolume.image = Images.imgVolumeHigh
            } else if (volume > 100/3) {
                btnVolume.image = Images.imgVolumeMedium
            } else if (volume > 0) {
                btnVolume.image = Images.imgVolumeLow
            } else {
                btnVolume.image = Images.imgVolumeZero
            }
        }
    }
    
    // Shows and automatically hides the pan label after a preset time interval
    private func showAndAutoHidePanLabel() {

        // Format the text and show the feedback label
        lblPan.stringValue = ValueFormatter.formatPan(panSlider.floatValue)
        autoHidingPanLabel.showView()
    }

    func updateRepeatAndShuffleControls(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {

        btnShuffle.switchState(shuffleMode)
        btnRepeat.switchState(repeatMode)
    }

    func trackChanged(_ playbackState: PlaybackState, _ loop: PlaybackLoop?, _ newTrack: IndexedTrack?) {
        
        btnPlayPause.onIf(playbackState == .playing)
        btnLoop.switchState(loop != nil ? LoopState.complete : LoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})

        if loop != nil {
            renderLoop(loop, newTrack!.track.duration)
        } else {
            seekSliderCell.removeLoop()
        }

        newTrack != nil ? showNowPlayingInfo(newTrack!.track) : clearNowPlayingInfo()
    }
    
    func gapStarted() {

        btnPlayPause.off()
        btnLoop.switchState(LoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})

        [seekSlider, lblTimeElapsed, lblTimeRemaining].forEach({$0?.hide()})
    }

    func getLocationForBookmarkPrompt() -> (view: NSView, edge: NSRectEdge) {

        // Slider knob position
        let knobRect = seekSliderCell.knobRect(flipped: false)
        seekPositionMarker.setFrameOrigin(NSPoint(x: seekSlider.frame.origin.x + knobRect.minX + 2, y: seekSlider.frame.origin.y + knobRect.minY))

        return (seekPositionMarker, NSRectEdge.maxY)
    }

    func showOrHideTimeElapsedRemaining() {

        PlayerViewState.showTimeElapsedRemaining = !PlayerViewState.showTimeElapsedRemaining
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf_elseHide(PlayerViewState.showTimeElapsedRemaining)})
    }
    
    func sequenceChanged() {
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        
        let interval = Int(1000 / (2 * rate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {
                self.updateSeekPosition()
            }, queue: DispatchQueue.main)
            
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    func changeTextSize(_ textSize: TextSizeScheme) {
        
        lblTimeElapsed.font = TextSizes.trackTimesFont
        lblTimeRemaining.font = TextSizes.trackTimesFont
        
        lblVolume.font = TextSizes.feedbackFont
        lblPan.font = TextSizes.feedbackFont
        lblPanCaption.font = TextSizes.feedbackFont
    }
    
    func changeColorScheme() {
        
        lblTimeElapsed.textColor = Colors.Player.trackTimesColor
        lblTimeRemaining.textColor = Colors.Player.trackTimesColor
        lblPanCaption.textColor = Colors.Player.trackTimesColor
        lblPan.textColor = Colors.Player.trackTimesColor
        lblVolume.textColor = Colors.Player.trackTimesColor
        
        btnPlayPause.colorSchemeChanged()
        [btnPreviousTrack, btnNextTrack].forEach({$0?.colorSchemeChanged()})
        [btnSeekBackward, btnSeekForward].forEach({$0?.colorSchemeChanged()})
        
        [btnRepeat, btnShuffle, btnLoop].forEach({$0?.colorSchemeChanged()})
        
        seekSlider.redraw()
        volumeSlider.redraw()
        panSlider.redraw()
    }
}

enum TimeElapsedDisplayType: String {

    case formatted
    case seconds
    case percentage

    func toggle() -> TimeElapsedDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .formatted

        }
    }
}


enum TimeRemainingDisplayType: String {

    case formatted
    case duration_formatted
    case duration_seconds
    case seconds
    case percentage

    func toggle() -> TimeRemainingDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .duration_formatted

        case .duration_formatted:     return .duration_seconds

        case .duration_seconds:     return .formatted

        }
    }
}
