//
//  PitchShiftUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A functional contract for a delegate representing the Pitch Shift effects unit.
///
/// Acts as a middleman between the Effects UI and the Pitch Shift effects unit,
/// providing a simplified interface / facade for the UI layer to control the Pitch Shift effects unit.
///
/// - SeeAlso: `PitchShiftUnit`
///
protocol PitchShiftUnitDelegateProtocol: EffectsUnitDelegateProtocol {
    
    // The pitch shift value, in octaves, semitones, and cents.
    var pitch: PitchShift {get set}
//    
//    var minPitch: Float {get}
//    var maxPitch: Float {get}
//    
//    // Increases the pitch shift by a small increment. Returns the new pitch shift value.
//    @discardableResult func increasePitch() -> PitchShift
//    
//    // Increases the pitch shift by one octave. Returns the new pitch shift value.
//    @discardableResult func increasePitchOneOctave() -> PitchShift
//    
//    // Increases the pitch shift by one semitone. Returns the new pitch shift value.
//    @discardableResult func increasePitchOneSemitone() -> PitchShift
//    
//    // Increases the pitch shift by one cent. Returns the new pitch shift value.
//    @discardableResult func increasePitchOneCent() -> PitchShift
//    
//    // Decreases the pitch shift by a small decrement. Returns the new pitch shift value.
//    @discardableResult func decreasePitch() -> PitchShift
//    
//    // Decreases the pitch shift by one octave. Returns the new pitch shift value.
//    @discardableResult func decreasePitchOneOctave() -> PitchShift
//    
//    // Decreases the pitch shift by one semitone. Returns the new pitch shift value.
//    @discardableResult func decreasePitchOneSemitone() -> PitchShift
//    
//    // Decreases the pitch shift by one cent. Returns the new pitch shift value.
//    @discardableResult func decreasePitchOneCent() -> PitchShift
    
    var presets: PitchShiftPresets {get}
}
