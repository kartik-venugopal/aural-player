//
//  AudioGraphDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    var availableDevices: [AudioDevice] {graph.availableDevices}
    
    var numberOfDevices: Int {graph.numberOfDevices}
    
    var systemDevice: AudioDevice {graph.systemDevice}
    
    var outputDevice: AudioDevice {
        
        get {graph.outputDevice}
        set {graph.outputDevice = newValue}
    }
    
    var indexOfOutputDevice: Int {
        graph.indexOfOutputDevice
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
    var replayGainUnit: ReplayGainUnitDelegateProtocol
    var audioUnits: [HostedAudioUnitDelegateProtocol]
    
    var allUnits: [EffectsUnitDelegateProtocol] {
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
    
    // The actual underlying audio graph
    private var graph: AudioGraphProtocol
    private let player: PlaybackInfoDelegateProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    lazy var soundProfiles: SoundProfiles = graph.soundProfiles
    
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
        replayGainUnit = ReplayGainUnitDelegate(for: graph.replayGainUnit)
        audioUnits = graph.audioUnits.map {HostedAudioUnitDelegate(for: $0)}
        
        // Set output device based on user preference
        
        // Check if remembered device is available (based on name and UID).
        if let prefDeviceUID = persistentState?.outputDevice?.uid,
           let foundDevice = graph.availableDevices.first(where: {$0.uid == prefDeviceUID}) {
            
            self.graph.outputDevice = foundDevice
        }
        
        graph.captureSystemSoundProfile()
        
        messenger.subscribe(to: .Application.willExit, handler: onAppExit)
        messenger.subscribe(to: .Player.preTrackPlayback, handler: preTrackPlayback(_:))
        
        messenger.subscribe(to: .Effects.saveSoundProfile, handler: saveSoundProfile)
        messenger.subscribe(to: .Effects.deleteSoundProfile, handler: deleteSoundProfile)
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
    let maxRightPan: Float = 1
    
    var pan: Float {
        
        get {round(graph.pan * ValueConversions.pan_audioGraphToUI)}
        set {graph.pan = newValue * ValueConversions.pan_UIToAudioGraph}
    }
    
    var formattedPan: String {ValueFormatter.formatPan(pan)}
    
    func increaseVolume(inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? preferences.volumeDelta.value : preferences.volumeDelta_continuous
        graph.volume = min(maxVolume, graph.volume + volumeDelta)
        
        return volume
    }
    
    func decreaseVolume(inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? preferences.volumeDelta.value : preferences.volumeDelta_continuous
        graph.volume = max(minVolume, graph.volume - volumeDelta)
        
        return volume
    }
    
    func panLeft() -> Float {
        
        let newPan = max(maxLeftPan, graph.pan - preferences.panDelta.value)
        
        // If the pan caused the balance to switch from L->R or R->L,
        // center the pan.
        graph.pan = graph.pan > 0 && newPan < 0 ? 0 : newPan
        
        return pan
    }
    
    func panRight() -> Float {
        
        let newPan = min(maxRightPan, graph.pan + preferences.panDelta.value)
        graph.pan = graph.pan < 0 && newPan > 0 ? 0 : newPan
        
        return pan
    }
    
    var visualizationAnalysisBufferSize: Int {graph.visualizationAnalysisBufferSize}
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnitDelegateProtocol, index: Int)? {
        
        guard let result = graph.addAudioUnit(ofType: type, andSubType: subType) else {return nil}
        
        let audioUnit = result.0
        let index = result.1
        
        let delegate = HostedAudioUnitDelegate(for: audioUnit)
        audioUnits.append(delegate)
        
        fxUnitStateObserverRegistry.observeAU(delegate)
        
        return (audioUnit: delegate, index: index)
    }
    
    func removeAudioUnits(at indices: IndexSet) -> [HostedAudioUnitDelegateProtocol] {
        
        graph.removeAudioUnits(at: indices)
        
        defer {fxUnitStateObserverRegistry.compositeAUStateUpdated()}
        
        let descendingIndices = indices.sortedDescending()
        return descendingIndices.map {audioUnits.remove(at: $0)}
    }
    
    func registerRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        graph.registerRenderObserver(observer)
    }
    
    func removeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        graph.removeRenderObserver(observer)
    }
    
    func pauseRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        graph.pauseRenderObserver(observer)
    }
    
    func resumeRenderObserver(_ observer: AudioGraphRenderObserverProtocol) {
        graph.resumeRenderObserver(observer)
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
    
    private var needToRememberSettingsForAllTracks: Bool {
        preferences.rememberEffectsSettingsForAllTracks.value
    }
    
    func preTrackPlayback(_ notification: PreTrackPlaybackNotification) {
        
        let oldTrack = notification.oldTrack
        let newTrack = notification.newTrack
        
        if let theOldTrack = oldTrack, (needToRememberSettingsForAllTracks || soundProfiles.hasFor(theOldTrack)) {
            
            doSaveProfile(forTrack: theOldTrack)
            
            if let theNewTrack = newTrack, let profile = soundProfiles[theNewTrack] {
                graph.applySoundProfile(profile)
                
            } else {
                graph.restoreSystemSoundProfile()
            }
            
        } else if let theNewTrack = newTrack, let profile = soundProfiles[theNewTrack] {
            
            graph.captureSystemSoundProfile()
            graph.applySoundProfile(profile)
        }
        
        // Replay gain ------------------------------------------------------------
        replayGainUnit.applyReplayGain(forTrack: newTrack)
    }
    
    @inline(__always)
    private func doSaveProfile(forTrack track: Track) {
        
        soundProfiles[track] = SoundProfile(file: track.file, volume: graph.volume,
                                               pan: graph.pan, effects: graph.settingsAsMasterPreset)
    }
    
    // This function is invoked when the user attempts to exit the app.
    // It checks if there is a track playing and if sound settings for the track need to be remembered.
    func onAppExit() {
        
        // Save a profile if either:
        // 1 - the preferences require profiles for all tracks, OR
        // 2 - there is an existing profile for this track (chosen by the user) so it needs to be
        // updated as the track is done playing.
        
        if let plTrack = player.playingTrack,
           needToRememberSettingsForAllTracks || soundProfiles.hasFor(plTrack) {
            
            doSaveProfile(forTrack: plTrack)
            
            // App exit implies the track has finished playing, restore system sound settings
            // so that they will be used on the next app launch.
            graph.restoreSystemSoundProfile()
        }
    }
}
