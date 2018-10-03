import Cocoa
import AVFoundation

/*
    Default values for app settings
*/
class AppDefaults {
    
    static let appMode: AppMode = .regular
    
    static let windowLayout: WindowLayoutPresets = .verticalFullStack
    
    static let repeatMode: RepeatMode = .off
    static let shuffleMode: ShuffleMode = .off
    
    static let volume: Float = 0.5
    static let balance: Float = 0
    static let muted: Bool = false
    
    static let masterState: EffectsUnitState = .active
    
    static let eqState: EffectsUnitState = .bypassed
    static let eqGlobalGain: Float = 0
    static let eqBandGain: Float = 0
    
    static let pitchState: EffectsUnitState = .bypassed
    static let pitch: Float = 0
    static let pitchOverlap: Float = 8
    
    static let timeState: EffectsUnitState = .bypassed
    static let timeStretchRate: Float = 1
    static let timeShiftPitch: Bool = false
    static let timeOverlap: Float = 8
    
    static let reverbState: EffectsUnitState = .bypassed
    static let reverbSpace: ReverbSpaces = .mediumHall
    static let reverbAmount: Float = 50
    
    static let delayState: EffectsUnitState = .bypassed
    static let delayAmount: Float = 100
    static let delayTime: Double = 1
    static let delayFeedback: Float = 50
    static let delayLowPassCutoff: Float = 15000

    static let filterState: EffectsUnitState = .bypassed
    static let filterBassMin: Float = 32
    static let filterBassMax: Float = 128
    static let filterMidMin: Float = 500
    static let filterMidMax: Float = 1000
    static let filterTrebleMin: Float = 4000
    static let filterTrebleMax: Float = 8000
}
