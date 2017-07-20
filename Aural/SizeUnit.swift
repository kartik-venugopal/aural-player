/*
    Enumeration of different file size units
*/

import Foundation

enum SizeUnit {
    
    case tb
    case gb
    case mb
    case kb
    case b
    
    var toString: String {
        
        switch self {
            
        case .tb: return "TB"
        case .gb: return "GB"
        case .mb: return "MB"
        case .kb: return "KB"
        case .b: return "B"
        }
    }
    
    fileprivate var magnitude: Int {
        
        switch self {
            
        case .tb: return 5
        case .gb: return 4
        case .mb: return 3
        case .kb: return 2
        case .b: return 1
        }
    }
    
    // Compares two size units for magnitude (For ex, MB > KB, TB > GB, etc)
    func compareTo(_ otherSizeUnit: SizeUnit) -> Int {
        
        if (self.magnitude > otherSizeUnit.magnitude) {
            return 1
        } else if (self.magnitude == otherSizeUnit.magnitude) {
            return 0
        } else {
            return -1
        }
    }
}
