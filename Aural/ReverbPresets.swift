/*
Enumeration of all possible reverb effect presets
*/

import Foundation
import AVFoundation

enum ReverbPresets: String {
    
    case smallRoom
    
    case mediumRoom
    
    case largeRoom
    
    case mediumHall
    
    case largeHall
    
    case mediumChamber
    
    case largeChamber
    
    case cathedral
    
    case plate
    
    // Maps a ReverbPresets to a AVAudioUnitReverbPreset
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
    
    static func mapFromAVPreset(_ preset: AVAudioUnitReverbPreset) -> ReverbPresets {
        
        switch preset {
            
        case AVAudioUnitReverbPreset.smallRoom: return ReverbPresets.smallRoom
        case AVAudioUnitReverbPreset.mediumRoom: return ReverbPresets.mediumRoom
        case AVAudioUnitReverbPreset.largeRoom: return ReverbPresets.largeRoom
            
        case AVAudioUnitReverbPreset.mediumHall: return ReverbPresets.mediumHall
        case AVAudioUnitReverbPreset.largeHall: return ReverbPresets.largeHall
            
        case AVAudioUnitReverbPreset.mediumChamber: return ReverbPresets.mediumChamber
        case AVAudioUnitReverbPreset.largeChamber: return ReverbPresets.largeChamber
            
        case AVAudioUnitReverbPreset.cathedral: return ReverbPresets.cathedral
        case AVAudioUnitReverbPreset.plate: return ReverbPresets.plate
            
        // This should never happen
        default: return ReverbPresets.smallRoom
        }
    }
    
    // User-friendly, UI-friendly description String
    var description: String {
        return Utils.splitCamelCaseWord(rawValue, false)
    }
 
    // Constructs a ReverPresets object from a description String
    static func fromDescription(_ description: String) -> ReverbPresets {
        return ReverbPresets(rawValue: Utils.camelCase(description)) ?? AppDefaults.reverbPreset
    }
}
