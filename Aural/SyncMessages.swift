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
    Defines a synchronous message. SyncMessage objects could be either 1 - notifications, indicating that some change has occurred (e.g. the playlist has been cleared), OR 2 - requests for the execution of a function (e.g. track playback).
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
    
    // See TrackChangedNotification
    case trackChangedNotification
    
    // See PlayingTrackInfoUpdatedNotification
    case playingTrackInfoUpdatedNotification
    
    // See StopPlaybackRequest
    case stopPlaybackRequest
    
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
    
    case searchResultSelectionRequest
    
    // See AppExitRequest
    case appExitRequest
    
    // See AppExitResponse
    case appExitResponse
    
    // See EmptyResponse
    case emptyResponse
}

// Notification indicating that the currently playing track has changed and the UI needs to be refreshed with the new track information
struct TrackChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .trackChangedNotification
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    var oldTrack: IndexedTrack?
    
    // The track that is now playing (may be nil, meaning no track playing)
    var newTrack: IndexedTrack?
    
    // Flag indicating whether or not playback resulted in an error
    var errorState: Bool = false
    
    init(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?) {
        self.oldTrack = oldTrack
        self.newTrack = newTrack
    }
    
    init(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool) {
        self.oldTrack = oldTrack
        self.newTrack = newTrack
        self.errorState = errorState
    }
}

// Notification indicating that new information is available for the currently playing track, and the UI needs to be refreshed with the new information
struct PlayingTrackInfoUpdatedNotification: NotificationMessage {
    
    var messageType: MessageType = .playingTrackInfoUpdatedNotification
    
    private init() {}

    // Singleton
    static let instance: PlayingTrackInfoUpdatedNotification = PlayingTrackInfoUpdatedNotification()
}

// Request from the playlist to stop playback (for instance, when the playlist is cleared, or the playing track has been removed)
struct StopPlaybackRequest: RequestMessage {
    
    var messageType: MessageType = .stopPlaybackRequest
    
    private init() {}
    
    // Singleton
    static let instance: StopPlaybackRequest = StopPlaybackRequest()
}

struct SearchResultSelectionRequest: RequestMessage {
    
    var messageType: MessageType = .searchResultSelectionRequest
    
    let searchResult: SearchResult
    
    init(_ searchResult: SearchResult) {
        self.searchResult = searchResult
    }
}

// Request from the playback view to the playlist view to remove a specific track from the playlist
struct RemoveTrackRequest: RequestMessage {
    
    var messageType: MessageType = .removeTrackRequest
    
    // Index of the track that needs to be removed
    var index: Int
    
    init(_ index: Int) {
        self.index = index
    }
}

// Notification that the playback rate has changed, in response to the user manipulating the time stretch effects unit controls.
struct PlaybackRateChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .playbackRateChangedNotification
    
    // The new playback rate
    var newPlaybackRate: Float
    
    init(_ newPlaybackRate: Float) {
        self.newPlaybackRate = newPlaybackRate
    }
}

// Notification about a change in playback state (paused/playing/noTrack).
struct PlaybackStateChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .playbackStateChangedNotification
    
    // The new playback state
    var newPlaybackState: PlaybackState
    
    init(_ newPlaybackState: PlaybackState) {
        self.newPlaybackState = newPlaybackState
    }
}

// Notification about a change in the seek position of the currently playing track (e.g. when a seek is performed)
struct SeekPositionChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .seekPositionChangedNotification
    
    private init() {}
    
    // Singleton
    static let instance: SeekPositionChangedNotification = SeekPositionChangedNotification()
}

// Notification that the search query text in the search modal dialog has changed, triggering a new search with the new search text
struct SearchTextChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .searchTextChangedNotification
    
    private init() {}
    
    // Singleton
    static let instance: SearchTextChangedNotification = SearchTextChangedNotification()
}

// Notification that the app has loaded
struct AppLoadedNotification: NotificationMessage {
    
    var messageType: MessageType = .appLoadedNotification
    
    // Files specified as launch parameters (files that the app needs to open upon launch)
    var filesToOpen: [URL]
    
    init(_ filesToOpen: [URL]) {
        self.filesToOpen = filesToOpen
    }
}

// Notification that the app has been reopened with a request to open certain files
struct AppReopenedNotification: NotificationMessage {
    
    var messageType: MessageType = .appReopenedNotification
    
    // Files specified as launch parameters (files that the app needs to open)
    var filesToOpen: [URL]
    
    // Whether or not the app has already sent a notification of this type very recently
    var isDuplicateNotification: Bool
    
    init(_ filesToOpen: [URL], _ isDuplicateNotification: Bool) {
        self.filesToOpen = filesToOpen
        self.isDuplicateNotification = isDuplicateNotification
    }
}

// Request from the application to its components to perform an exit. Receiving components will determine whether or not the app may exit, and send an AppExitResponse, in response.
struct AppExitRequest: RequestMessage {
    
    var messageType: MessageType = .appExitRequest
    
    private init() {}
    
    // Singleton
    static let instance: AppExitRequest = AppExitRequest()
}

// Response to an AppExitRequest
struct AppExitResponse: ResponseMessage {
    
    var messageType: MessageType = .appExitResponse
    
    // Whether or not it is ok for the application to exit
    var okToExit: Bool
    
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
    
    var messageType: MessageType = .emptyResponse
    
    private init() {}
    
    // Singleton
    static let instance: EmptyResponse = EmptyResponse()
}
