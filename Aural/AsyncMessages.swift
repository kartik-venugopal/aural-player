import Cocoa

protocol AsyncMessage {
    
    var messageType: AsyncMessageType {get}
}

protocol AsyncMessageSubscriber {
    
    // Every AsyncMessage subscriber must implement this method to consume an AsyncMessage it is interested in
    func consumeAsyncMessage(_ message: AsyncMessage)
}

/*
    An enumeration of all AsyncMessage types
*/
enum AsyncMessageType {
    
    case playbackCompleted

    case trackChanged
    
    case trackInfoUpdated
    
    case trackAdded
    
    case trackNotPlayed
    
    case tracksNotAdded
    
    case startedAddingTracks
    
    case doneAddingTracks
}

// AsyncMessage indicating that the currently playing track has changed and the UI needs to be refreshed with the new track information
struct TrackChangedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .trackChanged
    
    // The track that is now playing (may be nil, meaning no track playing)
    var newTrack: IndexedTrack?
    
    init(_ newTrack: IndexedTrack?) {
        self.newTrack = newTrack
    }
}

// AsyncMessage indicating that playback of the currently playing track has completed
struct PlaybackCompletedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .playbackCompleted
    
    // The PlaybackSession associated with this AsyncMessage. This is required in order to determine if the session is still current. If another session has started before this AsyncMessage occurs, this AsyncMessage is no longer relevant because its session has been invalidated. For instance, if the user selects "Next track" before the previous track completes playing, this playback completion AsyncMessage no longer needs to be processed.
    let session: PlaybackSession
    init(_ session: PlaybackSession) {self.session = session}
}

// AsyncMessage indicating that some new information has been loaded for a track (e.g. duration/display name, etc), and that the UI should refresh itself to show the new information
struct TrackInfoUpdatedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .trackInfoUpdated
    var trackIndex: Int
    
    init(_ trackIndex: Int) {
        self.trackIndex = trackIndex
    }
}

// AsyncMessage indicating that a new track has been added to the playlist, and that the UI should refresh itself to show the new information
struct TrackAddedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .trackAdded
    
    var trackIndex: Int
    var progress: TrackAddedAsyncMessageProgress
    
    init(_ trackIndex: Int, _ progress: TrackAddedAsyncMessageProgress) {
        self.trackIndex = trackIndex
        self.progress = progress
    }
}

// Indicates current progress associated with a TrackAddedAsyncMessage
struct TrackAddedAsyncMessageProgress {
    
    var tracksAdded: Int
    var totalTracks: Int
    
    // Computed property
    var percentage: Double
    
    init(_ tracksAdded: Int, _ totalTracks: Int) {
        self.tracksAdded = tracksAdded
        self.totalTracks = totalTracks
        self.percentage = totalTracks > 0 ? Double(tracksAdded) * 100 / Double(totalTracks) : 0
    }
}

// AsyncMessage indicating that an error was encountered while attempting to play back a track
struct TrackNotPlayedAsyncMessage: AsyncMessage {
 
    var messageType: AsyncMessageType = .trackNotPlayed
    
    // An error object containing detailed information such as the track file and the root cause
    var error: InvalidTrackError
    
    init(_ error: InvalidTrackError) {
        self.error = error
    }
}

// AsyncMessage indicating that some selected files were not loaded into the playlist
struct TracksNotAddedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .tracksNotAdded
    
    // An array of error objects containing detailed information such as the track file and the root cause
    var errors: [InvalidTrackError]
    
    init(_ errors: [InvalidTrackError]) {
        self.errors = errors
    }
}

// AsyncMessage indicating that tracks are now being added to the playlist in a background thread
struct StartedAddingTracksAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .startedAddingTracks
    static let instance = StartedAddingTracksAsyncMessage()
}

// AsyncMessage indicating that tracks are done being added to the playlist in a background thread
struct DoneAddingTracksAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .doneAddingTracks
    static let instance = DoneAddingTracksAsyncMessage()
}
