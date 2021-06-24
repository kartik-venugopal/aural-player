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

struct AudioGraphDefaults {
    
    static let volume: Float = 0.5
    static let balance: Float = 0
    static let muted: Bool = false
    
    static let masterState: FXUnitState = .active
    
    static let eqState: FXUnitState = .bypassed
    static let eqType: EQType = .tenBand
    static let eqGlobalGain: Float = 0
    static let eqBands: [Float] = Array(repeating: Float(0), count: 10)
    static let eqBandGain: Float = 0
    
    static let pitchState: FXUnitState = .bypassed
    static let pitch: Float = 0
    static let pitchOverlap: Float = 8
    
    static let timeState: FXUnitState = .bypassed
    static let timeStretchRate: Float = 1
    static let timeShiftPitch: Bool = false
    static let timeOverlap: Float = 8
    
    static let reverbState: FXUnitState = .bypassed
    static let reverbSpace: ReverbSpaces = .mediumHall
    static let reverbAmount: Float = 50
    
    static let delayState: FXUnitState = .bypassed
    static let delayAmount: Float = 100
    static let delayTime: Double = 1
    static let delayFeedback: Float = 50
    static let delayLowPassCutoff: Float = 15000

    static let filterState: FXUnitState = .bypassed
    static let filterBandType: FilterBandType = .bandStop
    static let filterBandMinFreq: Float = SoundConstants.audibleRangeMin
    static let filterBandMaxFreq: Float = SoundConstants.subBass_max
    
    static let auState: FXUnitState = .active
}
