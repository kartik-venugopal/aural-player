import Cocoa

/*
    Provides actions for the Playback menu that affect the playing track and playback sequence (repeat/shuffle modes).
 
    NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
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
    private lazy var sequenceInfo: SequencerInfoDelegateProtocol = ObjectGraph.sequencerInfoDelegate
    private lazy var playbackProfiles: PlaybackProfiles = ObjectGraph.playbackDelegate.profiles
    
    private lazy var playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    
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
        let noTrack = playbackState == .noTrack
        
        // Play/pause enabled if at least one track available
        playOrPauseMenuItem.enableIf(playlist.size > 0)
        
        stopMenuItem.enableIf(!noTrack)
        jumpToTimeMenuItem.enableIf(isPlayingOrPaused)
        
        // Enabled only in regular mode if playing/paused
        showInPlaylistMenuItem.enableIf(isPlayingOrPaused && WindowManager.instance.isShowingPlaylist)
        [replayTrackMenuItem, loopMenuItem, detailedInfoMenuItem].forEach({$0.enableIf(isPlayingOrPaused)})
        
        // Should not invoke these items when a popover is being displayed (because of the keyboard shortcuts which conflict with the CMD arrow and Alt arrow functions when editing text within a popover)
        let showingModalComponent = WindowManager.instance.isShowingModalComponent
        
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
        rememberLastPositionMenuItem.showIf_elseHide(preferences.rememberLastPositionOption == .individualTracks)
        
        if let playingTrack = playbackInfo.currentTrack {
            rememberLastPositionMenuItem.onIf(playbackProfiles.hasFor(playingTrack))
        }
    }
    
    // MARK: Basic playback functions (tracks)
    
    // Plays, pauses or resumes playback
    @IBAction func playOrPauseAction(_ sender: AnyObject) {
        Messenger.publish(.player_playOrPause)
    }
    
    @IBAction func stopAction(_ sender: AnyObject) {
        Messenger.publish(.player_stop)
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        Messenger.publish(.player_previousTrack)
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        Messenger.publish(.player_nextTrack)
    }
    
    // Replays the currently playing track from the beginning, if there is one
    @IBAction func replayTrackAction(_ sender: AnyObject) {
        Messenger.publish(.player_replayTrack)
    }
    
    // Toggles A->B playback loop
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
        Messenger.publish(.player_toggleLoop)
    }
    
    // MARK: Basic playback functions (chapters)
    
    // Plays the previous available chapter
    @IBAction func previousChapterAction(_ sender: AnyObject) {
        Messenger.publish(.player_previousChapter)
    }
    
    // Plays the next available chapter
    @IBAction func nextChapterAction(_ sender: AnyObject) {
        Messenger.publish(.player_nextChapter)
    }
    
    // Replays the currently playing chapter from the beginning, if there is one
    @IBAction func replayChapterAction(_ sender: AnyObject) {
        Messenger.publish(.player_replayChapter)
    }
    
    // Toggles current chapter playback loop
    @IBAction func toggleChapterLoopAction(_ sender: AnyObject) {
        Messenger.publish(.player_toggleChapterLoop)
    }
    
    // MARK: Seeking functions
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        Messenger.publish(.player_seekBackward, payload: UserInputMode.discrete)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        Messenger.publish(.player_seekForward, payload: UserInputMode.discrete)
    }
    
    // Seeks backward within the currently playing track
    @IBAction func seekBackwardSecondaryAction(_ sender: AnyObject) {
        Messenger.publish(.player_seekBackward_secondary)
    }
    
    // Seeks forward within the currently playing track
    @IBAction func seekForwardSecondaryAction(_ sender: AnyObject) {
        Messenger.publish(.player_seekForward_secondary)
    }
    
    @IBAction func jumpToTimeAction(_ sender: AnyObject) {
        _ = jumpToTimeDialog.showDialog()
    }
    
    // MARK: Repeat and Shuffle
    
    // Sets the repeat mode to "Off"
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        Messenger.publish(.player_setRepeatMode, payload: RepeatMode.off)
    }
    
    // Sets the repeat mode to "Repeat One"
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        Messenger.publish(.player_setRepeatMode, payload: RepeatMode.one)
    }
    
    // Sets the repeat mode to "Repeat All"
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        Messenger.publish(.player_setRepeatMode, payload: RepeatMode.all)
    }
    
    // Sets the shuffle mode to "Off"
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        Messenger.publish(.player_setShuffleMode, payload: ShuffleMode.off)
    }
    
    // Sets the shuffle mode to "On"
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        Messenger.publish(.player_setShuffleMode, payload: ShuffleMode.on)
    }
    
    // MARK: Miscellaneous playing track functions
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        Messenger.publish(.player_moreInfo)
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        Messenger.publish(.playlist_showPlayingTrack, payload: PlaylistViewSelector.forView(PlaylistViewState.current))
    }
    
    @IBAction func rememberLastPositionAction(_ sender: ToggleMenuItem) {
        Messenger.publish(!rememberLastPositionMenuItem.isOn ? .player_savePlaybackProfile : .player_deletePlaybackProfile)
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
