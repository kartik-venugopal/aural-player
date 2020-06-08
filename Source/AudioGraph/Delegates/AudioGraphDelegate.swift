/*
 Concrete implementation of AudioGraphDelegateProtocol
 */

import AVFoundation

class AudioGraphDelegate: AudioGraphDelegateProtocol, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
    var availableDevices: [AudioDevice] {
        return graph.availableDevices
    }
    var systemDevice: AudioDevice {return graph.systemDevice}
    
    var outputDevice: AudioDevice {
        
        get {return graph.outputDevice}
        
        set(newValue) {
            graph.outputDevice = newValue
        }
    }
    
    var masterUnit: MasterUnitDelegateProtocol
    var eqUnit: EQUnitDelegateProtocol
    var pitchUnit: PitchUnitDelegateProtocol
    var timeUnit: TimeUnitDelegateProtocol
    var reverbUnit: ReverbUnitDelegateProtocol
    var delayUnit: DelayUnitDelegateProtocol
    var filterUnit: FilterUnitDelegateProtocol
    
    // The actual underlying audio graph
    private var graph: AudioGraphProtocol
    private let player: PlaybackInfoDelegateProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    var soundProfiles: SoundProfiles {return graph.soundProfiles}
    
    private let notificationQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
    
    init(_ graph: AudioGraphProtocol, _ player: PlaybackInfoDelegateProtocol, _ preferences: SoundPreferences, _ graphState: AudioGraphState) {
        
        self.graph = graph
        self.player = player
        self.preferences = preferences
        
        masterUnit = MasterUnitDelegate(graph)
        eqUnit = EQUnitDelegate(graph.eqUnit, preferences)
        pitchUnit = PitchUnitDelegate(graph.pitchUnit, preferences)
        timeUnit = TimeUnitDelegate(graph.timeUnit, preferences)
        reverbUnit = ReverbUnitDelegate(graph.reverbUnit)
        delayUnit = DelayUnitDelegate(graph.delayUnit)
        filterUnit = FilterUnitDelegate(graph.filterUnit)
        
        // Set output device based on user preference
        
        if preferences.outputDeviceOnStartup.option == .rememberFromLastAppLaunch {
            
            let prefDevice: AudioDeviceState = graphState.outputDevice
            
            // Check if remembered device is available (based on name and UID)
            if let foundDevice = graph.availableDevices.first(where: {$0.name! == prefDevice.name && $0.uid! == prefDevice.uid}) {
                self.graph.outputDevice = foundDevice
            }
            
        } else if preferences.outputDeviceOnStartup.option == .specific,
            let prefDeviceName = preferences.outputDeviceOnStartup.preferredDeviceName,
            let prefDeviceUID = preferences.outputDeviceOnStartup.preferredDeviceUID {
            
            // Check if preferred device is available (based on name and UID)
            if let foundDevice = graph.availableDevices.first(where: {$0.name! == prefDeviceName && $0.uid! == prefDeviceUID}) {
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
        
        SyncMessenger.subscribe(messageTypes: [.preTrackChangeNotification, .appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.saveSoundProfile, .deleteSoundProfile], subscriber: self)
        AsyncMessenger.subscribe([.trackTransition], subscriber: self, dispatchQueue: notificationQueue)
    }
    
    var settingsAsMasterPreset: MasterPreset {
        return graph.settingsAsMasterPreset
    }
    
    var volume: Float {
        
        get {return round(graph.volume * AppConstants.ValueConversions.volume_audioGraphToUI)}
        set(newValue) {graph.volume = newValue * AppConstants.ValueConversions.volume_UIToAudioGraph}
    }
    
    var formattedVolume: String {return ValueFormatter.formatVolume(volume)}
    
    var muted: Bool {
        
        get {return graph.muted}
        set(newValue) {graph.muted = newValue}
    }
    
    var balance: Float {
        
        get {return round(graph.balance * AppConstants.ValueConversions.pan_audioGraphToUI)}
        set(newValue) {graph.balance = newValue * AppConstants.ValueConversions.pan_UIToAudioGraph}
    }
    
    var formattedBalance: String {return ValueFormatter.formatPan(balance)}
    
    func increaseVolume(_ actionMode: ActionMode) -> Float {
        
        let volumeDelta = actionMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
        graph.volume = min(1, graph.volume + volumeDelta)
        
        return volume
    }
    
    func decreaseVolume(_ actionMode: ActionMode) -> Float {
        
        let volumeDelta = actionMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
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
    
    // MARK: Message handling
    
    let subscriberId: String = "AudioGraphDelegate"
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? PreTrackChangeNotification {
            
            preTrackChange(msg.oldTrack, msg.newTrack)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let msg = message as? TrackTransitionAsyncMessage, msg.trackChanged && (msg.gapStarted || msg.transcodingStarted) {
            
            preTrackChange(msg.beginTrack, msg.endTrack)
            return
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        message.actionType == .saveSoundProfile ? saveSoundProfile() : deleteSoundProfile()
    }
    
    private func saveSoundProfile() {
        
        if let plTrack = player.currentTrack {
            soundProfiles.add(plTrack)
        }
    }
    
    private func deleteSoundProfile() {
        
        if let plTrack = player.currentTrack {
            soundProfiles.remove(plTrack)
        }
    }
    
    private func preTrackChange(_ lastPlayedTrack: Track?, _ newTrack: Track?) {
        
        // Save/apply sound profile
        if preferences.rememberEffectsSettings {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            if let oldTrack = lastPlayedTrack, preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(oldTrack) {
                
                // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the track is done playing
                soundProfiles.add(oldTrack)
            }
            
            // Apply sound profile if there is one for the new track and the preferences allow it
            if let theNewTrack = newTrack, let profile = soundProfiles.get(theNewTrack) {
                
                graph.volume = profile.volume
                graph.balance = profile.balance
                masterUnit.applyPreset(profile.effects)
            }
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if preferences.rememberEffectsSettings, let plTrack = player.currentTrack, preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(plTrack) {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the app is exiting
            soundProfiles.add(plTrack)
        }
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }
}
