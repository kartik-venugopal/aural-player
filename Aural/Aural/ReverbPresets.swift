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
    
    case None
    
    // Maps a ReverbPresets to a AVAudioUnitReverbPreset (nil if preset is .NONE)
    var avPreset: AVAudioUnitReverbPreset? {
        
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
        case .None: return nil
            
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
        case .None: return "None"
            
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
        case .None: return "None"
            
        }
    }
    
    static func mapFromAVPreset(preset: AVAudioUnitReverbPreset?) -> ReverbPresets {
        
        if (preset == nil) {
            return .None
        }
        
        let _preset = preset!
        switch _preset {
            
        case AVAudioUnitReverbPreset.SmallRoom: return ReverbPresets.SmallRoom
        case AVAudioUnitReverbPreset.MediumRoom: return ReverbPresets.MediumRoom
        case AVAudioUnitReverbPreset.LargeRoom: return ReverbPresets.LargeRoom
            
        case AVAudioUnitReverbPreset.MediumHall: return ReverbPresets.MediumHall
        case AVAudioUnitReverbPreset.LargeHall: return ReverbPresets.LargeHall
            
        case AVAudioUnitReverbPreset.MediumChamber: return ReverbPresets.MediumChamber
        case AVAudioUnitReverbPreset.LargeChamber: return ReverbPresets.LargeChamber
            
        case AVAudioUnitReverbPreset.Cathedral: return ReverbPresets.Cathedral
        case AVAudioUnitReverbPreset.Plate: return ReverbPresets.Plate
        default: return .None
            
        }
    }
    
    static func fromString(string: String) -> ReverbPresets {
        
        switch string {
            
        case "None": return .None
            
        case "SmallRoom": return .SmallRoom
        case "MediumRoom": return .MediumRoom
        case "LargeRoom": return .LargeRoom
            
        case "MediumHall": return .MediumHall
        case "LargeHall": return .LargeHall
            
        case "MediumChamber": return .MediumChamber
        case "LargeChamber": return .LargeChamber
            
        case "Cathedral": return .Cathedral
        case "Plate": return .Plate
        default: return .None
            
        }
    }
}