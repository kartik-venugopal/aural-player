/*
Enumeration of all possible reverb effect presets
*/

import Foundation
import AVFoundation

enum ReverbPresets {
    
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
    
    // User-friendly, UI-friendly description String
    var description: String {
        
        switch self {
            
        case .smallRoom: return "Small room"
        case .mediumRoom: return "Medium room"
        case .largeRoom: return "Large room"
            
        case .mediumHall: return "Medium hall"
        case .largeHall: return "Large hall"
            
        case .mediumChamber: return "Medium chamber"
        case .largeChamber: return "Large chamber"
            
        case .cathedral: return "Cathedral"
        case .plate: return "Plate"
            
        }
    }
    
    // Converts this ReverbPresets enum to a String representation
    var toString: String {
        
        switch self {
            
        case .smallRoom: return "SmallRoom"
        case .mediumRoom: return "MediumRoom"
        case .largeRoom: return "LargeRoom"
            
        case .mediumHall: return "MediumHall"
        case .largeHall: return "LargeHall"
            
        case .mediumChamber: return "MediumChamber"
        case .largeChamber: return "LargeChamber"
            
        case .cathedral: return "Cathedral"
        case .plate: return "Plate"
            
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
    
    static func fromString(_ string: String) -> ReverbPresets {
        
        switch string {
            
        case "SmallRoom": return .smallRoom
        case "MediumRoom": return .mediumRoom
        case "LargeRoom": return .largeRoom
            
        case "MediumHall": return .mediumHall
        case "LargeHall": return .largeHall
            
        case "MediumChamber": return .mediumChamber
        case "LargeChamber": return .largeChamber
            
        case "Cathedral": return .cathedral
        case "Plate": return .plate
     
        // This should never happen
        default: return .smallRoom
        }
    }
    
    static func fromDescription(_ description: String) -> ReverbPresets {
        
        var preset: ReverbPresets
        
        switch description {
            
        case smallRoom.description: preset = .smallRoom
        case mediumRoom.description: preset = .mediumRoom
        case largeRoom.description: preset = .largeRoom
            
        case mediumChamber.description: preset = .mediumChamber
        case largeChamber.description: preset = .largeChamber
            
        case mediumHall.description: preset = .mediumHall
        case largeHall.description: preset = .largeHall
            
        case cathedral.description: preset = .cathedral
        case plate.description: preset = .plate
            
            // This should never happen
        default: preset = .smallRoom
        }
        
        return preset
    }
}
