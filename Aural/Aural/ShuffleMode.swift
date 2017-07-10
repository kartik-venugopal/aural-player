/*
    Enumeration of all possible playback shuffle modes
*/

import Foundation

enum ShuffleMode {
    
    // Play tracks in random order
    case ON
    
    // Don't shuffle
    case OFF
    
    // Converts a String representation to a RepeatMode enum
    static func fromString(string: String) -> ShuffleMode {
        
        switch string {
        case "OFF": return .OFF
        case "ON": return .ON
        default: return OFF
        }
    }
    
    // Converts this ShuffleMode enum to a String representation
    var toString : String {
        
        switch self {
            
        case .OFF: return "OFF"
        case .ON: return "ON"
            
        }
    }
}