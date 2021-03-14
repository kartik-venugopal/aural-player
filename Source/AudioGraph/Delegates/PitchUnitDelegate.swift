import Foundation

class PitchUnitDelegate: FXUnitDelegate<PitchUnit>, PitchUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    var pitch: Float {
        
        get {return unit.pitch * AppConstants.ValueConversions.pitch_audioGraphToUI}
        set(newValue) {unit.pitch = newValue * AppConstants.ValueConversions.pitch_UIToAudioGraph}
    }
    
    var formattedPitch: String {
        return ValueFormatter.formatPitch(pitch)
    }
    
    var overlap: Float {
        
        get {return unit.overlap}
        set(newValue) {unit.overlap = newValue}
    }
    
    var formattedOverlap: String {
        return ValueFormatter.formatOverlap(overlap)
    }
    
    var presets: PitchPresets {return unit.presets}
    
    init(_ unit: PitchUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
    }
    
    func increasePitch() -> (pitch: Float, pitchString: String) {
        ensureActiveAndResetPitch()
        return setUnitPitch(min(2400, unit.pitch + Float(preferences.pitchDelta)))
    }
    
    func decreasePitch() -> (pitch: Float, pitchString: String) {
        ensureActiveAndResetPitch()
        return setUnitPitch(max(-2400, unit.pitch - Float(preferences.pitchDelta)))
    }
    
    private func setUnitPitch(_ value: Float) -> (pitch: Float, pitchString: String) {
        unit.pitch = value
        return (pitch, formattedPitch)
    }
    
    private func ensureActiveAndResetPitch() {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase/decrease
        if state != .active {
            
            _ = unit.toggleState()
            unit.pitch = AppDefaults.pitch
        }
    }
}
