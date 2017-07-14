
import Cocoa

/*
    An enumeration of all event types
*/
enum EventType {
    
    // Indicates that playback of a track has completed. Published by the player and consumed by the middleman between the player and the UI.
    case PlaybackCompleted
    
    // Indicates that the currently playing track has changed. Published by the middleman and consumed by the UI
    case TrackChanged
}

// Event indicating that the currently playing track has changed and the UI needs to be refreshed with the new track information
class TrackChangedEvent: Event {
    
    // The track that is now playing (may be nil, meaning no track playing)
    var newTrack: Track?
    
    // The index of the track that is now playing (may be nil, meaning no track playing)
    var newTrackIndex: Int?
    
    init(newTrack: Track?, newTrackIndex: Int?) {
        self.newTrack = newTrack
        self.newTrackIndex = newTrackIndex
    }
}

// Event indicating that playback of the currently playing track has completed
class PlaybackCompletedEvent: Event {
    
//    // The track that completed playing
//    var track: Track
//    
//    init(track: Track) {
//        self.track = track
//    }
    
    private init() {}
    
    static let instance = PlaybackCompletedEvent()
}