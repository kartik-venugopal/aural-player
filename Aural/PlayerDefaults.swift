import Cocoa
import AVFoundation

/*
    Default values for player sound settings
*/
class PlayerDefaults {
    
    static let repeatMode: RepeatMode = .off
    static let shuffleMode: ShuffleMode = .off
    
    static let volume: Float = 0.5
    static let balance: Float = 0
    static let muted: Bool = false
    
    static let eqGlobalGain: Float = 0
    static let eqBandGain: Float = 0
    
    static let pitchBypass: Bool = true
    static let pitch: Float = 0
    static let pitchOverlap: Float = 8
    
    static let timeBypass: Bool = true
    static let timeStretchRate: Float = 1
    
    static let reverbBypass: Bool = true
    static let reverbPreset: ReverbPresets = .mediumHall
    static let reverbAmount: Float = 50
    
    static let delayBypass: Bool = true
    static let delayAmount: Float = 100
    static let delayTime: Double = 1
    static let delayFeedback: Float = 50
    static let delayLowPassCutoff: Float = 15000

    static let filterBypass: Bool = true
    static let filterLowPassCutoff: Float = AppConstants.audibleRangeMax
    static let filterHighPassCutoff: Float = AppConstants.audibleRangeMin
}
