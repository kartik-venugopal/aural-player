//
//  FilterPresets.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Manages a mapped collection of presets that can be applied to the Filter effects unit.
///
class FilterPresets: EffectsUnitPresets<FilterPreset> {
    
    init(persistentState: FilterUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedFilterPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).compactMap {FilterPreset(persistentState: $0)}
        
        super.init(systemDefinedObjects: systemDefinedPresets, userDefinedObjects: userDefinedPresets)
    }
    
    override var defaultPreset: FilterPreset {systemDefinedObject(named: SystemDefinedFilterPresetParams.passThrough.rawValue)!}
}

///
/// Represents a single Filter effects unit preset.
///
class FilterPreset: EffectsUnitPreset {
    
    let bands: [FilterBand]
    
    init(name: String, state: EffectsUnitState, bands: [FilterBand], systemDefined: Bool) {
        
        self.bands = bands
        super.init(name: name, state: state, systemDefined: systemDefined)
    }
    
    init?(persistentState: FilterPresetPersistentState) {
        
        guard let name = persistentState.name, let unitState = persistentState.state,
              let bands = persistentState.bands else {return nil}
        
        self.bands = bands.compactMap {FilterBand(persistentState: $0)}
        super.init(name: name, state: unitState, systemDefined: false)
    }
    
    func equalToOtherPreset(bands: [FilterBand]) -> Bool {

        if self.bands.count != bands.count {
            return false
        }
        
        for index in self.bands.indices {
            
            if self.bands[index] != bands[index] {
                return false
            }
        }
        
        return true
    }
}

extension FilterBand: Equatable {
    
    static func == (lhs: FilterBand, rhs: FilterBand) -> Bool {
        
        lhs.type == rhs.type &&
        Float.optionalValuesEqual(lhs.minFreq, rhs.minFreq, tolerance: 0.001) &&
        Float.optionalValuesEqual(lhs.maxFreq, rhs.maxFreq, tolerance: 0.001)
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
        FilterPreset(name: rawValue, state: .active, bands: bands, systemDefined: true)
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
    static let nothingButBass: [FilterBand] = [FilterBand.lowPassBand(maxFreq: SoundConstants.bass_max)]
    static let emphasizedVocals: [FilterBand] = [FilterBand.bandPassBand(minFreq: SoundConstants.mid_min, maxFreq: SoundConstants.mid_max)]
    static let noBass: [FilterBand] = [FilterBand.highPassBand(minFreq: SoundConstants.bass_max)]
    static let noSubBass: [FilterBand] = [FilterBand.highPassBand(minFreq: SoundConstants.subBass_max)]
    static let karaoke: [FilterBand] = [FilterBand.bandStopBand(minFreq: SoundConstants.mid_min, maxFreq: SoundConstants.mid_max)]
}
