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
    Defines a synchronous message. Messages could be either 1 - notifications, indicating that some change has occurred (e.g. the playlist has been cleared), OR 2 - requests for the execution of a function (e.g. track playback).
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
    case trackPlaybackRequest
    case stopPlaybackRequest
    
    case removeTrackRequest
    
    case playlistScrollUpNotification
    case playlistScrollDownNotification
    
    case playbackStateChangedNotification
    case playbackRateChangedNotification
    
    case seekPositionChangedNotification
    
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

// Request from the playback view to the playlist view to remove a specific track from the playlist
struct RemoveTrackRequest: RequestMessage {
    
    var messageType: MessageType = .removeTrackRequest
    var index: Int
    
    init(_ index: Int) {
        self.index = index
    }
}

struct TrackPlaybackRequest: RequestMessage {
    
    var messageType: MessageType = .trackPlaybackRequest
    var trackIndex: Int
    
    init(_ trackIndex: Int) {
        self.trackIndex = trackIndex
    }
}

// Notification that the playback rate has changed, in response to the user manipulating the time stretch effects unit controls.
struct PlaybackRateChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .playbackRateChangedNotification
    var newPlaybackRate: Float
    
    init(_ newPlaybackRate: Float) {
        self.newPlaybackRate = newPlaybackRate
    }
}

// Notification about a change in playback state (paused/playing/noTrack).
struct PlaybackStateChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .playbackStateChangedNotification
    var newPlaybackState: PlaybackState
    
    init(_ newPlaybackState: PlaybackState) {
        self.newPlaybackState = newPlaybackState
    }
}

struct SeekPositionChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .seekPositionChangedNotification
    static let instance: SeekPositionChangedNotification = SeekPositionChangedNotification()
    
    private init() {}
}

struct SearchQueryChangedNotification: NotificationMessage {
    
    var messageType: MessageType = .searchQueryChangedNotification
    static let instance: SearchQueryChangedNotification = SearchQueryChangedNotification()
    
    private init() {}
}

struct AppLoadedNotification: NotificationMessage {
    
    var messageType: MessageType = .appLoadedNotification
    
    // Files specified as launch parameters (files that the app needs to open upon launch)
    var filesToOpen: [URL]
    
    init(_ filesToOpen: [URL]) {
        self.filesToOpen = filesToOpen
    }
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
