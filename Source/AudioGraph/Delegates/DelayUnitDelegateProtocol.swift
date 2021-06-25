//
//  DelayUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A functional contract for a delegate representing the Delay effects unit.
///
/// Acts as a middleman between the Effects UI and the Delay effects unit,
/// providing a simplified interface / facade for the UI layer to control the Delay effects unit.
///
/// - SeeAlso: `DelayUnit`
///
protocol DelayUnitDelegateProtocol: EffectsUnitDelegateProtocol {
    
    var amount: Float {get set}
    
    var formattedAmount: String {get}
    
    var time: Double {get set}
    
    var formattedTime: String {get}
    
    var feedback: Float {get set}
    
    var formattedFeedback: String {get}
    
    var lowPassCutoff: Float {get set}
    
    var formattedLowPassCutoff: String {get}
    
    var presets: DelayPresets {get}
}
