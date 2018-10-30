/*
    Concrete implementation of AudioGraphDelegateProtocol
 */

import Foundation

class AudioGraphDelegate: AudioGraphDelegateProtocol {
    
    // The actual underlying audio graph
    private let graph: AudioGraphProtocol
    
    // User preferences
    private let preferences: SoundPreferences
    
    init(_ graph: AudioGraphProtocol, _ preferences: SoundPreferences) {
        
        self.graph = graph
        self.preferences = preferences
        
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
    
    func saveMasterPreset(_ presetName: String) {
        graph.saveMasterPreset(presetName)
    }
    
    func applyMasterPreset(_ presetName: String) {
        
        if let preset = MasterPresets.presetByName(presetName) {
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
    
    // MARK: EQ unit functions
    
    func getEQType() -> EQType {
        return graph.getEQType()
    }
    
    func chooseEQType(_ type: EQType) {
        graph.chooseEQType(type)
    }
    
    func getEQState() -> EffectsUnitState {
        return graph.getEQState()
    }
    
    func toggleEQState() -> EffectsUnitState {
        return graph.toggleEQState()
    }
    
    func getEQGlobalGain() -> Float {
        return graph.getEQGlobalGain()
    }
    
    func getEQBands() -> [Int: Float] {
        return graph.getEQBands()
    }
    
    func setEQGlobalGain(_ gain: Float) {
        graph.setEQGlobalGain(gain)
    }
    
    func setEQBand(_ index: Int, gain: Float) {
        graph.setEQBand(index, gain: gain)
    }
    
    func setEQBands(_ bands: [Int : Float]) {
        graph.setEQBands(bands)
    }
    
    func increaseBass() -> [Int : Float] {
        
        ensureEQActive()
        return graph.increaseBass(preferences.eqDelta)
    }
    
    func decreaseBass() -> [Int : Float] {
        
        ensureEQActive()
        return graph.decreaseBass(preferences.eqDelta)
    }
    
    func increaseMids() -> [Int : Float] {
        
        ensureEQActive()
        return graph.increaseMids(preferences.eqDelta)
    }
    
    func decreaseMids() -> [Int : Float] {
        
        ensureEQActive()
        return graph.decreaseMids(preferences.eqDelta)
    }
    
    func increaseTreble() -> [Int : Float] {
        
        ensureEQActive()
        return graph.increaseTreble(preferences.eqDelta)
    }
    
    func decreaseTreble() -> [Int : Float] {
        
        ensureEQActive()
        return graph.decreaseTreble(preferences.eqDelta)
    }
    
    // Activates and resets the EQ unit if it is inactive
    private func ensureEQActive() {
        
        // If the EQ unit is currently inactive, activate it
        if graph.getEQState() != .active {
            _ = graph.toggleEQState()
            
            // Reset to "flat" preset (because it is equivalent to an inactive EQ)
            graph.setEQBands(EQPresets.defaultPreset.bands)
        }
    }
    
    func saveEQPreset(_ presetName: String) {
        graph.saveEQPreset(presetName)
    }
    
    func applyEQPreset(_ presetName: String) {
        
        let preset = EQPresets.presetByName(presetName)
        graph.applyEQPreset(preset)
    }
    
    // MARK: Pitch shift unit functions
    
    // Returns the current state of the pitch shift audio effects unit
    func getPitchState() -> EffectsUnitState {
        return graph.getPitchState()
    }
    
    // Toggles the state of the pitch shift audio effects unit, and returns its new state
    func togglePitchState() -> EffectsUnitState {
        return graph.togglePitchState()
    }
    
    func getPitch() -> (pitch: Float, pitchString: String) {
        
        let pitch = graph.getPitch() * AppConstants.pitchConversion_audioGraphToUI
        return (pitch, ValueFormatter.formatPitch(pitch))
    }
    
    func setPitch(_ pitch: Float, _ ensureActive: Bool = false) -> String {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase
        if ensureActive && graph.getPitchState() != .active {
            
            _ = graph.togglePitchState()
        }
        
        // Convert from octaves (-2, 2) to cents (-2400, 2400)
        graph.setPitch(pitch * AppConstants.pitchConversion_UIToAudioGraph)
        
        return ValueFormatter.formatPitch(pitch)
    }
    
    func getPitchOverlap() -> (overlap: Float, overlapString: String) {
        let overlap = graph.getPitchOverlap()
        return (overlap, ValueFormatter.formatOverlap(overlap))
    }
    
    func setPitchOverlap(_ overlap: Float) -> String {
        graph.setPitchOverlap(overlap)
        return ValueFormatter.formatOverlap(overlap)
    }
    
    func increasePitch() -> (pitch: Float, pitchString: String) {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase
        if graph.getPitchState() != .active {
            
            _ = graph.togglePitchState()
            graph.setPitch(AppDefaults.pitch)
        }
        
        // TODO: Put this value in a constant
        let newPitch = min(2400, graph.getPitch() + Float(preferences.pitchDelta))
        graph.setPitch(newPitch)
        
        // Convert from cents to octaves
        let convPitch = newPitch * AppConstants.pitchConversion_audioGraphToUI
        
        return (convPitch, ValueFormatter.formatPitch(convPitch))
    }
    
    func decreasePitch() -> (pitch: Float, pitchString: String) {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the decrease
        if graph.getPitchState() != .active {
            
            _ = graph.togglePitchState()
            graph.setPitch(AppDefaults.pitch)
        }
        
        // TODO: Put this value in a constant
        let newPitch = max(-2400, graph.getPitch() - Float(preferences.pitchDelta))
        graph.setPitch(newPitch)
        
        // Convert from cents to octaves
        let convPitch = newPitch * AppConstants.pitchConversion_audioGraphToUI
        
        return (convPitch, ValueFormatter.formatPitch(convPitch))
    }
    
    func savePitchPreset(_ presetName: String) {
        graph.savePitchPreset(presetName)
    }
    
    func applyPitchPreset(_ presetName: String) {
        
        let preset = PitchPresets.presetByName(presetName)
        graph.applyPitchPreset(preset)
    }
    
    // MARK: Time stretch unit functions
    
    func getTimeState() -> EffectsUnitState {
        return graph.getTimeState()
    }
    
    func toggleTimeState() -> EffectsUnitState {
        return graph.toggleTimeState()
    }
   
    func getTimePitchShift() -> String {
        return ValueFormatter.formatPitch(graph.getTimePitchShift() * AppConstants.pitchConversion_audioGraphToUI)
    }
    
    func isTimePitchShift() -> Bool {
        return graph.isTimePitchShift()
    }
    
    func toggleTimePitchShift() -> Bool {
        return graph.toggleTimePitchShift()
    }
   
    func getTimeRate() -> (rate: Float, rateString: String) {
        let rate = graph.getTimeStretchRate()
        return (rate, ValueFormatter.formatTimeStretchRate(rate))
    }
    
    func setTimeStretchRate(_ rate: Float) -> String {
        
        graph.setTimeStretchRate(rate)
        return ValueFormatter.formatTimeStretchRate(rate)
    }
    
    func increaseRate() -> (rate: Float, rateString: String) {
        
        // If the time unit is currently inactive, start at default playback rate, before the increase
        if graph.getTimeState() != .active {
            
            _ = graph.toggleTimeState()
            graph.setTimeStretchRate(AppDefaults.timeStretchRate)
        }
        
        // Volume is increased by an amount set in the user preferences
        
        let curRate = graph.getTimeStretchRate()
        
        // TODO: Put this value in a constant
        let newRate = min(4, curRate + preferences.timeDelta)
        graph.setTimeStretchRate(newRate)
        
        return (newRate, ValueFormatter.formatTimeStretchRate(newRate))
    }
    
    func decreaseRate() -> (rate: Float, rateString: String) {
        
        // If the time unit is currently inactive, start at default playback rate, before the decrease
        if graph.getTimeState() != .active {
            
            _ = graph.toggleTimeState()
            graph.setTimeStretchRate(AppDefaults.timeStretchRate)
        }
        
        // Volume is increased by an amount set in the user preferences
        
        let curRate = graph.getTimeStretchRate()
        
        // TODO: Put this value in a constant
        let newRate = max(0.25, curRate - preferences.timeDelta)
        graph.setTimeStretchRate(newRate)
        
        return (newRate, ValueFormatter.formatTimeStretchRate(newRate))
    }
    
    func getTimeOverlap() -> (overlap: Float, overlapString: String) {
        let overlap = graph.getTimeOverlap()
        return (overlap, ValueFormatter.formatOverlap(overlap))
    }
    
    func setTimeOverlap(_ overlap: Float) -> String {
        graph.setTimeOverlap(overlap)
        return ValueFormatter.formatOverlap(overlap)
    }
    
    func saveTimePreset(_ presetName: String) {
        graph.saveTimePreset(presetName)
    }
    
    func applyTimePreset(_ presetName: String) {
        
        let preset = TimePresets.presetByName(presetName)
        graph.applyTimePreset(preset)
    }
    
    // MARK: Reverb unit functions
    
    func getReverbState() -> EffectsUnitState {
        return graph.getReverbState()
    }
    
    func toggleReverbState() -> EffectsUnitState {
        return graph.toggleReverbState()
    }
    
    func getReverbSpace() -> ReverbSpaces {
        return graph.getReverbSpace()
    }
    
    func setReverbSpace(_ space: ReverbSpaces) {
        graph.setReverbSpace(space)
    }
    
    func getReverbAmount() -> (amount: Float, amountString: String) {
        let amount = graph.getReverbAmount()
        return (amount, ValueFormatter.formatReverbAmount(amount))
    }
    
    func setReverbAmount(_ amount: Float) -> String {
        graph.setReverbAmount(amount)
        return ValueFormatter.formatReverbAmount(amount)
    }
    
    func saveReverbPreset(_ presetName: String) {
        graph.saveReverbPreset(presetName)
    }
    
    func applyReverbPreset(_ presetName: String) {
        
        let preset = ReverbPresets.presetByName(presetName)!
        graph.applyReverbPreset(preset)
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
    
    func saveDelayPreset(_ presetName: String) {
        graph.saveDelayPreset(presetName)
    }
    
    func applyDelayPreset(_ presetName: String) {
        
        let preset = DelayPresets.presetByName(presetName)
        graph.applyDelayPreset(preset)
    }
    
    // MARK: Filter unit functions
    
    func getFilterState() -> EffectsUnitState {
        return graph.getFilterState()
    }
    
    func toggleFilterState() -> EffectsUnitState{
        return graph.toggleFilterState()
    }
    
    func getFilterBassBand() -> (min: Float, max: Float, rangeString: String) {
        let minMax = graph.getFilterBassBand()
        return (minMax.min, minMax.max, ValueFormatter.formatFilterFrequencyRange(minMax.min, minMax.max))
    }
    
    func setFilterBassBand(_ min: Float, _ max: Float) -> String {
        graph.setFilterBassBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func getFilterMidBand() -> (min: Float, max: Float, rangeString: String) {
        let minMax = graph.getFilterMidBand()
        return (minMax.min, minMax.max, ValueFormatter.formatFilterFrequencyRange(minMax.min, minMax.max))
    }
    
    func setFilterMidBand(_ min: Float, _ max: Float) -> String {
        graph.setFilterMidBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func getFilterTrebleBand() -> (min: Float, max: Float, rangeString: String) {
        let minMax = graph.getFilterTrebleBand()
        return (minMax.min, minMax.max, ValueFormatter.formatFilterFrequencyRange(minMax.min, minMax.max))
    }
    
    func setFilterTrebleBand(_ min: Float, _ max: Float) -> String {
        graph.setFilterTrebleBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func saveFilterPreset(_ presetName: String) {
        graph.saveFilterPreset(presetName)
    }
    
    func applyFilterPreset(_ presetName: String) {
        
        let preset = FilterPresets.presetByName(presetName)
        graph.applyFilterPreset(preset)
    }
}
