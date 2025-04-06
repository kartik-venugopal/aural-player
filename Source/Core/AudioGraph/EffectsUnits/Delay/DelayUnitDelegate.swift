////
////  DelayUnitDelegate.swift
////  Aural
////
////  Copyright © 2025 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////
//import Foundation
//
/////
///// A delegate representing the Delay effects unit.
/////
///// Acts as a middleman between the Effects UI and the Delay effects unit,
///// providing a simplified interface / facade for the UI layer to control the Delay effects unit.
/////
///// - SeeAlso: `DelayUnit`
///// - SeeAlso: `DelayUnitDelegateProtocol`
/////
//class DelayUnitDelegate: EffectsUnitDelegate<DelayUnit>, DelayUnitDelegateProtocol {
//    
//    var presets: DelayPresets {unit.presets}
//    
//    var amount: Float {
//        
//        get {unit.amount}
//        set {unit.amount = newValue}
//    }
//    
//    var formattedAmount: String {ValueFormatter.formatDelayAmount(amount)}
//    
//    var time: Double {
//        
//        get {unit.time}
//        set {unit.time = newValue}
//    }
//    
//    var formattedTime: String {ValueFormatter.formatDelayTime(time)}
//    
//    var feedback: Float {
//        
//        get {unit.feedback}
//        set {unit.feedback = newValue}
//    }
//    
//    var formattedFeedback: String {ValueFormatter.formatDelayFeedback(feedback)}
//    
//    var lowPassCutoff: Float {
//        
//        get {unit.lowPassCutoff}
//        set {unit.lowPassCutoff = newValue}
//    }
//    
//    var formattedLowPassCutoff: String {ValueFormatter.formatDelayLowPassCutoff(lowPassCutoff)}
//}
//
