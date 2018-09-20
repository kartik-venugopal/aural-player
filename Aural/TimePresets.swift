import Foundation

class TimePresets {
    
    private static var presets: [String: TimePreset] = {
        
        var map = [String: TimePreset]()
        SystemDefinedTimePresets.allValues.forEach({
            map[$0.rawValue] = TimePreset(name: $0.rawValue, rate: $0.rate, overlap: $0.overlap, pitchShift: $0.pitchShift, systemDefined: true)
        })
        
        return map
    }()
    
    static var userDefinedPresets: [TimePreset] {
        return presets.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedPresets: [TimePreset] {
        return presets.values.filter({$0.systemDefined == true})
    }
    
    static var defaultPreset: TimePreset {
        return presetByName(SystemDefinedTimePresets.normal.rawValue)
    }
    
    static func presetByName(_ name: String) -> TimePreset {
        return presets[name] ?? defaultPreset
    }
    
    static func loadUserDefinedPresets(_ userDefinedPresets: [TimePreset]) {
        userDefinedPresets.forEach({presets[$0.name] = $0})
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedPreset(_ name: String, _ rate: Float, _ overlap: Float, _ pitchShift: Bool) {
        presets[name] = TimePreset(name: name, rate: rate, overlap: overlap, pitchShift: pitchShift, systemDefined: false)
    }
    
    static func presetWithNameExists(_ name: String) -> Bool {
        return presets[name] != nil
    }
}

// TODO: Make this a sibling of EQPreset with a protocol
struct TimePreset {
    
    let name: String
    let rate: Float
    let overlap: Float
    let pitchShift: Bool
    let systemDefined: Bool
}

/*
    An enumeration of built-in pitch presets the user can choose from
 */
fileprivate enum SystemDefinedTimePresets: String {
    
    case normal = "Normal (1x)"  // default
    
    case quarterX = "0.25x"
    case halfX = "0.5x"
    case threeFourthsX = "0.75x"
    
    case twoX = "2x"
    case threeX = "3x"
    case fourX = "4x"
    
    case tooMuchCoffee = "Too much coffee"
    case laidBack = "Laid back"
    case speedyGonzales = "Speedy Gonzales"
    case slowLikeMolasses = "Slow like molasses"
    
    static var allValues: [SystemDefinedTimePresets] = [.normal, .quarterX, .halfX, .threeFourthsX, .twoX, .threeX, .fourX, .speedyGonzales, .slowLikeMolasses, .tooMuchCoffee, .laidBack]
    
    // Converts a user-friendly display name to an instance of TimePresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedTimePresets {
        return SystemDefinedTimePresets(rawValue: displayName) ?? .normal
    }
    
    var rate: Float {
        
        switch self {
            
        case .normal:   return 1
            
        case .quarterX: return 0.25
            
        case .halfX: return 0.5
            
        case .threeFourthsX:  return 0.75
            
        case .twoX: return 2
            
        case .threeX: return 3
            
        case .fourX:  return 4
            
        case .tooMuchCoffee:    return 1.15
            
        case .laidBack:   return 0.9
            
        case .speedyGonzales:   return 1.5
            
        case .slowLikeMolasses: return 0.8
            
        }
    }
    
    var overlap: Float {
        return 8
    }
    
    var pitchShift: Bool {
        return true
    }
}
