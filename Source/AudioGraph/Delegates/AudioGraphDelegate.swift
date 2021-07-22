//
//  AudioGraphDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
 Concrete implementation of AudioGraphDelegateProtocol
 */

import AVFoundation

///
/// A delegate representing the Audio Graph.
///
/// Acts as a middleman between the Effects UI and the Audio Graph,
/// providing a simplified interface / facade for the UI layer to manipulate the Audio Graph.
///
/// - SeeAlso: `AudioGraphDelegateProtocol`
/// - SeeAlso: `AudioGraph`
///
class AudioGraphDelegate: AudioGraphDelegateProtocol {
    
    var availableDevices: AudioDeviceList {graph.availableDevices}
    
    var systemDevice: AudioDevice {graph.systemDevice}
    
    var outputDevice: AudioDevice {
        
        get {graph.outputDevice}
        set {graph.outputDevice = newValue}
    }
    
    var outputDeviceBufferSize: Int {
        
        get {graph.outputDeviceBufferSize}
        set {graph.outputDeviceBufferSize = newValue}
    }
    
    var outputDeviceSampleRate: Double {graph.outputDeviceSampleRate}
    
    var masterUnit: MasterUnitDelegateProtocol
    var eqUnit: EQUnitDelegateProtocol
    var pitchShiftUnit: PitchShiftUnitDelegateProtocol
    var timeStretchUnit: TimeStretchUnitDelegateProtocol
    var reverbUnit: ReverbUnitDelegateProtocol
    var delayUnit: DelayUnitDelegateProtocol
    var filterUnit: FilterUnitDelegateProtocol
    var audioUnits: [HostedAudioUnitDelegateProtocol]
    
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
    
    // The actual underlying audio graph
    private var graph: AudioGraphProtocol
    private let player: PlaybackInfoDelegateProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    var soundProfiles: SoundProfiles {graph.soundProfiles}
    
    private lazy var messenger = Messenger(for: self)
    
    init(graph: AudioGraphProtocol, persistentState: AudioGraphPersistentState?,
         player: PlaybackInfoDelegateProtocol, preferences: SoundPreferences) {
        
        self.graph = graph
        self.player = player
        self.preferences = preferences
        
        masterUnit = MasterUnitDelegate(for: graph.masterUnit)
        eqUnit = EQUnitDelegate(for: graph.eqUnit, preferences: preferences)
        pitchShiftUnit = PitchShiftUnitDelegate(for: graph.pitchShiftUnit, preferences: preferences)
        timeStretchUnit = TimeStretchUnitDelegate(for: graph.timeStretchUnit, preferences: preferences)
        reverbUnit = ReverbUnitDelegate(for: graph.reverbUnit)
        delayUnit = DelayUnitDelegate(for: graph.delayUnit)
        filterUnit = FilterUnitDelegate(for: graph.filterUnit)
        audioUnits = graph.audioUnits.map {HostedAudioUnitDelegate(for: $0)}
        
        // Set output device based on user preference
        
        // Check if remembered device is available (based on name and UID).
        if preferences.outputDeviceOnStartup.option == .rememberFromLastAppLaunch,
           let prefDeviceUID = persistentState?.outputDevice?.uid,
           let foundDevice = graph.availableDevices.find(byUID: prefDeviceUID) {
            
            self.graph.outputDevice = foundDevice
            
        } // Check if preferred device is available (based on name and UID).
        else if preferences.outputDeviceOnStartup.option == .specific,
           let prefDeviceName = preferences.outputDeviceOnStartup.preferredDeviceName,
           let prefDeviceUID = preferences.outputDeviceOnStartup.preferredDeviceUID,
           let foundDevice = graph.availableDevices.find(byName: prefDeviceName, andUID: prefDeviceUID) {
            
            self.graph.outputDevice = foundDevice
        }
        
        // Set volume and effects based on user preference
        
        if preferences.volumeOnStartupOption == .specific {
            
            self.graph.volume = preferences.startupVolumeValue
            self.muted = false
        }
        
        if preferences.effectsSettingsOnStartupOption == .applyMasterPreset,
           let presetName = preferences.masterPresetOnStartup_name {
            
            masterUnit.applyPreset(named: presetName)
        }
        
        messenger.subscribe(to: .application_willExit, handler: onAppExit)
        messenger.subscribe(to: .player_preTrackPlayback, handler: preTrackPlayback(_:))
        
        messenger.subscribe(to: .effects_saveSoundProfile, handler: saveSoundProfile)
        messenger.subscribe(to: .effects_deleteSoundProfile, handler: deleteSoundProfile)
    }
    
    var settingsAsMasterPreset: MasterPreset {
        graph.settingsAsMasterPreset
    }
    
    let minVolume: Float = 0
    let maxVolume: Float = 1
    
    var volume: Float {
        
        get {round(graph.volume * ValueConversions.volume_audioGraphToUI)}
        set {graph.volume = newValue * ValueConversions.volume_UIToAudioGraph}
    }
    
    var formattedVolume: String {ValueFormatter.formatVolume(volume)}
    
    var muted: Bool {
        
        get {graph.muted}
        set {graph.muted = newValue}
    }
    
    let maxLeftPan: Float = -1
    let maxRightPan: Float = -1
    
    var pan: Float {
        
        get {round(graph.pan * ValueConversions.pan_audioGraphToUI)}
        set {graph.pan = newValue * ValueConversions.pan_UIToAudioGraph}
    }
    
    var formattedPan: String {ValueFormatter.formatPan(pan)}
    
    func increaseVolume(inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
        graph.volume = min(maxVolume, graph.volume + volumeDelta)
        
        return volume
    }
    
    func decreaseVolume(inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
        graph.volume = max(minVolume, graph.volume - volumeDelta)
        
        return volume
    }
    
    func panLeft() -> Float {
        
        let newPan = max(maxLeftPan, graph.pan - preferences.panDelta)
        
        // If the pan caused the balance to switch from L->R or R->L,
        // center the pan.
        graph.pan = graph.pan > 0 && newPan < 0 ? 0 : newPan
        
        return pan
    }
    
    func panRight() -> Float {
        
        let newPan = min(maxRightPan, graph.pan + preferences.panDelta)
        graph.pan = graph.pan < 0 && newPan > 0 ? 0 : newPan
        
        return pan
    }
    
    var visualizationAnalysisBufferSize: Int {graph.visualizationAnalysisBufferSize}
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnitDelegateProtocol, index: Int)? {
        
        guard let result = graph.addAudioUnit(ofType: type, andSubType: subType) else {return nil}
        
        let audioUnit = result.0
        let index = result.1
        
        self.audioUnits.append(HostedAudioUnitDelegate(for: audioUnit))
        return (audioUnit: self.audioUnits.last!, index: index)
    }
    
    func removeAudioUnits(at indices: IndexSet) -> [HostedAudioUnitDelegateProtocol] {
        
        graph.removeAudioUnits(at: indices)
        
        let descendingIndices = indices.sorted(by: Int.descendingIntComparator)
        return descendingIndices.map {audioUnits.remove(at: $0)}
    }
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        graph.registerRenderObserver(observer)
    }
    
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        graph.removeRenderObserver(observer)
    }
    
    // MARK: Message handling
    
    private func saveSoundProfile() {
        
        if let plTrack = player.playingTrack {
            
            soundProfiles[plTrack] = SoundProfile(file: plTrack.file, volume: graph.volume,
                                                  pan: graph.pan, effects: graph.settingsAsMasterPreset)
        }
    }
    
    private func deleteSoundProfile() {
        
        if let plTrack = player.playingTrack {
            soundProfiles.removeFor(plTrack)
        }
    }
    
    func preTrackPlayback(_ notification: PreTrackPlaybackNotification) {
        trackChanged(notification.oldTrack, notification.newTrack)
    }
    
    private func trackChanged(_ oldTrack: Track?, _ newTrack: Track?) {
        
        // Save/apply sound profile
        saveProfile(forTrack: oldTrack)
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if let theNewTrack = newTrack, let profile = soundProfiles[theNewTrack] {
            
            graph.volume = profile.volume
            graph.pan = profile.pan
            masterUnit.applyPreset(profile.effects)
        }
    }
    
    private func saveProfile(forTrack track: Track?) {
        
        // Save a profile if either:
        // 1 - the preferences require profiles for all tracks, OR
        // 2 - there is an existing profile for this track (chosen by the user) so it needs to be
        // updated as the track is done playing.
        
        if let theTrack = track,
           preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(theTrack) {
            
            
            soundProfiles[theTrack] = SoundProfile(file: theTrack.file, volume: graph.volume,
                                                   pan: graph.pan, effects: graph.settingsAsMasterPreset)
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    func onAppExit() {
        saveProfile(forTrack: player.playingTrack)
    }
}
