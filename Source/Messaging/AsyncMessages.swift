import Cocoa

// Represents a message that is delivered asynchronously. This type of message is intended to be sent across application layers. For example, when the player needs to inform the UI that track playback has been completed.
protocol AsyncMessage {
    
    var messageType: AsyncMessageType {get}
}

// Contract for an object that consumes AsyncMessage
protocol AsyncMessageSubscriber {
    
    // Consume/process the given async message
    func consumeAsyncMessage(_ message: AsyncMessage)
    
    var subscriberId: String {get}
}

extension AsyncMessageSubscriber {

    var subscriberId: String {

        let className = String(describing: mirrorFor(self).subjectType)

        if let obj = self as? NSObject {
            return String(format: "%@-%d", className, obj.hashValue)
        }

        return className
    }
}

// An enumeration of all AsyncMessage types
enum AsyncMessageType {
   
    case playbackCompleted

    case trackTransition
    
    case trackInfoUpdated
    
    case trackMetadataUpdated
    
    case trackAdded
    
    case trackGrouped
    
    case itemsAdded
    
    case tracksRemoved
    
    case trackNotPlayed
    
    case trackNotTranscoded
    
    case tracksNotAdded
    
    case startedAddingTracks
    
    case doneAddingTracks
    
    case historyUpdated
    
    case addedToFavorites
    
    case removedFromFavorites
    
    case audioOutputChanged
    
    case transcodingProgress
    
    case transcodingCancelled
    
    case transcodingFinished
}

struct TrackTransitionAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackTransition
    
    // The track that was playing before the track transition (may be nil, meaning no track was playing)
    let beginTrack: Track?
    
    // Playback state before the track transition
    let beginState: PlaybackState
    
    // The track that was playing before the track transition (may be nil, meaning no track was playing)
    let endTrack: Track?
    
    // Playback state before the track transition
    let endState: PlaybackState
    
    // nil unless a playback gap has started
    let gapEndTime: Date?
    
    var trackChanged: Bool {
        return beginTrack != endTrack
    }
    
    var playbackStarted: Bool {
        return endState == .playing
    }
    
    var playbackEnded: Bool {
        return endState == .noTrack
    }
    
    var stateChanged: Bool {
        return beginState != endState
    }
    
    var gapStarted: Bool {
        return endState == .waiting
    }
    
    var transcodingStarted: Bool {
        return endState == .transcoding
    }
    
    init(_ beginTrack: Track?, _ beginState: PlaybackState, _ endTrack: Track?, _ endState: PlaybackState, _ gapEndTime: Date? = nil) {
        
        self.beginTrack = beginTrack
        self.beginState = beginState
        
        self.endTrack = endTrack
        self.endState = endState
        
        self.gapEndTime = gapEndTime
    }
}

// AsyncMessage indicating that playback of the currently playing track has completed
struct PlaybackCompletedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .playbackCompleted
    
    let session: PlaybackSession
    
    init(_ session: PlaybackSession) {
        self.session = session
    }
}

// AsyncMessage indicating that some new information has been loaded for a track (e.g. duration/display name, etc), and that the UI should refresh itself to show the new information
struct TrackUpdatedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackInfoUpdated
    
    // The track that has been updated
    let track: Track
    
    init(_ track: Track) {
        self.track = track
    }
}

struct TrackMetadataUpdatedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackMetadataUpdated
    
    let track: Track
    
    init(_ track: Track) {
        self.track = track
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
    
    static func fromTrackAddResult(_ result: Int, _ groupInfo: [GroupType: GroupedTrackAddResult], _ progress: TrackAddedMessageProgress) -> TrackAddedAsyncMessage {
    
        return TrackAddedAsyncMessage(result, groupInfo, progress)
    }
}

struct TrackGroupedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackGrouped
    
    let index: Int
    let groupingResults: [GroupType: GroupedTrackAddResult]
    
    init(_ index: Int, _ groupingResults: [GroupType: GroupedTrackAddResult]) {
        self.index = index
        self.groupingResults = groupingResults
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
    
    // The track that was playing before this error occurred (used to refresh certain UI elements, eg. playlist).
    let oldTrack: Track?
    
    // An error object containing detailed information such as the failed track's file and the root cause.
    let error: InvalidTrackError
    
    init(_ oldTrack: Track?, _ error: InvalidTrackError) {
        
        self.oldTrack = oldTrack
        self.error = error
    }
}

struct TrackNotTranscodedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .trackNotTranscoded
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let track: Track
    
    // An error object containing detailed information such as the track file and the root cause
    let error: InvalidTrackError
    
    init(_ track: Track, _ error: InvalidTrackError) {
        
        self.track = track
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
    
    private init() {}
    
    static let instance: AudioOutputChangedMessage = AudioOutputChangedMessage()
}

struct TranscodingProgressAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .transcodingProgress
    
    let track: Track
    
    let percTranscoded: Double
    let timeElapsed: Double
    let timeRemaining: Double
    
    init(_ track: Track, _ percTranscoded: Double, _ timeElapsed: Double, _ timeRemaining: Double) {
        
        self.track = track
        
        self.percTranscoded = percTranscoded
        self.timeElapsed = timeElapsed
        self.timeRemaining = timeRemaining
    }
}

struct TranscodingFinishedAsyncMessage: AsyncMessage {
    
    let messageType: AsyncMessageType = .transcodingFinished
    
    let track: Track
    let success: Bool
    
    init(_ track: Track, _ success: Bool) {
        self.track = track
        self.success = success
    }
}
