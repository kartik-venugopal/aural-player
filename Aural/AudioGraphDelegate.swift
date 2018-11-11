/*
    Concrete implementation of AudioGraphDelegateProtocol
 */

import Foundation

class AudioGraphDelegate: AudioGraphDelegateProtocol {
    
//    var masterUnit: MasterUnit
    var eqUnit: EQUnitDelegate
    var pitchUnit: PitchUnitDelegate
    var timeUnit: TimeUnitDelegate
    var reverbUnit: ReverbUnitDelegate
    var delayUnit: DelayUnitDelegate
    var filterUnit: FilterUnitDelegate
    
    // The actual underlying audio graph
    private var graph: AudioGraphProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    init(_ graph: inout AudioGraphProtocol, _ preferences: SoundPreferences) {
        
        self.graph = graph
        self.preferences = preferences
        
        eqUnit = EQUnitDelegate(graph.eqUnit, preferences)
        pitchUnit = PitchUnitDelegate(graph.pitchUnit, preferences)
        timeUnit = TimeUnitDelegate(graph.timeUnit, preferences)
        reverbUnit = ReverbUnitDelegate(graph.reverbUnit)
        delayUnit = DelayUnitDelegate(graph.delayUnit)
        filterUnit = FilterUnitDelegate(graph.filterUnit)
        
        if (preferences.volumeOnStartupOption == .specific) {
            
            graph.volume = preferences.startupVolumeValue
            muted = false
        }
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
}
