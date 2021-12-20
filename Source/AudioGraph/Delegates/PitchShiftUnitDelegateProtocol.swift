//
//  PitchShiftUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    // The pitch shift value, in cents, specified as a value between -2400 and 2400
    var pitch: PitchShift {get set}
    
    var minPitch: Float {get}
    var maxPitch: Float {get}
    
    var formattedPitch: String {get}
    
    // Increases the pitch shift by a small increment. Returns the new pitch shift value.
    func increasePitch() -> PitchShift
    
    // Decreases the pitch shift by a small decrement. Returns the new pitch shift value.
    func decreasePitch() -> PitchShift
    
    var presets: PitchShiftPresets {get}
}

struct PitchShift {
    
    let octaves: Int
    let semitones: Int
    let cents: Int
    
    var asCents: Int {
        
        octaves * ValueConversions.pitch_octaveToCents +
        semitones * ValueConversions.pitch_semitoneToCents
        + cents
    }
    
    init(octaves: Int, semitones: Int, cents: Int) {
        
        self.octaves = octaves
        self.semitones = semitones
        self.cents = cents
    }
    
    init(fromCents pitchCents: Int) {
        
        var cents = pitchCents
        
        self.octaves = cents / ValueConversions.pitch_octaveToCents
        cents -= octaves * ValueConversions.pitch_octaveToCents
        
        self.semitones = cents / ValueConversions.pitch_semitoneToCents
        cents -= semitones * ValueConversions.pitch_semitoneToCents
        
        self.cents = cents
    }
}
