//
//  TimeStretchUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A functional contract for a delegate representing the Time Stretch effects unit.
///
/// Acts as a middleman between the Effects UI and the Time Stretch effects unit,
/// providing a simplified interface / facade for the UI layer to control the Time Stretch effects unit.
///
/// - SeeAlso: `TimeStretchUnit`
///
protocol TimeStretchUnitDelegateProtocol: EffectsUnitDelegateProtocol {
    
    var rate: Float {get set}
    
    var effectiveRate: Float {get}
    
    var formattedRate: String {get}
    
    var overlap: Float {get set}
    
    var formattedOverlap: String {get}
    
    var shiftPitch: Bool {get set}
    
    var pitch: Float {get}
    
    var formattedPitch: String {get}
    
    // Increases the playback rate by a small increment. Returns the new playback rate value.
    func increaseRate() -> (rate: Float, rateString: String)
    
    // Decreases the playback rate by a small decrement. Returns the new playback rate value.
    func decreaseRate() -> (rate: Float, rateString: String)
    
    var presets: TimeStretchPresets {get}
}
