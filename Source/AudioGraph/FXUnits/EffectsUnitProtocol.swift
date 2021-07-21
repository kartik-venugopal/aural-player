//
//  EffectsUnitProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// A functional contract for an effects unit that processes audio.
///
protocol EffectsUnitProtocol {
    
    var state: EffectsUnitState {get}
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> EffectsUnitState
    
    func suppress()
    
    func unsuppress()
    
    var avNodes: [AVAudioNode] {get}
    
    associatedtype PresetType: EffectsUnitPreset
    associatedtype PresetsType: EffectsUnitPresetsProtocol
    
    var presets: PresetsType {get}
    
    func savePreset(named presetName: String)
    
    func applyPreset(named presetName: String)
    
    func applyPreset(_ preset: PresetType)
    
    var settingsAsPreset: PresetType {get}
}
