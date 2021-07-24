//
//  AudioGraph.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    var masterUnit: MasterUnit
    var eqUnit: EQUnit
    var pitchShiftUnit: PitchShiftUnit
    var timeStretchUnit: TimeStretchUnit
    var reverbUnit: ReverbUnit
    var delayUnit: DelayUnit
    var filterUnit: FilterUnit
    var audioUnits: [HostedAudioUnit]
    
    var soundProfiles: SoundProfiles
    
    private lazy var messenger = Messenger(for: self)
    
    let visualizationAnalysisBufferSize: Int = 2048
    
    // Used by callbacks
    fileprivate lazy var unmanagedReferenceToSelf: UnsafeMutableRawPointer = Unmanaged.passUnretained(self).toOpaque()
    fileprivate lazy var outputAudioUnit: AudioUnit = outputNode.audioUnit!
    
    // Sets up the audio engine
    init(audioEngine: AudioEngine, audioUnitsManager: AudioUnitsManager, persistentState: AudioGraphPersistentState?) {
        
        self.audioEngine = audioEngine
        
        let volume = persistentState?.volume ?? AudioGraphDefaults.volume
        let pan = persistentState?.pan ?? AudioGraphDefaults.pan
        
        // If running on 10.12 Sierra or older, use the legacy AVAudioPlayerNode APIs
        if #available(OSX 10.13, *) {
            playerNode = AuralPlayerNode(useLegacyAPI: false, volume: volume, pan: pan)
        } else {
            playerNode = AuralPlayerNode(useLegacyAPI: true, volume: volume, pan: pan)
        }
        
        let muted = persistentState?.muted ?? AudioGraphDefaults.muted
        auxMixer = AVAudioMixerNode(muted: muted)
        
        outputNode = audioEngine.outputNode
        
        deviceManager = DeviceManager(outputAudioUnit: outputNode.audioUnit!)
        
        eqUnit = EQUnit(persistentState: persistentState?.eqUnit)
        pitchShiftUnit = PitchShiftUnit(persistentState: persistentState?.pitchUnit)
        timeStretchUnit = TimeStretchUnit(persistentState: persistentState?.timeUnit)
        reverbUnit = ReverbUnit(persistentState: persistentState?.reverbUnit)
        delayUnit = DelayUnit(persistentState: persistentState?.delayUnit)
        filterUnit = FilterUnit(persistentState: persistentState?.filterUnit)
        
        self.audioUnitsManager = audioUnitsManager
        audioUnits = []
        
        for auState in persistentState?.audioUnits ?? [] {
            
            guard let componentType = auState.componentType,
                  let componentSubType = auState.componentSubType,
                  let component = audioUnitsManager.audioUnit(ofType: componentType,
                                                              andSubType: componentSubType) else {continue}
            
            audioUnits.append(HostedAudioUnit(forComponent: component, persistentState: auState))
        }
        
        let nativeSlaveUnits = [eqUnit, pitchShiftUnit, timeStretchUnit, reverbUnit, delayUnit, filterUnit]
        masterUnit = MasterUnit(persistentState: persistentState?.masterUnit, nativeSlaveUnits: nativeSlaveUnits,
                                audioUnits: audioUnits)

        let permanentNodes = [playerNode, auxMixer] + (nativeSlaveUnits.flatMap {$0.avNodes})
        let removableNodes = audioUnits.flatMap {$0.avNodes}
        audioEngine.addNodes(permanentNodes: permanentNodes, removableNodes: removableNodes)
        
        soundProfiles = SoundProfiles(persistentState: persistentState?.soundProfiles)
        
        audioGraphInstance = self
        
        // Register self as an observer for notifications when the audio output device has changed (e.g. headphones)
        messenger.subscribe(to: .AVAudioEngineConfigurationChange, handler: outputDeviceChanged)
        
        deviceManager.maxFramesPerSlice = visualizationAnalysisBufferSize
        audioEngine.start()
    }
    
    // MARK: Audio engine functions ----------------------------------
    
    func reconnectPlayerNode(withFormat format: AVAudioFormat) {
        audioEngine.reconnect(outputOf: playerNode, toInputOf: auxMixer, withFormat: format)
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
        set {playerNode.volume = newValue}
    }
    
    var pan: Float {
        
        get {playerNode.pan}
        set {playerNode.pan = newValue}
    }
    
    var muted: Bool {
        
        get {auxMixer.muted}
        set {auxMixer.muted = newValue}
    }
    
    // MARK: Device management ----------------------------------
    
    var availableDevices: AudioDeviceList {deviceManager.allDevices}
    
    var systemDevice: AudioDevice {deviceManager.systemDevice}
    
    var outputDevice: AudioDevice {
        
        get {deviceManager.outputDevice}
        set(newDevice) {deviceManager.outputDevice = newDevice}
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
        messenger.publish(.audioGraph_outputDeviceChanged)
    }
    
    // MARK: Audio Units management ----------------------------------
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnit, index: Int)? {
        
        if let auComponent = audioUnitsManager.audioUnit(ofType: type, andSubType: subType) {
            
            let newUnit: HostedAudioUnit = HostedAudioUnit(forComponent: auComponent)
            audioUnits.append(newUnit)
            masterUnit.addAudioUnit(newUnit)
            
            let context = AudioGraphChangeContext()
            messenger.publish(PreAudioGraphChangeNotification(context: context))
            audioEngine.insertNode(newUnit.avNodes[0])
            messenger.publish(AudioGraphChangedNotification(context: context))
            
            return (audioUnit: newUnit, index: audioUnits.lastIndex)
        }
        
        return nil
    }
    
    func removeAudioUnits(at indices: IndexSet) {
        
        let descendingIndices = indices.sorted(by: Int.descendingIntComparator)
        descendingIndices.forEach {audioUnits.remove(at: $0)}
        
        masterUnit.removeAudioUnits(at: descendingIndices)
        
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
                                  masterUnit: masterUnit.persistentState,
                                  eqUnit: eqUnit.persistentState,
                                  pitchUnit: pitchShiftUnit.persistentState,
                                  timeUnit: timeStretchUnit.persistentState,
                                  reverbUnit: reverbUnit.persistentState,
                                  delayUnit: delayUnit.persistentState,
                                  filterUnit: filterUnit.persistentState,
                                  audioUnits: audioUnits.map {$0.persistentState},
                                  soundProfiles: soundProfiles.persistentState)
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
        
        renderObserver?.rendered(timeStamp: inTimeStamp.pointee,
                                 frameCount: inNumberFrames,
                                 audioBuffer: bufferList)
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
