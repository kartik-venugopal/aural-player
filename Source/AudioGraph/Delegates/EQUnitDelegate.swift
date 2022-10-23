//
//  EQUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate representing the Equalizer effects unit.
///
/// Acts as a middleman between the Effects UI and the Equalizer effects unit,
/// providing a simplified interface / facade for the UI layer to control the Equalizer effects unit.
///
/// - SeeAlso: `EQUnitDelegateProtocol`
/// - SeeAlso: `EQUnit`
///
class EQUnitDelegate: EffectsUnitDelegate<EQUnit>, EQUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    init(for unit: EQUnit, preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(for: unit)
    }
    
    var globalGain: Float {
        
        get {unit.globalGain}
        set {unit.globalGain = newValue}
    }
    
    var bands: [Float] {
        
        get {unit.bands}
        set {unit.bands = newValue}
    }
    
    var presets: EQPresets {unit.presets}
    
    /// Gets / sets the gain for the band at the given index.
    subscript(_ index: Int) -> Float {
        
        get {unit[index]}
        set {unit[index] = newValue}
    }
    
    func increaseBass() -> [Float] {
        
        ensureEQActive()
        return unit.increaseBass(by: preferences.eqDelta)
    }
    
    func decreaseBass() -> [Float] {
        
        ensureEQActive()
        return unit.decreaseBass(by: preferences.eqDelta)
    }
    
    func increaseMids() -> [Float] {
        
        ensureEQActive()
        return unit.increaseMids(by: preferences.eqDelta)
    }
    
    func decreaseMids() -> [Float] {
        
        ensureEQActive()
        return unit.decreaseMids(by: preferences.eqDelta)
    }
    
    func increaseTreble() -> [Float] {
        
        ensureEQActive()
        return unit.increaseTreble(by: preferences.eqDelta)
    }
    
    func decreaseTreble() -> [Float] {
        
        ensureEQActive()
        return unit.decreaseTreble(by: preferences.eqDelta)
    }
    
    private func ensureEQActive() {
        
        // If the EQ unit is currently inactive, activate it
        if !unit.isActive {
            
            _ = toggleState()
            
            // Reset to "flat" preset (because it is equivalent to an inactive EQ)
            bands = presets.defaultPreset.bands
        }
    }
}
