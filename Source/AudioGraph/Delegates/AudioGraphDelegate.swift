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
class AudioGraphDelegate: AudioGraphDelegateProtocol, NotificationSubscriber {
    
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
    
    // The actual underlying audio graph
    private var graph: AudioGraphProtocol
    private let player: PlaybackInfoDelegateProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    var soundProfiles: SoundProfiles {graph.soundProfiles}
    
    init(_ graph: AudioGraphProtocol, _ player: PlaybackInfoDelegateProtocol, _ preferences: SoundPreferences, _ graphState: AudioGraphPersistentState?) {
        
        self.graph = graph
        self.player = player
        self.preferences = preferences
        
        masterUnit = MasterUnitDelegate(graph.masterUnit)
        eqUnit = EQUnitDelegate(graph.eqUnit, preferences)
        pitchShiftUnit = PitchShiftUnitDelegate(graph.pitchShiftUnit, preferences)
        timeStretchUnit = TimeStretchUnitDelegate(graph.timeStretchUnit, preferences)
        reverbUnit = ReverbUnitDelegate(graph.reverbUnit)
        delayUnit = DelayUnitDelegate(graph.delayUnit)
        filterUnit = FilterUnitDelegate(graph.filterUnit)
        audioUnits = graph.audioUnits.map {HostedAudioUnitDelegate($0)}
        
        // Set output device based on user preference
        
        if preferences.outputDeviceOnStartup.option == .rememberFromLastAppLaunch {

            // Check if remembered device is available (based on name and UID)
            if let prefDevice: AudioDevicePersistentState = graphState?.outputDevice,
               let foundDevice = graph.availableDevices.allDevices.first(where: {$0.name == prefDevice.name &&
                                                                            $0.uid == prefDevice.uid}) {
                
                self.graph.outputDevice = foundDevice
            }

        } else if preferences.outputDeviceOnStartup.option == .specific,
            let prefDeviceName = preferences.outputDeviceOnStartup.preferredDeviceName,
            let prefDeviceUID = preferences.outputDeviceOnStartup.preferredDeviceUID {

            // Check if preferred device is available (based on name and UID)
            if let foundDevice = graph.availableDevices.allDevices.first(where: {$0.name == prefDeviceName &&
                                                                            $0.uid == prefDeviceUID}) {
                self.graph.outputDevice = foundDevice
            }
        }
        
        // Set volume and effects based on user preference
        
        if (preferences.volumeOnStartupOption == .specific) {
            
            self.graph.volume = preferences.startupVolumeValue
            self.muted = false
        }
        
        if preferences.effectsSettingsOnStartupOption == .applyMasterPreset, let presetName = preferences.masterPresetOnStartup_name {
            masterUnit.applyPreset(presetName)
        }
        
        Messenger.subscribe(self, .application_exitRequest, self.onAppExit(_:))
        Messenger.subscribe(self, .player_preTrackPlayback, self.preTrackPlayback(_:))
        
        Messenger.subscribe(self, .effects_saveSoundProfile, self.saveSoundProfile)
        Messenger.subscribe(self, .effects_deleteSoundProfile, self.deleteSoundProfile)
    }
    
    var settingsAsMasterPreset: MasterPreset {
        return graph.settingsAsMasterPreset
    }
    
    var volume: Float {
        
        get {round(graph.volume * ValueConversions.volume_audioGraphToUI)}
        set {graph.volume = newValue * ValueConversions.volume_UIToAudioGraph}
    }
    
    var formattedVolume: String {return ValueFormatter.formatVolume(volume)}
    
    var muted: Bool {
        
        get {graph.muted}
        set {graph.muted = newValue}
    }
    
    var balance: Float {
        
        get {round(graph.balance * ValueConversions.pan_audioGraphToUI)}
        set {graph.balance = newValue * ValueConversions.pan_UIToAudioGraph}
    }
    
    var formattedBalance: String {return ValueFormatter.formatPan(balance)}
    
    func increaseVolume(_ inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
        graph.volume = min(1, graph.volume + volumeDelta)
        
        return volume
    }
    
    func decreaseVolume(_ inputMode: UserInputMode) -> Float {
        
        let volumeDelta = inputMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
        graph.volume = max(0, graph.volume - volumeDelta)
        
        return volume
    }
    
    func panLeft() -> Float {
        
        let newBalance = max(-1, graph.balance - preferences.panDelta)
        graph.balance = graph.balance > 0 && newBalance < 0 ? 0 : newBalance
        
        return balance
    }
    
    func panRight() -> Float {
        
        let newBalance = min(1, graph.balance + preferences.panDelta)
        graph.balance = graph.balance < 0 && newBalance > 0 ? 0 : newBalance
        
        return balance
    }
    
    func addAudioUnit(ofType type: OSType, andSubType subType: OSType) -> (audioUnit: HostedAudioUnitDelegateProtocol, index: Int)? {
        
        if let result = graph.addAudioUnit(ofType: type, andSubType: subType) {
            
            let audioUnit = result.0
            let index = result.1
            
            self.audioUnits.append(HostedAudioUnitDelegate(audioUnit))
            return (audioUnit: self.audioUnits.last!, index: index)
        }
        
        return nil
    }
    
    func removeAudioUnits(at indices: IndexSet) -> [HostedAudioUnitDelegateProtocol] {
        
        graph.removeAudioUnits(at: indices)
        
        let descendingIndices = indices.filter {$0 < audioUnits.count}.sorted(by: Int.descendingIntComparator)
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
            soundProfiles.add(plTrack, SoundProfile(file: plTrack.file, volume: graph.volume,
                                                    balance: graph.balance, effects: graph.settingsAsMasterPreset))
        }
    }
    
    private func deleteSoundProfile() {
        
        if let plTrack = player.playingTrack {
            soundProfiles.remove(plTrack)
        }
    }
    
    func preTrackPlayback(_ notification: PreTrackPlaybackNotification) {
        trackChanged(notification.oldTrack, notification.newTrack)
    }
    
    private func trackChanged(_ oldTrack: Track?, _ newTrack: Track?) {
        
        // Save/apply sound profile
        
        // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
        if let theOldTrack = oldTrack, preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(theOldTrack) {
            
            // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the track is done playing
            soundProfiles.add(theOldTrack, SoundProfile(file: theOldTrack.file, volume: graph.volume,
                                                        balance: graph.balance, effects: graph.settingsAsMasterPreset))
        }
        
        // Apply sound profile if there is one for the new track and the preferences allow it
        if let theNewTrack = newTrack, let profile = soundProfiles.get(theNewTrack) {
            
            graph.volume = profile.volume
            graph.balance = profile.balance
            masterUnit.applyPreset(profile.effects)
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    func onAppExit(_ request: AppExitRequestNotification) {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if let plTrack = player.playingTrack, preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(plTrack) {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the app is exiting
            soundProfiles.add(plTrack, SoundProfile(file: plTrack.file, volume: graph.volume,
                                                    balance: graph.balance, effects: graph.settingsAsMasterPreset))
        }
        
        // Proceed with exit
        request.acceptResponse(okToExit: true)
    }
}
