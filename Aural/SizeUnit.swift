/*
    Enumeration of different file size units
*/

import Foundation

enum SizeUnit {
    
    case TB
    case GB
    case MB
    case KB
    case B
    
    var toString: String {
        
        switch self {
            
        case TB: return "TB"
        case GB: return "GB"
        case MB: return "MB"
        case KB: return "KB"
        case B: return "B"
        }
    }
    
    private var magnitude: Int {
        
        switch self {
            
        case TB: return 5
        case GB: return 4
        case MB: return 3
        case KB: return 2
        case B: return 1
        }
    }
    
    // Compares two size units for magnitude (For ex, MB > KB, TB > GB, etc)
    func compareTo(otherSizeUnit: SizeUnit) -> Int {
        
        if (self.magnitude > otherSizeUnit.magnitude) {
            return 1
        } else if (self.magnitude == otherSizeUnit.magnitude) {
            return 0
        } else {
            return -1
        }
    }
}