import Foundation

class PitchPresets: FXPresets<PitchPreset> {
    
    override init() {
        
        super.init()
        addPresets(SystemDefinedPitchPresets.presets)
    }
    
    static var defaultPreset: PitchPreset = {return SystemDefinedPitchPresets.presets.first(where: {$0.name == SystemDefinedPitchPresetParams.normal.rawValue})!}()
}

class PitchPreset: EffectsUnitPreset {
    
    let pitch: Float
    let overlap: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ pitch: Float, _ overlap: Float, _ systemDefined: Bool) {
        
        self.pitch = pitch
        self.overlap = overlap
        super.init(name, state, systemDefined)
    }
    
    init(persistentState: PitchPresetState) {
        
        self.pitch = persistentState.pitch
        self.overlap = persistentState.overlap ?? AudioGraphDefaults.pitchOverlap
        super.init(persistentState.name, persistentState.state, false)
    }
}

fileprivate struct SystemDefinedPitchPresets {
    
    static let presets: [PitchPreset] = {
        
        var arr: [PitchPreset] = []
        SystemDefinedPitchPresetParams.allValues.forEach({
            arr.append(PitchPreset($0.rawValue, $0.state, $0.pitch, $0.overlap, true))
        })
        
        return arr
    }()
}

/*
    An enumeration of built-in pitch presets the user can choose from
 */
fileprivate enum SystemDefinedPitchPresetParams: String {
    
    case normal = "Normal"  // default
    case happyLittleGirl = "Happy little girl"
    case chipmunk = "Chipmunk"
    case oneOctaveUp = "+1 8ve"
    case twoOctavesUp = "+2 8ve"
    
    case deep = "A bit deep"
    case robocop = "Robocop"
    case oneOctaveDown = "-1 8ve"
    case twoOctavesDown = "-2 8ve"
    
    static var allValues: [SystemDefinedPitchPresetParams] = [.normal, .chipmunk, .happyLittleGirl, .oneOctaveUp, .twoOctavesUp, .deep, .robocop, .oneOctaveDown, .twoOctavesDown]
    
    // Converts a user-friendly display name to an instance of PitchPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedPitchPresetParams {
        return SystemDefinedPitchPresetParams(rawValue: displayName) ?? .normal
    }
    
    var pitch: Float {
        
        switch self {
            
        case .normal:   return 0
            
        case .happyLittleGirl: return 0.3 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        case .chipmunk: return 0.5 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        case .oneOctaveUp:  return 1 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        case .twoOctavesUp: return 2 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        case .deep: return -0.3 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        case .robocop:  return -0.5 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        case .oneOctaveDown:    return -1 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        case .twoOctavesDown:   return -2 * AppConstants.ValueConversions.pitch_UIToAudioGraph
            
        }
    }
    
    var overlap: Float {
        return 8
    }
    
    var state: EffectsUnitState {
        return .active
    }
}
