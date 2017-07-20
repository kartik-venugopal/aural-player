/*
    Enumeration of all possible playback repeat modes
*/

import Foundation

enum RepeatMode {
    
    // Play all tracks once, in playlist order
    case off
    
    // Repeat one track forever
    case one
    
    // Repeat all tracks forever, in playlist order
    case all
    
    // Converts a String representation to a RepeatMode enum
    static func fromString(_ string: String) -> RepeatMode {
        
        switch string {
        case "OFF": return .off
        case "ONE": return .one
        case "ALL": return .all
        default: return off
        }
    }

    // Converts this RepeatMode enum to a String representation
    var toString : String {
        
        switch self {
            
        case .off: return "OFF"
        case .one: return "ONE"
        case .all: return "ALL"
            
        }
    }
}
