/*
 Concrete implementation of AudioGraphDelegateProtocol
 */

import Foundation

class AudioGraphDelegate: AudioGraphDelegateProtocol, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
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
    
    init(_ graph: AudioGraphProtocol, _ player: PlaybackInfoDelegateProtocol, _ preferences: SoundPreferences) {
        
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
        
        if (preferences.volumeOnStartupOption == .specific) {
            
            self.graph.volume = preferences.startupVolumeValue
            self.muted = false
        }
        
        if preferences.effectsSettingsOnStartupOption == .applyMasterPreset, let presetName = preferences.masterPresetOnStartup_name {
            masterUnit.applyPreset(presetName)
        }
        
        SyncMessenger.subscribe(messageTypes: [.preTrackChangeNotification, .appExitRequest], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.saveSoundProfile, .deleteSoundProfile], subscriber: self)
        AsyncMessenger.subscribe([.gapStarted], subscriber: self, dispatchQueue: notificationQueue)
    }
    
    func getSettingsAsMasterPreset() -> MasterPreset {
        return graph.getSettingsAsMasterPreset()
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
    
    var subscriberId: String {
        return "AudioGraphDelegate"
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let msg = notification as? PreTrackChangeNotification {
            preTrackChange(msg.oldTrack, msg.oldState, msg.newTrack)
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let msg = message as? PlaybackGapStartedAsyncMessage {
            gapStarted(msg)
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        message.actionType == .saveSoundProfile ? saveSoundProfile() : deleteSoundProfile()
    }
    
    private func saveSoundProfile() {
        
        if let plTrack = player.playingTrack?.track {
            soundProfiles.add(plTrack)
        }
    }
    
    private func deleteSoundProfile() {
        
        if let plTrack = player.playingTrack?.track {
            soundProfiles.remove(plTrack)
        }
    }
    
    private func preTrackChange(_ lastPlayedTrack: IndexedTrack?, _ oldState: PlaybackState, _ newTrack: IndexedTrack?) {
        
        // Save/apply sound profile
        if preferences.rememberEffectsSettings {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            if let oldTrack = lastPlayedTrack?.track, oldState != .waiting, preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(oldTrack) {
                
                // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the track is done playing
                soundProfiles.add(oldTrack)
            }
            
            // Apply sound profile if there is one for the new track and the preferences allow it
            if newTrack != nil, let profile = soundProfiles.get(newTrack!.track) {
                
                graph.volume = profile.volume
                graph.balance = profile.balance
                masterUnit.applyPreset(profile.effects)
            }
        }
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        if preferences.rememberEffectsSettings, let oldTrack = msg.lastPlayedTrack?.track, preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(oldTrack) {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the track is done playing
            soundProfiles.add(oldTrack)
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if preferences.rememberEffectsSettings, let plTrack = player.playingTrack?.track, preferences.rememberEffectsSettingsOption == .allTracks || soundProfiles.hasFor(plTrack) {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the app is exiting
            soundProfiles.add(plTrack)
        }
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }
}
