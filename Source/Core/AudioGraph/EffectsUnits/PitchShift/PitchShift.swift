//
// PitchShift.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

struct PitchShift {
    
    let octaves: Int
    let semitones: Int
    let cents: Int
    
    var asCents: Int {
        
        octaves * ValueConversions.pitch_octaveToCents +
        semitones * ValueConversions.pitch_semitoneToCents +
        cents
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
