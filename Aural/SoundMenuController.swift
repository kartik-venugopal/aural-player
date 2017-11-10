import Cocoa

/*
    Provides actions for the Sound menu
 */
class SoundMenuController: NSObject {
    
    @IBAction func panLeftAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.panLeft))
    }
    
    @IBAction func panRightAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.panRight))
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
}
