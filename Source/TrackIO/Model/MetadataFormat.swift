import Foundation

// Denotes the type (format) of a metadata entry
enum MetadataFormat: String {
    
    case common
    case iTunes
    case id3
    case audioToolbox
    case wma
    case vorbis
    case ape
    case other
    
    // Smaller the number, higher the sort order
    var sortOrder: Int {
        
        switch self {
            
        case .common:   return 0
            
        case .iTunes:  return 1
            
        case .id3:  return 2
            
        case .audioToolbox: return 3
            
        case .wma:  return 4
            
        case .vorbis:  return 5
            
        case .ape:  return 6
            
        case .other:    return 7
            
        }
    }
}
