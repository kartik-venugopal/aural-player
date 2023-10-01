//
//  BassFFTData.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import Accelerate

class BassFFTData {
    
    let maxBassFrequency: Float = 160
    
    var peakBassMagnitude: Float = 0
    var numBassBands: vDSP_Length = 1
    
    func setUp(for fft: FFT) {
        numBassBands = vDSP_Length(fft.frequencies.firstIndex(where: {$0 > maxBassFrequency}) ?? 1)
    }
    
    // Temp variable for frequent reuse by update()
    var magnitude: Float = 0
    
    func update(with fft: FFT) {
        
        vDSP_maxv(fft.normalizedMagnitudes, 1, &magnitude, numBassBands)
        peakBassMagnitude = magnitude.clamp(to: fft.magnitudeRange)
    }
}
