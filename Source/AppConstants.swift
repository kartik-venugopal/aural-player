//
//  AppConstants.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa
import AVFoundation

/*
    A collection of app-level constants
*/
struct AppConstants {
    
    struct Sound {

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
    
    struct ValueConversions {
        
        // Value conversion constants used when passing values across layers of the app (e.g. the UI uses a range of 0-100 for volume, while the audio graph uses a volume range of 0-1)
        
        static let volume_UIToAudioGraph: Float = (1/100) // Divide by 100
        static let volume_audioGraphToUI: Float = 100     // Multiply by 100
        
        static let pan_UIToAudioGraph: Float = (1/100) // Divide by 100
        static let pan_audioGraphToUI: Float = 100     // Multiply by 100
        
        static let pitch_UIToAudioGraph: Float = 1200     // Multiply by 1200
        static let pitch_audioGraphToUI: Float = (1/1200) // Divide by 1200
    }
}
