//
//  AudioGraphProtocols.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A functional contract for the Audio Graph.
///
/// The Audio Graph is one of the core components of the app and is responsible for all audio output. It serves as the infrastructure for playback,
/// effects, and visualization.
///
protocol AudioGraphProtocol: PlayerGraphProtocol {
    
    var availableDevices: [AudioDevice] {get}
    var numberOfDevices: Int {get}
    
    var systemDevice: AudioDevice {get}
    
    var outputDevice: AudioDevice {get set}
    var indexOfOutputDevice: Int {get}
    
    var outputDeviceBufferSize: Int {get set}
    var outputDeviceSampleRate: Double {get}
    
    var playerOutputFormat: AVAudioFormat {get}
    
    var volume: Float {get set}
    
    @discardableResult func increaseVolume(by increment: Float) -> Float
    @discardableResult func decreaseVolume(by decrement: Float) -> Float
    
    var pan: Float {get set}
    @discardableResult func panLeft(by delta: Float) -> Float
    @discardableResult func panRight(by delta: Float) -> Float
    
    var muted: Bool {get set}
    
    var masterUnit: MasterUnitProtocol {get}
    var eqUnit: EQUnitProtocol {get}
    var pitchShiftUnit: PitchShiftUnitProtocol {get}
    var timeStretchUnit: TimeStretchUnitProtocol {get}
    var reverbUnit: ReverbUnitProtocol {get}
    var delayUnit: DelayUnitProtocol {get}
    var filterUnit: FilterUnitProtocol {get}
    var replayGainUnit: ReplayGainUnitProtocol {get}
    
    var audioUnits: [HostedAudioUnitProtocol] {get}
    var audioUnitsState: EffectsUnitState {get}
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnit, index: Int)?
    func removeAudioUnits(at indices: IndexSet)
    
    var allUnits: [any EffectsUnitProtocol] {get}
    
    var settingsAsMasterPreset: MasterPreset {get}
    
    var soundProfiles: SoundProfiles {get set}
    func applySoundProfile(_ profile: SoundProfile)
    func captureSystemSoundProfile()
    func restoreSystemSoundProfile()
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    func pauseRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    func resumeRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    
    var visualizationAnalysisBufferSize: Int {get}
    var isSetUpForVisualizationAnalysis: Bool {get}
    func setUpForVisualizationAnalysis()
    
    // Shuts down the audio graph, releasing all its resources
    func tearDown()
}

///
/// Contract for a sub-graph of the audio graph, suitable for a player, that performs operations on only the player node of the graph.
///
protocol PlayerGraphProtocol {
    
    // The audio graph node responsible for playback
    var playerNode: AuralPlayerNode {get}
    
    // Reconnects the player node to its output node, with a new audio format
    func reconnectPlayerNode(withFormat format: AVAudioFormat)
    
    // Clears reverb/delay sound tails. Suitable for use when stopping the player.
    func clearSoundTails()
}

///
/// Contract for a client that observes the rendering of audio data to an output device.
///
/// An example of such an observer is the **Visualizer**.
/// - SeeAlso: `Visualizer`
///
protocol AudioGraphRenderObserverProtocol {
    
    func rendered(audioBuffer: AudioBufferList)
    
    func deviceChanged(newDeviceBufferSize: Int, newDeviceSampleRate: Double)
    
    func deviceSampleRateChanged(newSampleRate: Double)
}
