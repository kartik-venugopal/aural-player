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
    
    var minPitch: Float {get}
    var maxPitch: Float {get}
    
    // Increases the pitch shift by a small increment. Returns the new pitch shift value.
    @discardableResult func increasePitch() -> PitchShift
    
    // Increases the pitch shift by one octave. Returns the new pitch shift value.
    @discardableResult func increasePitchOneOctave() -> PitchShift
    
    // Increases the pitch shift by one semitone. Returns the new pitch shift value.
    @discardableResult func increasePitchOneSemitone() -> PitchShift
    
    // Increases the pitch shift by one cent. Returns the new pitch shift value.
    @discardableResult func increasePitchOneCent() -> PitchShift
    
    // Decreases the pitch shift by a small decrement. Returns the new pitch shift value.
    @discardableResult func decreasePitch() -> PitchShift
    
    // Decreases the pitch shift by one octave. Returns the new pitch shift value.
    @discardableResult func decreasePitchOneOctave() -> PitchShift
    
    // Decreases the pitch shift by one semitone. Returns the new pitch shift value.
    @discardableResult func decreasePitchOneSemitone() -> PitchShift
    
    // Decreases the pitch shift by one cent. Returns the new pitch shift value.
    @discardableResult func decreasePitchOneCent() -> PitchShift
    
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
    
    var asCentsFloat: Float {
        Float(asCents)
    }
    
    init(octaves: Int = 0, semitones: Int = 0, cents: Int = 0) {
        
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
    
    init(fromCents pitchCents: Float) {
        self.init(fromCents: pitchCents.roundedInt)
    }
    
    var formattedString: String {
        
        if octaves != 0 {
            
            if semitones != 0 {
                
                return cents != 0 ?
                "\(octavesString) \(semitonesString) \(centsString)" :
                "\(octavesString) \(semitonesString)"
                
            } else {
                
                return cents != 0 ?
                "\(octavesString) \(centsString)" :
                "\(octavesString)"
            }
            
        } else {
            
            if semitones != 0 {
                
                return cents != 0 ?
                "\(semitonesString) \(centsString)" :
                "\(semitonesString)"
                
            } else {
                
                return cents != 0 ?
                "\(centsString)" :
                "0"
            }
        }
    }
    
    var octavesString: String {
        "\(octaves.signedString) \(abs(octaves) == 1 ? "octave" : "octaves")"
    }
    
    var semitonesString: String {
        "\(semitones.signedString) \(abs(semitones) == 1 ? "semitone" : "semitones")"
    }
    
    var centsString: String {
        "\(cents.signedString) \(abs(cents) == 1 ? "cent" : "cents")"
    }
}
