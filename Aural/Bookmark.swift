import Foundation

struct Bookmark {
    
    // A name or description (e.g. "2nd chapter of audiobook")
    let name: String
    
    // The track being bookmarked
    let track: Track
    
    // Seek position within track, expressed in seconds
    let position: Double
    
    init(_ name: String, _ track: Track, _ position: Double) {
        
        self.name = name
        self.track = track
        self.position = position
    }
}
