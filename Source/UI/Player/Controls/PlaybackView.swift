import Cocoa

class PlaybackView: NSView, ColorSchemeable, TextSizeable {
    
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
   
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: OnOffImageButton!
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
    
    override func awakeFromNib() {

        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's off state button color.
        let offStateTintFunction = {return Colors.toggleButtonOffStateColor}
        
        // When the buttons are in an "Off" state, they should be tinted according to the system color scheme's function button color.
        let onStateTintFunction = {return Colors.functionButtonColor}

        btnLoop.stateImageMappings = [(LoopState.none, (Images.imgLoopOff, offStateTintFunction)), (LoopState.started, (Images.imgLoopStarted, onStateTintFunction)), (LoopState.complete, (Images.imgLoopComplete, onStateTintFunction))]

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
        
        lblTimeElapsed.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeElapsedDisplayAction)))

        lblTimeRemaining.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeRemainingDisplayAction)))
    }

    // TODO: Make this initialize method more generic or conform to some protocol for views
    func initialize(_ playbackState: PlaybackState, _ playbackRate: Float, seekPositionFunction: @escaping (() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double))) {

        btnPlayPause.onIf(playbackState == .playing)
        
        seekSliderCell.removeLoop()
        btnLoop.switchState(LoopState.none)
        
        self.seekPositionFunction = seekPositionFunction
        
        let seekTimerInterval = Int(1000 / (2 * playbackRate))
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval, task: {
            self.updateSeekPosition()
        }, queue: DispatchQueue.main)
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
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
    }

    func updateSeekPosition() {

        let seekPosn = seekPositionFunction()
        seekSlider.doubleValue = seekPosn.percentageElapsed

        let trackTimes = ValueFormatter.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)

        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemaining.stringValue = trackTimes.remaining
        
        for task in SeekTimerTaskQueue.tasksArray {
            task()
        }
    }

    // Resets the seek slider and time elapsed/remaining labels when playback of a track begins
    func resetSeekPosition(_ track: Track) {

        let trackTimes = ValueFormatter.formatTrackTimes(0, track.duration, 0, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)

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
            btnLoop.switchState(loop.isComplete ? LoopState.complete: LoopState.started)
            
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

    func trackChanged(_ playbackState: PlaybackState, _ loop: PlaybackLoop?, _ newTrack: Track?) {
        
        btnPlayPause.onIf(playbackState == .playing)
        btnLoop.switchState(loop != nil ? LoopState.complete : LoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})
        
        if let track = newTrack {
            
            playbackLoopChanged(loop, track.duration)
            showNowPlayingInfo(track)
            
        } else {
            
            seekSliderCell.removeLoop()
            clearNowPlayingInfo()
        }
    }
    
    func gapStarted() {

        btnPlayPause.off()
        btnLoop.switchState(LoopState.none)
        [btnPreviousTrack, btnNextTrack].forEach({$0?.updateTooltip()})

        [seekSlider, lblTimeElapsed, lblTimeRemaining].forEach({$0?.hide()})
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
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        // This call will also take care of toggle buttons
        changeFunctionButtonColor()
        
        changeSliderValueTextColor()
        changeSliderColors()
    }
    
    func applyColorSchemeComponent(_ msg: ColorSchemeComponentActionMessage) {
     
        switch msg.actionType {

        case .changeFunctionButtonColor:
            
            changeFunctionButtonColor()
            
        case .changeToggleButtonOffStateColor:
            
            changeToggleButtonOffStateColor()
            
        case .changePlayerSliderColors:
            
            changeSliderColors()
            
        case .changePlayerSliderValueTextColor:
            
            changeSliderValueTextColor()
            
        default:
            
            return
        }
    }
    
    private func changeFunctionButtonColor() {
        
        [btnLoop, btnPlayPause, btnPreviousTrack, btnNextTrack, btnSeekBackward, btnSeekForward].forEach({
            ($0 as? Tintable)?.reTint()
        })
    }
    
    private func changeToggleButtonOffStateColor() {
        
        // Only these buttons have off states that look different from their on states
        btnLoop.reTint()
    }
    
    private func changeSliderValueTextColor() {
        
        lblTimeElapsed.textColor = Colors.Player.trackTimesTextColor
        lblTimeRemaining.textColor = Colors.Player.trackTimesTextColor
    }
    
    private func changeSliderColors() {
        seekSlider.redraw()
    }
    
    // Positions the "seek position marker" view at the center of the seek slider knob.
    func positionSeekPositionMarkerView() {
        
        // Slider knob position
        let knobRect = seekSliderCell.knobRect(flipped: false)
        seekPositionMarker.setFrameOrigin(NSPoint(x: seekSlider.frame.minX + knobRect.centerX, y: seekSlider.frame.minY + knobRect.minY))
    }
}
