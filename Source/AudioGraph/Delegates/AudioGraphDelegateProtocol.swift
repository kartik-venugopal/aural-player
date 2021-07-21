//
//  AudioGraphDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Contract for a middleman/delegate that relays all requests to alter the audio graph, i.e. to tune the sound output - volume, panning, equalizer (EQ), sound effects, etc
 */
import Cocoa
import AVFoundation

///
/// A functional contract for a delegate representing the Audio Graph.
///
/// Acts as a middleman between the Effects UI and the Audio Graph,
/// providing a simplified interface / facade for the UI layer to manipulate the Audio Graph.
///
/// - SeeAlso: `AudioGraph`
///
protocol AudioGraphDelegateProtocol {
    
    var availableDevices: AudioDeviceList {get}
    var systemDevice: AudioDevice {get}
    var outputDevice: AudioDevice {get set}
    var outputDeviceBufferSize: Int {get set}
    var outputDeviceSampleRate: Double {get}
    
    // NOTE - All functions that return String values return user-friendly text representations of the value being get/set, for display in the UI. For instance, setDelayLowPassCutoff(64) might return a value like "64 Hz"
    var volume: Float {get set}
    
    var formattedVolume: String {get}
    
    /*
     Increases the player volume by a small increment. Returns the new player volume.
     
     The "inputMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The input mode will affect the amount by which the volume is increased.
     */
    func increaseVolume(_ inputMode: UserInputMode) -> Float
    
    /*
     Decreases the player volume by a small decrement. Returns the new player volume.
     
     The "inputMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The input mode will affect the amount by which the volume is decreased.
     */
    func decreaseVolume(_ inputMode: UserInputMode) -> Float
    
    var muted: Bool {get set}
    
    var pan: Float {get set}
    
    var formattedPan: String {get}
    
    // Pans left by a small increment. Returns new pan value.
    func panLeft() -> Float
    
    // Pans right by a small increment. Returns new pan value.
    func panRight() -> Float
    
    var masterUnit: MasterUnitDelegateProtocol {get}
    var eqUnit: EQUnitDelegateProtocol {get}
    var pitchShiftUnit: PitchShiftUnitDelegateProtocol {get}
    var timeStretchUnit: TimeStretchUnitDelegateProtocol {get}
    var reverbUnit: ReverbUnitDelegateProtocol {get}
    var delayUnit: DelayUnitDelegateProtocol {get}
    var filterUnit: FilterUnitDelegateProtocol {get}
    
    var audioUnits: [HostedAudioUnitDelegateProtocol] {get}
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnitDelegateProtocol, index: Int)?
    func removeAudioUnits(at indices: IndexSet) -> [HostedAudioUnitDelegateProtocol]
    
    var soundProfiles: SoundProfiles {get}
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol)
    
    var visualizationAnalysisBufferSize: Int {get}
}
