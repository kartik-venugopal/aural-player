//
//  WaveformScale.swift
//  Periphony: Spatial Audio Player
//  Copyright © Oli Larkin Plug-ins Ltd. 2022. All rights reserved.
//  Developed by Kartik Venugopal
//

import Foundation
import Accelerate

///
/// Enumerates all the waveform scaling options.
///
enum WaveformScale: Equatable, Codable {
    
    /// Waveform is rendered using a linear scale.
    case linear

    ///
    /// Waveform is rendered using a logarithmic scale.
    ///
    /// - Parameter noiseFloor:     The "zero" level (in dB).
    ///
    case logarithmic(noiseFloor: CGFloat)

    ///
    /// Equality comparison of 2 ``WaveformScale`` instances, for conformance to ``Equatable``.
    ///
    /// See http://stackoverflow.com/questions/24339807/how-to-test-equality-of-swift-enums-with-associated-values
    ///
    static func ==(lhs: WaveformScale, rhs: WaveformScale) -> Bool {
        
        switch lhs {
        
        case .linear:
            
            if case .linear = rhs {
                return true
            }
            
        case .logarithmic(let lhsNoiseFloor):
            
            if case .logarithmic(let rhsNoiseFloor) = rhs {
                return lhsNoiseFloor == rhsNoiseFloor
            }
        }
        
        return false
    }

    /// Noise floor.
    var floorValue: CGFloat {
        
        switch self {
        
        case .linear:                       return 0
            
        case .logarithmic(let noiseFloor):  return noiseFloor
            
        }
    }
}
