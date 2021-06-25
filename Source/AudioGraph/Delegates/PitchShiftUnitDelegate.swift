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
    
    var pitch: Float {
        
        get {unit.pitch * ValueConversions.pitch_audioGraphToUI}
        set {unit.pitch = newValue * ValueConversions.pitch_UIToAudioGraph}
    }
    
    var formattedPitch: String {
        return ValueFormatter.formatPitch(pitch)
    }
    
    var overlap: Float {
        
        get {unit.overlap}
        set {unit.overlap = newValue}
    }
    
    var formattedOverlap: String {
        return ValueFormatter.formatOverlap(overlap)
    }
    
    var presets: PitchPresets {return unit.presets}
    
    init(_ unit: PitchShiftUnit, _ preferences: SoundPreferences) {
        
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
            unit.pitch = AudioGraphDefaults.pitch
        }
    }
}
