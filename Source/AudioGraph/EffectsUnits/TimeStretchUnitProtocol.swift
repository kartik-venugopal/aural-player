//
//  TimeStretchUnitProtocol.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an effects unit that applies a "time stretch" effect to an audio signal,
/// i.e. changes the playback rate of the signal. Optionally, the pitch of the input signal can also be
/// adjusted, thus syncing the pitch and playback rate.
///
protocol TimeStretchUnitProtocol: EffectsUnitProtocol {
    
    // The playback rate, specified as a value between 1/32 and 32
    var rate: Float {get set}
    
    // An option to alter the pitch of the sound, along with the rate
    var shiftPitch: Bool {get set}
    
    // Returns the pitch offset of the time audio effects unit. If the pitch shift option of the unit is enabled, this value will range between -2400 and +2400 cents. It will be 0 otherwise (i.e. pitch unaltered).
    var pitch: Float {get}
}
