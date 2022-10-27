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
    
    var unitType: EffectsUnitType {get}
    
    var state: EffectsUnitState {get}
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> EffectsUnitState
    
    func ensureActive()
    
    var isActive: Bool {get}
    
    var stateFunction: EffectsUnitStateFunction {get}
    
    func suppress()
    
    func unsuppress()
    
    @available(macOS 10.13, *)
    var renderQuality: Int {get set}
    
    var avNodes: [AVAudioNode] {get}
    
    associatedtype PresetType: EffectsUnitPreset
    associatedtype PresetsType: EffectsUnitPresetsProtocol
    
    var presets: PresetsType {get}
    
    func savePreset(named presetName: String)
    
    func applyPreset(named presetName: String)
    
    func applyPreset(_ preset: PresetType)
    
    var settingsAsPreset: PresetType {get}
    
    var currentPreset: PresetType? {get}
    
    func setCurrentPreset(byName presetName: String)
}
