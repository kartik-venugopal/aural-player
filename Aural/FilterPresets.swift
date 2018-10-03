import Foundation

// TODO: Create a superclass to reduce code duplication
class FilterPresets {
    
    private static var presets: [String: FilterPreset] = {
        
        var map = [String: FilterPreset]()
        
        SystemDefinedFilterPresets.allValues.forEach({
            
            map[$0.rawValue] = FilterPreset($0.rawValue, $0.state, $0.bassBand, $0.midBand, $0.trebleBand, true)
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
    static func addUserDefinedPreset(_ name: String, _ state: EffectsUnitState, _ bassBand: ClosedRange<Double>, _ midBand: ClosedRange<Double>, _ trebleBand: ClosedRange<Double>) {
        
        presets[name] = FilterPreset(name, state, bassBand, midBand, trebleBand, false)
    }
    
    static func presetWithNameExists(_ name: String) -> Bool {
        return presets[name] != nil
    }
}

class FilterPreset: EffectsUnitPreset {
    
    let bassBand: ClosedRange<Double>
    let midBand: ClosedRange<Double>
    let trebleBand: ClosedRange<Double>
    
    init(_ name: String, _ state: EffectsUnitState, _ bassBand: ClosedRange<Double>, _ midBand: ClosedRange<Double>, _ trebleBand: ClosedRange<Double>, _ systemDefined: Bool) {
        
        self.bassBand = bassBand
        self.midBand = midBand
        self.trebleBand = trebleBand
        
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
    case karaoke = "Karaoke"
    
    static var allValues: [SystemDefinedFilterPresets] = [.passThrough, .nothingButBass, .emphasizedVocals, .noBass, .karaoke]
    
    // Converts a user-friendly display name to an instance of FilterPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedFilterPresets {
        return SystemDefinedFilterPresets(rawValue: displayName) ?? .passThrough
    }
    
    var bassBand: ClosedRange<Double> {
        
        switch self {
            
        // Allow all bass
        case .passThrough, .nothingButBass, .karaoke:  return AppConstants.bass_min...AppConstants.bass_min
           
        // Block all bass
        case .emphasizedVocals, .noBass:   return AppConstants.bass_min...AppConstants.bass_max
            
        }
    }
    
    var midBand: ClosedRange<Double> {
        
        switch self {
            
        // Allow all mids
        case .passThrough, .emphasizedVocals, .noBass:  return AppConstants.mid_min...AppConstants.mid_min
            
        // Block all mids
        case .nothingButBass, .karaoke:   return AppConstants.mid_min...AppConstants.mid_max
            
        }
    }
    
    var trebleBand: ClosedRange<Double> {
        
        switch self {
            
        // Allow all treble
        case .passThrough, .noBass, .karaoke:  return AppConstants.treble_min...AppConstants.treble_min
            
        // Block all treble
        case .nothingButBass, .emphasizedVocals:   return AppConstants.treble_min...AppConstants.treble_max
            
        }
    }
    
    var state: EffectsUnitState {
        return .active
    }
}
