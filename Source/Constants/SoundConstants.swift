//
//  SoundConstants.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct SoundConstants {

    // Audible range (frequencies)
    static let audibleRangeMin: Float = 20      // 20 Hz
    static let audibleRangeMax: Float = 20000   // 20 KHz
    
    static let eq10BandFrequencies: [Float] = [31, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    static let eq15BandFrequencies: [Float] = [25, 40, 63, 100, 160, 250, 400, 630, 1000, 1600, 2500, 4000, 6300, 10000, 16000]
    
    static let subBass_min: Float = audibleRangeMin
    static let subBass_max: Float = 60
    
    // Frequency ranges for each of the 3 bands (in Hz)
    static let bass_min: Float = audibleRangeMin
    static let bass_max: Float = 250
    
    static let mid_min: Float = bass_max
    static let mid_max: Float = 4000
}
