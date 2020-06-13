/*
    View controller for all playback-related controls (play/pause, prev/next track, seeking, segment looping).
    Also handles playback requests from app menus.
 */
import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var playbackView: PlaybackView!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    override var nibName: String? {return "PlayerControls"}
    
    override func viewDidLoad() {
        
        Messenger.subscribe(self, .trackNotPlayed, self.trackNotPlayed(_:))
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackNotTranscoded], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        Messenger.subscribe(self, .playbackRateChanged, self.playbackRateChanged(_:))
        Messenger.subscribe(self, .playTrack, self.performTrackPlayback(_:))
        Messenger.subscribe(self, .chapterPlayback, self.performChapterPlayback(_:))
        
        SyncMessenger.subscribe(messageTypes: [.trackTransitionNotification, .playbackLoopChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.playOrPause, .stop, .replayTrack, .toggleLoop, .previousTrack, .nextTrack, .seekBackward, .seekForward, .seekBackward_secondary, .seekForward_secondary, .jumpToTime, .changePlayerTextSize, .applyColorScheme, .changeFunctionButtonColor, .changeToggleButtonOffStateColor, .changePlayerSliderColors, .changePlayerSliderValueTextColor, .showOrHideTimeElapsedRemaining, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat], subscriber: self)
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        player.togglePlayPause()
        playbackView.playbackStateChanged(player.state)
    }
    
    func performTrackPlayback(_ command: TrackPlaybackCommandNotification) {
        
        switch command.type {
            
        case .index:
            
            if let index = command.index {
                playTrackWithIndex(index, command.delay)
            }
            
        case .track:
            
            if let track = command.track {
                playTrack(track, command.delay)
            }
            
        case .group:
            
            if let group = command.group {
                playGroup(group, command.delay)
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
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        self.trackChanged(nil)
        
        //        DispatchQueue.main.async {
        //            // Position and display an alert with error info
        //            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(error))
        //        }
        
        let error = notification.error
        alertDialog.showAlert(.error, "Track not played", error.track?.conciseDisplayName ?? "<Unknown>", error.message)
    }
    
    private func gapOrTranscodingStarted() {
        playbackView.gapOrTranscodingStarted()
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
    
    // MARK: Chapter playback functions ------------------------------------------------------------
    
    func performChapterPlayback(_ command: ChapterPlaybackCommandNotification) {
        
        switch command.commandType {
            
        case .playSelectedChapter:
            
            if let index = command.chapterIndex {
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
                Messenger.publish(ChapterChangedNotification(oldChapter: self.curChapter, newChapter: playingChapter))
                self.curChapter = playingChapter
            }
        })
    }
    
    // Disables the chapter change polling task
    private func stopPollingForChapterChange() {
        SeekTimerTaskQueue.dequeueTask("ChapterChangePollingTask")
    }
    
    // MARK: Message handling ---------------------------------------------------------------------
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackNotTranscoded:
            
            if let trackNotTranscodedMsg = message as? TrackNotTranscodedAsyncMessage {
                trackNotTranscoded(trackNotTranscodedMsg)
            }
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackTransitionNotification:
            
            if let trackTransitionMsg = notification as? TrackTransitionNotification {
                
                if trackTransitionMsg.gapStarted || trackTransitionMsg.transcodingStarted {
                    gapOrTranscodingStarted()
                    
                } else {
                    trackChanged(trackTransitionMsg.endTrack)
                }
            }
            
        case .playbackLoopChangedNotification:
            
            playbackLoopChanged()
            
        default: return
            
        }
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        playbackView.playbackRateChanged(notification.newPlaybackRate, player.state)
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        // MARK: Player functions
            
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
