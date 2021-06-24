//
//  ValueConversions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct ValueConversions {
    
    // Value conversion constants used when passing values across layers of the app (e.g. the UI uses a range of 0-100 for volume, while the audio graph uses a volume range of 0-1)
    
    static let volume_UIToAudioGraph: Float = (1/100) // Divide by 100
    static let volume_audioGraphToUI: Float = 100     // Multiply by 100
    
    static let pan_UIToAudioGraph: Float = (1/100) // Divide by 100
    static let pan_audioGraphToUI: Float = 100     // Multiply by 100
    
    static let pitch_UIToAudioGraph: Float = 1200     // Multiply by 1200
    static let pitch_audioGraphToUI: Float = (1/1200) // Divide by 1200
}
