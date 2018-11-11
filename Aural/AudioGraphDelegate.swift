/*
    Concrete implementation of AudioGraphDelegateProtocol
 */

import Foundation

class AudioGraphDelegate: AudioGraphDelegateProtocol, MessageSubscriber {
    
    var masterUnit: MasterUnitDelegate
    var eqUnit: EQUnitDelegate
    var pitchUnit: PitchUnitDelegate
    var timeUnit: TimeUnitDelegate
    var reverbUnit: ReverbUnitDelegate
    var delayUnit: DelayUnitDelegate
    var filterUnit: FilterUnitDelegate
    
    // The actual underlying audio graph
    private var graph: AudioGraphProtocol
    private let player: PlaybackInfoDelegateProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    init(_ graph: AudioGraphProtocol, _ player: PlaybackInfoDelegateProtocol, _ preferences: SoundPreferences) {
        
        self.graph = graph
        self.player = player
        self.preferences = preferences
        
        masterUnit = MasterUnitDelegate(graph, preferences)
        eqUnit = EQUnitDelegate(graph.eqUnit, preferences)
        pitchUnit = PitchUnitDelegate(graph.pitchUnit, preferences)
        timeUnit = TimeUnitDelegate(graph.timeUnit, preferences)
        reverbUnit = ReverbUnitDelegate(graph.reverbUnit)
        delayUnit = DelayUnitDelegate(graph.delayUnit)
        filterUnit = FilterUnitDelegate(graph.filterUnit)
        
        if (preferences.volumeOnStartupOption == .specific) {
            
            self.graph.volume = preferences.startupVolumeValue
            muted = false
        }
        
        SyncMessenger.subscribe(messageTypes: [.appExitRequest], subscriber: self)
    }
    
    func getSettingsAsMasterPreset() -> MasterPreset {
        return graph.getSettingsAsMasterPreset()
    }
    
    var volume: Float {

        get {return round(graph.volume * AppConstants.volumeConversion_audioGraphToUI)}
        set(newValue) {graph.volume = round(newValue * AppConstants.volumeConversion_UIToAudioGraph)}
    }
    
    var formattedVolume: String {return ValueFormatter.formatVolume(volume)}
    
    var muted: Bool {
        
        get {return graph.muted}
        set(newValue) {graph.muted = newValue}
    }
    
    var balance: Float {
        
        get {return round(graph.balance * AppConstants.panConversion_audioGraphToUI)}
        set(newValue) {graph.balance = newValue * AppConstants.panConversion_UIToAudioGraph}
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
    
    func getID() -> String {
        return "AudioGraphDelegate"
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is AppExitRequest) {
            return onExit()
        }
        
        return EmptyResponse.instance
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there is a track playing and if sound settings for the track need to be remembered.
    private func onExit() -> AppExitResponse {
        
        // Apply sound profile if there is one for the new track and if the preferences allow it
        if preferences.rememberEffectsSettings, let plTrack = player.getPlayingTrack()?.track {
            
            // Remember the current sound settings the next time this track plays. Update the profile with the latest settings applied for this track.
            // Save a profile if either 1 - the preferences require profiles for all tracks, or 2 - there is a profile for this track (chosen by user) so it needs to be updated as the app is exiting
            if preferences.rememberEffectsSettingsOption == .allTracks || SoundProfiles.profileForTrack(plTrack) != nil {
                SoundProfiles.saveProfile(plTrack, graph.volume, graph.balance, graph.getSettingsAsMasterPreset())
            }
        }
        
        // Proceed with exit
        return AppExitResponse.okToExit
    }

}
