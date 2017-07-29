
import Cocoa

/*
    An enumeration of all event types
*/
enum EventType {
    
    // Indicates that playback of a track has completed. Published by the player and consumed by the middleman between the player and the UI.
    case playbackCompleted
    
    // Indicates that the currently playing track has changed. Published by the middleman and consumed by the UI
    case trackChanged
    
    case trackInfoUpdated
    
    case trackAdded
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
    
    fileprivate init() {}
    
    static let instance = PlaybackCompletedEvent()
}

// Event indicating that some new information has been loaded for a track (e.g. duration/display name, etc), and that the UI should refresh itself to show the new information
class TrackInfoUpdatedEvent: Event {
    
    var trackIndex: Int
    
    init(trackIndex: Int) {
        self.trackIndex = trackIndex
    }
}

// Event indicating that a new track has been added to the playlist, and that the UI should refresh itself to show the new information
class TrackAddedEvent: Event {
    
    var trackIndex: Int
    
    init(trackIndex: Int) {
        self.trackIndex = trackIndex
    }
}
