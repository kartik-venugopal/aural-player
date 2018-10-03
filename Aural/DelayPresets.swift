import Foundation

// TODO: Create a superclass to reduce code duplication
class DelayPresets {
    
    private static var presets: [String: DelayPreset] = {
        
        var map = [String: DelayPreset]()
        
        SystemDefinedDelayPresets.allValues.forEach({
            
            map[$0.rawValue] = DelayPreset($0.rawValue, $0.state, $0.amount, $0.time, $0.feedback, $0.cutoff, true)
        })
        
        return map
    }()
    
    static var userDefinedPresets: [DelayPreset] {
        return presets.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedPresets: [DelayPreset] {
        return presets.values.filter({$0.systemDefined == true})
    }
    
    static var defaultPreset: DelayPreset {
        return presetByName(SystemDefinedDelayPresets.oneSecond.rawValue)
    }
    
    static func presetByName(_ name: String) -> DelayPreset {
        return presets[name] ?? defaultPreset
    }
    
    static func loadUserDefinedPresets(_ userDefinedPresets: [DelayPreset]) {
        userDefinedPresets.forEach({presets[$0.name] = $0})
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedPreset(_ name: String, _ state: EffectsUnitState, _ amount: Float, _ time: Double, _ feedback: Float, _ cutoff: Float) {
        
        presets[name] = DelayPreset(name, state, amount, time, feedback, cutoff, false)
    }
    
    static func presetWithNameExists(_ name: String) -> Bool {
        return presets[name] != nil
    }
}

class DelayPreset: EffectsUnitPreset {
    
    let amount: Float
    let time: Double
    let feedback: Float
    let cutoff: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ amount: Float, _ time: Double, _ feedback: Float, _ cutoff: Float, _ systemDefined: Bool) {
        
        self.amount = amount
        self.time = time
        self.feedback = feedback
        self.cutoff = cutoff
        
        super.init(name, state, systemDefined)
    }
}

/*
    An enumeration of built-in delay presets the user can choose from
 */
fileprivate enum SystemDefinedDelayPresets: String {
    
    case quarterSecond = "1/4 second delay"
    case halfSecond = "1/2 second delay"
    case threeFourthsSecond = "3/4 second delay"
    case oneSecond = "1 second delay"   // default
    case twoSeconds = "2 seconds delay"
    
    case slightEcho = "Slight echo"
    
    static var allValues: [SystemDefinedDelayPresets] = [.quarterSecond, .halfSecond, .threeFourthsSecond, .oneSecond, .twoSeconds, .slightEcho]
    
    // Converts a user-friendly display name to an instance of DelayPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedDelayPresets {
        return SystemDefinedDelayPresets(rawValue: displayName) ?? .oneSecond
    }
    
    var time: Double {
        
        switch self {
            
        case .quarterSecond:    return 0.25
            
        case .halfSecond:   return 0.5
            
        case .threeFourthsSecond:   return 0.75
            
        case .oneSecond:    return 1
            
        case .twoSeconds:   return 2
            
        case .slightEcho:   return 0.05
            
        }
    }
    
    var amount: Float {
        return self == .slightEcho ? 20 : 50
    }
    
    var feedback: Float {
        return self == .slightEcho ? 25 : 50
    }
    
    var cutoff: Float {
        return 15000
    }
    
    var state: EffectsUnitState {
        return .active
    }
}
