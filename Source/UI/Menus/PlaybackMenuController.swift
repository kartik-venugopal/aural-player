import Cocoa

/*
    Provides actions for the Playback menu that affect the playing track and playback sequence (repeat/shuffle modes).
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class PlaybackMenuController: NSObject, NSMenuDelegate {
    
    // Menu items whose states are toggled when they (or others) are clicked
    
    @IBOutlet weak var playOrPauseMenuItem: NSMenuItem!     // Needs to be toggled
    @IBOutlet weak var stopMenuItem: NSMenuItem!

    @IBOutlet weak var previousTrackMenuItem: NSMenuItem!
    @IBOutlet weak var nextTrackMenuItem: NSMenuItem!
    @IBOutlet weak var replayTrackMenuItem: NSMenuItem!
    @IBOutlet weak var loopMenuItem: NSMenuItem!
    
    @IBOutlet weak var previousChapterMenuItem: NSMenuItem!
    @IBOutlet weak var nextChapterMenuItem: NSMenuItem!
    @IBOutlet weak var replayChapterMenuItem: NSMenuItem!
    @IBOutlet weak var loopChapterMenuItem: NSMenuItem!
    
    @IBOutlet weak var seekForwardMenuItem: NSMenuItem!
    @IBOutlet weak var seekBackwardMenuItem: NSMenuItem!
    @IBOutlet weak var seekForwardSecondaryMenuItem: NSMenuItem!
    @IBOutlet weak var seekBackwardSecondaryMenuItem: NSMenuItem!
    @IBOutlet weak var jumpToTimeMenuItem: NSMenuItem!
    
    @IBOutlet weak var detailedInfoMenuItem: NSMenuItem!
    @IBOutlet weak var showInPlaylistMenuItem: NSMenuItem!
    
    // Playback repeat modes
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    // Playback shuffle modes
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    
    @IBOutlet weak var rememberLastPositionMenuItem: ToggleMenuItem!
    
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    private lazy var sequenceInfo: PlaybackSequencerInfoDelegateProtocol = ObjectGraph.playbackSequencerInfoDelegate
    private lazy var playbackProfiles: PlaybackProfiles = ObjectGraph.playbackDelegate.profiles
    
    private lazy var playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    
    // Delegate that provides access to History information
    private let history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
    
    private let preferences: PlaybackPreferences = ObjectGraph.preferencesDelegate.preferences.playbackPreferences
    
    private let jumpToTimeDialog: ModalDialogDelegate = WindowFactory.jumpToTimeEditorDialog
    
    // One-time setup
    override func awakeFromNib() {
        playOrPauseMenuItem.off()
    }
    
    // When the menu is about to open, update the menu item states
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let playbackState = playbackInfo.state
        let isPlayingOrPaused = playbackState.isPlayingOrPaused
        let isPlayingPausedOrTranscoding = isPlayingOrPaused || playbackState == .transcoding
        let noTrack = playbackState == .noTrack
        
        // Play/pause enabled if at least one track available
        playOrPauseMenuItem.enableIf(playlist.size > 0 && playbackState != .transcoding)
        
        stopMenuItem.enableIf(!noTrack)
        jumpToTimeMenuItem.enableIf(isPlayingOrPaused)
        
        // Enabled only in regular mode if playing/paused
        showInPlaylistMenuItem.enableIf(isPlayingPausedOrTranscoding && WindowManager.isShowingPlaylist)
        [replayTrackMenuItem, loopMenuItem, detailedInfoMenuItem].forEach({$0.enableIf(isPlayingOrPaused)})
        
        // Should not invoke these items when a popover is being displayed (because of the keyboard shortcuts which conflict with the CMD arrow and Alt arrow functions when editing text within a popover)
        let showingModalComponent = WindowManager.isShowingModalComponent
        
        [previousTrackMenuItem, nextTrackMenuItem].forEach({$0.enableIf(!noTrack && !showingModalComponent)})
        
        // These items should be enabled only if there is a playing track and it has chapter markings
        [previousChapterMenuItem, nextChapterMenuItem, replayChapterMenuItem, loopChapterMenuItem].forEach({$0?.enableIf(playbackInfo.chapterCount > 0)})
        
        [seekForwardMenuItem, seekBackwardMenuItem, seekForwardSecondaryMenuItem, seekBackwardSecondaryMenuItem].forEach({$0?.enableIf(isPlayingOrPaused && !showingModalComponent)})
        
        rememberLastPositionMenuItem.enableIf(isPlayingOrPaused)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        updateRepeatAndShuffleMenuItemStates()
        
        // Play/pause enabled if at least one track available
        playOrPauseMenuItem.onIf(playbackInfo.state == .playing)
        rememberLastPositionMenuItem.showIf_elseHide(preferences.rememberLastPosition && preferences.rememberLastPositionOption == .individualTracks)
        
        if let playingTrack = playbackInfo.currentTrack {
            rememberLastPositionMenuItem.onIf(playbackProfiles.hasFor(playingTrack))
        }
    }
    
    // MARK: Basic playback functions (tracks)
    
    // Plays, pauses or resumes playback
    @IBAction func playOrPauseAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.playOrPause))
    }
    
    @IBAction func stopAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.stop))
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.previousTrack))
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.nextTrack))
    }
    
    // Replays the currently playing track from the beginning, if there is one
    @IBAction func replayTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.replayTrack))
    }
    
    // Toggles A->B playback loop
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.toggleLoop))
    }
    
    // MARK: Basic playback functions (chapters)
    
    // Plays the previous available chapter
    @IBAction func previousChapterAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.previousChapter))
    }
    
    // Plays the next available chapter
    @IBAction func nextChapterAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.nextChapter))
    }
    
    // Replays the currently playing chapter from the beginning, if there is one
    @IBAction func replayChapterAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.replayChapter))
    }
    
    // Toggles current chapter playback loop
    @IBAction func toggleChapterLoopAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.toggleChapterLoop))
    }
    
    // MARK: Seeking functions
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekBackward))
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekForward))
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardSecondaryAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekBackward_secondary))
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardSecondaryAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekForward_secondary))
    }
    
    @IBAction func jumpToTimeAction(_ sender: AnyObject) {
        _ = jumpToTimeDialog.showDialog()
    }
    
    // MARK: Repeat and Shuffle
    
    // Sets the repeat mode to "Off"
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatOff))
    }
    
    // Sets the repeat mode to "Repeat One"
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatOne))
    }
    
    // Sets the repeat mode to "Repeat All"
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatAll))
    }
    
    // Sets the shuffle mode to "Off"
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOff))
    }
    
    // Sets the shuffle mode to "On"
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOn))
    }
    
    // MARK: Miscellaneous playing track functions
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.moreInfo))
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    @IBAction func rememberLastPositionAction(_ sender: ToggleMenuItem) {
        
        !rememberLastPositionMenuItem.isOn ? SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.save) : SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.delete)
    }
    
    // Updates the menu item states per the current playback modes
    private func updateRepeatAndShuffleMenuItemStates() {
        
        let modes = sequenceInfo.repeatAndShuffleModes
        
        shuffleOffMenuItem.onIf(modes.shuffleMode == .off)
        shuffleOnMenuItem.onIf(modes.shuffleMode == .on)
        
        switch modes.repeatMode {
            
        case .off:
            
            repeatOffMenuItem.on()
            [repeatOneMenuItem, repeatAllMenuItem].forEach({$0?.off()})
            
        case .one:
            
            repeatOneMenuItem.on()
            [repeatOffMenuItem, repeatAllMenuItem].forEach({$0?.off()})
            
        case .all:
            
            repeatAllMenuItem.on()
            [repeatOffMenuItem, repeatOneMenuItem].forEach({$0?.off()})
        }
    }
}
