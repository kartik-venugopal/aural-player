import AVFoundation

public enum RecordingQuality: Int {
    
    case min
    
    case low
    
    case medium
    
    case high
    
    case max
    
    var avAudioQuality: AVAudioQuality {
        return AVAudioQuality(rawValue: self.rawValue)!
    }
}
