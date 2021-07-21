//
//  PitchShiftUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate representing the Pitch Shift effects unit.
///
/// Acts as a middleman between the Effects UI and the Pitch Shift effects unit,
/// providing a simplified interface / facade for the UI layer to control the Pitch Shift effects unit.
///
/// - SeeAlso: `PitchShiftUnit`
/// - SeeAlso: `PitchUnitDelegateProtocol`
///
class PitchShiftUnitDelegate: EffectsUnitDelegate<PitchShiftUnit>, PitchShiftUnitDelegateProtocol {
    
    let preferences: SoundPreferences
    
    let minPitch: Float = -2400
    let maxPitch: Float = 2400
    
    init(_ unit: PitchShiftUnit, _ preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(unit)
    }
    
    var pitch: Float {
        
        get {unit.pitch * ValueConversions.pitch_audioGraphToUI}
        set {unit.pitch = newValue * ValueConversions.pitch_UIToAudioGraph}
    }
    
    var formattedPitch: String {
        ValueFormatter.formatPitch(pitch)
    }
    
    var overlap: Float {
        
        get {unit.overlap}
        set {unit.overlap = newValue}
    }
    
    var formattedOverlap: String {
        ValueFormatter.formatOverlap(overlap)
    }
    
    var presets: PitchShiftPresets {unit.presets}
    
    func increasePitch() -> (pitch: Float, pitchString: String) {
        
        ensureActiveAndResetPitch()
        return setUnitPitch(min(maxPitch, unit.pitch + Float(preferences.pitchDelta)))
    }
    
    func decreasePitch() -> (pitch: Float, pitchString: String) {
        
        ensureActiveAndResetPitch()
        return setUnitPitch(max(minPitch, unit.pitch - Float(preferences.pitchDelta)))
    }
    
    private func setUnitPitch(_ value: Float) -> (pitch: Float, pitchString: String) {
        
        unit.pitch = value
        return (pitch, formattedPitch)
    }
    
    private func ensureActiveAndResetPitch() {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase/decrease
        if !unit.isActive {
            
            _ = unit.toggleState()
            unit.pitch = AudioGraphDefaults.pitch
        }
    }
}
