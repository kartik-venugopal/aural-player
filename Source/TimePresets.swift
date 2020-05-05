import Foundation

class TimePresets: FXPresets<TimePreset> {
    
    override init() {
        
        super.init()
        addPresets(SystemDefinedTimePresets.presets)
    }
    
    static var defaultPreset: TimePreset = {return SystemDefinedTimePresets.presets.first(where: {$0.name == SystemDefinedTimePresetParams.normal.rawValue})!}()
}

class TimePreset: EffectsUnitPreset {
    
    let rate: Float
    let overlap: Float
    let shiftPitch: Bool
    
    init(_ name: String, _ state: EffectsUnitState, _ rate: Float, _ overlap: Float, _ shiftPitch: Bool, _ systemDefined: Bool) {
        
        self.rate = rate
        self.overlap = overlap
        self.shiftPitch = shiftPitch
        super.init(name, state, systemDefined)
    }
}

fileprivate struct SystemDefinedTimePresets {
    
    static let presets: [TimePreset] = {
        
        var arr: [TimePreset] = []
        SystemDefinedTimePresetParams.allValues.forEach({
            arr.append(TimePreset($0.rawValue, $0.state, $0.rate, $0.overlap, $0.shiftPitch, true))
        })
        
        return arr
    }()
}

/*
    An enumeration of built-in pitch presets the user can choose from
 */
fileprivate enum SystemDefinedTimePresetParams: String {
    
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
    
    static var allValues: [SystemDefinedTimePresetParams] = [.normal, .quarterX, .halfX, .threeFourthsX, .twoX, .threeX, .fourX, .speedyGonzales, .slowLikeMolasses, .tooMuchCoffee, .laidBack]
    
    // Converts a user-friendly display name to an instance of TimePresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedTimePresetParams {
        return SystemDefinedTimePresetParams(rawValue: displayName) ?? .normal
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
    
    var shiftPitch: Bool {
        return true
    }
    
    var state: EffectsUnitState {
        return .active
    }
}
