//
//  EQUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A functional contract for a delegate representing the Equalizer effects unit.
///
/// Acts as a middleman between the Effects UI and the Equalizer effects unit,
/// providing a simplified interface / facade for the UI layer to control the Equalizer effects unit.
///
/// - SeeAlso: `EQUnit`
///
protocol EQUnitDelegateProtocol: EffectsUnitDelegateProtocol {
    
    var globalGain: Float {get set}
    
    var bands: [Float] {get set}
    
    // Gets / sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    subscript(_ index: Int) -> Float {get set}
    
    // Increases the equalizer bass band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    @discardableResult func increaseBass() -> [Float]
    
    // Decreases the equalizer bass band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    @discardableResult func decreaseBass() -> [Float]
    
    // Increases the equalizer mid-frequency band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    @discardableResult func increaseMids() -> [Float]
    
    // Decreases the equalizer mid-frequency band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    @discardableResult func decreaseMids() -> [Float]
    
    // Increases the equalizer treble band gains by a small increment, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    @discardableResult func increaseTreble() -> [Float]
    
    // Decreases the equalizer treble band gains by a small decrement, activating and resetting the EQ unit if it is inactive. Returns all EQ band gain values, mapped by index.
    @discardableResult func decreaseTreble() -> [Float]
    
    var presets: EQPresets {get}
}
