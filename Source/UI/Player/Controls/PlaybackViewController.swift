/*
    View controller for all playback-related controls (play/pause, prev/next track, seeking, segment looping).
    Also handles playback requests from app menus.
 */
import Cocoa

class PlaybackViewController: NSViewController, NotificationSubscriber, Destroyable {
    
    @IBOutlet weak var playbackView: PlaybackView!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    private lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    override func viewDidLoad() {
        
        // MARK: Notifications --------------------------------------------------------------
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribe(self, .player_trackNotPlayed, self.trackNotPlayed(_:))
        
        Messenger.subscribe(self, .fx_playbackRateChanged, self.playbackRateChanged(_:))
        Messenger.subscribe(self, .player_playbackLoopChanged, self.playbackLoopChanged)
        
        // MARK: Commands --------------------------------------------------------------
        
        Messenger.subscribe(self, .player_playTrack, self.performTrackPlayback(_:))
        
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
        
        Messenger.subscribe(self, .player_playChapter, self.playChapter(_:))
        Messenger.subscribe(self, .player_previousChapter, self.previousChapter)
        Messenger.subscribe(self, .player_nextChapter, self.nextChapter)
        Messenger.subscribe(self, .player_replayChapter, self.replayChapter)
        Messenger.subscribe(self, .player_toggleChapterLoop, self.toggleChapterLoop)
        
        Messenger.subscribe(self, .player_showOrHideTimeElapsedRemaining, playbackView.showOrHideTimeElapsedRemaining)
        Messenger.subscribe(self, .player_setTimeElapsedDisplayFormat, playbackView.setTimeElapsedDisplayFormat(_:))
        Messenger.subscribe(self, .player_setTimeRemainingDisplayFormat, playbackView.setTimeRemainingDisplayFormat(_:))
        
        Messenger.subscribe(self, .applyTheme, playbackView.applyTheme)
        Messenger.subscribe(self, .applyFontScheme, playbackView.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, playbackView.applyColorScheme(_:))
        Messenger.subscribe(self, .player_changeSliderColors, playbackView.changeSliderColors)
        Messenger.subscribe(self, .changeFunctionButtonColor, playbackView.changeFunctionButtonColor(_:))
        Messenger.subscribe(self, .changeToggleButtonOffStateColor, playbackView.changeToggleButtonOffStateColor(_:))
        Messenger.subscribe(self, .player_changeSliderValueTextColor, playbackView.changeSliderValueTextColor(_:))
    }
    
    func destroy() {
        Messenger.unsubscribeAll(for: self)
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
                playTrackWithIndex(index)
            }
            
        case .track:
            
            if let track = command.track {
                playTrack(track)
            }
            
        case .group:
            
            if let group = command.group {
                playGroup(group)
            }
        }
    }
    
    private func playTrackWithIndex(_ trackIndex: Int) {
        player.play(trackIndex, PlaybackParams.defaultParams())
    }
    
    private func playTrack(_ track: Track) {
        player.play(track, PlaybackParams.defaultParams())
    }
    
    private func playGroup(_ group: Group) {
        player.play(group, PlaybackParams.defaultParams())
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
        
        if let invalidTrackError = notification.error as? InvalidTrackError {
            alertDialog.showAlert(.error, "Track not played", invalidTrackError.file.lastPathComponent, notification.error.message)
        } else {
            alertDialog.showAlert(.error, "Track not played", "", notification.error.message)
        }
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
    
    func seekBackward(_ inputMode: UserInputMode) {
        
        player.seekBackward(inputMode)
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
    
    func seekForward(_ inputMode: UserInputMode) {
        
        player.seekForward(inputMode)
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
            
            Messenger.publish(.player_playbackLoopChanged)
        }
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged() {
        
        if let playingTrack = player.playingTrack {
            playbackView.playbackLoopChanged(player.playbackLoop, playingTrack.duration)
        }
    }
    
    // MARK: Chapter playback functions ------------------------------------------------------------
    
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
    
    private func toggleChapterLoop() {
        
        _ = player.toggleChapterLoop()
        playbackView.playbackLoopChanged(player.playbackLoop, player.playingTrack?.duration ?? 0)
        
        Messenger.publish(.player_playbackLoopChanged)
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
        trackChanged(notification.endTrack)
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ newPlaybackRate: Float) {
        playbackView.playbackRateChanged(newPlaybackRate, player.state)
    }
}
