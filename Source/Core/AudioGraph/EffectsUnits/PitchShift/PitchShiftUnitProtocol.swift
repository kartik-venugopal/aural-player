//
//  PitchShiftUnitProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an effects unit that applies a "pitch shift" effect to an audio signal, i.e. changes the pitch of the signal.
///
protocol PitchShiftUnitProtocol: EffectsUnitProtocol {
    
    // The pitch shift value, in cents, specified as a value between -2400 and 2400
    // The pitch shift value, in octaves, semitones, and cents.
    var pitch: PitchShift {get set}
    
    var minPitch: Float {get}
    var maxPitch: Float {get}
    
    // Increases the pitch shift by a small increment. Returns the new pitch shift value.
    @discardableResult func increasePitch(by cents: Int) -> PitchShift
    
    // Increases the pitch shift by one octave. Returns the new pitch shift value.
    @discardableResult func increasePitchOneOctave() -> PitchShift
    
    // Increases the pitch shift by one semitone. Returns the new pitch shift value.
    @discardableResult func increasePitchOneSemitone() -> PitchShift
    
    // Increases the pitch shift by one cent. Returns the new pitch shift value.
    @discardableResult func increasePitchOneCent() -> PitchShift
    
    // Decreases the pitch shift by a small decrement. Returns the new pitch shift value.
    @discardableResult func decreasePitch(by cents: Int) -> PitchShift
    
    // Decreases the pitch shift by one octave. Returns the new pitch shift value.
    @discardableResult func decreasePitchOneOctave() -> PitchShift
    
    // Decreases the pitch shift by one semitone. Returns the new pitch shift value.
    @discardableResult func decreasePitchOneSemitone() -> PitchShift
    
    // Decreases the pitch shift by one cent. Returns the new pitch shift value.
    @discardableResult func decreasePitchOneCent() -> PitchShift
    
    var presets: PitchShiftPresets {get}
    
    func applyPreset(_ preset: PitchShiftPreset)
    
    var settingsAsPreset: PitchShiftPreset {get}
}
