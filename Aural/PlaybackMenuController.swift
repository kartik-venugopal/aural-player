import Cocoa

/*
    Provides actions for the Playback menu that affect the playing track and playback sequence (repeat/shuffle modes).
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class PlaybackMenuController: NSObject, NSMenuDelegate {
    
    // Menu items whose states are toggled when they (or others) are clicked
    
    @IBOutlet weak var playOrPauseMenuItem: ToggleMenuItem!     // Needs to be toggled
    @IBOutlet weak var replayTrackMenuItem: NSMenuItem!
    @IBOutlet weak var previousTrackMenuItem: NSMenuItem!
    @IBOutlet weak var nextTrackMenuItem: NSMenuItem!
    
    @IBOutlet weak var seekForwardMenuItem: NSMenuItem!
    @IBOutlet weak var seekBackwardMenuItem: NSMenuItem!
    @IBOutlet weak var seekForwardSecondaryMenuItem: NSMenuItem!
    @IBOutlet weak var seekBackwardSecondaryMenuItem: NSMenuItem!
    
    @IBOutlet weak var detailedInfoMenuItem: NSMenuItem!
    @IBOutlet weak var showInPlaylistMenuItem: NSMenuItem!
    
    // Playback repeat modes
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    // Playback shuffle modes
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    
    // Segment playback loop toggling
    @IBOutlet weak var loopMenuItem: NSMenuItem!
    
    @IBOutlet weak var rememberLastPositionMenuItem: ToggleMenuItem!
    
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private lazy var playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.getPlaylistAccessorDelegate()
    
    // Delegate that provides access to History information
    private let history: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    private let preferences: PlaybackPreferences = ObjectGraph.getPreferencesDelegate().getPreferences().playbackPreferences
    
    // One-time setup
    override func awakeFromNib() {
        
        playOrPauseMenuItem.off()
    }
    
    // When the menu is about to open, update the menu item states
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        updateRepeatAndShuffleMenuItemStates()
        
        let isRegularMode = AppModeManager.mode == .regular
        let isPlayingOrPaused = playbackInfo.getPlaybackState() != .noTrack
        
        // Play/pause enabled if at least one track available
        playOrPauseMenuItem.isEnabled = playlist.size() > 0
        playOrPauseMenuItem.onIf(playbackInfo.getPlaybackState() == .playing)
        
        // Enabled only in regular mode if playing/paused
        
        // TODO: Show in playlist only available when playlist is visible
        [replayTrackMenuItem, loopMenuItem, detailedInfoMenuItem, showInPlaylistMenuItem].forEach({$0.isEnabled = isRegularMode && isPlayingOrPaused})
        
        // Should not invoke these items when a popover is being displayed (because of the keyboard shortcuts which conflict with the CMD arrow and Alt arrow functions when editing text within a popover)
        [previousTrackMenuItem, nextTrackMenuItem, seekForwardMenuItem, seekBackwardMenuItem, seekForwardSecondaryMenuItem, seekBackwardSecondaryMenuItem].forEach({$0.isEnabled = isPlayingOrPaused && !WindowState.showingPopover})
        
        rememberLastPositionMenuItem.isHidden = !(preferences.rememberLastPosition && preferences.rememberLastPositionOption == .individualTracks)
        
        if let playingTrack = playbackInfo.getPlayingTrack()?.track {
            
            rememberLastPositionMenuItem.isEnabled = true
            rememberLastPositionMenuItem.onIf(PlaybackProfiles.profileForTrack(playingTrack) != nil)
        } else {
            rememberLastPositionMenuItem.isEnabled = false
        }
    }
    
    // Plays, pauses or resumes playback
    @IBAction func playOrPauseAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.playOrPause))
    }
    
    // Replays the currently playing track from the beginning, if there is one
    @IBAction func replayTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.replayTrack))
    }
    
    // Toggles A->B playback loop
    @IBAction func toggleLoopAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.toggleLoop))
    }
    
    // Plays the previous track in the current playback sequence
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.previousTrack))
    }
    
    // Plays the next track in the current playback sequence
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.nextTrack))
    }
    
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
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.moreInfo))
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    @IBAction func rememberLastPositionAction(_ sender: ToggleMenuItem) {
        
        !rememberLastPositionMenuItem.isOn() ? SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.save) : SyncMessenger.publishActionMessage(PlaybackProfileActionMessage.delete)
    }
    
    // Updates the menu item states per the current playback modes
    private func updateRepeatAndShuffleMenuItemStates() {
        
        let modes = playbackInfo.getRepeatAndShuffleModes()
        
        shuffleOffMenuItem.state = NSControl.StateValue(rawValue: modes.shuffleMode == .off ? 1 : 0)
        shuffleOnMenuItem.state = NSControl.StateValue(rawValue: modes.shuffleMode == .on ? 1 : 0)
        
        switch modes.repeatMode {
            
        case .off:
            
            repeatOffMenuItem.state = convertToNSControlStateValue(1)
            [repeatOneMenuItem, repeatAllMenuItem].forEach({$0?.state = convertToNSControlStateValue(0)})
            
        case .one:
            
            repeatOneMenuItem.state = convertToNSControlStateValue(1)
            [repeatOffMenuItem, repeatAllMenuItem].forEach({$0?.state = convertToNSControlStateValue(0)})
            
        case .all:
            
            repeatAllMenuItem.state = convertToNSControlStateValue(1)
            [repeatOffMenuItem, repeatOneMenuItem].forEach({$0?.state = convertToNSControlStateValue(0)})
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
