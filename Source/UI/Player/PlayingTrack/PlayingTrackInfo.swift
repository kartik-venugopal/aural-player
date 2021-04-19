import Cocoa

// Encapsulates displayed information for the currently playing track.
struct PlayingTrackInfo {
    
    let track: Track
    let playingChapterTitle: String?
    
    init(_ track: Track, _ playingChapterTitle: String?) {
        
        self.track = track
        self.playingChapterTitle = playingChapterTitle
    }
    
    var art: NSImage? {
        return track.art?.image
    }
    
    var artist: String? {
        return track.artist
    }
    
    var album: String? {
        return track.album
    }
    
    var displayName: String? {
        return track.title ?? track.defaultDisplayName
    }
}
