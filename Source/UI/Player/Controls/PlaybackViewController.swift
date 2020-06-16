/*
    View controller for all playback-related controls (play/pause, prev/next track, seeking, segment looping).
    Also handles playback requests from app menus.
 */
import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playbackView: PlaybackView!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    private lazy var alertDialog: AlertWindowController = WindowFactory.alertWindowController
    
    override var nibName: String? {return "PlayerControls"}
    
    override func viewDidLoad() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        Messenger.subscribeAsync(self, .trackTransition, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribe(self, .trackNotPlayed, self.trackNotPlayed(_:))
        Messenger.subscribeAsync(self, .trackNotTranscoded, self.trackNotTranscoded(_:), queue: .main)
        
        Messenger.subscribe(self, .playbackRateChanged, self.playbackRateChanged(_:))
        Messenger.subscribe(self, .playbackLoopChanged, self.playbackLoopChanged)
        
        // MARK: Commands --------------------------------------------------------------
        
        Messenger.subscribe(self, .playTrack, self.performTrackPlayback(_:))
        Messenger.subscribe(self, .chapterPlayback, self.performChapterPlayback(_:))
        
        Messenger.subscribe(self, .player_playOrPause, self.playOrPause)
        Messenger.subscribe(self, .player_stop, self.stop)
        Messenger.subscribe(self, .player_previousTrack, self.previousTrack)
        Messenger.subscribe(self, .player_nextTrack, self.nextTrack)
        Messenger.subscribe(self, .player_replayTrack, self.replayTrack)
        Messenger.subscribe(self, .player_seekBackward, self.seekBackward(_:))
        Messenger.subscribe(self, .player_seekForward, self.seekForward(_:))
        Messenger.subscribe(self, .player_seekBackward_secondary, self.seekBackward_secondary)
        Messenger.subscribe(self, .player_seekForward_secondary, self.seekForward_secondary)
        Messenger.subscribe(self, .player_jumpToTime, self.jumpToTime(_:))
        Messenger.subscribe(self, .player_toggleLoop, self.toggleLoop)
        
        Messenger.subscribe(self, .player_showOrHideTimeElapsedRemaining, playbackView.showOrHideTimeElapsedRemaining)
        Messenger.subscribe(self, .player_setTimeElapsedDisplayFormat, playbackView.setTimeElapsedDisplayFormat(_:))
        Messenger.subscribe(self, .player_setTimeRemainingDisplayFormat, playbackView.setTimeRemainingDisplayFormat(_:))
        
        Messenger.subscribe(self, .changePlayerTextSize, playbackView.changeTextSize(_:))
        
        SyncMessenger.subscribe(actionTypes: [.applyColorScheme, .changeFunctionButtonColor, .changeToggleButtonOffStateColor,
                                              .changePlayerSliderColors, .changePlayerSliderValueTextColor], subscriber: self)
    }
    
    // MARK: Track playback actions/functions ------------------------------------------------------------
    
    // Plays, pauses, or resumes playback
    @IBAction func playPauseAction(_ sender: AnyObject) {
        playOrPause()
    }
    
    func playOrPause() {
        
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
        previousTrack()
    }
    
    func previousTrack() {
        player.previousTrack()
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        nextTrack()
    }

    func nextTrack() {
        player.nextTrack()
    }
    
    func stop() {
        player.stop()
    }
    
    // Replays the currently playing track, from the beginning, if there is one
    func replayTrack() {
        
        let wasPaused: Bool = player.state == .paused
        
        player.replay()
        playbackView.updateSeekPosition()
        
        if wasPaused {
            playbackView.playbackStateChanged(player.state)
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
    
    func trackNotTranscoded(_ notification: TrackNotTranscodedNotification) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        //        DispatchQueue.main.async {
        //
        //            // Position and display an alert with error info
        //            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotTranscodedAlertWithError(msg.error, "OK"))
        //        }
        
        alertDialog.showAlert(.error, "Track not transcoded", notification.track.conciseDisplayName, notification.error.message)
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
    
    func seekBackward(_ actionMode: ActionMode) {
        
        player.seekBackward(actionMode)
        playbackView.updateSeekPosition()
    }
    
    func seekBackward_secondary() {
        
        player.seekBackwardSecondary()
        playbackView.updateSeekPosition()
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        seekForward(.discrete)
    }
    
    func seekForward(_ actionMode: ActionMode) {
        
        player.seekForward(actionMode)
        playbackView.updateSeekPosition()
    }
    
    func seekForward_secondary() {
        
        player.seekForwardSecondary()
        playbackView.updateSeekPosition()
    }
    
    func jumpToTime(_ time: Double) {
        
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
    
    func toggleLoop() {
        
        if player.state.isPlayingOrPaused {
            
            _ = player.toggleLoop()
            playbackLoopChanged()
            
            Messenger.publish(.playbackLoopChanged)
        }
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged() {
        
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

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        if notification.gapStarted || notification.transcodingStarted {
            gapOrTranscodingStarted()
            
        } else {
            trackChanged(notification.endTrack)
        }
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        playbackView.playbackRateChanged(notification.newPlaybackRate, player.state)
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {

        // MARK: Appearance
            
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
