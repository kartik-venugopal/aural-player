import Foundation

class EQUnitDelegate: FXUnitDelegate<EQUnit>, EQUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    init(_ unit: EQUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
    }
    
    var type: EQType {
        
        get {return unit.type}
        set(newType) {unit.type = newType}
    }
    
    var globalGain: Float {
        
        get {return unit.globalGain}
        set(newValue) {unit.globalGain = newValue}
    }
    
    var bands: [Int: Float] {
        
        get {return unit.bands}
        set(newValue) {unit.bands = newValue}
    }
    
    var sync: Bool {
        
        get {return unit.sync}
        set(newValue) {unit.sync = newValue}
    }
    
    var presets: EQPresets {return unit.presets}
    
    func setBand(_ index: Int, gain: Float) {
        unit.setBand(index, gain: gain)
    }
    
    func increaseBass() -> [Int : Float] {
        
        ensureEQActive()
        return unit.increaseBass(preferences.eqDelta)
    }
    
    func decreaseBass() -> [Int : Float] {
        
        ensureEQActive()
        return unit.decreaseBass(preferences.eqDelta)
    }
    
    func increaseMids() -> [Int : Float] {
        
        ensureEQActive()
        return unit.increaseMids(preferences.eqDelta)
    }
    
    func decreaseMids() -> [Int : Float] {
        
        ensureEQActive()
        return unit.decreaseMids(preferences.eqDelta)
    }
    
    func increaseTreble() -> [Int : Float] {
        
        ensureEQActive()
        return unit.increaseTreble(preferences.eqDelta)
    }
    
    func decreaseTreble() -> [Int : Float] {
        
        ensureEQActive()
        return unit.decreaseTreble(preferences.eqDelta)
    }
    
    private func ensureEQActive() {
        
        // If the EQ unit is currently inactive, activate it
        if state != .active {
            
            _ = toggleState()
            
            // Reset to "flat" preset (because it is equivalent to an inactive EQ)
            bands = EQPresets.defaultPreset.bands
        }
    }
    
    override func savePreset(_ presetName: String) {
        unit.savePreset(presetName)
    }
    
    override func applyPreset(_ presetName: String) {
        unit.applyPreset(presetName)
    }
}
