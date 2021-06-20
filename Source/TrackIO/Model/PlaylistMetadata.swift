import Foundation

struct PlaylistMetadata {
    
    var title: String?
    
    var artist: String?
    var albumArtist: String?
    var performer: String?
    
    var album: String?
    var genre: String?
    
    var trackNumber: Int?
    var totalTracks: Int?
    
    var discNumber: Int?
    var totalDiscs: Int?
    
    var duration: Double = 0
    var durationIsAccurate: Bool = false
    
    var isProtected: Bool?
    
    var chapters: [Chapter] = []
}
