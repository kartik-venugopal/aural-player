/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlayerViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
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
    @IBOutlet weak var btnPlayPause: MultiStateImageButton!
    @IBOutlet weak var btnShuffle: MultiStateImageButton!
    @IBOutlet weak var btnRepeat: MultiStateImageButton!
    @IBOutlet weak var btnLoop: MultiStateImageButton!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Player"}
    
    override func viewDidLoad() {
        
        let appState = ObjectGraph.getUIAppState()
        initVolumeAndPan(appState)
        initToggleButtons(appState)
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackNotPlayed, .trackChanged], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.appModeChangedNotification], subscriber: self)
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        SyncMessenger.unsubscribe(messageTypes: [.playbackRequest, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn], subscriber: self)
    }
    
    private func initVolumeAndPan(_ appState: UIAppState) {
        
        volumeSlider.floatValue = appState.volume
        setVolumeImage(appState.muted)
        panSlider.floatValue = appState.balance
        
        autoHidingVolumeLabel = AutoHidingView(lblVolume, UIConstants.feedbackLabelAutoHideIntervalSeconds)
        autoHidingPanLabel = AutoHidingView(lblPan, UIConstants.feedbackLabelAutoHideIntervalSeconds)
    }

    private func initToggleButtons(_ appState: UIAppState) {
        
        // Initialize image/state mappings for toggle buttons
        
        btnPlayPause.stateImageMappings = [(PlaybackState.noTrack, Images.imgPlay), (PlaybackState.paused, Images.imgPlay), (PlaybackState.playing, Images.imgPause)]
        btnPlayPause.switchState(PlaybackState.noTrack)
        
        btnRepeat.stateImageMappings = [(RepeatMode.off, Images.imgRepeatOff), (RepeatMode.one, Images.imgRepeatOne), (RepeatMode.all, Images.imgRepeatAll)]
        
        btnLoop.stateImageMappings = [(LoopState.none, Images.imgLoopOff), (LoopState.started, Images.imgLoopStarted), (LoopState.complete, Images.imgLoopComplete)]
        
        btnShuffle.stateImageMappings = [(ShuffleMode.off, Images.imgShuffleOff), (ShuffleMode.on, Images.imgShuffleOn)]
        
        updateRepeatAndShuffleControls(appState.repeatMode, appState.shuffleMode)
    }
    
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
        
        print("Now " + String(describing: player.getPlaybackState()))
    }
    
    // Replays the currently playing track, from the beginning, if there is one
    private func replayTrack() {
        
        if let _ = player.getPlayingTrack() {
            
            // TODO: Move this to a new delegate function replayTrack()
            player.seekToPercentage(0)
            SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
        }
    }
    
    // Toggles the state of the segment playback loop for the currently playing track
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
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
    
    private func playbackLoopChanged() {
        
        let loop = player.getPlaybackLoop()
        
        // Update loop button image
        let loopState: LoopState = loop == nil ? .none : (loop!.isComplete() ? .complete: .started)
        btnLoop.switchState(loopState)
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
    private func trackChanged(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        btnPlayPause.switchState(player.getPlaybackState())
        SyncMessenger.publishNotification(TrackChangedNotification(oldTrack, newTrack, errorState))
        btnLoop.switchState(LoopState.none)
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
    
    // When the mode has just been changed to "regular", the Player view will need to be refreshed
    private func modeActive() {
        
        initSubscriptions()
        
        btnPlayPause.switchState(player.getPlaybackState())
        
        volumeSlider.floatValue = audioGraph.getVolume()
        setVolumeImage(audioGraph.isMuted())
        
        let rsModes = player.getRepeatAndShuffleModes()
        updateRepeatAndShuffleControls(rsModes.repeatMode, rsModes.shuffleMode)
        
        playbackLoopChanged()
    }
    
    // When the mode has just been changed to "miniBar", subscriptions need to be removed so as to prevent this view from acting on notifications/requests
    private func modeInactive() {
        removeSubscriptions()
    }
    
    func getOperationalAppMode() -> AppMode? {
        return .regular
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackChanged:
            
            trackChanged(message as! TrackChangedAsyncMessage)
            
        case .trackNotPlayed:
            
            trackNotPlayed(message as! TrackNotPlayedAsyncMessage)
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .playbackLoopChangedNotification:
            
            playbackLoopChanged()
            
        case .appModeChangedNotification:
            
            let modeChgMsg = notification as! AppModeChangedNotification
            
            if (modeChgMsg.newMode == .regular) {
                modeActive()
            } else {
                modeInactive()
            }
            
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
            
        case .toggleLoop: toggleLoop()
            
        case .previousTrack: previousTrackAction(self)
            
        case .nextTrack: nextTrackAction(self)
            
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
}
