/*
Enumeration of all possible reverb effect presets
*/

import Foundation
import AVFoundation

enum ReverbPresets {
    
    case SmallRoom
    
    case MediumRoom
    
    case LargeRoom
    
    case MediumHall
    
    case LargeHall
    
    case MediumChamber
    
    case LargeChamber
    
    case Cathedral
    
    case Plate
    
    // Maps a ReverbPresets to a AVAudioUnitReverbPreset
    var avPreset: AVAudioUnitReverbPreset {
        
        switch self {
            
        case .SmallRoom: return AVAudioUnitReverbPreset.SmallRoom
        case .MediumRoom: return AVAudioUnitReverbPreset.MediumRoom
        case .LargeRoom: return AVAudioUnitReverbPreset.LargeRoom
            
        case .MediumHall: return AVAudioUnitReverbPreset.MediumHall
        case .LargeHall: return AVAudioUnitReverbPreset.LargeHall
            
        case .MediumChamber: return AVAudioUnitReverbPreset.MediumChamber
        case .LargeChamber: return AVAudioUnitReverbPreset.LargeChamber
            
        case .Cathedral: return AVAudioUnitReverbPreset.Cathedral
        case .Plate: return AVAudioUnitReverbPreset.Plate
            
        }
    }
    
    // User-friendly, UI-friendly description String
    var description: String {
        
        switch self {
            
        case .SmallRoom: return "Small room"
        case .MediumRoom: return "Medium room"
        case .LargeRoom: return "Large room"
            
        case .MediumHall: return "Medium hall"
        case .LargeHall: return "Large hall"
            
        case .MediumChamber: return "Medium chamber"
        case .LargeChamber: return "Large chamber"
            
        case .Cathedral: return "Cathedral"
        case .Plate: return "Plate"
            
        }
    }
    
    // Converts this ReverbPresets enum to a String representation
    var toString: String {
        
        switch self {
            
        case .SmallRoom: return "SmallRoom"
        case .MediumRoom: return "MediumRoom"
        case .LargeRoom: return "LargeRoom"
            
        case .MediumHall: return "MediumHall"
        case .LargeHall: return "LargeHall"
            
        case .MediumChamber: return "MediumChamber"
        case .LargeChamber: return "LargeChamber"
            
        case .Cathedral: return "Cathedral"
        case .Plate: return "Plate"
            
        }
    }
    
    static func mapFromAVPreset(preset: AVAudioUnitReverbPreset) -> ReverbPresets {
        
        switch preset {
            
        case AVAudioUnitReverbPreset.SmallRoom: return ReverbPresets.SmallRoom
        case AVAudioUnitReverbPreset.MediumRoom: return ReverbPresets.MediumRoom
        case AVAudioUnitReverbPreset.LargeRoom: return ReverbPresets.LargeRoom
            
        case AVAudioUnitReverbPreset.MediumHall: return ReverbPresets.MediumHall
        case AVAudioUnitReverbPreset.LargeHall: return ReverbPresets.LargeHall
            
        case AVAudioUnitReverbPreset.MediumChamber: return ReverbPresets.MediumChamber
        case AVAudioUnitReverbPreset.LargeChamber: return ReverbPresets.LargeChamber
            
        case AVAudioUnitReverbPreset.Cathedral: return ReverbPresets.Cathedral
        case AVAudioUnitReverbPreset.Plate: return ReverbPresets.Plate
            
        // This should never happen
        default: return ReverbPresets.SmallRoom
        }
    }
    
    static func fromString(string: String) -> ReverbPresets {
        
        switch string {
            
        case "SmallRoom": return .SmallRoom
        case "MediumRoom": return .MediumRoom
        case "LargeRoom": return .LargeRoom
            
        case "MediumHall": return .MediumHall
        case "LargeHall": return .LargeHall
            
        case "MediumChamber": return .MediumChamber
        case "LargeChamber": return .LargeChamber
            
        case "Cathedral": return .Cathedral
        case "Plate": return .Plate
     
        // This should never happen
        default: return .SmallRoom
        }
    }
    
    static func fromDescription(description: String) -> ReverbPresets {
        
        var preset: ReverbPresets
        
        switch description {
            
        case SmallRoom.description: preset = .SmallRoom
        case MediumRoom.description: preset = .MediumRoom
        case LargeRoom.description: preset = .LargeRoom
            
        case MediumChamber.description: preset = .MediumChamber
        case LargeChamber.description: preset = .LargeChamber
            
        case MediumHall.description: preset = .MediumHall
        case LargeHall.description: preset = .LargeHall
            
        case Cathedral.description: preset = .Cathedral
        case Plate.description: preset = .Plate
            
            // This should never happen
        default: preset = .SmallRoom
        }
        
        return preset
    }
}