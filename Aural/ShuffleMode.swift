/*
    Enumeration of all possible playback shuffle modes
*/

import Foundation

enum ShuffleMode {
    
    // Play tracks in random order
    case on
    
    // Don't shuffle
    case off
    
    // Converts a String representation to a RepeatMode enum
    static func fromString(_ string: String) -> ShuffleMode {
        
        switch string {
        case "OFF": return .off
        case "ON": return .on
        default: return off
        }
    }
    
    // Converts this ShuffleMode enum to a String representation
    var toString : String {
        
        switch self {
            
        case .off: return "OFF"
        case .on: return "ON"
            
        }
    }
}
