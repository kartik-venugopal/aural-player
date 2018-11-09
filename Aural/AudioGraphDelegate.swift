/*
    Concrete implementation of AudioGraphDelegateProtocol
 */

import Foundation

class AudioGraphDelegate: AudioGraphDelegateProtocol {
    
    var eqUnit: EQUnitDelegate
    var pitchUnit: PitchUnitDelegate
    var timeUnit: TimeUnitDelegate
    var reverbUnit: ReverbUnitDelegate
    
    // The actual underlying audio graph
    private var graph: AudioGraphProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    init(_ graph: AudioGraphProtocol, _ preferences: SoundPreferences) {
        
        self.graph = graph
        self.preferences = preferences
        
        eqUnit = EQUnitDelegate(graph.eqUnit, preferences)
        pitchUnit = PitchUnitDelegate(graph.pitchUnit, preferences)
        timeUnit = TimeUnitDelegate(graph.timeUnit, preferences)
        reverbUnit = ReverbUnitDelegate(graph.reverbUnit)
        
        if (preferences.volumeOnStartupOption == .specific) {
            graph.setVolume(preferences.startupVolumeValue)
            graph.unmute()
        }
    }
    
    func toggleMasterBypass() -> Bool {
        return graph.toggleMasterBypass()
    }
    
    func isMasterBypass() -> Bool {
        return graph.isMasterBypass()
    }
    
    var masterPresets: MasterPresets {
        return graph.masterPresets
    }
    
    func saveMasterPreset(_ presetName: String) {
        graph.saveMasterPreset(presetName)
    }
    
    func applyMasterPreset(_ presetName: String) {
        
        if let preset = masterPresets.presetByName(presetName) {
            graph.applyMasterPreset(preset)
        }
    }
    
    func applyMasterPreset(_ preset: MasterPreset) {
        graph.applyMasterPreset(preset)
    }
    
    func getSettingsAsMasterPreset() -> MasterPreset {
        return graph.getSettingsAsMasterPreset()
    }
    
    func getVolume() -> Float {
        
        // Convert from {0,1} to percentage
        return round(graph.getVolume() * AppConstants.volumeConversion_audioGraphToUI)
    }
    
    func setVolume(_ volumePercentage: Float) {
        
        // Convert from percentage to {0,1}
        graph.setVolume(volumePercentage * AppConstants.volumeConversion_UIToAudioGraph)
    }
    
    func increaseVolume(_ actionMode: ActionMode) -> Float {
        
        // Volume is increased by an amount set in the user preferences
        
        // The volume increment will depend on the action mode
        let volumeDelta = actionMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
        
        let newVolume = min(1, graph.getVolume() + volumeDelta)
        graph.setVolume(newVolume)
        
        // Convert from {0,1} to percentage
        return round(newVolume * AppConstants.volumeConversion_audioGraphToUI)
    }
    
    func decreaseVolume(_ actionMode: ActionMode) -> Float {
        
        // Volume is decreased by an amount set in the user preferences
        
        // The volume decrement will depend on the action mode
        let volumeDelta = actionMode == .discrete ? preferences.volumeDelta : preferences.volumeDelta_continuous
        
        let newVolume = max(0, graph.getVolume() - volumeDelta)
        graph.setVolume(newVolume)
        
        // Convert from {0,1} to percentage
        return round(newVolume * AppConstants.volumeConversion_audioGraphToUI)
    }
    
    func toggleMute() -> Bool {
        
        let muted = isMuted()
        if muted {
            graph.unmute()
        } else {
            graph.mute()
        }
        
        return !muted
    }
    
    func isMuted() -> Bool {
        return graph.isMuted()
    }
    
    func getBalance() -> Float {
        
        // Convert from {-1,1} to percentage
        return round(graph.getBalance() * AppConstants.panConversion_audioGraphToUI)
    }
    
    func setBalance(_ balance: Float) {
        
        // Convert from percentage to {-1,1}
        graph.setBalance(balance * AppConstants.panConversion_UIToAudioGraph)
    }
    
    func panLeft() -> Float {
        
        // Pan is shifted left by an amount set in the user preferences
        
        let curBalance = graph.getBalance()
        var newBalance = max(-1, curBalance - preferences.panDelta)
        
        // Snap to center
        if (curBalance > 0 && newBalance < 0) {
            newBalance = 0
        }
        
        graph.setBalance(newBalance)
        
        // Convert from {-1,1} to percentage
        return round(newBalance * AppConstants.panConversion_audioGraphToUI)
    }
    
    func panRight() -> Float {
        
        // Pan is shifted right by an amount set in the user preferences
        
        let curBalance = graph.getBalance()
        var newBalance = min(1, curBalance + preferences.panDelta)
        
        // Snap to center
        if (curBalance < 0 && newBalance > 0) {
            newBalance = 0
        }
        
        graph.setBalance(newBalance)
        
        // Convert from {-1,1} to percentage
        return round(newBalance * AppConstants.panConversion_audioGraphToUI)
    }
    
    // MARK: Delay unit functions
    
    func getDelayState() -> EffectsUnitState {
        return graph.getDelayState()
    }
    
    func toggleDelayState() -> EffectsUnitState {
        return graph.toggleDelayState()
    }
    
    func getDelayAmount() -> (amount: Float, amountString: String) {
        let amount = graph.getDelayAmount()
        return (amount, ValueFormatter.formatDelayAmount(amount))
    }
    
    func setDelayAmount(_ amount: Float) -> String {
        graph.setDelayAmount(amount)
        return ValueFormatter.formatDelayAmount(amount)
    }
    
    func getDelayTime() -> (time: Double, timeString: String) {
        let time = graph.getDelayTime()
        return (time, ValueFormatter.formatDelayTime(time))
    }
    
    func setDelayTime(_ time: Double) -> String {
        graph.setDelayTime(time)
        return ValueFormatter.formatDelayTime(time)
    }
    
    func getDelayFeedback() -> (percent: Float, percentString: String) {
        let feedback = graph.getDelayFeedback()
        return (feedback, ValueFormatter.formatDelayFeedback(feedback))
    }
    
    func setDelayFeedback(_ percent: Float) -> String {
        graph.setDelayFeedback(percent)
        return ValueFormatter.formatDelayFeedback(percent)
    }
    
    func getDelayLowPassCutoff() -> (cutoff: Float, cutoffString: String) {
        let cutoff = graph.getDelayLowPassCutoff()
        return (cutoff, ValueFormatter.formatDelayLowPassCutoff(cutoff))
    }
    
    func setDelayLowPassCutoff(_ cutoff: Float) -> String {
        graph.setDelayLowPassCutoff(cutoff)
        return ValueFormatter.formatDelayLowPassCutoff(cutoff)
    }
    
    var delayPresets: DelayPresets {
        return graph.delayPresets
    }
    
    func saveDelayPreset(_ presetName: String) {
        graph.saveDelayPreset(presetName)
    }
    
    func applyDelayPreset(_ presetName: String) {
        
        let preset = delayPresets.presetByName(presetName)!
        graph.applyDelayPreset(preset)
    }
    
    // MARK: Filter unit functions
    
    func getFilterState() -> EffectsUnitState {
        return graph.getFilterState()
    }
    
    func toggleFilterState() -> EffectsUnitState{
        return graph.toggleFilterState()
    }
    
    func addFilterBand(_ band: FilterBand) -> Int {
        return graph.addFilterBand(band)
    }
    
    func updateFilterBand(_ index: Int, _ band: FilterBand) {
        graph.updateFilterBand(index, band)
    }
    
    func removeFilterBands(_ indexSet: IndexSet) {
        graph.removeFilterBands(indexSet)
    }
    
    func removeAllFilterBands() {
        graph.removeAllFilterBands()
    }
    
    func allFilterBands() -> [FilterBand] {
        return graph.allFilterBands()
    }
    
    func getFilterBand(_ index: Int) -> FilterBand {
        return graph.getFilterBand(index)
    }
    
    var filterPresets: FilterPresets {
        return graph.filterPresets
    }
    
    func saveFilterPreset(_ presetName: String) {
        graph.saveFilterPreset(presetName)
    }
    
    func applyFilterPreset(_ presetName: String) {
        
        let preset = filterPresets.presetByName(presetName)!
        graph.applyFilterPreset(preset)
    }
}
