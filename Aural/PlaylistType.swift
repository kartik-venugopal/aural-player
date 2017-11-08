import Foundation

// Enumeration of each of the playlist types
enum PlaylistType: String {
    
    // Flat playlist listing all tracks
    case tracks
    
    // Hierarchical playlist that groups tracks by their artist
    case artists
    
    // Hierarchical playlist that groups tracks by their album
    case albums
    
    // Hierarchical playlist that groups tracks by their genre
    case genres
    
    func toGroupType() -> GroupType? {
        
        switch self {
            
        case .tracks: return nil
            
        case .artists: return .artist
            
        case .albums: return .album
            
        case .genres: return .genre
            
        }
    }
}
