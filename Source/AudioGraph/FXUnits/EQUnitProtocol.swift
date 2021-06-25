//
//  EQUnitProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an Equalizer effects unit that controls the volume of sound in
/// different frequency bands. So, it can emphasize or suppress bass (low frequencies),
/// vocals (mid frequencies), or treble (high frequencies).
///
protocol EQUnitProtocol: EffectsUnitProtocol {
    
    var type: EQType {get set}
    
    var globalGain: Float {get set}
    
    var bands: [Float] {get set}
    
    // Sets the gain value of a single equalizer band identified by index (the lowest frequency band has an index of 0).
    subscript(_ index: Int) -> Float {get set}
    
    // Increases the equalizer bass band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseBass(_ increment: Float) -> [Float]
    
    // Decreases the equalizer bass band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseBass(_ decrement: Float) -> [Float]
    
    // Increases the equalizer mid-frequency band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseMids(_ increment: Float) -> [Float]
    
    // Decreases the equalizer mid-frequency band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseMids(_ decrement: Float) -> [Float]
    
    // Increases the equalizer treble band gains by a small increment. Returns all EQ band gain values, mapped by index.
    func increaseTreble(_ increment: Float) -> [Float]
    
    // Decreases the equalizer treble band gains by a small decrement. Returns all EQ band gain values, mapped by index.
    func decreaseTreble(_ decrement: Float) -> [Float]
}
