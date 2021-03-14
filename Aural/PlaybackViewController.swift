/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber, ConstituentView {
    
    @IBOutlet weak var controlsView: PlayerControlsView!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    // Delegate that retrieves playback sequencing info (previous/next track)
    private let playbackSequence: PlaybackSequencerInfoDelegateProtocol = ObjectGraph.playbackSequencerInfoDelegate
    
    // Delegate that conveys all volume/pan adjustments to the audio graph
    private var audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    private let timeUnit: TimeUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.timeUnit
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    private let soundPreferences: SoundPreferences = ObjectGraph.preferencesDelegate.getPreferences().soundPreferences
    
    private let appState: PlayerUIState = ObjectGraph.appState.ui.player
    
    override var nibName: String? {return "Player"}
    
    override func viewDidLoad() {

        AppModeManager.registerConstituentView(.regular, self)
    }
    
    func activate() {
        
        let playbackRate = timeUnit.isActive ? timeUnit.rate : Float(1.0)
        let rsModes = player.repeatAndShuffleModes
        
        controlsView.initialize(audioGraph.volume, audioGraph.muted, audioGraph.balance, player.state, playbackRate, rsModes.repeatMode, rsModes.shuffleMode, seekPositionFunction: {() -> (timeElapsed: Double, percentageElapsed: Double, trackDuration: Double) in return self.player.seekPosition })
        
        changeColorScheme()
        
//        let newTrack = player.playingTrack
//
//        if (newTrack != nil) {
//
////            showNowPlayingInfo(newTrack!.track)
//
//        } else {
//
//            // No track playing, clear the info fields
////            clearNowPlayingInfo()
//        }
        
        initSubscriptions()
    }
    
    func deactivate() {
        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackNotPlayed, .trackNotTranscoded, .trackChanged, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest, .playbackLoopChangedNotification, .playbackRateChangedNotification, .sequenceChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .stop, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .seekBackward_secondary, .seekForward_secondary, .jumpToTime, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat, .showOrHideTimeElapsedRemaining, .changePlayerTextSize, .changeColorScheme], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.trackNotPlayed, .trackNotTranscoded, .trackChanged, .gapStarted], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.playbackRequest, .playbackLoopChangedNotification, .playbackRateChangedNotification], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.muteOrUnmute, .increaseVolume, .decreaseVolume, .panLeft, .panRight, .playOrPause, .stop, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .seekBackward_secondary, .seekForward_secondary, .jumpToTime, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat, .showOrHideTimeElapsedRemaining, .changePlayerTextSize, .changeColorScheme], subscriber: self)
    }
    
    private func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        controlsView.setTimeElapsedDisplayFormat(format)
    }
    
    private func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
        controlsView.setTimeRemainingDisplayFormat(format)
    }
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(controlsView.seekSliderValue)
        controlsView.updateSeekPosition()
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    private func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        controlsView.playbackRateChanged(notification.newPlaybackRate, player.state)
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    private func playbackStateChanged() {
        controlsView.playbackStateChanged(player.state)
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    private func playbackLoopChanged() {
        controlsView.playbackLoopChanged(player.playbackLoop, player.playingTrack!.track.duration)
    }
    
    // MARK - Volume and Pan
    
    // Updates the volume
    @IBAction func volumeAction(_ sender: AnyObject) {
        
        audioGraph.volume = controlsView.volumeSliderValue
        controlsView.volumeChanged(audioGraph.volume, audioGraph.muted)
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        
        audioGraph.muted = !audioGraph.muted
        controlsView.mutedOrUnmuted(audioGraph.volume, audioGraph.muted)
    }
    
    // Decreases the volume by a certain preset decrement
    private func decreaseVolume(_ actionMode: ActionMode) {
        
        let newVolume = audioGraph.decreaseVolume(actionMode)
        controlsView.volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Increases the volume by a certain preset increment
    private func increaseVolume(_ actionMode: ActionMode) {
        
        let newVolume = audioGraph.increaseVolume(actionMode)
        controlsView.volumeChanged(newVolume, audioGraph.muted)
    }
    
    // Updates the stereo pan
    @IBAction func panAction(_ sender: AnyObject) {
        
        audioGraph.balance = controlsView.panSliderValue
        controlsView.panChanged(audioGraph.balance)
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    private func panLeft() {
        controlsView.panChanged(audioGraph.panLeft())
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    private func panRight() {
        controlsView.panChanged(audioGraph.panRight())
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
        
        if let _ = player.playingTrack {
            
            let wasPaused: Bool = player.state == .paused
            
            player.replay()
            controlsView.updateSeekPosition()
            
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
        
        if player.state.playingOrPaused() {
        
            if let _ = player.playingTrack {
                
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
        controlsView.updateSeekPosition()
    }
    
    private func seekBackward(_ actionMode: ActionMode) {
        
        player.seekBackward(actionMode)
        controlsView.updateSeekPosition()
    }
    
    private func seekForward_secondary() {
        
        player.seekForwardSecondary()
        controlsView.updateSeekPosition()
    }
    
    private func seekBackward_secondary() {
        
        player.seekBackwardSecondary()
        controlsView.updateSeekPosition()
    }
    
    private func jumpToTime(_ time: Double) {
        
        player.seekToTime(time)
        controlsView.updateSeekPosition()
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
        controlsView.updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Toggles the shuffle mode
    @IBAction func shuffleAction(_ sender: AnyObject) {
        
        let modes = player.toggleShuffleMode()
        controlsView.updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the repeat mode to "Off"
    private func repeatOff() {
        
        let modes = player.setRepeatMode(.off)
        controlsView.updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the repeat mode to "Repeat One"
    private func repeatOne() {
        
        let modes = player.setRepeatMode(.one)
        controlsView.updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the repeat mode to "Repeat All"
    private func repeatAll() {
        
        let modes = player.setRepeatMode(.all)
        controlsView.updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the shuffle mode to "Off"
    private func shuffleOff() {
        
        let modes = player.setShuffleMode(.off)
        controlsView.updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // Sets the shuffle mode to "On"
    private func shuffleOn() {
        
        let modes = player.setShuffleMode(.on)
        controlsView.updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ oldTrack: IndexedTrack?, _ oldState: PlaybackState, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        controlsView.trackChanged(player.state, player.playbackLoop, newTrack)
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if soundPreferences.rememberEffectsSettings, newTrack != nil, soundProfiles.hasFor(newTrack!.track) {

            controlsView.volumeChanged(audioGraph.volume, audioGraph.muted)
            controlsView.panChanged(audioGraph.balance)
        }
    }
    
    private func trackChanged(_ message: TrackChangedAsyncMessage) {
        trackChanged(message.oldTrack, message.oldState, message.newTrack)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        handleTrackNotPlayedError(message.oldTrack, message.error)
    }
    
    private func handleTrackNotPlayedError(_ oldTrack: IndexedTrack?, _ error: InvalidTrackError) {
        
        self.trackChanged(oldTrack, .playing, nil, true)
        
//        DispatchQueue.main.async {
//            // Position and display an alert with error info
//            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(error))
//        }
        
        alertDialog.showAlert(.error, "Track not played", error.track.conciseDisplayName, error.message)
    }
    
    private func performPlayback(_ request: PlaybackRequest) {
        
        switch request.type {
            
        case .index: playTrackWithIndex(request.index!, request.delay)
            
        case .track: playTrack(request.track!, request.delay)
            
        case .group: playGroup(request.group!, request.delay)
            
        }
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        controlsView.gapStarted()
    }
    
    func getLocationForBookmarkPrompt() -> (view: NSView, edge: NSRectEdge) {
        return controlsView.getLocationForBookmarkPrompt()
    }
    
    private func showOrHideTimeElapsedRemaining() {
        controlsView.showOrHideTimeElapsedRemaining()
    }
    
    private func sequenceChanged() {
        controlsView.sequenceChanged()
    }
    
    private func trackNotTranscoded(_ msg: TrackNotTranscodedAsyncMessage) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
//        DispatchQueue.main.async {
//
//            // Position and display an alert with error info
//            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotTranscodedAlertWithError(msg.error, "OK"))
//        }
        
        alertDialog.showAlert(.error, "Track not transcoded", msg.track.conciseDisplayName, msg.error.message)
    }
    
    func changeTextSize(_ textSize: TextSizeScheme) {
        controlsView.changeTextSize(textSize)
    }
    
    func changeColorScheme() {
        controlsView.changeColorScheme()
        controlsView.setVolumeImage(audioGraph.volume, audioGraph.muted)
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
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
            
        case .trackNotTranscoded:
            
            trackNotTranscoded(message as! TrackNotTranscodedAsyncMessage)
            
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
            
        case .sequenceChangedNotification:
            
            sequenceChanged()
            
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
            
        case .changePlayerTextSize:
            
            changeTextSize((message as! TextSizeActionMessage).textSize)
            
        case .changeColorScheme:

            changeColorScheme()
            
        default: return
            
        }
    }
}
