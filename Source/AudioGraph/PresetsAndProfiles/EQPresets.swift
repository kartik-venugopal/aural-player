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
class EQPresets: EffectsPresets<EQPreset> {
    
    init(persistentState: EQUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedEQPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {EQPreset(persistentState: $0)}
        
        super.init(systemDefinedPresets: systemDefinedPresets, userDefinedPresets: userDefinedPresets)
    }
    
    override var defaultPreset: EQPreset {systemDefinedPreset(named: SystemDefinedEQPresetParams.flat.rawValue)!}
}

///
/// Represents a single Equalizer effects unit preset.
///
class EQPreset: EffectsUnitPreset {
    
    let bands: [Float]
    let globalGain: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ bands: [Float], _ globalGain: Float, _ systemDefined: Bool) {
        
        self.bands = bands
        self.globalGain = globalGain
        super.init(name, state, systemDefined)
    }
    
    init?(persistentState: EQPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let bands = persistentState.bands else {return nil}
        
        self.bands = bands
        self.globalGain = persistentState.globalGain ?? AudioGraphDefaults.eqGlobalGain
        
        super.init(name, unitState, false)
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
            
        case .flat: return EQPresetsBands.flatBands
        case .highBassAndTreble: return EQPresetsBands.highBassAndTrebleBands
            
        case .dance: return EQPresetsBands.danceBands
        case .electronic: return EQPresetsBands.electronicBands
        case .hipHop: return EQPresetsBands.hipHopBands
        case .jazz: return EQPresetsBands.jazzBands
        case .latin: return EQPresetsBands.latinBands
        case .lounge: return EQPresetsBands.loungeBands
        case .piano: return EQPresetsBands.pianoBands
        case .pop: return EQPresetsBands.popBands
        case .rAndB: return EQPresetsBands.rAndBBands
        case .rock: return EQPresetsBands.rockBands
            
        case .soft: return EQPresetsBands.softBands
        case .vocal: return EQPresetsBands.vocalBands
        case .karaoke: return EQPresetsBands.karaokeBands
            
        }
    }
    
    var globalGain: Float {
        return 0
    }
    
    var state: EffectsUnitState {
        return .active
    }
    
    var preset: EQPreset {
        EQPreset(rawValue, state, bands, globalGain, true)
    }
}

///
/// An enumeration of Equalizer band gain values for all system-defined EQ presets.
///
fileprivate struct EQPresetsBands {
    
    static let flatBands: [Float] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    static let highBassAndTrebleBands: [Float] = [15, 12.5, 10, 0, 0, 0, 0, 10, 12.5, 15]
    
    static let danceBands: [Float] = [0, 7, 4, 0, -1, -2, -4, 0, 4, 5]
    
    static let electronicBands: [Float] = [7, 6.5, 0, -2, -5, 0, 0, 0, 6.5, 7]
    
    static let hipHopBands: [Float] = [7, 7, 0, 0, -3, -3, -2, 1, 1, 7]
    
    static let jazzBands: [Float] = [0, 3, 0, 0, -3, -3, 0, 0, 3, 5]
    
    static let latinBands: [Float] = [8, 5, 0, 0, -4, -4, -4, 0, 6, 8]
    
    static let loungeBands: [Float] = [-5, -2, 0, 2, 4, 3, 0, 0, 3, 0]
    
    static let pianoBands: [Float] = [1, -1, -3, 0, 1, -1, 2, 3, 1, 2]
    
    static let popBands: [Float] = [-2, -1.5, 0, 3, 7, 7, 3.5, 0, -2, -3]
    
    static let rAndBBands: [Float] = [0, 7, 4, -3, -5, -4.5, -2, -1.5, 0, 1.5]
    
    static let rockBands: [Float] = [5, 3, 1.5, 0, -5, -6, -2.5, 0, 2.5, 4]
    
    static let softBands: [Float] = [0, 1, 2, 6, 8, 10, 12, 12, 13, 14]
    
    static let karaokeBands: [Float] = [8, 6, 4, -20, -20, -20, -20, 4, 6, 8]
    
    static let vocalBands: [Float] = [-20, -20, -20, 12, 14, 14, 12, -20, -20, -20]
}
