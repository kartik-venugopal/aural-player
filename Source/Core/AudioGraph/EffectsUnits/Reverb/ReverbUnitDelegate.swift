//
//  ReverbUnitDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A delegate representing the Reverb effects unit.
///
/// Acts as a middleman between the Effects UI and the Reverb effects unit,
/// providing a simplified interface / facade for the UI layer to control the Reverb effects unit.
///
/// - SeeAlso: `ReverbUnit`
/// - SeeAlso: `ReverbUnitDelegateProtocol`
///
class ReverbUnitDelegate: EffectsUnitDelegate<ReverbUnit>, ReverbUnitDelegateProtocol {
    
    var presets: ReverbPresets {unit.presets}
    
    var space: ReverbSpace {
        
        get {unit.space}
        set {unit.space = newValue}
    }
    
    var amount: Float {
        
        get {unit.amount}
        set {unit.amount = newValue}
    }
    
    var formattedAmount: String {
        ValueFormatter.formatReverbAmount(amount)
    }
}
