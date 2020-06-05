/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var playbackView: PlaybackView!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    private let soundPreferences: SoundPreferences = ObjectGraph.preferencesDelegate.preferences.soundPreferences
    
    override var nibName: String? {return "PlayerControls"}
    
    override func viewDidLoad() {

        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackNotPlayed, .trackNotTranscoded, .trackChanged, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest, .chapterPlaybackRequest, .seekPositionChangedNotification, .playbackLoopChangedNotification, .playbackRateChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.playOrPause, .stop, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .seekBackward_secondary, .seekForward_secondary, .jumpToTime, .changePlayerTextSize, .applyColorScheme, .changeFunctionButtonColor, .changeToggleButtonOffStateColor, .changePlayerSliderColors, .changePlayerSliderValueTextColor, .showOrHideTimeElapsedRemaining, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat], subscriber: self)
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        player.togglePlayPause()
        playbackView.playbackStateChanged(player.state)
    }

    private func performPlayback(_ request: PlaybackRequest) {
        
        switch request.type {
            
        case .index:
            
            if let index = request.index {
                playTrackWithIndex(index, request.delay)
            }
            
        case .track:
            
            if let track = request.track {
                playTrack(track, request.delay)
            }
            
        case .group:
            
            if let group = request.group {
                playGroup(group, request.delay)
            }
        }
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
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        player.previousTrack()
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        player.nextTrack()
    }
    
    private func stop() {
        player.stop()
    }
    
    // Replays the currently playing track, from the beginning, if there is one
    private func replayTrack() {
        
        if player.state.isPlayingOrPaused {
            
            let wasPaused: Bool = player.state == .paused
            
            player.replay()
            playbackView.updateSeekPosition()
            
            if wasPaused {
                playbackView.playbackStateChanged(player.state)
            }
        }
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: Track?) {
        
        playbackView.trackChanged(player.state, player.playbackLoop, newTrack)
        
        if let track = newTrack, track.hasChapters {
            beginPollingForChapterChange()
        } else {
            stopPollingForChapterChange()
        }
    }
    
    private func trackChanged(_ message: TrackChangedAsyncMessage) {
        trackChanged(message.newTrack)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        handleTrackNotPlayedError(message.oldTrack, message.error)
    }
    
    private func handleTrackNotPlayedError(_ oldTrack: Track?, _ error: InvalidTrackError) {
        
        self.trackChanged(nil)
        
        //        DispatchQueue.main.async {
        //            // Position and display an alert with error info
        //            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(error))
        //        }
        
        alertDialog.showAlert(.error, "Track not played", error.track?.conciseDisplayName ?? "<Unknown>", error.message)
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
            playbackView.gapStarted()
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
    
    // MARK: Chapter playback functions ------------------------------------------------------------
    
    private func performChapterPlayback(_ request: ChapterPlaybackRequest) {
        
        switch request.type {
            
        case .playSelectedChapter:
            
            if let index = request.index {
                playChapter(index)
            }
            
        case .previousChapter:  previousChapter()
            
        case .nextChapter:  nextChapter()
            
        case .replayChapter:    replayChapter()
            
        case .addChapterLoop:   addChapterLoop()
            
        case .removeChapterLoop:    removeChapterLoop()
            
        }
    }
    
    private func playChapter(_ index: Int) {
        
        player.playChapter(index)
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        playbackView.playbackStateChanged(player.state)
    }
    
    private func previousChapter() {
        
        player.previousChapter()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        playbackView.playbackStateChanged(player.state)
    }
    
    private func nextChapter() {
        
        player.nextChapter()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        playbackView.playbackStateChanged(player.state)
    }
    
    private func replayChapter() {
        
        player.replayChapter()
        playbackView.updateSeekPosition()
        playbackView.playbackStateChanged(player.state)
    }
    
    private func addChapterLoop() {
        
        player.loopChapter()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
    }
    
    private func removeChapterLoop() {
        
        _ = player.toggleLoop()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
    }
    
    // MARK: Current chapter tracking ---------------------------------------------------------------------
    
    // Keeps track of the last known value of the current chapter (used to detect chapter changes)
    private var curChapter: IndexedChapter? = nil
    
    // Creates a recurring task that polls the player to detect a change in the currently playing track chapter.
    // This only occurs when the currently playing track actually has chapters.
    private func beginPollingForChapterChange() {
        
        SeekTimerTaskQueue.enqueueTask("ChapterChangePollingTask", {() -> Void in
            
            let playingChapter: IndexedChapter? = self.player.playingChapter
    
            // Compare the current chapter with the last known value of current chapter
            if self.curChapter != playingChapter {
                
                // There has been a change ... notify observers and update the variable
                SyncMessenger.publishNotification(ChapterChangedNotification(self.curChapter, playingChapter))
                self.curChapter = playingChapter
            }
        })
    }
    
    // Disables the chapter change polling task
    private func stopPollingForChapterChange() {
        SeekTimerTaskQueue.dequeueTask("ChapterChangePollingTask")
    }
    
    // MARK: Seeking actions/functions ------------------------------------------------------------
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        
        player.seekToPercentage(playbackView.seekSliderValue)
        playbackView.updateSeekPosition()
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
        playbackView.updateSeekPosition()
    }
    
    private func seekBackward(_ actionMode: ActionMode) {
        
        player.seekBackward(actionMode)
        playbackView.updateSeekPosition()
    }
    
    private func seekForward_secondary() {
        
        player.seekForwardSecondary()
        playbackView.updateSeekPosition()
    }
    
    private func seekBackward_secondary() {
        
        player.seekBackwardSecondary()
        playbackView.updateSeekPosition()
    }
    
    private func jumpToTime(_ time: Double) {
        
        player.seekToTime(time)
        playbackView.updateSeekPosition()
    }
    
    // Returns a view that marks the current position of the seek slider knob.
    var seekPositionMarkerView: NSView {
        
        playbackView.positionSeekPositionMarkerView()
        return playbackView.seekPositionMarker
    }
    
    // MARK: Segment looping actions/functions ------------------------------------------------------------
    
    // Toggles the state of the segment playback loop for the currently playing track
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
        toggleLoop()
    }
    
    private func toggleLoop() {
        
        if player.state.isPlayingOrPaused {
                
            _ = player.toggleLoop()
            playbackLoopChanged()
            SyncMessenger.publishNotification(PlaybackLoopChangedNotification.instance)
        }
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    private func playbackLoopChanged() {
        
        if let playingTrack = player.playingTrack {
            playbackView.playbackLoopChanged(player.playbackLoop, playingTrack.duration)
        }
    }
    
    // MARK: Message handling ---------------------------------------------------------------------

    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackChanged:
            
            if let msg = message as? TrackChangedAsyncMessage {
                
                trackChanged(msg)
                SyncMessenger.publishNotification(TrackChangedNotification(msg.oldTrack, msg.newTrack, false))
            }
            
        case .trackNotPlayed:
            
            if let trackNotPlayedMsg = message as? TrackNotPlayedAsyncMessage {
                trackNotPlayed(trackNotPlayedMsg)
            }
            
        case .trackNotTranscoded:
            
            if let trackNotTranscodedMsg = message as? TrackNotTranscodedAsyncMessage {
                trackNotTranscoded(trackNotTranscodedMsg)
            }
            
        case .gapStarted:
            
            if let gapStartedMsg = message as? PlaybackGapStartedAsyncMessage {
                gapStarted(gapStartedMsg)
            }
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .seekPositionChangedNotification:
            
            playbackView.updateSeekPosition()
            
        case .playbackRateChangedNotification:
            
            // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
            if let playbackRateChangedMsg = notification as? PlaybackRateChangedNotification {
                playbackView.playbackRateChanged(playbackRateChangedMsg.newPlaybackRate, player.state)
            }
            
        case .playbackLoopChangedNotification:
            
            playbackLoopChanged()
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .playbackRequest:
            
            if let playbackRequest = request as? PlaybackRequest {
                performPlayback(playbackRequest)
            }
            
        case .chapterPlaybackRequest:
            
            if let playbackRequest = request as? ChapterPlaybackRequest {
                performChapterPlayback(playbackRequest)
            }
            
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
            
            if let playbackActionMessage = message as? PlaybackActionMessage {
                seekBackward(playbackActionMessage.actionMode)
            }
            
        case .seekForward:
            
            if let playbackActionMessage = message as? PlaybackActionMessage {
                seekForward(playbackActionMessage.actionMode)
            }
            
        case .seekBackward_secondary:
            
            seekBackward_secondary()
            
        case .seekForward_secondary:
            
            seekForward_secondary()
            
        case .jumpToTime:
            
            if let jumpToTimeActionMessage = message as? JumpToTimeActionMessage {
                jumpToTime(jumpToTimeActionMessage.time)
            }
            
        // MARK: Player view settings
            
        case .showOrHideTimeElapsedRemaining:
            
            playbackView.showOrHideTimeElapsedRemaining()
            
        case .setTimeElapsedDisplayFormat:
            
            if let format = (message as? SetTimeElapsedDisplayFormatActionMessage)?.format {
                playbackView.setTimeElapsedDisplayFormat(format)
            }
            
        case .setTimeRemainingDisplayFormat:
            
            if let format = (message as? SetTimeRemainingDisplayFormatActionMessage)?.format {
                playbackView.setTimeRemainingDisplayFormat(format)
            }
            
        // MARK: Appearance
            
        case .changePlayerTextSize:
            
            if let textSizeMsg = message as? TextSizeActionMessage {
                playbackView.changeTextSize(textSizeMsg.textSize)
            }
            
        case .applyColorScheme:
            
            if let colorSchemeActionMsg = message as? ColorSchemeActionMessage {
                playbackView.applyColorScheme(colorSchemeActionMsg.scheme)
            }
            
        default:
            
            if let colorComponentActionMsg = message as? ColorSchemeComponentActionMessage {
                
                playbackView.applyColorSchemeComponent(colorComponentActionMsg)
                return
            }
        }
    }
}
