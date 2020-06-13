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
   
    case trackTransition
    
    case trackInfoUpdated
    
    case trackNotTranscoded
    
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

// Indicates that playback of the currently playing track has completed
struct PlaybackCompletedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playbackCompleted
    let completedSession: PlaybackSession
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

// Indicates that a new track has been added to the playlist, and that the UI should refresh itself to show the new information.
struct TrackAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .trackAdded
    
    // The index of the newly added track
    let trackIndex: Int
    
    // Grouping info (parent groups) for the newly added track
    let groupingInfo: [GroupType: GroupedTrackAddResult]
    
    // The current progress of the track add operation (See TrackAddedMessageProgress)
    let addOperationProgress: TrackAddOperationProgressNotification
}

// Message indicating that some tracks have been removed from the playlist.
struct TracksRemovedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .tracksRemoved
    
    // Information about which tracks were removed and their former locations within the playlist (used to refresh the playlist views)
    let results: TrackRemovalResults
    
    // Flag indicating whether or not the currently playing track was removed. If no track was playing, this will be false.
    let playingTrackRemoved: Bool
}

// Indicates current progress associated with a TrackAddedNotification
struct TrackAddOperationProgressNotification {
    
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
struct TrackNotPlayedNotification: NotificationPayload {
 
    let notificationName: Notification.Name = .trackNotPlayed
    
    // The track that was playing before this error occurred (used to refresh certain UI elements, eg. playlist).
    let oldTrack: Track?
    
    // An error object containing detailed information such as the failed track's file and the root cause.
    let error: InvalidTrackError
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

// Indicates that some selected files were not loaded into the playlist
struct TracksNotAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .tracksNotAdded
    
    // An array of error objects containing detailed information such as the track file and the root cause
    let errors: [DisplayableError]
}

// Indicates that some items were added to the playlist. This is used for the History feature, to keep track of recently added items.
struct HistoryItemsAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .historyItemsAdded
    
    // The files that were added to the playlist
    let files: [URL]
}

// Indicates that the playing track has either been added to, or removed from, the Favorites list
struct FavoritesUpdatedNotification: NotificationPayload {
    
    let notificationName: Notification.Name
    
    // The filesystem file of the track that was added to or removed from Favorites
    let trackFile: URL
    
    init(notificationName: Notification.Name, trackFile: URL) {
        
        self.notificationName = notificationName
        self.trackFile = trackFile
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
