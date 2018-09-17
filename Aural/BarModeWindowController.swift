import Cocoa

class BarModeWindowController: NSWindowController, MessageSubscriber, AsyncMessageSubscriber, ActionMessageSubscriber {
    
    // Fields that display playing track info
    @IBOutlet weak var lblTrackName: BannerLabel!
    @IBOutlet weak var artView: NSImageView!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: BarModeSeekSliderCell!
    
    // Used to render playback loops
    @IBOutlet weak var seekSliderClone: NSSlider!
    @IBOutlet weak var seekSliderCloneCell: BarModeSeekSliderCell!
    
    // Timer that periodically updates the seek position slider and label
    private var seekTimer: RepeatingTaskExecutor?
    
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var btnVolume: NSButton!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnPlayPause: MultiStateImageButton!
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
    
    override var windowNibName: String? {return "BarMode"}
    
    private var theWindow: NSWindow {
        return self.window!
    }
    
    override func windowDidLoad() {
        
        theWindow.isMovableByWindowBackground = true
        
        // Use persistent app state to determine the initial state of the view
        initControls(ObjectGraph.getUIAppState())
        
        let appState = ObjectGraph.getUIAppState()
        initVolumeAndPan(appState)
        initToggleButtons(appState)
        
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
        
        SyncMessenger.subscribe(messageTypes: [.appModeChangedNotification], subscriber: self)
        initSubscriptions()
        
        theWindow.level = Int(CGWindowLevelForKey(.floatingWindow))
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        AsyncMessenger.subscribe([.tracksRemoved, .addedToFavorites, .removedFromFavorites, .trackNotPlayed, .trackChanged], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest, .trackChangedNotification, .playbackRateChangedNotification, .playbackStateChangedNotification, .playbackLoopChangedNotification, .seekPositionChangedNotification, .playingTrackInfoUpdatedNotification, .appInBackgroundNotification, .appInForegroundNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .replayTrack, .previousTrack, .nextTrack, .toggleLoop, .seekBackward, .seekForward, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.tracksRemoved, .addedToFavorites, .removedFromFavorites, .trackNotPlayed, .trackChanged], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.playbackRequest, .trackChangedNotification, .playbackRateChangedNotification, .playbackStateChangedNotification, .seekPositionChangedNotification, .playingTrackInfoUpdatedNotification, .appInBackgroundNotification, .appInForegroundNotification, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .replayTrack, .previousTrack, .nextTrack, .toggleLoop, .seekBackward, .seekForward, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn], subscriber: self)
    }
    
    private func initControls(_ appState: UIAppState) {
        
        // Timer interval depends on whether time stretch unit is active
        seekTimer = RepeatingTaskExecutor(intervalMillis: appState.seekTimerInterval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
        
        // Set up the art view and the default animation
        artView.canDrawSubviewsIntoLayer = true
        artView.image = Images.imgPlayingArt
        
        lblTrackName.font = Fonts.barModePlayingTrackTextFont
        lblTrackName.alignment = NSTextAlignment.center
    }
    
    private func initVolumeAndPan(_ appState: UIAppState) {
        
        volumeSlider.floatValue = appState.volume
        setVolumeImage(appState.muted)
    }
    
    private func initToggleButtons(_ appState: UIAppState) {
        
        // Initialize image/state mappings for toggle buttons
        
        btnPlayPause.stateImageMappings = [(PlaybackState.noTrack, Images.imgPlay), (PlaybackState.paused, Images.imgPlay), (PlaybackState.playing, Images.imgPause)]
        btnPlayPause.switchState(PlaybackState.noTrack)
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, Images.imgRepeatOff), (RepeatMode.one, Images.imgRepeatOne), (RepeatMode.all, Images.imgRepeatAll)]
        
        btnShuffle.stateImageMappings = [(ShuffleMode.off, Images.imgShuffleOff), (ShuffleMode.on, Images.imgShuffleOn)]
        
        btnLoop.stateImageMappings = [(LoopState.none, Images.imgLoopOff), (LoopState.started, Images.imgLoopStarted), (LoopState.complete, Images.imgLoopComplete)]
        
        updateRepeatAndShuffleControls(appState.repeatMode, appState.shuffleMode)
    }
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
    }
    
    private func showNowPlayingInfo(_ track: Track) {
        
        lblTrackName.text = track.conciseDisplayName
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork animation
            artView.image = Images.imgPlayingArt
            artView.animates = true
        }
        
        initSeekPosition()
        setSeekTimerState(true)
    }
    
    private func clearNowPlayingInfo() {
        
        lblTrackName.text = ""
        artView.image = Images.imgPlayingArt
        artView.animates = false
        
        seekSlider.floatValue = 0
        setSeekTimerState(false)
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        
        if (timerOn) {
            
            if (!seekSlider.isEnabled) {
                seekSlider.isEnabled = true
                seekTimer?.startOrResume()
            }
            
        } else {
            
            if (seekSlider.isEnabled) {
                seekTimer?.pause()
                seekSlider.isEnabled = false
            }
        }
    }
    
    // Updates the seek slider and time elapsed/remaining labels as playback proceeds
    private func updateSeekPosition() {
        
        if (player.getPlaybackState() == .playing) {
            seekSlider.doubleValue = player.getSeekPosition().percentageElapsed
        }
    }
    
    // Regardless of playback state
    private func initSeekPosition() {
        seekSlider.doubleValue = player.getSeekPosition().percentageElapsed
    }
    
    // Resets the seek slider and time elapsed/remaining labels when playback of a track begins
    private func resetSeekPosition() {
        seekSlider.floatValue = 0
    }
    
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        // Check if the playing track was removed. If so, need to update display fields, because playback will have stopped.
        if (message.playingTrackRemoved) {
            trackChanged(nil)
        }
    }
    
    private func trackChanged(_ notification: TrackChangedNotification) {
        trackChanged(notification.newTrack, notification.errorState)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
            if (!errorState) {
                setSeekTimerState(true)
                
            } else {
                
                // Error state
                setSeekTimerState(false)
            }
            
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    private func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        
        let interval = Int(1000 / (2 * notification.newPlaybackRate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
            
            let playbackState = player.getPlaybackState()
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    private func playbackStateChanged(_ notification: PlaybackStateChangedNotification) {
        
        let isPlaying: Bool = (notification.newPlaybackState == .playing)
        
        // The seek timer can be disabled when not needed (e.g. when paused)
        setSeekTimerState(isPlaying)
        
        // Pause/resume the art animation
        artView.animates = shouldAnimate()
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        showNowPlayingInfo(player.getPlayingTrack()!.track)
    }
    
    private func appInBackground() {
        artView.animates = false
    }
    
    private func appInForeground() {
        artView.animates = shouldAnimate()
    }
    
    // Helper function that determines whether or not the playing track animation should be shown animated
    private func shouldAnimate() -> Bool {
        
        // Animation enabled only if 1 - the appropriate playlist view is currently shown, 2 - a track is currently playing (not paused), and 3 - the app window is currently in the foreground
        return (player.getPlaybackState() == .playing) && WindowState.isInForeground()
    }
    
    // Updates the volume
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        audioGraph.setVolume(volumeSlider.floatValue)
        setVolumeImage(audioGraph.isMuted())
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        setVolumeImage(audioGraph.toggleMute())
    }
    
    // Decreases the volume by a certain preset decrement
    private func decreaseVolume(_ actionMode: ActionMode) {
        volumeSlider.floatValue = audioGraph.decreaseVolume(actionMode)
        setVolumeImage(audioGraph.isMuted())
    }
    
    // Increases the volume by a certain preset increment
    private func increaseVolume(_ actionMode: ActionMode) {
        volumeSlider.floatValue = audioGraph.increaseVolume(actionMode)
        setVolumeImage(audioGraph.isMuted())
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
    
    // Pans the sound towards the left channel, by a certain preset value
    private func panLeft() {
        _ = audioGraph.panLeft()
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    private func panRight() {
        _ = audioGraph.panRight()
    }
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let playbackInfo = try player.togglePlayPause()
            let playbackState = playbackInfo.playbackState
            btnPlayPause.switchState(playbackState)
            
            switch playbackState {
                
            case .noTrack, .paused:
                
                SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                
            case .playing:
                
                if (playbackInfo.trackChanged) {
                    trackChanged(oldTrack, playbackInfo.playingTrack)
                } else {
                    // Resumed the same track
                    SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                }
            }
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    // Replays the currently playing track, from the beginning, if there is one
    private func replayTrack() {
        
        if let _ = player.getPlayingTrack() {
            player.seekToPercentage(0)
            SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
        }
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let prevTrack = try player.previousTrack()
            if (prevTrack?.track != nil) {
                trackChanged(oldTrack, prevTrack)
            }
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            let nextTrack = try player.nextTrack()
            if (nextTrack?.track != nil) {
                trackChanged(oldTrack, nextTrack)
            }
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
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
        SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
    }
    
    private func seekBackward(_ actionMode: ActionMode) {
        
        player.seekBackward(actionMode)
        SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
    }
    
    private func playTrackWithIndex(_ trackIndex: Int) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let track = try player.play(trackIndex)
            trackChanged(oldTrack, track)
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    private func playTrack(_ track: Track) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let playingTrack = try player.play(track)
            trackChanged(oldTrack, playingTrack)
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    private func playGroup(_ group: Group) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let track = try player.play(group)
            trackChanged(oldTrack, track)
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
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
    
    @IBAction func loopAction(_ sender: Any) {
        toggleLoop()
    }
    
    private func toggleLoop() {
        
        if player.getPlaybackState() == .playing {
            
            if let _ = player.getPlayingTrack() {
                
                _ = player.toggleLoop()
                SyncMessenger.publishNotification(PlaybackLoopChangedNotification.instance)
            }
        }
    }
    
    private func renderLoop() {
        
        if let loop = player.getPlaybackLoop() {
            
            // Update loop button image
            let loopState: LoopState = loop.isComplete() ? .complete: .started
            btnLoop.switchState(loopState)
            
            let duration = (player.getPlayingTrack()?.track.duration)!
            
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
    }
    
    private func playbackLoopChanged() {
        
        if let loop = player.getPlaybackLoop() {
            
            // Update loop button image
            let loopState: LoopState = loop.isComplete() ? .complete: .started
            btnLoop.switchState(loopState)
            
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
    
    // Quits the app
    @IBAction func quitAction(_ sender: AnyObject) {
        NSApp.terminate(self)
    }
    
    @IBAction func regularModeAction(_ sender: AnyObject) {
        
        removeSubscriptions()
        SyncMessenger.publishActionMessage(AppModeActionMessage(.regularAppMode))
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        btnPlayPause.switchState(player.getPlaybackState())
        SyncMessenger.publishNotification(TrackChangedNotification(oldTrack, newTrack, errorState))
    }
    
    private func trackChanged(_ message: TrackChangedAsyncMessage) {
        trackChanged(message.oldTrack, message.newTrack)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        handleTrackNotPlayedError(message.oldTrack, message.error)
    }
    
    private func performPlayback(_ request: PlaybackRequest) {
        
        switch request.type {
            
        case .index: playTrackWithIndex(request.index!)
            
        case .track: playTrack(request.track!)
            
        case .group: playGroup(request.group!)
            
        }
    }
    
    private func handleTrackNotPlayedError(_ oldTrack: IndexedTrack?, _ error: InvalidTrackError) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        DispatchQueue.main.async {
            
            let errorTrack = error.track
            self.trackChanged(oldTrack, nil, true)
            
            // Position and display an alert with error info
            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(error))
            
            // Remove the bad track from the playlist and update the UI
            _ = SyncMessenger.publishRequest(RemoveTrackRequest(errorTrack))
        }
    }
    
    private func modeActive() {
        
        initSubscriptions()
        
        volumeSlider.floatValue = audioGraph.getVolume()
        setVolumeImage(audioGraph.isMuted())
     
        let rsModes = player.getRepeatAndShuffleModes()
        updateRepeatAndShuffleControls(rsModes.repeatMode, rsModes.shuffleMode)
        
        btnPlayPause.switchState(player.getPlaybackState())
        
        if let plTrack = player.getPlayingTrack() {
            showNowPlayingInfo(plTrack.track)
            renderLoop()
        } else {
            clearNowPlayingInfo()
        }
        
        lblTrackName.beginAnimation()
    }
    
    private func modeInactive() {
        lblTrackName.endAnimation()
        removeSubscriptions()
    }
    
    // MARK: Message handlers
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        case .playbackRateChangedNotification:
            
            playbackRateChanged(notification as! PlaybackRateChangedNotification)
            
        case .playbackStateChangedNotification:
            
            playbackStateChanged(notification as! PlaybackStateChangedNotification)
            
        case .playbackLoopChangedNotification:
            
            playbackLoopChanged()
            
        case .seekPositionChangedNotification:
            
            updateSeekPosition()
            
        case .playingTrackInfoUpdatedNotification:
            
            playingTrackInfoUpdated(notification as! PlayingTrackInfoUpdatedNotification)
            
        case .appInBackgroundNotification:
            
            appInBackground()
            
        case .appInForegroundNotification:
            
            appInForeground()
            
        case .appModeChangedNotification:
            
            let ntf = notification as! AppModeChangedNotification
            if (ntf.newMode == .miniBar) {
                modeActive()
            } else {
                modeInactive()
            }
            
        default: return
            
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        case .trackChanged:
            
            trackChanged(message as! TrackChangedAsyncMessage)
            
        case .trackNotPlayed:
            
            trackNotPlayed(message as! TrackNotPlayedAsyncMessage)
            
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
            
        case .replayTrack: replayTrack()
            
        case .previousTrack: previousTrackAction(self)
            
        case .nextTrack: nextTrackAction(self)
            
        case .toggleLoop:   toggleLoop()
            
        case .seekBackward:
            
            let msg = message as! PlaybackActionMessage
            seekBackward(msg.actionMode)
            
        case .seekForward:
            
            let msg = message as! PlaybackActionMessage
            seekForward(msg.actionMode)
            
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
            
        default: return
            
        }
    }
    
    func getID() -> String {
        return self.className
    }
}
