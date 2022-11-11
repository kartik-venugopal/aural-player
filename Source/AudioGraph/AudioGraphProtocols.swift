//
//  AudioGraphProtocols.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

///
/// A functional contract for the Audio Graph.
///
/// The Audio Graph is one of the core components of the app and is responsible for all audio output. It serves as the infrastructure for playback,
/// effects, and visualization.
///
protocol AudioGraphProtocol: PlayerGraphProtocol {
    
    var availableDevices: AudioDeviceList {get}
    var systemDevice: AudioDevice {get}
    var outputDevice: AudioDevice {get set}
    var outputDeviceBufferSize: Int {get set}
    var outputDeviceSampleRate: Double {get}
    
    var volume: Float {get set}
    var pan: Float {get set}
    var muted: Bool {get set}
    
    var masterUnit: MasterUnit {get}
    var eqUnit: EQUnit {get}
    var pitchShiftUnit: PitchShiftUnit {get}
    var timeStretchUnit: TimeStretchUnit {get}
    var reverbUnit: ReverbUnit {get}
    var delayUnit: DelayUnit {get}
    var filterUnit: FilterUnit {get}
    
    var audioUnits: [HostedAudioUnit] {get}
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnit, index: Int)?
    func removeAudioUnits(at indices: IndexSet)
    
    var settingsAsMasterPreset: MasterPreset {get}
    
    var soundProfiles: SoundProfiles {get set}
    func applySoundProfile(_ profile: SoundProfile)
    func captureSystemSoundProfile()
    func restoreSystemSoundProfile()
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    
    // Shuts down the audio graph, releasing all its resources
    func tearDown()
    
    var visualizationAnalysisBufferSize: Int {get}
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
    
    func rendered(timeStamp: AudioTimeStamp, frameCount: UInt32, audioBuffer: AudioBufferList)
    
    func deviceChanged(newDeviceBufferSize: Int, newDeviceSampleRate: Double)
    
    func deviceSampleRateChanged(newSampleRate: Double)
}
