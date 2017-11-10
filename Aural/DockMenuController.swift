import Cocoa

class DockMenuController: NSObject {
    
    @IBOutlet weak var repeatOffMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMenuItem: NSMenuItem!
    
    @IBOutlet weak var shuffleOffMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMenuItem: NSMenuItem!
    
    private lazy var playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func awakeFromNib() {
        updateRepeatAndShuffleMenuItemStates()
    }
    
    @IBAction func playOrPauseAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.playOrPause))
    }
    
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.previousTrack))
    }
    
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.nextTrack))
    }
    
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekBackward))
    }
    
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.seekForward))
    }
    
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.muteOrUnmute))
    }
    
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.decreaseVolume))
    }
    
    @IBAction func increaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.increaseVolume))
    }
    
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatOff))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatOne))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.repeatAll))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOff))
        updateRepeatAndShuffleMenuItemStates()
    }
    
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(PlaybackActionMessage(.shuffleOn))
        updateRepeatAndShuffleMenuItemStates()
    }
    
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
