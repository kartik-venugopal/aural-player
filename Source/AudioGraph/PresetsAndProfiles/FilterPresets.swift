import Foundation

class FilterPresets: FXPresets<FilterPreset> {
    
    init(persistentState: FilterUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedFilterPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).map {FilterPreset(persistentState: $0)}
        
        super.init(systemDefinedPresets: systemDefinedPresets, userDefinedPresets: userDefinedPresets)
    }
    
    override var defaultPreset: FilterPreset {systemDefinedPreset(named: SystemDefinedFilterPresetParams.passThrough.rawValue)!}
}

class FilterPreset: EffectsUnitPreset {
    
    let bands: [FilterBand]
    
    init(_ name: String, _ state: EffectsUnitState, _ bands: [FilterBand], _ systemDefined: Bool) {
        
        self.bands = bands
        super.init(name, state, systemDefined)
    }
    
    init(persistentState: FilterPresetState) {
        
        self.bands = persistentState.bands.map {FilterBand(persistentState: $0)}
        super.init(persistentState.name, persistentState.state, false)
    }
}

/*
    An enumeration of built-in delay presets the user can choose from
 */
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

fileprivate struct FilterPresetsBands {
    
    static let passThrough: [FilterBand] = []
    static let nothingButBass: [FilterBand] = [FilterBand.bandPassBand(AppConstants.Sound.bass_min, AppConstants.Sound.bass_max)]
    static let emphasizedVocals: [FilterBand] = [FilterBand.bandPassBand(AppConstants.Sound.mid_min, AppConstants.Sound.mid_max)]
    static let noBass: [FilterBand] = [FilterBand.bandStopBand(AppConstants.Sound.bass_min, AppConstants.Sound.bass_max)]
    static let noSubBass: [FilterBand] = [FilterBand.bandStopBand(AppConstants.Sound.subBass_min, AppConstants.Sound.subBass_max)]
    static let karaoke: [FilterBand] = [FilterBand.bandStopBand(AppConstants.Sound.mid_min, AppConstants.Sound.mid_max)]
}
