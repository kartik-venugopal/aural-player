//
//  PitchShiftUnitProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an effects unit that applies a "pitch shift" effect to an audio signal, i.e. changes the pitch of the signal.
///
protocol PitchShiftUnitProtocol: EffectsUnitProtocol {
    
    // The pitch shift value, in cents, specified as a value between -2400 and 2400
    var pitch: Float {get set}
}
