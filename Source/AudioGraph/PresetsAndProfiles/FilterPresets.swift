//
//  FilterPresets.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Filter effects unit.
///
class FilterPresets: EffectsPresets<FilterPreset> {
    
    init(persistentState: FilterUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedFilterPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {FilterPreset(persistentState: $0)}
        
        super.init(systemDefinedPresets: systemDefinedPresets, userDefinedPresets: userDefinedPresets)
    }
    
    override var defaultPreset: FilterPreset {systemDefinedPreset(named: SystemDefinedFilterPresetParams.passThrough.rawValue)!}
}

///
/// Represents a single Filter effects unit preset.
///
class FilterPreset: EffectsUnitPreset {
    
    let bands: [FilterBand]
    
    init(_ name: String, _ state: EffectsUnitState, _ bands: [FilterBand], _ systemDefined: Bool) {
        
        self.bands = bands
        super.init(name, state, systemDefined)
    }
    
    init?(persistentState: FilterPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let bands = persistentState.bands else {return nil}
        
        self.bands = bands.compactMap {FilterBand(persistentState: $0)}
        super.init(name, unitState, false)
    }
}

///
/// An enumeration of system-defined (built-in) Filter presets the user can choose from.
///
fileprivate enum SystemDefinedFilterPresetParams: String, CaseIterable {
    
    case passThrough = "Pass through"   // default
    case nothingButBass = "Nothing but bass"
    case emphasizedVocals = "Emphasized vocals"
    case noBass = "No bass"
    case noSubBass = "No sub-bass"
    case karaoke = "Karaoke"
    
    var bands: [FilterBand] {
        
        switch self {
            
        case .passThrough:  return FilterPresetsBands.passThrough
            
        case .nothingButBass:   return FilterPresetsBands.nothingButBass
            
        case .emphasizedVocals:     return FilterPresetsBands.emphasizedVocals
            
        case .noBass:   return FilterPresetsBands.noBass
            
        case .noSubBass:    return FilterPresetsBands.noSubBass
            
        case .karaoke:  return FilterPresetsBands.karaoke
            
        }
    }
    
    var preset: FilterPreset {
        FilterPreset(rawValue, .active, bands, true)
    }
    
    // Converts a user-friendly display name to an instance of FilterPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedFilterPresetParams {
        return SystemDefinedFilterPresetParams(rawValue: displayName) ?? .passThrough
    }
}

///
/// An enumeration of Filter bands arrays for all system-defined Filter presets.
///
fileprivate struct FilterPresetsBands {
    
    static let passThrough: [FilterBand] = []
    static let nothingButBass: [FilterBand] = [FilterBand.bandPassBand(SoundConstants.bass_min, SoundConstants.bass_max)]
    static let emphasizedVocals: [FilterBand] = [FilterBand.bandPassBand(SoundConstants.mid_min, SoundConstants.mid_max)]
    static let noBass: [FilterBand] = [FilterBand.bandStopBand(SoundConstants.bass_min, SoundConstants.bass_max)]
    static let noSubBass: [FilterBand] = [FilterBand.bandStopBand(SoundConstants.subBass_min, SoundConstants.subBass_max)]
    static let karaoke: [FilterBand] = [FilterBand.bandStopBand(SoundConstants.mid_min, SoundConstants.mid_max)]
}
