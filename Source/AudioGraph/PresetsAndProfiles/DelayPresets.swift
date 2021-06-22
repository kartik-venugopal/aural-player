import Foundation

class DelayPresets: FXPresets<DelayPreset> {
    
    init(persistentState: DelayUnitPersistentState?) {
        
        let systemDefinedPresets = SystemDefinedDelayPresetParams.allCases.map {$0.preset}
        let userDefinedPresets = (persistentState?.userPresets ?? []).map {DelayPreset(persistentState: $0)}
        
        super.init(systemDefinedPresets: systemDefinedPresets, userDefinedPresets: userDefinedPresets)
    }
    
    override var defaultPreset: DelayPreset {systemDefinedPresetsMap[SystemDefinedDelayPresetParams.oneSecond.rawValue]!}
}

class DelayPreset: EffectsUnitPreset {
    
    let amount: Float
    let time: Double
    let feedback: Float
    let lowPassCutoff: Float
    
    init(_ name: String, _ state: EffectsUnitState, _ amount: Float, _ time: Double, _ feedback: Float, _ cutoff: Float, _ systemDefined: Bool) {
        
        self.amount = amount
        self.time = time
        self.feedback = feedback
        self.lowPassCutoff = cutoff
        
        super.init(name, state, systemDefined)
    }
    
    init(persistentState: DelayPresetPersistentState) {
        
        self.amount = persistentState.amount
        self.time = persistentState.time
        self.feedback = persistentState.feedback
        self.lowPassCutoff = persistentState.lowPassCutoff
        
        super.init(persistentState: persistentState)
    }
}

/*
    An enumeration of built-in delay presets the user can choose from
 */
fileprivate enum SystemDefinedDelayPresetParams: String, CaseIterable {
    
    case quarterSecond = "1/4 second delay"
    case halfSecond = "1/2 second delay"
    case threeFourthsSecond = "3/4 second delay"
    case oneSecond = "1 second delay"   // default
    case twoSeconds = "2 seconds delay"
    
    case slightEcho = "Slight echo"
    
    // Converts a user-friendly display name to an instance of DelayPresets
    static func fromDisplayName(_ displayName: String) -> SystemDefinedDelayPresetParams {
        return SystemDefinedDelayPresetParams(rawValue: displayName) ?? .oneSecond
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
    
    var preset: DelayPreset {
        DelayPreset(rawValue, state, amount, time, feedback, cutoff, true)
    }
}
