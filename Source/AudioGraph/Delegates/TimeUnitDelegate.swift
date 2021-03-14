import Foundation

class TimeUnitDelegate: FXUnitDelegate<TimeUnit>, TimeUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    var rate: Float {
        
        get {return unit.rate}
        set(newValue) {unit.rate = newValue}
    }
    
    var effectiveRate: Float {
        return isActive ? rate : 1.0
    }
    
    var formattedRate: String {return ValueFormatter.formatTimeStretchRate(rate)}
    
    var overlap: Float {
        
        get {return unit.overlap}
        set(newValue) {unit.overlap = newValue}
    }
    
    var formattedOverlap: String {return ValueFormatter.formatOverlap(overlap)}
    
    var shiftPitch: Bool {
        
        get {return unit.shiftPitch}
        set(newValue) {unit.shiftPitch = newValue}
    }
    
    var pitch: Float {return unit.pitch}
    
    var formattedPitch: String {return ValueFormatter.formatPitch(pitch * AppConstants.ValueConversions.pitch_audioGraphToUI)}
    
    var presets: TimePresets {return unit.presets}
    
    init(_ unit: TimeUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
    }
    
    func increaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is increased by an amount set in the user preferences
        // TODO: Put this value in a constant
        rate = min(4, rate + preferences.timeDelta)
        
        return (rate, formattedRate)
    }
    
    func decreaseRate() -> (rate: Float, rateString: String) {
        
        ensureActiveAndResetRate()
        
        // Rate is decreased by an amount set in the user preferences
        // TODO: Put this value in a constant
        rate = max(0.25, rate - preferences.timeDelta)
        
        return (rate, formattedRate)
    }
    
    private func ensureActiveAndResetRate() {
        
        if state != .active {
            
            _ = toggleState()
            
            // If the time unit is currently inactive, start at default playback rate, before the increase
            rate = AppDefaults.timeStretchRate
        }
    }
}
