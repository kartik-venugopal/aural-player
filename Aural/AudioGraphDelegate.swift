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
        
        if (preferences.volumeOnStartup == .specific) {
            graph.setVolume(preferences.startupVolumeValue)
            graph.unmute()
        }
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
    
    func toggleEQBypass() -> Bool {
        return graph.toggleEQBypass()
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
        return graph.increaseBass()
    }
    
    func decreaseBass() -> [Int : Float] {
        
        ensureEQActive()
        return graph.decreaseBass()
    }
    
    func increaseMids() -> [Int : Float] {
        
        ensureEQActive()
        return graph.increaseMids()
    }
    
    func decreaseMids() -> [Int : Float] {
        
        ensureEQActive()
        return graph.decreaseMids()
    }
    
    func increaseTreble() -> [Int : Float] {
        
        ensureEQActive()
        return graph.increaseTreble()
    }
    
    func decreaseTreble() -> [Int : Float] {
        
        ensureEQActive()
        return graph.decreaseTreble()
    }
    
    private func ensureEQActive() {
        
        // If the EQ unit is currently inactive, activate it
        if graph.isEQBypass() {
            _ = graph.toggleEQBypass()
        }
    }
    
    func togglePitchBypass() -> Bool {
        return graph.togglePitchBypass()
    }
    
    func isPitchBypass() -> Bool {
        return graph.isPitchBypass()
    }
    
    func setPitch(_ pitch: Float) -> String {
        
        // Convert from octaves (-2, 2) to cents (-2400, 2400)
        graph.setPitch(pitch * AppConstants.pitchConversion_UIToAudioGraph)
        
        return ValueFormatter.formatPitch(pitch)
    }
    
    func setPitchOverlap(_ overlap: Float) -> String {
        graph.setPitchOverlap(overlap)
        return ValueFormatter.formatOverlap(overlap)
    }
    
    func increasePitch() -> (pitch: Float, pitchString: String) {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase
        if graph.isPitchBypass() {
            _ = graph.togglePitchBypass()
            graph.setPitch(AppDefaults.pitch)
        }
        
        let newPitch = min(2400, graph.getPitch() + 100)
        graph.setPitch(newPitch)
        
        // Convert from cents to octaves
        let convPitch = newPitch * AppConstants.pitchConversion_audioGraphToUI
        
        return (convPitch, ValueFormatter.formatPitch(convPitch))
    }
    
    func decreasePitch() -> (pitch: Float, pitchString: String) {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the decrease
        if graph.isPitchBypass() {
            _ = graph.togglePitchBypass()
            graph.setPitch(AppDefaults.pitch)
        }
        
        let newPitch = max(-2400, graph.getPitch() - 100)
        graph.setPitch(newPitch)
        
        // Convert from cents to octaves
        let convPitch = newPitch * AppConstants.pitchConversion_audioGraphToUI
        
        return (convPitch, ValueFormatter.formatPitch(convPitch))
    }
    
    func toggleTimeBypass() -> Bool {
        return graph.toggleTimeBypass()
    }
    
    func isTimeBypass() -> Bool {
        return graph.isTimeBypass()
    }
    
    func setTimeStretchRate(_ rate: Float) -> String {
        graph.setTimeStretchRate(rate)
        return ValueFormatter.formatTimeStretchRate(rate)
    }
    
    func increaseRate() -> (rate: Float, rateString: String) {
        
        // If the time unit is currently inactive, start at default playback rate, before the increase
        if graph.isTimeBypass() {
            _ = graph.toggleTimeBypass()
            graph.setTimeStretchRate(AppDefaults.timeStretchRate)
        }
        
        // Volume is increased by an amount set in the user preferences
        
        let curRate = graph.getTimeStretchRate()
        let newRate = min(4, curRate + 0.05)
        graph.setTimeStretchRate(newRate)
        
        return (newRate, ValueFormatter.formatTimeStretchRate(newRate))
    }
    
    func decreaseRate() -> (rate: Float, rateString: String) {
        
        // If the time unit is currently inactive, start at default playback rate, before the decrease
        if graph.isTimeBypass() {
            _ = graph.toggleTimeBypass()
            graph.setTimeStretchRate(AppDefaults.timeStretchRate)
        }
        
        // Volume is increased by an amount set in the user preferences
        
        let curRate = graph.getTimeStretchRate()
        let newRate = max(0.25, curRate - 0.05)
        graph.setTimeStretchRate(newRate)
        
        return (newRate, ValueFormatter.formatTimeStretchRate(newRate))
    }
    
    func setTimeOverlap(_ overlap: Float) -> String {
        graph.setTimeOverlap(overlap)
        return ValueFormatter.formatOverlap(overlap)
    }
    
    func toggleReverbBypass() -> Bool {
        return graph.toggleReverbBypass()
    }
    
    func setReverb(_ preset: ReverbPresets) {
        graph.setReverb(preset)
    }
    
    func setReverbAmount(_ amount: Float) -> String {
        graph.setReverbAmount(amount)
        return ValueFormatter.formatReverbAmount(amount)
    }
    
    func toggleDelayBypass() -> Bool {
        return graph.toggleDelayBypass()
    }
    
    func setDelayAmount(_ amount: Float) -> String {
        graph.setDelayAmount(amount)
        return ValueFormatter.formatDelayAmount(amount)
    }
    
    func setDelayTime(_ time: Double) -> String {
        graph.setDelayTime(time)
        return ValueFormatter.formatDelayTime(time)
    }
    
    func setDelayFeedback(_ percent: Float) -> String {
        graph.setDelayFeedback(percent)
        return ValueFormatter.formatDelayFeedback(percent)
    }
    
    func setDelayLowPassCutoff(_ cutoff: Float) -> String {
        graph.setDelayLowPassCutoff(cutoff)
        return ValueFormatter.formatDelayLowPassCutoff(cutoff)
    }
    
    func toggleFilterBypass() -> Bool {
        return graph.toggleFilterBypass()
    }
    
    func setFilterBassBand(_ min: Float, _ max: Float) -> String {
        graph.setFilterBassBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func setFilterMidBand(_ min: Float, _ max: Float) -> String {
        graph.setFilterMidBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
    
    func setFilterTrebleBand(_ min: Float, _ max: Float) -> String {
        graph.setFilterTrebleBand(min, max)
        return ValueFormatter.formatFilterFrequencyRange(min, max)
    }
}
