//
//  EQPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Equalizer effects unit.
///
class EQPresets: EffectsUnitPresets<EQPreset> {
    
    init(persistentState: EQUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedEQPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {EQPreset(persistentState: $0)}
        
        super.init(systemDefinedObjects: systemDefinedPresets, userDefinedObjects: userDefinedPresets)
    }
    
    override var defaultPreset: EQPreset {systemDefinedObject(named: SystemDefinedEQPresetParams.flat.rawValue)!}
}

///
/// Represents a single Equalizer effects unit preset.
///
class EQPreset: EffectsUnitPreset {
    
    let bands: [Float]
    let globalGain: Float
    
    init(name: String, state: EffectsUnitState, bands: [Float],
         globalGain: Float, systemDefined: Bool) {
        
        self.bands = bands
        self.globalGain = globalGain
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: EQPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let bands = persistentState.bands else {return nil}
        
        self.bands = bands
        self.globalGain = persistentState.globalGain ?? AudioGraphDefaults.eqGlobalGain
        
        super.init(name: name, state: unitState, systemDefined: false)
    }
}

///
/// An enumeration of system-defined (built-in) Equalizer presets the user can choose from.
///
fileprivate enum SystemDefinedEQPresetParams: String, CaseIterable {
    
    case flat = "Flat" // default
    case highBassAndTreble = "High bass and treble"
    
    case dance = "Dance"
    case electronic = "Electronic"
    case hipHop = "Hip Hop"
    case jazz = "Jazz"
    case latin = "Latin"
    case lounge = "Lounge"
    case piano = "Piano"
    case pop = "Pop"
    case rAndB = "R&B"
    case rock = "Rock"
    
    case soft = "Soft"
    case karaoke = "Karaoke"
    case vocal = "Vocal"
    
    // Converts a user-friendly display name to an instance of EQPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedEQPresetParams {
        return SystemDefinedEQPresetParams(rawValue: displayName) ?? .flat
    }
    
    // Returns the frequency->gain mappings for each of the frequency bands, for this preset
    var bands: [Float] {
        
        switch self {
            
        case .flat: return EQPresetsBands.flat
        case .highBassAndTreble: return EQPresetsBands.highBassAndTreble
            
        case .dance: return EQPresetsBands.dance
        case .electronic: return EQPresetsBands.electronic
        case .hipHop: return EQPresetsBands.hipHop
        case .jazz: return EQPresetsBands.jazz
        case .latin: return EQPresetsBands.latin
        case .lounge: return EQPresetsBands.lounge
        case .piano: return EQPresetsBands.piano
        case .pop: return EQPresetsBands.pop
        case .rAndB: return EQPresetsBands.rAndB
        case .rock: return EQPresetsBands.rock
            
        case .soft: return EQPresetsBands.soft
        case .vocal: return EQPresetsBands.vocal
        case .karaoke: return EQPresetsBands.karaoke
            
        }
    }
    
    var preset: EQPreset {
        EQPreset(name: rawValue, state: .active, bands: bands, globalGain: 0, systemDefined: true)
    }
}

///
/// An enumeration of Equalizer band gain values for all system-defined EQ presets.
///
fileprivate struct EQPresetsBands {
    
    static let flat: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    static let highBassAndTreble: [Float] = [15, 12.5, 10, 0, 0, 0, 0, 10, 12.5, 15]
    
    static let dance: [Float] = [0, 7, 4, 0, -1, -2, -4, 0, 4, 5]
    
    static let electronic: [Float] = [7, 6.5, 0, -2, -5, 0, 0, 0, 6.5, 7]
    
    static let hipHop: [Float] = [7, 7, 0, 0, -3, -3, -2, 1, 1, 7]
    
    static let jazz: [Float] = [0, 3, 0, 0, -3, -3, 0, 0, 3, 5]
    
    static let latin: [Float] = [8, 5, 0, 0, -4, -4, -4, 0, 6, 8]
    
    static let lounge: [Float] = [-5, -2, 0, 2, 4, 3, 0, 0, 3, 0]
    
    static let piano: [Float] = [1, -1, -3, 0, 1, -1, 2, 3, 1, 2]
    
    static let pop: [Float] = [-2, -1.5, 0, 3, 7, 7, 3.5, 0, -2, -3]
    
    static let rAndB: [Float] = [0, 7, 4, -3, -5, -4.5, -2, -1.5, 0, 1.5]
    
    static let rock: [Float] = [5, 3, 1.5, 0, -5, -6, -2.5, 0, 2.5, 4]
    
    static let soft: [Float] = [0, 1, 2, 6, 8, 10, 12, 12, 13, 14]
    
    static let karaoke: [Float] = [8, 6, 4, -20, -20, -20, -20, 4, 6, 8]
    
    static let vocal: [Float] = [-20, -20, -20, 12, 14, 14, 12, -20, -20, -20]
}
