import Cocoa

// Represents a message that is delivered asynchronously. This type of message is intended to be sent across application layers. For example, when the player needs to inform the UI that track playback has been completed.
protocol AsyncMessage {
    
    var messageType: AsyncMessageType {get}
}

// Contract for an object that consumes AsyncMessage
protocol AsyncMessageSubscriber {
    
    // Consume/Process the given async message
    func consumeAsyncMessage(_ message: AsyncMessage)
}

// An enumeration of all AsyncMessage types
enum AsyncMessageType {
   
    // See PlaybackCompletedAsyncMessage
    case playbackCompleted

    // See TrackChangedAsyncMessage
    case trackChanged
    
    // See TrackUpdatedAsyncMessage
    case trackInfoUpdated
    
    // See TrackAddedAsyncMessage
    case trackAdded
    
    case tracksRemoved
    
    // See TrackNotPlayedAsyncMessage
    case trackNotPlayed
    
    // See TracksNotAddedAsyncMessage
    case tracksNotAdded
    
    // See StartedAddingTracksAsyncMessage
    case startedAddingTracks
    
    // See DoneAddingTracksAsyncMessage
    case doneAddingTracks
}

// AsyncMessage indicating that the currently playing track has changed and the UI needs to be refreshed with the new track information
struct TrackChangedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .trackChanged
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    var oldTrack: IndexedTrack?
    
    // The track that is now playing (may be nil, meaning no track playing)
    var newTrack: IndexedTrack?
    
    init(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?) {
        self.oldTrack = oldTrack
        self.newTrack = newTrack
    }
}

// AsyncMessage indicating that playback of the currently playing track has completed
struct PlaybackCompletedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .playbackCompleted
    
    private init() {}
    
    // Singleton
    static let instance: PlaybackCompletedAsyncMessage = PlaybackCompletedAsyncMessage()
}

//// AsyncMessage indicating that some new information has been loaded for a track (e.g. duration/display name, etc), and that the UI should refresh itself to show the new information
struct TrackUpdatedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .trackInfoUpdated
    
    // The index of the track that has been updated
    let trackIndex: Int
    
    let groupInfo: [GroupType: GroupedTrack]
    
    init(_ trackIndex: Int, _ groupInfo: [GroupType: GroupedTrack]) {
        
        self.trackIndex = trackIndex
        self.groupInfo = groupInfo
    }
}

//// AsyncMessage indicating that a new track has been added to the playlist, and that the UI should refresh itself to show the new information
struct TrackAddedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .trackAdded
    
    // The index of the newly added track
    let trackIndex: Int
    
    let groupInfo: [GroupType: GroupedTrackAddResult]
    
    // The current progress of the track add operation (See TrackAddedMessageProgress)
    let progress: TrackAddedMessageProgress
    
    init(_ trackIndex: Int, _ groupInfo: [GroupType: GroupedTrackAddResult], _ progress: TrackAddedMessageProgress) {
        
        self.trackIndex = trackIndex
        self.groupInfo = groupInfo
        self.progress = progress
    }
}

struct TracksRemovedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .tracksRemoved
    
    let results: RemoveOperationResults
    
    init(_ results: RemoveOperationResults) {
        self.results = results
    }
}

// Indicates current progress associated with a TrackAddedAsyncMessage
struct TrackAddedMessageProgress {
    
    // Number of tracks added so far
    let tracksAdded: Int
    
    // Total number of tracks to add
    let totalTracks: Int
    
    // Percentage of tracks added (computed)
    let percentage: Double
    
    init(_ tracksAdded: Int, _ totalTracks: Int) {
        
        self.tracksAdded = tracksAdded
        self.totalTracks = totalTracks
        self.percentage = totalTracks > 0 ? Double(tracksAdded) * 100 / Double(totalTracks) : 0
    }
}

// AsyncMessage indicating that an error was encountered while attempting to play back a track
struct TrackNotPlayedAsyncMessage: AsyncMessage {
 
    var messageType: AsyncMessageType = .trackNotPlayed
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let oldTrack: IndexedTrack?
    
    // An error object containing detailed information such as the track file and the root cause
    let error: InvalidTrackError
    
    init(_ oldTrack: IndexedTrack?, _ error: InvalidTrackError) {
        self.oldTrack = oldTrack
        self.error = error
    }
}

// AsyncMessage indicating that some selected files were not loaded into the playlist
struct TracksNotAddedAsyncMessage: AsyncMessage {
    
    var messageType: AsyncMessageType = .tracksNotAdded
    
    // An array of error objects containing detailed information such as the track file and the root cause
    let errors: [InvalidTrackError]
    
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
