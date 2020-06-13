import Foundation

/*
 Contract for all subscribers of synchronous messages
 */
protocol MessageSubscriber {
    
    // Every message subscriber must implement this method to consume a type of message it is interested in
    func consumeNotification(_ notification: NotificationMessage)
    
    // Every message subscriber must implement this method to process a type of request it serves
    func processRequest(_ request: RequestMessage) -> ResponseMessage
    
    var subscriberId: String {get}
}

extension MessageSubscriber {
    
    func consumeNotification(_ notification: NotificationMessage) {
        // Do nothing
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
    
    var subscriberId: String {
        
        let className = String(describing: mirrorFor(self).subjectType)
        
        if let obj = self as? NSObject {
            return String(format: "%@-%d", className, obj.hashValue)
        }
        
        return className
    }
}

/*
 Defines a synchronous message. SyncMessage objects could be either 1 - notifications, indicating that some change has occurred (e.g. the playlist has been cleared), OR 2 - requests for the execution of a function (e.g. track playback) that may return a response to the caller.
 */
protocol SyncMessage {
    var messageType: MessageType {get}
}

// Marker protocol denoting a SyncMessage that does not need a response, i.e. a notification
protocol NotificationMessage: SyncMessage {
}

// Marker protocol denoting a SyncMessage that is a request, requiring a response
protocol RequestMessage: SyncMessage {
}

// Marker protocol denoting a SyncMessage that is a response to a RequestMessage
protocol ResponseMessage: SyncMessage {
}

// Enumeration of the different message types. See the various Message structs below, for descriptions of each message type.
enum MessageType {
    
    case trackTransitionNotification
    
    case sequenceChangedNotification
    
    case playingTrackInfoUpdatedNotification
    
    case playbackLoopChangedNotification
    
    case searchTextChangedNotification
    
    case editorSelectionChangedNotification
    
    case emptyResponse
    
    case gapUpdatedNotification
}

struct TrackTransitionNotification: NotificationMessage {
    
    let messageType: MessageType = .trackTransitionNotification
    
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

struct PreTrackChangeNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .preTrackChange
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let oldTrack: Track?
    
    // Playback state before the track change
    let oldState: PlaybackState
    
    // The track that is now playing (may be nil, meaning no track playing)
    let newTrack: Track?
}

// Notification to indicate that the currently playing chapter has changed
struct ChapterChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .chapterChanged
    
    // The chapter that was playing before the chapter change (may be nil, meaning no defined chapter was playing)
    let oldChapter: IndexedChapter?
    
    // The chapter that is now playing (may be nil, meaning no chapter playing)
    let newChapter: IndexedChapter?
}

// Notification indicating the the playback sequence may have changed and that the UI may need to be refreshed to show updated sequence information
struct SequenceChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .sequenceChangedNotification
    private init() {}
    
    // Singleton
    static let instance: SequenceChangedNotification = SequenceChangedNotification()
}

// Notification indicating that new information is available for the currently playing track, and the UI needs to be refreshed with the new information
struct PlayingTrackInfoUpdatedNotification: NotificationMessage {
    
    let messageType: MessageType = .playingTrackInfoUpdatedNotification
    
    private init() {}
    
    // Singleton
    static let instance: PlayingTrackInfoUpdatedNotification = PlayingTrackInfoUpdatedNotification()
}

// Command from the playlist search dialog to the playlist, to show a specific search result within the playlist.
struct SelectSearchResultCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .selectSearchResult
    let searchResult: SearchResult
}

// Notification that the playback rate has changed, in response to the user manipulating the time stretch effects unit controls.
struct PlaybackRateChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playbackRateChanged
    
    // The new playback rate
    let newPlaybackRate: Float
}

// Notification that the search query text in the search modal dialog has changed, triggering a new search with the new search text
struct SearchTextChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .searchTextChangedNotification
    
    private init() {}
    
    // Singleton
    static let instance: SearchTextChangedNotification = SearchTextChangedNotification()
}

// Notification that the app has launched (used to perform UI initialization)
struct AppLaunchedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .appLaunched
    
    // Files specified as launch parameters (files that the app needs to open upon launch)
    let filesToOpen: [URL]
}

// Notification that the app has been reopened with a request to open certain files
struct AppReopenedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .appReopened
    
    // Files specified as launch parameters (files that the app needs to open)
    let filesToOpen: [URL]
    
    // Whether or not the app has already sent a notification of this type very recently
    let isDuplicateNotification: Bool
}

// Notification that the playlist view (tracks/artists, etc) has been changed, by switching playlist tabs, within the UI
struct PlaylistTypeChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playlistTypeChanged
    let newPlaylistType: PlaylistType
}

// A command to initiate playback for a particular track/group
struct TrackPlaybackCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playTrack
    
    // Type indicates whether the request parameter is an index, track, or group. This is used to initialize the new playback sequence.
    let type: PlaybackCommandType
    
    // Only one of these 3 fields will be non-nil, depending on the request type
    var index: Int? = nil
    var track: Track? = nil
    var group: Group? = nil
    
    // An (optional) delay before starting playback.
    var delay: Double? = nil
    
    // Initialize the request with a track index. This will be done from the Tracks playlist.
    init(index: Int, delay: Double? = nil) {
        
        self.index = index
        self.type = .index
        self.delay = delay
    }
    
    // Initialize the request with a track. This will be done from a grouping/hierarchical playlist.
    init(track: Track, delay: Double? = nil) {
        
        self.track = track
        self.type = .track
        self.delay = delay
    }
    
    // Initialize the request with a group. This will be done from a grouping/hierarchical playlist.
    init(group: Group, delay: Double? = nil) {
        
        self.group = group
        self.type = .group
        self.delay = delay
    }
}

// A command related to playback of a chapter within a track.
struct ChapterPlaybackCommandNotification: NotificationPayload {

    let notificationName: Notification.Name = .chapterPlayback
    
    let commandType: ChapterPlaybackCommandType
    
    // The index of the chapter to which this command applies (may be nil).
    var chapterIndex: Int? = nil
   
    init(commandType: ChapterPlaybackCommandType, chapterIndex: Int? = nil) {
        
        self.commandType = commandType
        self.chapterIndex = chapterIndex
    }
}

// The various types of chapter playback commands. See ChapterPlaybackCommandNotification.
enum ChapterPlaybackCommandType {
    
    // Play the chapter selected in the chapters list
    case playSelectedChapter
    
    // Play the previous chapter (relative to the currently playing chapter)
    case previousChapter
    
    // Play the next chapter (relative to the currently playing chapter)
    case nextChapter
    
    // Replay the currently playing chapter from its start time
    case replayChapter
    
    // Loop the currently playing chapter from its start time
    case addChapterLoop
    
    // Remove the previously added loop for the current chapter
    case removeChapterLoop
}

// Enumerates all the possible playback command types. See PlaybackCommandNotification.
enum PlaybackCommandType {
    
    // Play the track with the given index
    case index
    
    // Play the given track
    case track
    
    // Play the given group
    case group
}

// Request from the application to its components to perform an exit. Receiving components will determine whether or not the app may exit, and send an AppExitResponse, in response.
class AppExitRequestNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .appExitRequest
    
    private var responses: [Bool] = []
    
    var okToExit: Bool {
        return !responses.contains(false)
    }
    
    func appendResponse(okToExit: Bool) {
        responses.append(okToExit)
    }
}

// Dummy message to be used when there is no other appropriate response message type
struct EmptyResponse: ResponseMessage {
    
    let messageType: MessageType = .emptyResponse
    
    private init() {}
    
    // Singleton
    static let instance: EmptyResponse = EmptyResponse()
}

// Notification that the state of the segment playback loop for the currently playing track has been changed and the UI may need to be updated as a result
struct PlaybackLoopChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .playbackLoopChangedNotification
    
    private init() {}
    
    // Singleton
    static let instance: PlaybackLoopChangedNotification = PlaybackLoopChangedNotification()
}

// Notification that the layout manager has changed the window layout
struct WindowLayoutChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .windowLayoutChanged
    
    let showingEffects: Bool
    let showingPlaylist: Bool
}

struct ApplyEffectsPresetRequest: RequestMessage {
    
    let messageType: MessageType
    let preset: EffectsUnitPreset
    
    init(_ messageType: MessageType, _ preset: EffectsUnitPreset) {
        
        self.messageType = messageType
        self.preset = preset
    }
}

struct EditorSelectionChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .editorSelectionChangedNotification
    let numberOfSelectedRows: Int
    
    init(_ numberOfSelectedRows: Int) {
        self.numberOfSelectedRows = numberOfSelectedRows
    }
}

struct PlaybackGapUpdatedNotification: NotificationMessage {
    
    let messageType: MessageType = .gapUpdatedNotification
    
    let updatedTrack: Track
    
    init(_ updatedTrack: Track) {
        self.updatedTrack = updatedTrack
    }
}
