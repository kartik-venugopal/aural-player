//
//  FXUnitProtocols.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

protocol FXUnitProtocol {
    
    var state: FXUnitState {get}
    
    // Toggles the state of the effects unit, and returns its new state
    func toggleState() -> FXUnitState
    
    func suppress()
    
    func unsuppress()
    
    var avNodes: [AVAudioNode] {get}
    
    associatedtype PresetType: FXUnitPreset
    associatedtype PresetsType: FXPresetsProtocol
    
    var presets: PresetsType {get}
    
    func savePreset(_ presetName: String)
    
    func applyPreset(_ presetName: String)
    
    func applyPreset(_ preset: PresetType)
    
    var settingsAsPreset: PresetType {get}
}
