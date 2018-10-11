import Cocoa

// Represents a message that is delivered asynchronously. This type of message is intended to be sent across application layers. For example, when the player needs to inform the UI that track playback has been completed.
protocol AsyncMessage {
    
    var messageType: AsyncMessageType {get}
}

// Contract for an object that consumes AsyncMessage
protocol AsyncMessageSubscriber {
    
    // Consume/process the given async message
    func consumeAsyncMessage(_ message: AsyncMessage)
    
    func getID() -> String
}

// An enumeration of all AsyncMessage types
enum AsyncMessageType {
   
    case playbackCompleted

    case trackChanged
    
    case trackInfoUpdated
    
    case trackAdded
    
    case itemsAdded
    
    case tracksRemoved
    
    case trackPlayed
    
    case trackNotPlayed
    
    case tracksNotAdded
    
    case startedAddingTracks
    
    case doneAddingTracks
    
    case historyUpdated
    
    case addedToFavorites
    
    case removedFromFavorites
    
    case audioOutputChanged
    
    case gapStarted
}

// AsyncMessage indicating that the currently playing track has changed and the UI needs to be refreshed with the new track information
struct TrackChangedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackChanged
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let oldTrack: IndexedTrack?
    
    // The track that is now playing (may be nil, meaning no track playing)
    let newTrack: IndexedTrack?
    
    init(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?) {
        self.oldTrack = oldTrack
        self.newTrack = newTrack
    }
}

// AsyncMessage indicating that playback of the currently playing track has completed
struct PlaybackCompletedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .playbackCompleted
    
    private init() {}
    
    // Singleton
    static let instance: PlaybackCompletedAsyncMessage = PlaybackCompletedAsyncMessage()
}

// AsyncMessage indicating that some new information has been loaded for a track (e.g. duration/display name, etc), and that the UI should refresh itself to show the new information
struct TrackUpdatedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackInfoUpdated
    
    // The index of the track that has been updated
    let trackIndex: Int
    
    let groupInfo: [GroupType: GroupedTrack]
    
    init(_ trackIndex: Int, _ groupInfo: [GroupType: GroupedTrack]) {
        
        self.trackIndex = trackIndex
        self.groupInfo = groupInfo
    }
    
    // Factory method
    static func fromTrackAddResult(_ result: TrackAddResult) -> TrackUpdatedAsyncMessage {
        
        var groupInfo = [GroupType: GroupedTrack]()
        result.groupingPlaylistResults.forEach({groupInfo[$0.key] = $0.value.track})
        
        return TrackUpdatedAsyncMessage(result.flatPlaylistResult, groupInfo)
    }
}

// AsyncMessage indicating that a new track has been added to the playlist, and that the UI should refresh itself to show the new information
struct TrackAddedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackAdded
    
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
    
    static func fromTrackAddResult(_ result: TrackAddResult, _ progress: TrackAddedMessageProgress) -> TrackAddedAsyncMessage {
    
        return TrackAddedAsyncMessage(result.flatPlaylistResult, result.groupingPlaylistResults, progress)
    }
}

// Message indicating that some tracks have been removed from the playlist.
struct TracksRemovedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .tracksRemoved
    
    // Information about which tracks were removed and their former locations within the playlist (used to refresh the playlist views)
    let results: TrackRemovalResults
    
    // Flag indicating whether or not the currently playing track was removed. If no track was playing, this will be false.
    let playingTrackRemoved: Bool
    
    init(_ results: TrackRemovalResults, _ playingTrackRemoved: Bool) {
        self.results = results
        self.playingTrackRemoved = playingTrackRemoved
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
 
    let messageType: AsyncMessageType = .trackNotPlayed
    
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
    
    let messageType: AsyncMessageType = .tracksNotAdded
    
    // An array of error objects containing detailed information such as the track file and the root cause
    let errors: [DisplayableError]
    
    init(_ errors: [DisplayableError]) {
        self.errors = errors
    }
}

// AsyncMessage indicating that tracks are now being added to the playlist in a background thread
struct StartedAddingTracksAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .startedAddingTracks
    static let instance = StartedAddingTracksAsyncMessage()
}

// AsyncMessage indicating that tracks are done being added to the playlist in a background thread
struct DoneAddingTracksAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .doneAddingTracks
    static let instance = DoneAddingTracksAsyncMessage()
}

// Indicates that some items were added to the playlist. This is used for the History feature, to keep track of recently added items.
struct ItemsAddedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .itemsAdded
    
    // The files that were added to the playlist
    let files: [URL]
}

// Indicates that a track was played. This is used for the History feature, to keep track of recently played items.
struct TrackPlayedAsyncMessage: AsyncMessage {
 
    let messageType: AsyncMessageType = .trackPlayed
    let track: Track
}

// Indicates that History information has been updated. UI elements may choose to refresh their views (e.g. dock menu), in response to this message.
struct HistoryUpdatedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .historyUpdated
 
    private init() {}
    
    // Singleton
    static let instance: HistoryUpdatedAsyncMessage = HistoryUpdatedAsyncMessage()
}

// Indicates that the playing track has either been added to, or removed from, the Favorites list
struct FavoritesUpdatedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType
    
    // The track that was added to or removed from Favorites
    let file: URL
    
    init(_ messageType: AsyncMessageType, _ file: URL) {
        
        self.messageType = messageType
        self.file = file
    }
}

// Indicates that the system's audio output device has changed (e.g. when headphones are plugged in/out)
struct AudioOutputChangedMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .audioOutputChanged
    let endedSession: PlaybackSession?
    
    init(_ session: PlaybackSession?) {
        self.endedSession = session
    }
}

struct PlaybackGapStartedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .gapStarted
    
    let gapEndTime: Date
    let lastPlayedTrack: IndexedTrack?
    let nextTrack: IndexedTrack
    
    init(_ gapEndTime: Date, _ lastPlayedTrack: IndexedTrack?, _ nextTrack: IndexedTrack) {
        
        self.gapEndTime = gapEndTime
        self.lastPlayedTrack = lastPlayedTrack
        self.nextTrack = nextTrack
    }
}
