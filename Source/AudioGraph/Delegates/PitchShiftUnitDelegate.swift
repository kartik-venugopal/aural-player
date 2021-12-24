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
    private lazy var pitchRange: ClosedRange<Float> = minPitch...maxPitch
    
    init(for unit: PitchShiftUnit, preferences: SoundPreferences) {
        
        self.preferences = preferences
        super.init(for: unit)
    }
    
    var pitch: PitchShift {
        
        get {PitchShift(fromCents: unit.pitch)}
        set {unit.pitch = newValue.asCentsFloat}
    }
    
    var presets: PitchShiftPresets {unit.presets}
    
    func increasePitch() -> PitchShift {
        
        ensureActiveAndResetPitch()
        return setUnitPitch((unit.pitch + Float(preferences.pitchDelta)).clamp(to: pitchRange))
    }
    
    func increasePitchOneOctave() -> PitchShift {
        setUnitPitch((unit.pitch + Float(ValueConversions.pitch_octaveToCents)).clamp(to: pitchRange))
    }
    
    func increasePitchOneSemitone() -> PitchShift {
        setUnitPitch((unit.pitch + Float(ValueConversions.pitch_semitoneToCents)).clamp(to: pitchRange))
    }
    
    func increasePitchOneCent() -> PitchShift {
        setUnitPitch((unit.pitch + Float(1)).clamp(to: pitchRange))
    }
    
    func decreasePitch() -> PitchShift {
        
        ensureActiveAndResetPitch()
        return setUnitPitch((unit.pitch - Float(preferences.pitchDelta)).clamp(to: pitchRange))
    }
    
    func decreasePitchOneOctave() -> PitchShift {
        setUnitPitch((unit.pitch - Float(ValueConversions.pitch_octaveToCents)).clamp(to: pitchRange))
    }
    
    func decreasePitchOneSemitone() -> PitchShift {
        setUnitPitch((unit.pitch - Float(ValueConversions.pitch_semitoneToCents)).clamp(to: pitchRange))
    }
    
    func decreasePitchOneCent() -> PitchShift {
        setUnitPitch((unit.pitch - Float(1)).clamp(to: pitchRange))
    }
    
    private func setUnitPitch(_ value: Float) -> PitchShift {
        
        unit.pitch = value
        return pitch
    }
    
    private func ensureActiveAndResetPitch() {
        
        // If the pitch unit is currently inactive, start at default pitch offset, before the increase/decrease
        if !unit.isActive {
            
            _ = unit.toggleState()
            unit.pitch = AudioGraphDefaults.pitchShift
        }
    }
}
