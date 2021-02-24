//import Cocoa
//import AVFoundation
//
///*
//    Mock for debugging without starting an audio engine.
// */
//class MockAudioGraph: AudioGraphProtocol, PersistentModelObject {
//
//    var _state: AudioGraphState
//    
//    // FX units
//    var masterUnit: MasterUnit
//    var eqUnit: EQUnit
//    var pitchUnit: PitchUnit
//    var timeUnit: TimeUnit
//    var reverbUnit: ReverbUnit
//    var delayUnit: DelayUnit
//    var filterUnit: FilterUnit
//    
//    var availableDevices: [AudioDevice] {
//        return []
//    }
//    
//    var systemDevice: AudioDevice {
//        return AudioDevice(deviceID: AudioDeviceID(0))
//    }
//    
//    var outputDevice: AudioDevice {
//        
//        get {return AudioDevice(deviceID: AudioDeviceID(0))}
//        set {}
//    }
//    
//    var playerNode: AuralPlayerNode
//    
//    var nodeForRecorderTap: AVAudioNode {
//        return AuralPlayerNode(useLegacyAPI: true)
//    }
//    
//    var soundProfiles: SoundProfiles
//    
//    // Sound setting value holders
//    private var playerVolume: Float
//    
//    // Sets up the audio engine
//    init(_ state: AudioGraphState) {
//        
//        playerNode = AuralPlayerNode(useLegacyAPI: true)
//        
//        soundProfiles = SoundProfiles()
//        _state = state
//        
//        playerVolume = state.volume
//        muted = state.muted
//        playerNode.volume = muted ? 0 : playerVolume
//        playerNode.pan = state.balance
//        
//        eqUnit = EQUnit(state)
//        pitchUnit = PitchUnit(state)
//        timeUnit = TimeUnit(state)
//        reverbUnit = ReverbUnit(state)
//        delayUnit = DelayUnit(state)
//        filterUnit = FilterUnit(state)
//        
//        let slaveUnits = [eqUnit, pitchUnit, timeUnit, reverbUnit, delayUnit, filterUnit]
//        masterUnit = MasterUnit(state, slaveUnits)
//        
//        state.soundProfiles.forEach {
//            soundProfiles.add($0.file, $0)
//        }
//    }
//    
//    var volume: Float {
//        
//        get {return playerVolume}
//        
//        set(newValue) {
//            playerVolume = newValue
//            if !muted {playerNode.volume = newValue}
//        }
//    }
//    
//    var balance: Float {
//        
//        get {return playerNode.pan}
//        set(newValue) {playerNode.pan = newValue}
//    }
//    
//    var muted: Bool {
//        didSet {playerNode.volume = muted ? 0 : playerVolume}
//    }
//    
//    var settingsAsMasterPreset: MasterPreset {
//        return MasterUnit(_state, []).settingsAsPreset
//    }
//
//    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
//    }
//    
//    // MARK: Miscellaneous functions
//    
//    func clearSoundTails() {
//    }
//    
//    var persistentState: PersistentState {
//        
//        let state: AudioGraphState = AudioGraphState()
//        
//        // Volume and pan (balance)
//        state.volume = playerVolume
//        state.muted = muted
//        state.balance = playerNode.pan
//        
//        state.masterUnit = masterUnit.persistentState
//        state.eqUnit = eqUnit.persistentState
//        state.pitchUnit = pitchUnit.persistentState
//        state.timeUnit = timeUnit.persistentState
//        state.reverbUnit = reverbUnit.persistentState
//        state.delayUnit = delayUnit.persistentState
//        state.filterUnit = filterUnit.persistentState
//        
//        state.soundProfiles.append(contentsOf: soundProfiles.all())
//        
//        return state
//    }
//    
//    func restartAudioEngine() {
//    }
//    
//    func tearDown() {
//    }
//}
