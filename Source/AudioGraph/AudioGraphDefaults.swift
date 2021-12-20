//
//  AudioGraphDefaults.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An enumeration of constants that are used as default values by the audio graph upon initialization when no
/// user-configured value is available.
///
struct AudioGraphDefaults {
    
    static let volume: Float = 0.5
    static let pan: Float = 0
    static let muted: Bool = false
    
    static let masterState: EffectsUnitState = .active
    
    static let eqState: EffectsUnitState = .bypassed
    static let eqType: EQType = .tenBand
    static let eqGlobalGain: Float = 0
    static let eqBands: [Float] = Array(repeating: Float(0), count: 10)
    static let eqBandGain: Float = 0
    
    static let pitchShiftState: EffectsUnitState = .bypassed
    static let pitchShift: Float = 0
    
    static let timeStretchState: EffectsUnitState = .bypassed
    static let timeStretchRate: Float = 1
    static let timeStretchShiftPitch: Bool = false
    static let timeStretchOverlap: Float = 8
    
    static let reverbState: EffectsUnitState = .bypassed
    static let reverbSpace: ReverbSpaces = .mediumHall
    static let reverbAmount: Float = 50
    
    static let delayState: EffectsUnitState = .bypassed
    static let delayAmount: Float = 100
    static let delayTime: Double = 1
    static let delayFeedback: Float = 50
    static let delayLowPassCutoff: Float = 15000

    static let filterState: EffectsUnitState = .bypassed
    
    static let auState: EffectsUnitState = .active
}
