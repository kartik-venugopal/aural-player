import Foundation

// TODO: Create a superclass to reduce code duplication
class FilterPresets {
    
    private static var presets: [String: FilterPreset] = {
        
        var map = [String: FilterPreset]()
        
        SystemDefinedFilterPresets.allValues.forEach({
            map[$0.rawValue] = FilterPreset($0.rawValue, .active, $0.bands, true)
        })
        
        return map
    }()
    
    static var userDefinedPresets: [FilterPreset] {
        return presets.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedPresets: [FilterPreset] {
        return presets.values.filter({$0.systemDefined == true})
    }
    
    static var defaultPreset: FilterPreset {
        return presetByName(SystemDefinedFilterPresets.passThrough.rawValue)
    }
    
    static func presetByName(_ name: String) -> FilterPreset {
        return presets[name] ?? defaultPreset
    }
    
    static func loadUserDefinedPresets(_ userDefinedPresets: [FilterPreset]) {
        userDefinedPresets.forEach({presets[$0.name] = $0})
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedPreset(_ name: String, _ state: EffectsUnitState, _ bands: [FilterBand]) {
        presets[name] = FilterPreset(name, state, bands, false)
    }
    
    static func presetWithNameExists(_ name: String) -> Bool {
        return presets[name] != nil
    }
    
    static func countUserDefinedPresets() -> Int {
        return userDefinedPresets.count
    }
    
    static func deletePresets(_ presetNames: [String]) {
        
        presetNames.forEach({
            presets[$0] = nil
        })
    }
    
    static func renamePreset(_ oldName: String, _ newName: String) {
        
        if presetWithNameExists(oldName) {
            
            let preset = presetByName(oldName)
            
            presets.removeValue(forKey: oldName)
            preset.name = newName
            presets[newName] = preset
        }
    }
}

class FilterPreset: EffectsUnitPreset {
    
    let bands: [FilterBand]
    
    init(_ name: String, _ state: EffectsUnitState, _ bands: [FilterBand], _ systemDefined: Bool) {
        
        self.bands = bands
        super.init(name, state, systemDefined)
    }
}

/*
    An enumeration of built-in delay presets the user can choose from
 */
fileprivate enum SystemDefinedFilterPresets: String {
    
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
    
    static var allValues: [SystemDefinedFilterPresets] = [.passThrough, .nothingButBass, .emphasizedVocals, .noBass, .noSubBass, .karaoke]
    
    // Converts a user-friendly display name to an instance of FilterPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedFilterPresets {
        return SystemDefinedFilterPresets(rawValue: displayName) ?? .passThrough
    }
}

fileprivate struct FilterPresetsBands {
    
    static let passThrough: [FilterBand] = []
    static let nothingButBass: [FilterBand] = [FilterBand.bandPassBand(AppConstants.bass_min, AppConstants.bass_max)]
    static let emphasizedVocals: [FilterBand] = [FilterBand.bandPassBand(AppConstants.mid_min, AppConstants.mid_max)]
    static let noBass: [FilterBand] = [FilterBand.bandStopBand(AppConstants.bass_min, AppConstants.bass_max)]
    static let noSubBass: [FilterBand] = [FilterBand.bandStopBand(AppConstants.subBass_min, AppConstants.subBass_max)]
    static let karaoke: [FilterBand] = [FilterBand.bandStopBand(AppConstants.mid_min, AppConstants.mid_max)]
}
