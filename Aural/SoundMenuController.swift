import Cocoa

/*
    Provides actions for the Sound menu
 */
class SoundMenuController: NSObject {
    
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.muteOrUnmute))
    }
    
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.decreaseVolume))
    }
    
    @IBAction func increaseVolumeAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.increaseVolume))
    }
    
    @IBAction func panLeftAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.panLeft))
    }
    
    @IBAction func panRightAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.panRight))
    }
    
    @IBAction func decreaseBassAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.decreaseBass))
    }
    
    @IBAction func increaseBassAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.increaseBass))
    }
    
    @IBAction func decreasePitchAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.decreasePitch))
    }
    
    @IBAction func increasePitchAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.increasePitch))
    }
    
    @IBAction func decreaseRateAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.decreaseRate))
    }
    
    @IBAction func increaseRateAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(AudioGraphActionMessage(.increaseRate))
    }
}
