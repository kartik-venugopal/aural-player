//
//  PlaybackViewController.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for all playback-related controls (play/pause, prev/next track, seeking, segment looping).
    Also handles playback requests from app menus.
 */
class PlaybackViewController: NSViewController, Destroyable {
    
    @IBOutlet weak var playbackView: PlaybackView!
    
    var displaysChapterIndicator: Bool {true}
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    let player: PlaybackDelegateProtocol = objectGraph.playbackDelegate
    lazy var playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    lazy var alertDialog: AlertWindowController = AlertWindowController.instance
    
    lazy var messenger = Messenger(for: self)
    
    private let seekTimerTaskQueue: SeekTimerTaskQueue = .instance
    
    override func viewDidLoad() {
        initSubscriptions()
    }
    
    func initSubscriptions() {}
    
    func destroy() {
        messenger.unsubscribeFromAll()
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
    
    // Replays the currently playing track, from the beginning, if there is one
    func replayTrack() {
        
        let wasPaused: Bool = player.state == .paused
        
        player.replay()
        playbackView.updateSeekPosition()
        
        if wasPaused {
            playbackView.playbackStateChanged(player.state)
        }
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
    
    func playFiles(_ files: [URL]) {
        playlist.addFiles(files, clearBeforeAdding: true, beginPlayback: true)
    }
    
    func enqueueFiles(_ files: [URL]) {
        playlist.addFiles(files, clearBeforeAdding: false)
    }
    
    func stop() {
        player.stop()
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    func trackChanged(_ newTrack: Track?) {
        
        playbackView.trackChanged(player.state, player.playbackLoop, newTrack)
        
        guard displaysChapterIndicator else {return}
        
        if let track = newTrack, track.hasChapters {
            beginPollingForChapterChange()
        } else {
            stopPollingForChapterChange()
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        self.trackChanged(nil)
        
        let errorDialog = DialogsAndAlerts.genericErrorAlert("Track not played",
                                                             notification.errorTrack.file.lastPathComponent,
                                                             notification.error.message)
            
        errorDialog.runModal()
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
    
    func seekBackward(by interval: Double) {
        
        player.seekBackward(by: interval)
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
    
    func seekForward(by interval: Double) {
        
        player.seekForward(by: interval)
        playbackView.updateSeekPosition()
    }
    
    func jumpToTime(_ time: Double) {
        
        player.seekToTime(time)
        playbackView.updateSeekPosition()
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
            
            messenger.publish(.player_playbackLoopChanged)
        }
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
    func playbackLoopChanged() {
        
        if let playingTrack = player.playingTrack {
            playbackView.playbackLoopChanged(player.playbackLoop, playingTrack.duration)
        }
    }
    
    // MARK: Current chapter tracking ---------------------------------------------------------------------
    
    // Keeps track of the last known value of the current chapter (used to detect chapter changes)
    var curChapter: IndexedChapter? = nil
    
    private static let chapterChangePollingTaskId: String = "ChapterChangePollingTask"
    
    // Creates a recurring task that polls the player to detect a change in the currently playing track chapter.
    // This only occurs when the currently playing track actually has chapters.
    func beginPollingForChapterChange() {
        
        seekTimerTaskQueue.enqueueTask(Self.chapterChangePollingTaskId, {
            
            let playingChapter: IndexedChapter? = self.player.playingChapter
            
            // Compare the current chapter with the last known value of current chapter.
            if self.curChapter != playingChapter {
                
                // There has been a change ... notify observers and update the variable.
                self.messenger.publish(ChapterChangedNotification(oldChapter: self.curChapter, newChapter: playingChapter))
                self.curChapter = playingChapter
            }
        })
    }
    
    // Disables the chapter change polling task
    func stopPollingForChapterChange() {
        seekTimerTaskQueue.dequeueTask(Self.chapterChangePollingTaskId)
    }
    
    // MARK: Message handling ---------------------------------------------------------------------

    func trackTransitioned(_ notification: TrackTransitionNotification) {
        trackChanged(notification.endTrack)
    }
    
    // When the playback rate changes (caused by the Time Stretch effects unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    func playbackRateChanged(_ newPlaybackRate: Float) {
        playbackView.playbackRateChanged(newPlaybackRate, player.state)
    }
}
