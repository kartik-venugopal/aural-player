import Foundation
import AVFoundation

/*
    Enumeration of all possible reverb effect presets
 */
enum ReverbSpaces: String {
    
    case smallRoom
    
    case mediumRoom
    
    case largeRoom
    
    case mediumHall
    
    case largeHall
    
    case mediumChamber
    
    case largeChamber
    
    case cathedral
    
    case plate
    
    // Maps a ReverbSpaces to a AVAudioUnitReverbPreset
    var avPreset: AVAudioUnitReverbPreset {
        
        switch self {
            
        case .smallRoom: return AVAudioUnitReverbPreset.smallRoom
        case .mediumRoom: return AVAudioUnitReverbPreset.mediumRoom
        case .largeRoom: return AVAudioUnitReverbPreset.largeRoom
            
        case .mediumHall: return AVAudioUnitReverbPreset.mediumHall
        case .largeHall: return AVAudioUnitReverbPreset.largeHall
            
        case .mediumChamber: return AVAudioUnitReverbPreset.mediumChamber
        case .largeChamber: return AVAudioUnitReverbPreset.largeChamber
            
        case .cathedral: return AVAudioUnitReverbPreset.cathedral
        case .plate: return AVAudioUnitReverbPreset.plate
            
        }
    }
    
    // Maps a AVAudioUnitReverbPreset to a ReverbPresets
    static func mapFromAVPreset(_ preset: AVAudioUnitReverbPreset) -> ReverbSpaces {
        
        switch preset {
            
        case AVAudioUnitReverbPreset.smallRoom: return .smallRoom
        case AVAudioUnitReverbPreset.mediumRoom: return .mediumRoom
        case AVAudioUnitReverbPreset.largeRoom: return .largeRoom
            
        case AVAudioUnitReverbPreset.mediumHall: return .mediumHall
        case AVAudioUnitReverbPreset.largeHall: return .largeHall
            
        case AVAudioUnitReverbPreset.mediumChamber: return .mediumChamber
        case AVAudioUnitReverbPreset.largeChamber: return .largeChamber
            
        case AVAudioUnitReverbPreset.cathedral: return .cathedral
        case AVAudioUnitReverbPreset.plate: return .plate
            
        // This should never happen
        default: return ReverbSpaces.smallRoom
            
        }
    }
    
    // User-friendly, UI-friendly description string
    var description: String {
        return StringUtils.splitCamelCaseWord(rawValue, false)
    }
 
    // Constructs a ReverPresets object from a description string
    static func fromDescription(_ description: String) -> ReverbSpaces {
        return ReverbSpaces(rawValue: StringUtils.camelCase(description)) ?? AppDefaults.reverbSpace
    }
}
