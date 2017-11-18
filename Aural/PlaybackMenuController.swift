import Cocoa

/*
    Provides actions for the Playback menu that affect the playing track and playback sequence (repeat/shuffle modes).
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class PlaybackMenuController: NSObject, NSMenuDelegate {
    
    // Menu items whose states are toggled when they (or others) are clicked
    
    // Playback repeat modes
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    // Playback shuffle modes
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    
    // Favorites menu item (needs to be toggled)
    @IBOutlet weak var favoritesMenuItem: ToggleMenuItem!
    
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // Delegate that provides access to History information
    private let history: HistoryDelegateProtocol = ObjectGraph.getHistoryDelegate()
    
    // One-time setup
    override func awakeFromNib() {
        
        favoritesMenuItem.offStateTitle = Strings.favoritesAddCaption
        favoritesMenuItem.onStateTitle = Strings.favoritesRemoveCaption
    }
    
    // When the menu is about to open, update the menu item states
    func menuWillOpen(_ menu: NSMenu) {
        
        updateRepeatAndShuffleMenuItemStates()
        
        // Update Favorites menu item
        if let playingTrack = playbackInfo.getPlayingTrack()?.track {
            favoritesMenuItem.onIf(history.hasFavorite(playingTrack))
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
    
    // Adds/removes the currently playing track, if there is one, to/from the "Favorites" list
    @IBAction func favoritesAction(_ sender: Any) {
        
        // Check if there is a track playing (this function cannot be invoked otherwise)
        if let playingTrack = (playbackInfo.getPlayingTrack()?.track) {
        
            // Publish an action message to add/remove the item to/from Favorites
            let action: ActionType = history.hasFavorite(playingTrack) ? .removeFavorite : .addFavorite
            SyncMessenger.publishActionMessage(FavoritesActionMessage(action, playingTrack))
        }
    }
    
    // Updates the menu item states per the current playback modes
    private func updateRepeatAndShuffleMenuItemStates() {
        
        let modes = playbackInfo.getRepeatAndShuffleModes()
        
        shuffleOffMenuItem.state = modes.shuffleMode == .off ? 1 : 0
        shuffleOnMenuItem.state = modes.shuffleMode == .on ? 1 : 0
        
        switch modes.repeatMode {
            
        case .off:
            
            repeatOffMenuItem.state = 1
            [repeatOneMenuItem, repeatAllMenuItem].forEach({$0?.state = 0})
            
        case .one:
            
            repeatOneMenuItem.state = 1
            [repeatOffMenuItem, repeatAllMenuItem].forEach({$0?.state = 0})
            
        case .all:
            
            repeatAllMenuItem.state = 1
            [repeatOffMenuItem, repeatOneMenuItem].forEach({$0?.state = 0})
        }
    }
}
