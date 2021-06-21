import Cocoa
import AVFoundation

/*
    Wrapper around AVAudioEngine. Manages the AVAudioEngine audio graph.
 */
class AudioGraph: AudioGraphProtocol, PersistentModelObject {
    
    var availableDevices: AudioDeviceList {
        return deviceManager.allDevices
    }
    
    var systemDevice: AudioDevice {
        return deviceManager.systemDevice
    }
    
    var outputDevice: AudioDevice {
        
        get {return deviceManager.outputDevice}
        
        set(newDevice) {
            deviceManager.outputDevice = newDevice
        }
    }
    
    var outputDeviceBufferSize: Int {
        
        get {deviceManager.outputDeviceBufferSize}
        set {deviceManager.outputDeviceBufferSize = newValue}
    }
    
    var outputDeviceSampleRate: Double {deviceManager.outputDeviceSampleRate}
    
    private let audioEngine: AVAudioEngine
    
    internal let outputNode: AVAudioOutputNode
    internal let playerNode: AuralPlayerNode
    internal let nodeForRecorderTap: AVAudioNode
    private let auxMixer: AVAudioMixerNode  // Used for conversions of sample rates / channel counts
    
    private let audioUnitsManager: AudioUnitsManager
    private let deviceManager: DeviceManager
    private let audioEngineHelper: AudioEngineHelper
    
    // FX units
    var masterUnit: MasterUnit
    var eqUnit: EQUnit
    var pitchUnit: PitchUnit
    var timeUnit: TimeUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit
    var audioUnits: [HostedAudioUnit]
    
    // Sound setting value holders
    private var playerVolume: Float
    
    var soundProfiles: SoundProfiles
    
    // Sets up the audio engine
    init(_ audioUnitsManager: AudioUnitsManager, _ persistentState: AudioGraphPersistentState?) {
        
        self.audioUnitsManager = audioUnitsManager
        audioEngine = AVAudioEngine()
        outputNode = audioEngine.outputNode
        
        // If running on 10.12 Sierra or older, use the legacy AVAudioPlayerNode APIs
        if #available(OSX 10.13, *) {
            playerNode = AuralPlayerNode(useLegacyAPI: false)
        } else {
            playerNode = AuralPlayerNode(useLegacyAPI: true)
        }
        
        nodeForRecorderTap = audioEngine.mainMixerNode
        auxMixer = AVAudioMixerNode()
        
        deviceManager = DeviceManager(outputAudioUnit: audioEngine.outputNode.audioUnit!)
        
        eqUnit = EQUnit(persistentState: persistentState?.eqUnit)
        pitchUnit = PitchUnit(persistentState: persistentState?.pitchUnit)
        timeUnit = TimeUnit(persistentState: persistentState?.timeUnit)
        reverbUnit = ReverbUnit(persistentState: persistentState?.reverbUnit)
        delayUnit = DelayUnit(persistentState: persistentState?.delayUnit)
        filterUnit = FilterUnit(persistentState: persistentState?.filterUnit)
        
        self.audioUnits = []
        for auState in persistentState?.audioUnits ?? [] {
            
            if let component = audioUnitsManager.component(ofType: auState.componentType, andSubType: auState.componentSubType) {
                audioUnits.append(HostedAudioUnit(forComponent: component, persistentState: auState))
            }
        }
        
        let nativeSlaveUnits = [eqUnit, pitchUnit, timeUnit, reverbUnit, delayUnit, filterUnit]
        masterUnit = MasterUnit(persistentState: persistentState?.masterUnit, nativeSlaveUnits: nativeSlaveUnits, audioUnits: audioUnits)

        let permanentNodes = [playerNode, auxMixer] + (nativeSlaveUnits.flatMap {$0.avNodes})
        let removableNodes = audioUnits.flatMap {$0.avNodes}
        
        audioEngineHelper = AudioEngineHelper(engine: audioEngine, permanentNodes: permanentNodes, removableNodes: removableNodes)
        
        playerVolume = persistentState?.volume ?? AudioGraphDefaults.volume
        muted = persistentState?.muted ?? AudioGraphDefaults.muted
        playerNode.volume = muted ? 0 : playerVolume
        playerNode.pan = persistentState?.balance ?? AudioGraphDefaults.balance
        
        soundProfiles = SoundProfiles(persistentState?.soundProfiles ?? [])
        
        // Register self as an observer for notifications when the audio output device has changed (e.g. headphones)
        NotificationCenter.default.addObserver(self, selector: #selector(outputChanged), name: NSNotification.Name.AVAudioEngineConfigurationChange, object: audioEngine)
        
        audioEngineHelper.connectNodes()
        
        deviceManager.maxFramesPerSlice = visualizationAnalysisBufferSize
        
        audioEngineHelper.prepareAndStart()
    }
    
    @objc func outputChanged() {
        
        deviceManager.maxFramesPerSlice = visualizationAnalysisBufferSize
        audioEngineHelper.start()
        
        // Send out a notification
        Messenger.publish(.audioGraph_outputDeviceChanged)
    }
    
    var volume: Float {
        
        get {return playerVolume}
        
        set(newValue) {
            playerVolume = newValue
            if !muted {playerNode.volume = newValue}
        }
    }
    
    var balance: Float {
        
        get {return playerNode.pan}
        set(newValue) {playerNode.pan = newValue}
    }
    
    var muted: Bool {
        didSet {playerNode.volume = muted ? 0 : playerVolume}
    }
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnit, index: Int)? {
        
        if let auComponent = audioUnitsManager.component(ofType: type, andSubType: subType) {
            
            let newUnit: HostedAudioUnit = HostedAudioUnit(forComponent: auComponent)
            audioUnits.append(newUnit)
            masterUnit.addAudioUnit(newUnit)
            
            let context = AudioGraphChangeContext()
            Messenger.publish(PreAudioGraphChangeNotification(context: context))
            
            audioEngineHelper.insertNode(newUnit.avNodes[0])
            
            Messenger.publish(AudioGraphChangedNotification(context: context))
            
            return (audioUnit: newUnit, index: audioUnits.lastIndex)
        }
        
        return nil
    }
    
    func removeAudioUnits(at indices: IndexSet) {
        
        let descendingIndices = indices.filter {$0 < audioUnits.count}.sorted(by: Int.descendingIntComparator)
        
        for index in descendingIndices {
            audioUnits.remove(at: index)
        }
        
        masterUnit.removeAudioUnits(descendingIndices)
        
        let context = AudioGraphChangeContext()
        Messenger.publish(PreAudioGraphChangeNotification(context: context))
        
        audioEngineHelper.removeNodes(descendingIndices)
        
        Messenger.publish(AudioGraphChangedNotification(context: context))
    }
    
    var settingsAsMasterPreset: MasterPreset {
        return masterUnit.settingsAsPreset
    }

    func reconnectPlayerNodeWithFormat(_ format: AVAudioFormat) {
        audioEngineHelper.reconnectNodes(playerNode, outputNode: auxMixer, format: format)
    }
    
    // MARK: Miscellaneous functions
    
    func clearSoundTails() {
        
        // Clear sound tails from reverb and delay nodes, if they're active
        [delayUnit, reverbUnit].forEach {
            if $0.isActive {$0.reset()}
        }
    }
    
    var persistentState: AudioGraphPersistentState {
        
        let state: AudioGraphPersistentState = AudioGraphPersistentState()
        
        let outputDevice = self.outputDevice
        state.outputDevice = AudioDevicePersistentState(name: outputDevice.name, uid: outputDevice.uid)
        
        // Volume and pan (balance)
        state.volume = playerVolume
        state.muted = muted
        state.balance = playerNode.pan
        
        state.masterUnit = masterUnit.persistentState
        state.eqUnit = eqUnit.persistentState
        state.pitchUnit = pitchUnit.persistentState
        state.timeUnit = timeUnit.persistentState
        state.reverbUnit = reverbUnit.persistentState
        state.delayUnit = delayUnit.persistentState
        state.filterUnit = filterUnit.persistentState
        state.audioUnits = audioUnits.map {$0.persistentState}
        
        state.soundProfiles = self.soundProfiles.all().map {SoundProfilePersistentState(file: $0.file, volume: $0.volume, balance: $0.balance, effects: MasterPresetPersistentState(preset: $0.effects))}
        
        return state
    }
    
    func restartAudioEngine() {
        audioEngineHelper.restart()
    }
    
    func tearDown() {
        
        // Release the audio engine resources
        audioEngine.stop()
    }
}

enum EffectsUnitState: String {
    
    // Master unit on, and effects unit on
    case active
    
    // Effects unit off
    case bypassed
    
    // Master unit off, and effects unit on
    case suppressed
}

struct AudioGraphDefaults {
    
    static let volume: Float = 0.5
    static let balance: Float = 0
    static let muted: Bool = false
    
    static let masterState: EffectsUnitState = .active
    
    static let eqState: EffectsUnitState = .bypassed
    static let eqType: EQType = .tenBand
    static let eqGlobalGain: Float = 0
    static let eqBands: [Float] = Array(repeating: Float(0), count: 10)
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
    static let filterBandType: FilterBandType = .bandStop
    static let filterBandMinFreq: Float = AppConstants.Sound.audibleRangeMin
    static let filterBandMaxFreq: Float = AppConstants.Sound.subBass_max
    
    static let auState: EffectsUnitState = .active
}
