import Cocoa
import AVFoundation

/*
    Default values for player sound settings
*/
class PlayerDefaults {
    
    static let volume: Float = 0.5
    static let balance: Float = 0
    static let muted: Bool = false
    static let pitch: Float = 0
    static let reverbPreset: AVAudioUnitReverbPreset? = nil
    static let reverbAmount: Float = 50
    static let delayAmount: Float = 50
    static let eqGlobalGain: Float = 0
}