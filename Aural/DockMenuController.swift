import Cocoa

/*
    Provides actions for the dock menu. These are a handful of simple essential functions that would typically be performed by a user running the app in the background.
 
    NOTE - No actions are directly handled by this class. Action messages are published to other app components that are responsible for these functions.
 */
class DockMenuController: NSObject {
    
    // Menu items whose states are toggled when they (or others) are clicked
    
    // Playback repeat modes
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    // Playback shuffle modes
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    
    // Delegate that retrieves current playback info (e.g. repeat/shuffle modes)
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // One-time setup. When the menu is loaded for the first time, update the menu item states per the current playback modes
    override func awakeFromNib() {
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Pauses or resumes playback
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
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the repeat mode to "Repeat One"
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatOne))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the repeat mode to "Repeat All"
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatAll))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the shuffle mode to "Off"
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOff))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Sets the shuffle mode to "On"
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOn))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.muteOrUnmute))
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.decreaseVolume))
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.increaseVolume))
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
