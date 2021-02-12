import Cocoa
import AVFoundation

/*
    Mock for debugging without starting an audio engine.
 */
class MockAudioGraph: AudioGraphProtocol, PersistentModelObject {

    var _state: AudioGraphState
    
    // FX units
    var masterUnit: MasterUnit
    var eqUnit: EQUnit
    var pitchUnit: PitchUnit
    var timeUnit: TimeUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit
    
    var availableDevices: [AudioDevice] {
        return []
    }
    
    var systemDevice: AudioDevice {
        return AudioDevice(deviceID: AudioDeviceID(0))
    }
    
    var outputDevice: AudioDevice {
        
        get {return AudioDevice(deviceID: AudioDeviceID(0))}
        set {}
    }
    
    var playerNode: AuralPlayerNode {
        AuralPlayerNode(useLegacyAPI: true)
    }
    
    var nodeForRecorderTap: AVAudioNode {
        return AuralPlayerNode(useLegacyAPI: true)
    }
    
    var soundProfiles: SoundProfiles
    
    // Sets up the audio engine
    init(_ state: AudioGraphState) {
        
        soundProfiles = SoundProfiles()
        _state = state
        
        eqUnit = EQUnit(state)
        pitchUnit = PitchUnit(state)
        timeUnit = TimeUnit(state)
        reverbUnit = ReverbUnit(state)
        delayUnit = DelayUnit(state)
        filterUnit = FilterUnit(state)
        
        let slaveUnits = [eqUnit, pitchUnit, timeUnit, reverbUnit, delayUnit, filterUnit]
        masterUnit = MasterUnit(state, slaveUnits)
    }
    
    var volume: Float {
        
        get {0}
        set {}
    }
    
    var balance: Float {
        
        get {0}
        set {}
    }
    
    var muted: Bool = false
    
    var settingsAsMasterPreset: MasterPreset {
        return MasterUnit(_state, []).settingsAsPreset
    }

    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
    }
    
    // MARK: Miscellaneous functions
    
    func clearSoundTails() {
    }
    
    var persistentState: PersistentState {
        return AudioGraphState()
    }
    
    func restartAudioEngine() {
    }
    
    func tearDown() {
    }
}
