//
//  AudioGraph.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// The Audio Graph is one of the core components of the app and is responsible for all audio output. It serves as the infrastructure for playback,
/// effects, and visualization.
///
/// It encapsulates an audio engine implemented using the **AVAudioEngine** framework and manages a "graph" of nodes attached to that
/// engine. Each node in the graph performs a distinct function, such as playback, mixing, or an effect such as equalization or reverb. Each
/// node exposes configurable properties, eg. volume, playback rate, or equalizer band gain, that determine how the node manipulates audio.
/// For instance, when the user manipulates the volume slider in the player window, it modifies the volume property of the player node in the audio graph.
///
/// The nodes in the graph are connected so as to form a signal processing chain where audio is processed by a node and then
/// passed as input to the next node, which itself processes the audio, then passes it on to the next node, and so on, till the engine's output
/// node sends the audio to the audio output hardware device. So, the audio that is output by the app is a function of the cumulative audio
/// processing performed sequentially by each node in in the chain.
///
/// - SeeAlso: `AudioGraphProtocol`
///
class AudioGraph: AudioGraphProtocol, PersistentModelObject {
    
    private let audioEngine: AudioEngine
    
    let outputNode: AVAudioOutputNode
    let playerNode: AuralPlayerNode
    let auxMixer: AVAudioMixerNode  // Used for conversions of sample rates / channel counts
    
    private let audioUnitsManager: AudioUnitsManager
    
    private let deviceManager: DeviceManager
    
    // Effects units
    var masterUnit: MasterUnitProtocol
    var eqUnit: EQUnitProtocol
    var pitchShiftUnit: PitchShiftUnitProtocol
    var timeStretchUnit: TimeStretchUnitProtocol
    var reverbUnit: ReverbUnitProtocol
    var delayUnit: DelayUnitProtocol
    var filterUnit: FilterUnitProtocol
    var replayGainUnit: ReplayGainUnitProtocol
    var audioUnits: [HostedAudioUnitProtocol]
    
    var allUnits: [any EffectsUnitProtocol] {
        [masterUnit, eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit, replayGainUnit] + audioUnits
    }
    
    private(set) lazy var audioUnitsStateFunction: EffectsUnitStateFunction = {[weak self] in
        
        for unit in self?.audioUnits ?? [] {
        
            if unit.state == .active {
                return .active
            }
            
            if unit.state == .suppressed {
                return .suppressed
            }
        }
        
        return .bypassed
    }
    
    var soundProfiles: SoundProfiles
    
    var audioUnitPresets: AudioUnitPresetsMap
    
    private lazy var messenger = Messenger(for: self)
    
    let visualizationAnalysisBufferSize: Int = 2048
    
    static let minVolume: Float = 0
    static let maxVolume: Float = 1
    
    static let maxLeftPan: Float = -1
    static let maxRightPan: Float = 1
    
    // Used by callbacks
    fileprivate lazy var unmanagedReferenceToSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
    fileprivate lazy var outputAudioUnit: AudioUnit = outputNode.audioUnit!
    
    // Sets up the audio engine
    init(persistentState: AppPersistentState, audioUnitsManager: AudioUnitsManager) {
        
        let persistentState: AudioGraphPersistentState? = persistentState.audioGraph
        
        self.audioEngine = AudioEngine()
        self.audioUnitsManager = audioUnitsManager
        
        let volume = persistentState?.volume ?? AudioGraphDefaults.volume
        let pan = persistentState?.pan ?? AudioGraphDefaults.pan
        
        playerNode = AuralPlayerNode(volume: volume, pan: pan)
        
        let muted = persistentState?.muted ?? AudioGraphDefaults.muted
        auxMixer = AVAudioMixerNode(muted: muted)
        
        outputNode = audioEngine.outputNode
        
        deviceManager = DeviceManager(outputAudioUnit: outputNode.audioUnit!)
        
        eqUnit = EQUnit(persistentState: persistentState?.eqUnit)
        pitchShiftUnit = PitchShiftUnit(persistentState: persistentState?.pitchShiftUnit)
        timeStretchUnit = TimeStretchUnit(persistentState: persistentState?.timeStretchUnit)
        reverbUnit = ReverbUnit(persistentState: persistentState?.reverbUnit)
        delayUnit = DelayUnit(persistentState: persistentState?.delayUnit)
        filterUnit = FilterUnit(persistentState: persistentState?.filterUnit)
        replayGainUnit = ReplayGainUnit(persistentState: persistentState?.replayGainUnit)
        
        audioUnits = []
        audioUnitPresets = AudioUnitPresetsMap(persistentState: persistentState?.audioUnitPresets)
        
        for auState in persistentState?.audioUnits ?? [] {
            
            guard let componentType = auState.componentType,
                  let componentSubType = auState.componentSubType,
                  let component = audioUnitsManager.audioUnit(ofType: componentType,
                                                              andSubType: componentSubType) else {continue}
            
            let presets = audioUnitPresets.getPresetsForAU(componentType: componentType, componentSubType: componentSubType)
            audioUnits.append(HostedAudioUnit(forComponent: component, persistentState: auState, presets: presets))
        }
        
        let nativeSlaveUnits = [eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit, replayGainUnit]
        masterUnit = MasterUnit(persistentState: persistentState?.masterUnit, nativeSlaveUnits: nativeSlaveUnits.compactMap {$0 as? EffectsUnit},
                                audioUnits: audioUnits.compactMap {$0 as? HostedAudioUnit})
        
        let permanentNodes = [playerNode, auxMixer] + (nativeSlaveUnits.flatMap {$0.avNodes})
        let removableNodes = audioUnits.flatMap {$0.avNodes}
        audioEngine.addNodes(permanentNodes: permanentNodes, removableNodes: removableNodes)
        
        soundProfiles = SoundProfiles(persistentState: persistentState?.soundProfiles)
        
        audioGraphInstance = self
        
        // Register self as an observer for notifications when the audio output device has changed (e.g. headphones)
        messenger.subscribe(to: .AVAudioEngineConfigurationChange, handler: outputDeviceChanged)
        
        deviceManager.maxFramesPerSlice = visualizationAnalysisBufferSize
        
        audioEngine.start()
        
        // Check if remembered device is available (based on name and UID).
        if let prefDeviceUID = persistentState?.outputDevice?.uid,
           let foundDevice = availableDevices.first(where: {$0.uid == prefDeviceUID}) {
            
            self.outputDevice = foundDevice
        }
        
        captureSystemSoundProfile()
    }
    
    func applySoundProfile(_ profile: SoundProfile) {
        
        self.volume = profile.volume
        self.pan = profile.pan
        masterUnit.applyPreset(profile.effects)
    }
    
    func captureSystemSoundProfile() {
        soundProfiles.systemProfile = SoundProfile(file: URL(fileURLWithPath: "system"), volume: volume, pan: pan, effects: settingsAsMasterPreset)
    }
    
    func restoreSystemSoundProfile() {
        
        guard let systemSoundProfile = soundProfiles.systemProfile else {return}
        
        self.volume = systemSoundProfile.volume
        self.pan = systemSoundProfile.pan
        masterUnit.applyPreset(systemSoundProfile.effects)
    }
    
    // MARK: Audio engine functions ----------------------------------
    
    var playerOutputFormat: AVAudioFormat {
        playerNode.outputFormat(forBus: 0)
    }
    
    func reconnectPlayerNode(withFormat format: AVAudioFormat) {
        
        if playerOutputFormat != format {
            audioEngine.reconnect(outputOf: playerNode, toInputOf: auxMixer, withFormat: format)
        }
    }
    
    func clearSoundTails() {
        
        // Clear sound tails from reverb and delay nodes, if they're active
        if delayUnit.isActive {delayUnit.reset()}
        if reverbUnit.isActive {reverbUnit.reset()}
    }
    
    func tearDown() {
        
        // Release the audio engine resources
        audioEngine.stop()
    }
    
    // MARK: Player node properties ----------------------------------
    
    var volume: Float {
        
        get {playerNode.volume}
        set {playerNode.volume = newValue.clamped(to: Self.minVolume...Self.maxVolume)}
    }
    
    func increaseVolume(by increment: Float) -> Float {
        
        volume += increment
        return volume
    }
    
    func decreaseVolume(by decrement: Float) -> Float {
        
        volume -= decrement
        return volume
    }
    
    var pan: Float {
        
        get {playerNode.pan}
        set {playerNode.pan = newValue.clamped(to: Self.maxLeftPan...Self.maxRightPan)}
    }
    
    func panLeft(by delta: Float) -> Float {
        
        pan -= delta
        return pan
    }
    
    func panRight(by delta: Float) -> Float {
        
        pan += delta
        return pan
    }
    
    var muted: Bool {
        
        get {auxMixer.muted}
        set {auxMixer.muted = newValue}
    }
    
    // MARK: Device management ----------------------------------
    
    var availableDevices: [AudioDevice] {deviceManager.allDevices}
    
    var numberOfDevices: Int {deviceManager.numberOfDevices}
    
    var systemDevice: AudioDevice {deviceManager.systemDevice}
    
    var outputDevice: AudioDevice {
        
        get {deviceManager.outputDevice}
        set(newDevice) {deviceManager.outputDevice = newDevice}
    }
    
    var indexOfOutputDevice: Int {
        deviceManager.indexOfOutputDevice
    }
    
    var outputDeviceSampleRate: Double {deviceManager.outputDeviceSampleRate}
    
    var outputDeviceBufferSize: Int {
        
        get {deviceManager.outputDeviceBufferSize}
        set {deviceManager.outputDeviceBufferSize = newValue}
    }
    
    func outputDeviceChanged() {
        
        deviceManager.maxFramesPerSlice = visualizationAnalysisBufferSize
        audioEngine.start()
        
        // Send out a notification
        messenger.publish(.AudioGraph.outputDeviceChanged)
    }
    
    // MARK: Audio Units management ----------------------------------
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnit, index: Int)? {
        
        guard let auComponent = audioUnitsManager.audioUnit(ofType: type, andSubType: subType) else {return nil}
        
        let newUnit: HostedAudioUnit = HostedAudioUnit(forComponent: auComponent,
                                                       presets: audioUnitPresets.getPresetsForAU(componentType: type, componentSubType: subType))
        
        audioUnits.append(newUnit)
//        masterUnit.addAudioUnit(newUnit)
        
        let context = AudioGraphChangeContext()
        messenger.publish(PreAudioGraphChangeNotification(context: context))
        audioEngine.insertNode(newUnit.avNodes[0])
        messenger.publish(AudioGraphChangedNotification(context: context))
        
        return (audioUnit: newUnit, index: audioUnits.lastIndex)
    }
    
    func removeAudioUnits(at indices: IndexSet) {
        
        let descendingIndices = indices.sortedDescending()
        descendingIndices.forEach {audioUnits.remove(at: $0)}
        
//        masterUnit.removeAudioUnits(at: descendingIndices)
        
        let context = AudioGraphChangeContext()
        messenger.publish(PreAudioGraphChangeNotification(context: context))
        audioEngine.removeNodes(at: descendingIndices)
        messenger.publish(AudioGraphChangedNotification(context: context))
    }
    
    // MARK: Miscellaneous properties / functions ------------------------
    
    var settingsAsMasterPreset: MasterPreset {masterUnit.settingsAsPreset}

    var persistentState: AudioGraphPersistentState {
        
        AudioGraphPersistentState(outputDevice: AudioDevicePersistentState(name: outputDevice.name,
                                                                           uid: outputDevice.uid),
                                  volume: volume,
                                  muted: muted,
                                  pan: pan,
                                  masterUnit: (masterUnit as! MasterUnit).persistentState,
                                  eqUnit: (eqUnit as! EQUnit).persistentState,
                                  pitchShiftUnit: (pitchShiftUnit as! PitchShiftUnit).persistentState,
                                  timeStretchUnit: (timeStretchUnit as! TimeStretchUnit).persistentState,
                                  reverbUnit: (reverbUnit as! ReverbUnit).persistentState,
                                  delayUnit: (delayUnit as! DelayUnit).persistentState,
                                  filterUnit: (filterUnit as! FilterUnit).persistentState,
                                  replayGainUnit: (replayGainUnit as! ReplayGainUnit).persistentState,
                                  audioUnits: audioUnits.compactMap { ($0 as? HostedAudioUnit)?.persistentState},
                                  audioUnitPresets: audioUnitPresets.persistentState,
                                  soundProfiles: soundProfiles.persistentState,
                                  replayGainAnalysisCache: replayGainScanner.persistentState)
        
    }
}

// MARK: Callbacks (render observer)

///
/// An **AudioGraph** extension providing functions to register / unregister observers in order to respond to audio graph render events,
/// i.e. every time an audio buffer has been rendered to the audio output hardware device.
///
/// Example - The **Visualizer** uses the render callback notifications to receive the rendered audio samples, in order to
/// render visualizations.
///
extension AudioGraph {
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        renderObserver = observer
        
        outputAudioUnit.registerRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.registerDeviceChangeCallback(inProc: deviceChanged, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.registerSampleRateChangeCallback(inProc: sampleRateChanged, inProcUserData: unmanagedReferenceToSelf)
    }
    
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        
        outputAudioUnit.removeRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.removeDeviceChangeCallback(inProc: deviceChanged, inProcUserData: unmanagedReferenceToSelf)
        outputAudioUnit.removeSampleRateChangeCallback(inProc: sampleRateChanged, inProcUserData: unmanagedReferenceToSelf)
        
        renderObserver = nil
    }
    
    func pauseRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        outputAudioUnit.removeRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
    }
    
    func resumeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        outputAudioUnit.registerRenderCallback(inProc: renderCallback, inProcUserData: unmanagedReferenceToSelf)
    }
}

fileprivate var audioGraphInstance: AudioGraph!

// Currently, only one observer can be registered. Otherwise, this var will be a collection.
fileprivate var renderObserver: AudioGraphRenderObserverProtocol?

fileprivate let callbackQueue: DispatchQueue = .global(qos: .userInteractive)

fileprivate func renderCallback(inRefCon: UnsafeMutableRawPointer,
                                ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
                                inTimeStamp: UnsafePointer<AudioTimeStamp>,
                                inBusNumber: UInt32,
                                inNumberFrames: UInt32,
                                ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus {
    
    // We are only interested in the post-render event.
    
    guard ioActionFlags.pointee == .unitRenderAction_PostRender,
          let bufferList = ioData?.pointee else {return noErr}
    
    callbackQueue.async {
        
        renderObserver?.rendered(audioBuffer: bufferList)
    }
    
    return noErr
}

fileprivate func deviceChanged(inRefCon: UnsafeMutableRawPointer,
                               inUnit: AudioUnit,
                               inID: AudioUnitPropertyID,
                               inScope: AudioUnitScope,
                               inElement: AudioUnitElement) {
    
    callbackQueue.async {
        
        renderObserver?.deviceChanged(newDeviceBufferSize: audioGraphInstance.outputDeviceBufferSize,
                                      newDeviceSampleRate: audioGraphInstance.outputDeviceSampleRate)
    }
}

fileprivate func sampleRateChanged(inRefCon: UnsafeMutableRawPointer,
                                   inUnit: AudioUnit,
                                   inID: AudioUnitPropertyID,
                                   inScope: AudioUnitScope,
                                   inElement: AudioUnitElement) {
    
    callbackQueue.async {
        renderObserver?.deviceSampleRateChanged(newSampleRate: audioGraphInstance.outputDeviceSampleRate)
    }
}
