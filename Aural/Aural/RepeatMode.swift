/*
    Enumeration of all possible playback repeat modes
*/

import Foundation

enum RepeatMode {
    
    // Play all tracks once, in playlist order
    case OFF
    
    // Repeat one track forever
    case ONE
    
    // Repeat all tracks forever, in playlist order
    case ALL
    
    // Converts a String representation to a RepeatMode enum
    static func fromString(string: String) -> RepeatMode {
        
        switch string {
        case "OFF": return .OFF
        case "ONE": return .ONE
        case "ALL": return .ALL
        default: return OFF
        }
    }

    // Converts this RepeatMode enum to a String representation
    var toString : String {
        
        switch self {
            
        case .OFF: return "OFF"
        case .ONE: return "ONE"
        case .ALL: return "ALL"
            
        }
    }
}