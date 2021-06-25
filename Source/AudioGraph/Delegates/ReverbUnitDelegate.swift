//
//  ReverbUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class ReverbUnitDelegate: EffectsUnitDelegate<ReverbUnit>, ReverbUnitDelegateProtocol {
    
    var presets: ReverbPresets {return unit.presets}
    
    var space: ReverbSpaces {
        
        get {unit.space}
        set {unit.space = newValue}
    }
    
    var amount: Float {
        
        get {unit.amount}
        set {unit.amount = newValue}
    }
    
    var formattedAmount: String {
        return ValueFormatter.formatReverbAmount(amount)
    }
}
