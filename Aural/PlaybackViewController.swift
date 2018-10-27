/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber, ConstituentView {
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: NewSeekSliderCell!
    
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
    @IBOutlet weak var lblVolume: NSTextField!
    @IBOutlet weak var lblPan: NSTextField!
    
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
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let playbackSequence: PlaybackSequencerInfoDelegateProtocol = ObjectGraph.getPlaybackSequencerInfoDelegate()
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    private let soundPreferences: SoundPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().soundPreferences
    
    private let appState: PlayerState = ObjectGraph.getAppState().uiState.playerState
    
    private var seekSliderFrame: NSRect?
    
    override var nibName: String? {return "Player"}
    
    override func viewDidLoad() {

        oneTimeSetup()
        AppModeManager.registerConstituentView(.regular, self)
    }
    
    private func oneTimeSetup() {
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        autoHidingPanLabel = AutoHidingView(lblPan, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, Images.imgRepeatOff), (RepeatMode.one, Images.imgRepeatOne), (RepeatMode.all, Images.imgRepeatAll)]
        
        btnLoop.stateImageMappings = [(LoopState.none, Images.imgLoopOff), (LoopState.started, Images.imgLoopStarted), (LoopState.complete, Images.imgLoopComplete)]
        
        btnShuffle.stateImageMappings = [(ShuffleMode.off, Images.imgShuffleOff), (ShuffleMode.on, Images.imgShuffleOn)]
        
        // Button tool tips
        btnPreviousTrack.toolTipFunction = {
            () -> String in
            
            if let prevTrack = self.playbackSequence.peekPrevious() {
                return String(format: "Previous track: '%@'", prevTrack.track.conciseDisplayName)
            }
            
            return "Previous track"
        }
        
        btnNextTrack.toolTipFunction = {
            () -> String in
            
            if let nextTrack = self.playbackSequence.peekNext() {
                return String(format: "Next track: '%@'", nextTrack.track.conciseDisplayName)
            }
            
            return "Next track"
        }
        
        let timeBypassed = audioGraph.getTimeState() != .active
        let seekTimerInterval = timeBypassed ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * audioGraph.getTimeRate().rate))
        
        // Timer interval depends on whether time stretch unit is active
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval, task: {
            
            if (self.player.getPlaybackState() == .playing) {
                self.updateSeekPosition()
            }
            
        }, queue: DispatchQueue.main)
        
        // Allow clicks on the seek time display labels to switch to different display formats
        
        PlayerViewState.timeElapsedDisplayType = appState.timeElapsedDisplayType
        PlayerViewState.timeRemainingDisplayType = appState.timeRemainingDisplayType
        
        let elapsedTimeGestureRecognizer: NSGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeElapsedDisplayAction))
        lblTimeElapsed.addGestureRecognizer(elapsedTimeGestureRecognizer)
        
        let remainingTimeGestureRecognizer: NSGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.switchTimeRemainingDisplayAction))
        lblTimeRemaining.addGestureRecognizer(remainingTimeGestureRecognizer)
    }
    
    func activate() {
        
        let newTrack = player.getPlayingTrack()
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
        
        initVolumeAndPan()
        btnPlayPause.onIf(player.getPlaybackState() == .playing)
        
        let rsModes = player.getRepeatAndShuffleModes()
        updateRepeatAndShuffleControls(rsModes.repeatMode, rsModes.shuffleMode)
        
        playbackLoopChanged()
        
        initSubscriptions()
    }
    
    func deactivate() {

        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackNotPlayed, .trackChanged, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest, .playbackLoopChangedNotification, .playbackRateChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .stop, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .seekBackward_secondary, .seekForward_secondary, .jumpToTime, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat, .showOrHideTimeElapsedRemaining], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.trackNotPlayed, .trackChanged, .gapStarted], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.playbackRequest, .playbackLoopChangedNotification, .playbackRateChangedNotification], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .stop, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .seekBackward_secondary, .seekForward_secondary, .jumpToTime, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat, .showOrHideTimeElapsedRemaining], subscriber: self)
    }
    
    private func initVolumeAndPan() {
        
        volumeSlider.floatValue = audioGraph.getVolume()
        setVolumeImage(audioGraph.isMuted())
        panSlider.floatValue = audioGraph.getBalance()
    }
    
    @IBAction func switchTimeElapsedDisplayAction(_ sender: Any) {
        
        PlayerViewState.timeElapsedDisplayType = PlayerViewState.timeElapsedDisplayType.toggle()
        updateSeekPosition()
    }
    
    @IBAction func switchTimeRemainingDisplayAction(_ sender: Any) {
        
        PlayerViewState.timeRemainingDisplayType = PlayerViewState.timeRemainingDisplayType.toggle()
        updateSeekPosition()
    }
    
    private func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        
        PlayerViewState.timeElapsedDisplayType = format
        updateSeekPosition()
    }
    
    private func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
        
        PlayerViewState.timeRemainingDisplayType = format
        updateSeekPosition()
    }
    
    private func showNowPlayingInfo(_ track: Track) {
        
        setSeekTimerState(true)
        initSeekPosition()
        seekSlider.enable()
        renderLoop()
    }
    
    private func clearNowPlayingInfo() {
        
        lblTimeElapsed.hide()
        lblTimeRemaining.hide()
        setSeekTimerState(false)
        seekSlider.floatValue = 0
        seekSlider.disable()
        seekSlider.hide()
    }
    
    private func initSeekPosition() {
        
        seekSlider.show()
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
        updateSeekPosition()
        
        if PlayerViewState.showTimeElapsedRemaining {
            
            let seekPosn = player.getSeekPosition()
            let trackTimes = StringUtils.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, PlayerViewState.timeElapsedDisplayType, TimeRemainingDisplayType.seconds)
            
            print(trackTimes.remaining)
            
            let timeRemString: NSString = trackTimes.remaining as NSString
            let stringSize: CGSize = timeRemString.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): lblTimeRemaining.font as AnyObject]))
            let lblWidth = lblTimeRemaining.frame.width
            let textWidth = min(stringSize.width, lblWidth)
            
            seekSlider.frame.origin.x = lblTimeElapsed.frame.minX + textWidth + 10
            var sf = seekSlider.frame
            sf.size = NSMakeSize(lblTimeRemaining.frame.maxX - textWidth - 10 - seekSlider.frame.origin.x, sf.height)
            
            seekSlider.setFrameSize(sf.size)
            
            seekSliderFrame = seekSlider.frame
            
        } else {
            
            seekSlider.frame.origin.x = 12
            seekSlider.frame.size = NSMakeSize(476, seekSlider.frame.height)
            seekSliderFrame = nil
        }
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        timerOn ? seekTimer?.startOrResume() : seekTimer?.pause()
    }
    
    private func updateSeekPosition() {
        
        let seekPosn = player.getSeekPosition()
        
        let trackTimes = StringUtils.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration, seekPosn.percentageElapsed, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)
        
        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemaining.stringValue = trackTimes.remaining
        
//        seekSliderCell.timeElapsed = trackTimes.elapsed
//        seekSliderCell.timeRemaining = trackTimes.remaining
        
        seekSlider.doubleValue = seekPosn.percentageElapsed
    }
    
    // Resets the seek slider and time elapsed/remaining labels when playback of a track begins
    private func resetSeekPosition(_ track: Track) {
        
        let trackTimes = StringUtils.formatTrackTimes(0, track.duration, 0, PlayerViewState.timeElapsedDisplayType, PlayerViewState.timeRemainingDisplayType)
        
        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemaining.stringValue = trackTimes.remaining
        
        lblTimeElapsed.show()
        lblTimeRemaining.show()
        
        seekSlider.floatValue = 0
    }

    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
        updateSeekPosition()
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    private func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        
        let interval = Int(1000 / (2 * notification.newPlaybackRate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {
                
                if (self.player.getPlaybackState() == .playing) {
                    self.updateSeekPosition()
                }
            }, queue: DispatchQueue.main)
            
            let playbackState = player.getPlaybackState()
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    private func playbackStateChanged() {
        
        let playbackState = player.getPlaybackState()
        let isPlaying: Bool = playbackState == .playing
        
        btnPlayPause.onIf(isPlaying)
        // The seek timer can be disabled when not needed (e.g. when paused)
        setSeekTimerState(isPlaying)
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    private func playbackLoopChanged() {
        
        if let loop = player.getPlaybackLoop() {
            
            // Update loop button image
            btnLoop.switchState(loop.isComplete() ? LoopState.complete: LoopState.started)
            
            let duration = (player.getPlayingTrack()?.track.duration)!
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if (loop.isComplete()) {
                
                seekSliderClone.doubleValue = loop.endTime! * 100 / duration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
                
            } else {
                
                seekSliderClone.doubleValue = loop.startTime * 100 / duration
                seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            }
            
        } else {
            
            seekSliderCell.removeLoop()
            btnLoop.switchState(LoopState.none)
        }
        
        // Force a redraw of the seek slider
        updateSeekPosition()
        seekSlider.setNeedsDisplay()
    }
    
    private func renderLoop() {
        
        if let loop = player.getPlaybackLoop() {
            
            // Update loop button image
            btnLoop.switchState(loop.isComplete() ? LoopState.complete: LoopState.started)
            
            let duration = (player.getPlayingTrack()?.track.duration)!
            
            // Mark start
            seekSliderClone.doubleValue = loop.startTime * 100 / duration
            seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if (loop.isComplete()) {
                
                seekSliderClone.doubleValue = loop.endTime! * 100 / duration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
            }
            
        } else {
            
            seekSliderCell.removeLoop()
            btnLoop.switchState(LoopState.none)
        }
        
        // Force a redraw of the seek slider
        updateSeekPosition()
        seekSlider.setNeedsDisplay()
    }
    
    // MARK - Volume and Pan
    
    // Updates the volume
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        audioGraph.setVolume(volumeSlider.floatValue)
        setVolumeImage(audioGraph.isMuted())
        showAndAutoHideVolumeLabel()
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        setVolumeImage(audioGraph.toggleMute())
    }
    
    // Decreases the volume by a certain preset decrement
    private func decreaseVolume(_ actionMode: ActionMode) {
        volumeSlider.floatValue = audioGraph.decreaseVolume(actionMode)
        setVolumeImage(audioGraph.isMuted())
        showAndAutoHideVolumeLabel()
    }
    
    // Increases the volume by a certain preset increment
    private func increaseVolume(_ actionMode: ActionMode) {
        volumeSlider.floatValue = audioGraph.increaseVolume(actionMode)
        setVolumeImage(audioGraph.isMuted())
        showAndAutoHideVolumeLabel()
    }
    
    // Shows and automatically hides the volume label after a preset time interval
    private func showAndAutoHideVolumeLabel() {
        
        // Format the text and show the feedback label
        lblVolume.stringValue = ValueFormatter.formatVolume(volumeSlider.floatValue)
        autoHidingVolumeLabel.showView()
    }
    
    private func setVolumeImage(_ muted: Bool) {
        
        if (muted) {
            btnVolume.image = Images.imgMute
        } else {
            
            let volume = audioGraph.getVolume()
            
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
    
    // Updates the stereo pan
    @IBAction func panAction(_ sender: AnyObject) {
        audioGraph.setBalance(panSlider.floatValue)
        showAndAutoHidePanLabel()
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    private func panLeft() {
        panSlider.floatValue = audioGraph.panLeft()
        showAndAutoHidePanLabel()
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    private func panRight() {
        panSlider.floatValue = audioGraph.panRight()
        showAndAutoHidePanLabel()
    }
    
    // Shows and automatically hides the pan label after a preset time interval
    private func showAndAutoHidePanLabel() {
        
        // Format the text and show the feedback label
        lblPan.stringValue = ValueFormatter.formatPan(panSlider.floatValue)
        autoHidingPanLabel.showView()
    }
    
    // MARK: Playback
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        player.togglePlayPause()
        playbackStateChanged()
    }
    
    private func stop() {
        player.stop()
    }
    
    // Replays the currently playing track, from the beginning, if there is one
    private func replayTrack() {
        
        if let _ = player.getPlayingTrack() {
            
            let wasPaused: Bool = player.getPlaybackState() == .paused
            
            player.replay()
            updateSeekPosition()
            
            if (wasPaused) {
                playbackStateChanged()
            }
        }
    }
    
    // Toggles the state of the segment playback loop for the currently playing track
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
        toggleLoop()
    }
    
    private func toggleLoop() {
        
        let playbackState = player.getPlaybackState()
        
        if playbackState == .playing || playbackState == .paused {
        
            if let _ = player.getPlayingTrack() {
                
                _ = player.toggleLoop()
                playbackLoopChanged()
            }
        }
    }
    
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        player.previousTrack()
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        player.nextTrack()
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        seekBackward(.discrete)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        seekForward(.discrete)
    }
    
    private func seekForward(_ actionMode: ActionMode) {
        
        player.seekForward(actionMode)
        updateSeekPosition()
    }
    
    private func seekBackward(_ actionMode: ActionMode) {
        
        player.seekBackward(actionMode)
        updateSeekPosition()
    }
    
    private func seekForward_secondary() {
        
        player.seekForwardSecondary()
        updateSeekPosition()
    }
    
    private func seekBackward_secondary() {
        
        player.seekBackwardSecondary()
        updateSeekPosition()
    }
    
    private func jumpToTime(_ time: Double) {
        
        player.seekToTime(time)
        updateSeekPosition()
    }
    
    private func playTrackWithIndex(_ trackIndex: Int, _ delay: Double?) {
        
        let params = PlaybackParams.defaultParams().withDelay(delay)
        player.play(trackIndex, params)
    }

    private func playTrack(_ track: Track, _ delay: Double?) {

        let params = PlaybackParams.defaultParams().withDelay(delay)
        player.play(track, params)
    }
    
    private func playGroup(_ group: Group, _ delay: Double?) {
        
        let params = PlaybackParams.defaultParams().withDelay(delay)
        player.play(group, params)
    }

    // Toggles the repeat mode
    @IBAction func repeatAction(_ sender: AnyObject) {
        
        let modes = player.toggleRepeatMode()
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        
        let modes = player.toggleShuffleMode()
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the repeat mode to "Off"
    private func repeatOff() {
        
        let modes = player.setRepeatMode(.off)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the repeat mode to "Repeat One"
    private func repeatOne() {
        
        let modes = player.setRepeatMode(.one)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the repeat mode to "Repeat All"
    private func repeatAll() {
        
        let modes = player.setRepeatMode(.all)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the shuffle mode to "Off"
    private func shuffleOff() {
        
        let modes = player.setShuffleMode(.off)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the shuffle mode to "On"
    private func shuffleOn() {
        
        let modes = player.setShuffleMode(.on)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    private func updateRepeatAndShuffleControls(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        btnShuffle.switchState(shuffleMode)
        btnRepeat.switchState(repeatMode)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ oldTrack: IndexedTrack?, _ oldState: PlaybackState, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        btnPlayPause.onIf(player.getPlaybackState() == .playing)
        btnLoop.switchState(player.getPlaybackLoop() != nil ? LoopState.complete : LoopState.none)
        
        if (player.getPlaybackLoop()) != nil {
            renderLoop()
        } else {
            seekSliderCell.removeLoop()
        }
        
        newTrack != nil ? showNowPlayingInfo(newTrack!.track) : clearNowPlayingInfo()
        
        if soundPreferences.rememberEffectsSettings {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            if let _oldTrack = oldTrack, oldState != .waiting {
                
                // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the track is done playing
                if soundPreferences.rememberEffectsSettingsOption == .allTracks || SoundProfiles.profileForTrack(_oldTrack.track) != nil {
                    
                    SoundProfiles.saveProfile(_oldTrack.track, audioGraph.getVolume(), audioGraph.getBalance(), audioGraph.getSettingsAsMasterPreset())
                }
            }
            
            // Apply sound profile if there is one for the new track and the preferences allow it
            if newTrack != nil, let profile = SoundProfiles.profileForTrack(newTrack!.track) {
                
                audioGraph.setVolume(profile.volume)
                audioGraph.setBalance(profile.balance)
                initVolumeAndPan()
            }
        }
    }
    
    private func trackChanged(_ message: TrackChangedAsyncMessage) {
        trackChanged(message.oldTrack, message.oldState, message.newTrack)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        handleTrackNotPlayedError(message.oldTrack, message.error)
    }
    
    private func performPlayback(_ request: PlaybackRequest) {
        
        switch request.type {
            
        case .index: playTrackWithIndex(request.index!, request.delay)
            
        case .track: playTrack(request.track!, request.delay)
            
        case .group: playGroup(request.group!, request.delay)
            
        }
    }
    
    private func handleTrackNotPlayedError(_ oldTrack: IndexedTrack?, _ error: InvalidTrackError) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        DispatchQueue.main.async {
            
            let errorTrack = error.track
            self.trackChanged(oldTrack, .playing, nil, true)
            
            // Position and display an alert with error info
            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(error))
            
            // Remove the bad track from the playlist and update the UI
            _ = SyncMessenger.publishRequest(RemoveTrackRequest(errorTrack))
        }
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        btnPlayPause.off()
        btnLoop.switchState(LoopState.none)
        
        [seekSlider, lblTimeElapsed, lblTimeRemaining].forEach({$0?.hide()})
        
        if soundPreferences.rememberEffectsSettings {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            if let oldTrack = msg.lastPlayedTrack {
                
                // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the track is done playing
                if soundPreferences.rememberEffectsSettingsOption == .allTracks || SoundProfiles.profileForTrack(oldTrack.track) != nil {
                    
                    SoundProfiles.saveProfile(oldTrack.track, audioGraph.getVolume(), audioGraph.getBalance(), audioGraph.getSettingsAsMasterPreset())
                }
            }
        }
    }
    
    func getLocationForBookmarkPrompt() -> (view: NSView, edge: NSRectEdge) {
        
        // Slider knob position
        let knobRect = seekSliderCell.knobRect(flipped: false)
        seekPositionMarker.setFrameOrigin(NSPoint(x: seekSlider.frame.origin.x + knobRect.minX + 2, y: seekSlider.frame.origin.y + knobRect.minY))
        
        return (seekPositionMarker, NSRectEdge.maxY)
    }
    
    private func showOrHideTimeElapsedRemaining() {
        
        PlayerViewState.showTimeElapsedRemaining = !PlayerViewState.showTimeElapsedRemaining
        [lblTimeElapsed, lblTimeRemaining].forEach({$0?.showIf(PlayerViewState.showTimeElapsedRemaining)})
        
        if PlayerViewState.showTimeElapsedRemaining {
            
            if let duration = player.getPlayingTrack()?.track.duration {
                
                if let frame = seekSliderFrame {
                    
                    seekSlider.frame = frame
                    
                } else {
                    
                    let trackTimes = StringUtils.formatTrackTimes(0, duration, 0, PlayerViewState.timeElapsedDisplayType, TimeRemainingDisplayType.seconds)
                    
                    let timeRemString: NSString = trackTimes.remaining as NSString
                    let stringSize: CGSize = timeRemString.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): lblTimeRemaining.font as AnyObject]))
                    let lblWidth = lblTimeRemaining.frame.width
                    let textWidth = min(stringSize.width, lblWidth)
                    
                    seekSlider.frame.origin.x = lblTimeElapsed.frame.minX + textWidth + 10
                    var sf = seekSlider.frame
                    sf.size = NSMakeSize(lblTimeRemaining.frame.maxX - textWidth - 10 - seekSlider.frame.origin.x, sf.height)
                    
                    seekSlider.setFrameSize(sf.size)
                    
                    seekSliderFrame = seekSlider.frame
                }
            }
            
        } else {
            
            seekSlider.frame.origin.x = 12
            seekSlider.frame.size = NSMakeSize(476, seekSlider.frame.height)
        }
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackChanged:
            
            let msg = message as! TrackChangedAsyncMessage
            trackChanged(msg)
            SyncMessenger.publishNotification(TrackChangedNotification(msg.oldTrack, msg.newTrack, false))
            
        case .trackNotPlayed:
            
            trackNotPlayed(message as! TrackNotPlayedAsyncMessage)
            
        case .gapStarted:
            
            gapStarted(message as! PlaybackGapStartedAsyncMessage)
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .playbackRateChangedNotification:
            
            playbackRateChanged(notification as! PlaybackRateChangedNotification)
            
        case .playbackLoopChangedNotification:
            
            playbackLoopChanged()
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .playbackRequest:
            
            performPlayback(request as! PlaybackRequest)
            
        default: break
            
        }
        
        // This class does not return any meaningful responses
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        // Player functions
            
        case .playOrPause: playPauseAction(self)
            
        case .stop: stop()
            
        case .replayTrack: replayTrack()
            
        case .toggleLoop: toggleLoop()
            
        case .previousTrack: previousTrackAction(self)
            
        case .nextTrack: nextTrackAction(self)
            
        case .seekBackward:
            
            let msg = message as! PlaybackActionMessage
            seekBackward(msg.actionMode)
            
        case .seekForward:
            
            let msg = message as! PlaybackActionMessage
            seekForward(msg.actionMode)
            
        case .seekBackward_secondary:
            
            seekBackward_secondary()
            
        case .seekForward_secondary:
            
            seekForward_secondary()
            
        case .jumpToTime:
            
            jumpToTime((message as! JumpToTimeActionMessage).time)
            
        // Repeat and Shuffle
            
        case .repeatOff: repeatOff()
            
        case .repeatOne: repeatOne()
            
        case .repeatAll: repeatAll()
            
        case .shuffleOff: shuffleOff()
            
        case .shuffleOn: shuffleOn()
            
        // Volume and Pan
            
        case .muteOrUnmute: muteOrUnmuteAction(self)
            
        case .decreaseVolume:
            
            let msg = message as! AudioGraphActionMessage
            decreaseVolume(msg.actionMode)
            
        case .increaseVolume:
            
            let msg = message as! AudioGraphActionMessage
            increaseVolume(msg.actionMode)
            
        case .panLeft: panLeft()
            
        case .panRight: panRight()
            
        case .setTimeElapsedDisplayFormat:
            
            setTimeElapsedDisplayFormat((message as! SetTimeElapsedDisplayFormatActionMessage).format)
            
        case .setTimeRemainingDisplayFormat:
            
            setTimeRemainingDisplayFormat((message as! SetTimeRemainingDisplayFormatActionMessage).format)
            
        case .showOrHideTimeElapsedRemaining:
            
            showOrHideTimeElapsedRemaining()
            
        default: return
            
        }
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
