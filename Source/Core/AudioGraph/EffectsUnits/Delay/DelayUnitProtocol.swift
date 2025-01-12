//
//  DelayUnitProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an effects unit that produces an echo effect by repeatedly
/// replaying the original input signal after a configurable delay. Each replayed
/// signal decays over time, creating a repeating and decaying echo.
///
protocol DelayUnitProtocol: EffectsUnitProtocol {
    
    var amount: Float {get set}
    
    var time: Double {get set}
    
    var feedback: Float {get set}
    
    var lowPassCutoff: Float {get set}
}
