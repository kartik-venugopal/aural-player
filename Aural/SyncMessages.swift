import Foundation

/*
    Contract for all subscribers of synchronous messages
 */
protocol MessageSubscriber {
    
    // Every message subscriber must implement this method to consume a type of message it is interested in
    func consumeNotification(_ notification: NotificationMessage)
    
    // Every message subscriber must implement this method to process a type of request it serves
    func processRequest(_ request: RequestMessage) -> ResponseMessage
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

// Enumeration of the different message types. See the letious Message structs below, for descriptions of each message type.
enum MessageType {
    
    case trackAddedNotification
    
    case trackUpdatedNotification
    
    case trackGroupUpdatedNotification
    
    // See TrackChangedNotification
    case trackChangedNotification
    
    case sequenceChangedNotification
    
    // See PlayingTrackInfoUpdatedNotification
    case playingTrackInfoUpdatedNotification
    
    // See RemoveTrackRequest
    case removeTrackRequest
    
    // See PlaybackStateChangedNotification
    case playbackStateChangedNotification
    
    // See PlaybackRateChangedNotification
    case playbackRateChangedNotification
    
    // See SeekPositionChangedNotification
    case seekPositionChangedNotification
    
    // See SearchTextChangedNotification
    case searchTextChangedNotification
    
    // See AppLoadedNotification
    case appLoadedNotification
    
    // See AppReopenedNotification
    case appReopenedNotification
    
    case playlistTypeChangedNotification
    
    case searchResultSelectionRequest
    
    case appInBackgroundNotification
    
    case playbackRequest
    
    // See AppExitRequest
    case appExitRequest
    
    // See AppExitResponse
    case appExitResponse
    
    // See EmptyResponse
    case emptyResponse
}

// indicating that a new track has been added to the playlist, and that the UI should refresh itself to show the new information
struct TrackAddedNotification: NotificationMessage {
    
    let messageType: MessageType = .trackAddedNotification
    
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

// Notification indicating that the currently playing track has changed and the UI needs to be refreshed with the new track information
struct TrackChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .trackChangedNotification
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let oldTrack: IndexedTrack?
    
    // The track that is now playing (may be nil, meaning no track playing)
    let newTrack: IndexedTrack?
    
    // Flag indicating whether or not playback resulted in an error
    let errorState: Bool
    
    init(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        self.oldTrack = oldTrack
        self.newTrack = newTrack
        self.errorState = errorState
    }
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

// Request from the playlist search dialog to the playlist, to show a specific search result within the playlist.
struct SearchResultSelectionRequest: RequestMessage {
    
    let messageType: MessageType = .searchResultSelectionRequest
    
    let searchResult: SearchResult
    
    init(_ searchResult: SearchResult) {
        self.searchResult = searchResult
    }
}

// Request from the playback view to the playlist view to remove a specific track from the playlist
struct RemoveTrackRequest: RequestMessage {
    
    let messageType: MessageType = .removeTrackRequest
    
    // Index of the track that needs to be removed
    let index: Int
    
    init(_ index: Int) {
        self.index = index
    }
}

// Notification that the playback rate has changed, in response to the user manipulating the time stretch effects unit controls.
struct PlaybackRateChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .playbackRateChangedNotification
    
    // The new playback rate
    let newPlaybackRate: Float
    
    init(_ newPlaybackRate: Float) {
        self.newPlaybackRate = newPlaybackRate
    }
}

// Notification about a change in playback state (paused/playing/noTrack).
struct PlaybackStateChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .playbackStateChangedNotification
    
    // The new playback state
    let newPlaybackState: PlaybackState
    
    init(_ newPlaybackState: PlaybackState) {
        self.newPlaybackState = newPlaybackState
    }
}

// Notification about a change in the seek position of the currently playing track (e.g. when a seek is performed)
struct SeekPositionChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .seekPositionChangedNotification
    
    private init() {}
    
    // Singleton
    static let instance: SeekPositionChangedNotification = SeekPositionChangedNotification()
}

// Notification that the search query text in the search modal dialog has changed, triggering a new search with the new search text
struct SearchTextChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .searchTextChangedNotification
    
    private init() {}
    
    // Singleton
    static let instance: SearchTextChangedNotification = SearchTextChangedNotification()
}

// Notification that the app has loaded
struct AppLoadedNotification: NotificationMessage {
    
    let messageType: MessageType = .appLoadedNotification
    
    // Files specified as launch parameters (files that the app needs to open upon launch)
    let filesToOpen: [URL]
    
    init(_ filesToOpen: [URL]) {
        self.filesToOpen = filesToOpen
    }
}

// Notification that the app has been reopened with a request to open certain files
struct AppReopenedNotification: NotificationMessage {
    
    let messageType: MessageType = .appReopenedNotification
    
    // Files specified as launch parameters (files that the app needs to open)
    let filesToOpen: [URL]
    
    // Whether or not the app has already sent a notification of this type very recently
    let isDuplicateNotification: Bool
    
    init(_ filesToOpen: [URL], _ isDuplicateNotification: Bool) {
        self.filesToOpen = filesToOpen
        self.isDuplicateNotification = isDuplicateNotification
    }
}

// Notification that the playlist view (tracks/artists, etc) has been changed, by switching playlist tabs, within the UI
struct PlaylistTypeChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .playlistTypeChangedNotification
    let newPlaylistType: PlaylistType
}

struct PlaybackRequest: RequestMessage {
    
    let messageType: MessageType = .playbackRequest
    
    let type: PlaybackRequestType
    
    // Only one of these 3 fields will be non-nil, depending on the request type
    var index: Int? = nil
    var track: Track? = nil
    var group: Group? = nil

    init(index: Int) {
        self.index = index
        self.type = .index
    }
    
    init(track: Track) {
        self.track = track
        self.type = .track
    }
    
    init(group: Group) {
        self.group = group
        self.type = .group
    }
}

enum PlaybackRequestType {
    
    case index
    case track
    case group
}

// Request from the application to its components to perform an exit. Receiving components will determine whether or not the app may exit, and send an AppExitResponse, in response.
struct AppExitRequest: RequestMessage {
    
    let messageType: MessageType = .appExitRequest
    
    private init() {}
    
    // Singleton
    static let instance: AppExitRequest = AppExitRequest()
}

// Response to an AppExitRequest
struct AppExitResponse: ResponseMessage {
    
    let messageType: MessageType = .appExitResponse
    
    // Whether or not it is ok for the application to exit
    let okToExit: Bool
    
    // Instance indicating an "Ok to exit" response
    static let okToExit: AppExitResponse = AppExitResponse(true)
    
    // Instance indicating a "Don't exit" response
    static let dontExit: AppExitResponse = AppExitResponse(false)
    
    private init(_ okToExit: Bool) {
        self.okToExit = okToExit
    }
}

// Dummy message to be used when there is no other appropriate response message type
struct EmptyResponse: ResponseMessage {
    
    let messageType: MessageType = .emptyResponse
    
    private init() {}
    
    // Singleton
    static let instance: EmptyResponse = EmptyResponse()
}

struct AppInBackgroundNotification: NotificationMessage {
 
    let messageType: MessageType = .appInBackgroundNotification
    
    private init() {}
    
    static let instance: AppInBackgroundNotification = AppInBackgroundNotification()
}
