import Cocoa

class PlayerControlsView: NSView, ColorSchemeable, TextSizeable {
    
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
    @IBOutlet weak var btnVolume: TintedImageButton!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var panSlider: NSSlider!
    
    // These are feedback labels that are shown briefly and automatically hidden
    @IBOutlet weak var lblVolume: VALabel!
    @IBOutlet weak var lblPan: VALabel!
    @IBOutlet weak var lblPanCaption: VALabel!
    @IBOutlet weak var lblPanCaption2: VALabel!
    
    // TODO - Revisit AutoHidingView
    // Wrappers around the feedback labels that automatically hide them after showing them for a brief interval
    private var autoHidingVolumeLabel: AutoHidingView!
    private var autoHidingPanLabel: AutoHidingView!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: OnOffImageButton!
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    @IBOutlet weak var btnLoop: MultiStateImageButton!
    
    // Buttons whose tool tips may change
    @IBOutlet weak var btnPreviousTrack: TrackPeekingButton!
    @IBOutlet weak var btnNextTrack: TrackPeekingButton!
    
    @IBOutlet weak var btnSeekBackward: NSButton!
    @IBOutlet weak var btnSeekForward: NSButton!
    
    var seekPositionFunction: (() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double)) = {() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) in
        return (0, 0, 0)
    }
    
    // TODO: Remove this dependency and instead pass in a closure
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let playbackSequence: PlaybackSequencerInfoDelegateProtocol = ObjectGraph.playbackSequencerInfoDelegate
    
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
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}

        btnRepeat.stateImageMappings = [(RepeatMode.off, (Images.imgRepeatOff, offStateTintFunction)), (RepeatMode.one, (Images.imgRepeatOne, onStateTintFunction)), (RepeatMode.all, (Images.imgRepeatAll, onStateTintFunction))]

        btnLoop.stateImageMappings = [(LoopState.none, (Images.imgLoopOff, offStateTintFunction)), (LoopState.started, (Images.imgLoopStarted, onStateTintFunction)), (LoopState.complete, (Images.imgLoopComplete, onStateTintFunction))]

        btnShuffle.stateImageMappings = [(ShuffleMode.off, (Images.imgShuffleOff, offStateTintFunction)), (ShuffleMode.on, (Images.imgShuffleOn, onStateTintFunction))]
        
        // Play/pause button does not really have an "off" state
        btnPlayPause.offStateTintFunction = onStateTintFunction
        
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

        let elapsedTimeGestureRecognizer: NSGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeElapsedDisplayAction))
        lblTimeElapsed.addGestureRecognizer(elapsedTimeGestureRecognizer)

        let remainingTimeGestureRecognizer: NSGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeRemainingDisplayAction))
        lblTimeRemaining.addGestureRecognizer(remainingTimeGestureRecognizer)
        
//        changeTextSize()
    }

    func initialize(_ volume: Float, _ muted: Bool, _ pan: Float, _ playbackState: PlaybackState, _ playbackRate: Float, _ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode, seekPositionFunction: @escaping (() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double))) {

        initVolumeAndPan(volume, muted, pan)
        btnPlayPause.onIf(playbackState == .playing)

        updateRepeatAndShuffleControls(repeatMode, shuffleMode)
        
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
        updateSeekPosition()
    }

    @IBAction func switchTimeRemainingDisplayAction(_ sender: Any) {
        updateSeekPosition()
    }

    func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        updateSeekPosition()
    }

    func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
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
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
    }

    func updateSeekPosition() {

        let seekPosn = seekPositionFunction()
        seekSlider.doubleValue = seekPosn.percentageElapsed

        let trackTimes = StringUtils.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)

        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemaining.stringValue = trackTimes.remaining
        
        for task in SeekTimerTaskQueue.tasksArray {
            task()
        }
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
            
            // If loop start has not yet been marked, mark it (e.g. when marking chapter loops)
            
            seekSliderClone.doubleValue = loop.startTime * 100 / trackDuration
            seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)

            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if let loopEndTime = loop.endTime {
                
                seekSliderClone.doubleValue = loopEndTime * 100 / trackDuration
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

    private func setVolumeImage(_ volume: Float, _ muted: Bool) {

        if muted {
            btnVolume.baseImage = Images.imgMute
        } else {

            // Zero / Low / Medium / High (different images)
            if (volume > 200/3) {
                btnVolume.baseImage = Images.imgVolumeHigh
            } else if (volume > 100/3) {
                btnVolume.baseImage = Images.imgVolumeMedium
            } else if (volume > 0) {
                btnVolume.baseImage = Images.imgVolumeLow
            } else {
                btnVolume.baseImage = Images.imgVolumeZero
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

        loop != nil ? playbackLoopChanged(loop, newTrack!.track.duration) : seekSliderCell.removeLoop()
        newTrack != nil ? showNowPlayingInfo(newTrack!.track) : clearNowPlayingInfo()
    }
    
    func gapStarted() {

        btnPlayPause.off()
        btnLoop.switchState(LoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})

        [seekSlider, lblTimeElapsed, lblTimeRemaining].forEach({$0?.hide()})
    }

    var locationForBookmarkPrompt: (view: NSView, edge: NSRectEdge) {

        // Slider knob position
        let knobRect = seekSliderCell.knobRect(flipped: false)
        seekPositionMarker.setFrameOrigin(NSPoint(x: seekSlider.frame.origin.x + knobRect.minX + 2, y: seekSlider.frame.origin.y + knobRect.minY))

        return (seekPositionMarker, NSRectEdge.maxY)
    }

    func showOrHideTimeElapsedRemaining() {
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
    }
    
    func sequenceChanged() {
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ rate: Float, _ playbackState: PlaybackState) {
        
        let interval = Int(1000 / (2 * rate))
        
        if interval != seekTimer?.interval {
            
            seekTimer?.stop()
            
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {
                self.updateSeekPosition()
            }, queue: DispatchQueue.main)
            
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    func changeTextSize(_ size: TextSize) {
        
        lblTimeElapsed.font = Fonts.Player.trackTimesFont
        lblTimeRemaining.font = Fonts.Player.trackTimesFont
        
        lblVolume.font = Fonts.Player.feedbackFont
        lblPan.font = Fonts.Player.feedbackFont
        
        lblPanCaption.font = Fonts.Player.feedbackFont
        lblPanCaption2.font = Fonts.Player.feedbackFont
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        // This call will also take care of toggle buttons
        changeFunctionButtonColor(scheme.general.functionButtonColor)
        
        changeSliderValueTextColor()
        changeSliderColors()
    }
    
    func changeFunctionButtonColor(_ color: NSColor) {
        
        [btnRepeat, btnShuffle, btnLoop, btnPlayPause, btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward, btnVolume].forEach({
            ($0 as? Tintable)?.reTint()
        })
        
        lblPanCaption.textColor = color
        lblPanCaption2.textColor = color
    }
    
    func changeToggleButtonOffStateColor(_ color: NSColor) {
        
        // Only these buttons have off states that look different from their on states
        [btnRepeat, btnShuffle, btnLoop].forEach({
            $0.reTint()
        })
    }
    
    func changeSliderValueTextColor() {
        
        lblTimeElapsed.textColor = Colors.Player.trackTimesTextColor
        lblTimeRemaining.textColor = Colors.Player.trackTimesTextColor
        
        lblVolume.textColor = Colors.Player.feedbackTextColor
        lblPan.textColor = Colors.Player.feedbackTextColor
    }
    
    func changeSliderColors() {
        [seekSlider, volumeSlider, panSlider].forEach({$0?.redraw()})
    }
    
    // Positions the "seek position marker" view at the center of the seek slider knob.
    func positionSeekPositionMarkerView() {
        
        // Slider knob position
        let knobRect = seekSliderCell.knobRect(flipped: false)
        seekPositionMarker.setFrameOrigin(NSPoint(x: seekSlider.frame.minX + knobRect.centerX, y: seekSlider.frame.minY + knobRect.minY))
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
