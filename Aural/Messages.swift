import Foundation

/*
 Contract for all subscribers of messages
 */
protocol MessageSubscriber {
    
    // Every message subscriber must implement this method to consume a type of message it is interested in
    func consumeNotification(_ notification: NotificationMessage)
    
    // Every message subscriber must implement this method to process a type of request it serves
    func processRequest(_ request: RequestMessage) -> ResponseMessage
}

/*
 Defines an inter-view message, sent from one view to another, in response to state changes or user actions. Messages could be either 1 - notifications, indicating that some change has occurred (e.g. the playlist has been cleared), OR 2 - requests for the execution of a function (e.g. track playback) from a different view.
 */
protocol Message {
    var messageType: MessageType {get}
}

protocol NotificationMessage: Message {
}

protocol RequestMessage: Message {
}

protocol ResponseMessage: Message {
}

// Enumeration of the different message types. See the various Message structs below, for descriptions of each message type.
enum MessageType {
    
    case trackRemovedNotification
    case trackChangedNotification
    
    case trackSelectionNotification
    case stopPlaybackRequest
    
    case playlistScrollUpNotification
    case playlistScrollDownNotification
    
    case playbackRateChangedNotification
    case searchQueryChangedNotification
    
    case appLoadedNotification
    case appExitNotification
    
    case appExitRequest
    case appExitResponse
    
    case emptyResponse
}

// Notification from the player that the playing track has changed (for instance, "next track" or when a track has finished playing)
struct TrackChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .trackChangedNotification
    var newTrack: IndexedTrack?
    
    init(_ newTrack: IndexedTrack?) {
        self.newTrack = newTrack
    }
}

// Notification from the playlist that a certain track has been removed.
struct TrackRemovedNotification: NotificationMessage {
    
    var messageType: MessageType = .trackRemovedNotification
    var removedTrackIndex: Int
    
    init(_ removedTrackIndex: Int) {
        self.removedTrackIndex = removedTrackIndex
    }
}

// Request from the playlist to play back the user-selected track (for instance, when the user double clicks a track in the playlist)
struct TrackSelectionNotification: NotificationMessage {
    
    var messageType: MessageType = .trackSelectionNotification
    var trackIndex: Int
    
    init(_ trackIndex: Int) {
        self.trackIndex = trackIndex
    }
}

// Notification that the playlist selection is to change (one row up)
struct PlaylistScrollUpNotification: NotificationMessage {
    
    var messageType: MessageType = .playlistScrollUpNotification
    static let instance: PlaylistScrollUpNotification = PlaylistScrollUpNotification()
    
    private init() {}
}

// Notification that the playlist selection is to change (one row down)
struct PlaylistScrollDownNotification: NotificationMessage {
    
    var messageType: MessageType = .playlistScrollDownNotification
    static let instance: PlaylistScrollDownNotification = PlaylistScrollDownNotification()
    
    private init() {}
}

// Request from the playlist to stop playback (for instance, when the playlist is cleared, or the playing track has been removed)
struct StopPlaybackRequest: RequestMessage {
    
    var messageType: MessageType = .stopPlaybackRequest
    static let instance: StopPlaybackRequest = StopPlaybackRequest()
    
    private init() {}
}

// Request from the Time effects unit to change the seek timer interval, in response to the user changing the playback rate.
struct PlaybackRateChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .playbackRateChangedNotification
    var newPlaybackRate: Float
    
    init(_ newPlaybackRate: Float) {
        self.newPlaybackRate = newPlaybackRate
    }
}

struct SearchQueryChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .searchQueryChangedNotification
    static let instance: SearchQueryChangedNotification = SearchQueryChangedNotification()
    
    private init() {}
}

struct AppLoadedNotification: NotificationMessage {
    
    var messageType: MessageType = .appLoadedNotification
    static let instance: AppLoadedNotification = AppLoadedNotification()
    
    private init() {}
}

struct AppExitNotification: NotificationMessage {
    
    var messageType: MessageType = .appExitNotification
    static let instance: AppExitNotification = AppExitNotification()
    
    private init() {}
}

struct AppExitRequest: RequestMessage {
    
    var messageType: MessageType = .appExitRequest
    static let instance: AppExitRequest = AppExitRequest()
    
    private init() {}
}

struct AppExitResponse: ResponseMessage {
    
    var messageType: MessageType = .appExitResponse
    var okToExit: Bool
    
    static let okToExit: AppExitResponse = AppExitResponse(true)
    static let dontExit: AppExitResponse = AppExitResponse(false)
    
    private init(_ okToExit: Bool) {
        self.okToExit = okToExit
    }
}

struct EmptyResponse: ResponseMessage {
    
    var messageType: MessageType = .emptyResponse
    static let instance: EmptyResponse = EmptyResponse()
    
    private init() {}
}
