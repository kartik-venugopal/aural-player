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
    
    case trackUpdatedNotification
    
    case trackGroupUpdatedNotification
    
    case trackAddedNotification
    
    case trackGroupedNotification
    
    case preTrackChangeNotification
    
    case trackChangedNotification
    
    case sequenceChangedNotification
    
    case effectsUnitStateChangedNotification
    
    case playingTrackInfoUpdatedNotification
    
    case removeTrackRequest
    
    case playbackStateChangedNotification
    
    case playbackRateChangedNotification
    
    case playbackLoopChangedNotification
    
    case seekPositionChangedNotification
    
    case searchTextChangedNotification
    
    case appLoadedNotification
    
    case appReopenedNotification
    
    case appModeChangedNotification
    
    case playlistTypeChangedNotification
    
    case editorSelectionChangedNotification
    
    case searchResultSelectionRequest
    
    case appInBackgroundNotification
    
    case appInForegroundNotification
    
    case appResignedActiveNotification
    
    case mainWindowResizingNotification
    
    case layoutChangedNotification
    
    case mouseEnteredView
    
    case mouseExitedView
    
    case playbackRequest
    
    case appExitRequest
    
    case appExitResponse
    
    case emptyResponse
    
    case saveEQUserPresetRequest
    
    case savePitchUserPresetRequest
    
    case saveTimeUserPresetRequest
    
    case applyEQPreset
    
    case applyPitchPreset
    
    case applyTimePreset
    
    case applyReverbPreset
    
    case applyDelayPreset
    
    case applyFilterPreset
    
    case gapUpdatedNotification
    
    case fxUnitActivatedNotification
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

struct PreTrackChangeNotification: NotificationMessage {
    
    let messageType: MessageType = .preTrackChangeNotification
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let oldTrack: IndexedTrack?
    
    // Playback state before the track change
    let oldState: PlaybackState
    
    // The track that is now playing (may be nil, meaning no track playing)
    let newTrack: IndexedTrack?
    
    init(_ oldTrack: IndexedTrack?, _ oldState: PlaybackState, _ newTrack: IndexedTrack?) {
        
        self.oldTrack = oldTrack
        self.oldState = oldState
        self.newTrack = newTrack
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
    
    // Track that needs to be removed
    let track: Track
    
    init(_ track: Track) {
        self.track = track
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

struct AppModeChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .appModeChangedNotification
    
    let newMode: AppMode
    
    init(_ newMode: AppMode) {
        self.newMode = newMode
    }
}

// Notification that the playlist view (tracks/artists, etc) has been changed, by switching playlist tabs, within the UI
struct PlaylistTypeChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .playlistTypeChangedNotification
    let newPlaylistType: PlaylistType
}

// Request to the playback controller to initiate playback for a particular track/group
struct PlaybackRequest: RequestMessage {
    
    let messageType: MessageType = .playbackRequest
    
    // Type indicates whether the request parameter is an index, track, or group. This is used to initialize the new playback sequence.
    let type: PlaybackRequestType
    
    var delay: Double? = nil
    
    // Only one of these 3 fields will be non-nil, depending on the request type
    var index: Int? = nil
    var track: Track? = nil
    var group: Group? = nil
    
    // Initialize the request with a track index. This will be done from the Tracks playlist.
    init(index: Int) {
        self.index = index
        self.type = .index
    }
    
    // Initialize the request with a track. This will be done from a grouping/hierarchical playlist.
    init(track: Track) {
        self.track = track
        self.type = .track
    }
    
    // Initialize the request with a group. This will be done from a grouping/hierarchical playlist.
    init(group: Group) {
        self.group = group
        self.type = .group
    }
}

// Enumerates all the possible playback request types. See PlaybackRequest.
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

// Notification indicating that the application has moved to the background and is no longer both visible and in focus.
struct AppInBackgroundNotification: NotificationMessage {
    
    let messageType: MessageType = .appInBackgroundNotification
    
    private init() {}
    
    // Singleton
    static let instance: AppInBackgroundNotification = AppInBackgroundNotification()
}

struct AppResignedActiveNotification: NotificationMessage {
    
    let messageType: MessageType = .appResignedActiveNotification
    
    private init() {}
    
    // Singleton
    static let instance: AppResignedActiveNotification = AppResignedActiveNotification()
}

// Notification indicating that the application has moved to the foreground and is both visible and in focus.
struct AppInForegroundNotification: NotificationMessage {
    
    let messageType: MessageType = .appInForegroundNotification
    
    private init() {}
    
    // Singleton
    static let instance: AppInForegroundNotification = AppInForegroundNotification()
}

// Notification indicating that one of the effects units has either become active or inactive. The Effects panel tab group may use this information to update its view.
struct EffectsUnitStateChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .effectsUnitStateChangedNotification
    
    private init() {}
    
    static let instance: EffectsUnitStateChangedNotification = EffectsUnitStateChangedNotification()
}

// Audio graph
struct FXUnitActivatedNotification: NotificationMessage {
    
    let messageType: MessageType = .fxUnitActivatedNotification
    private init() {}
    
    static let instance: FXUnitActivatedNotification = FXUnitActivatedNotification()
}

// Notification that the state of the segment playback loop for the currently playing track has been changed and the UI may need to be updated as a result
struct PlaybackLoopChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .playbackLoopChangedNotification
    
    private init() {}
    
    // Singleton
    static let instance: PlaybackLoopChangedNotification = PlaybackLoopChangedNotification()
}

// TODO: This is dead code, remove it
// Request from the User Presets popover to an effects unit controller to save a user-defined preset with a given name
struct SaveUserPresetRequest: RequestMessage {
    
    let messageType: MessageType
    
    // Name of the new Pitch preset being saved
    let presetName: String
    
    init(_ messageType: MessageType, _ presetName: String) {
        self.messageType = messageType
        self.presetName = presetName
    }
}

// Notification that the main window is about to be resized
struct MainWindowResizingNotification: NotificationMessage {
 
    let messageType: MessageType = .mainWindowResizingNotification
    
    private init() {}
    
    // Singleton
    static let instance: MainWindowResizingNotification = MainWindowResizingNotification()
}

// Notification that the layout manager has changed the window layout
struct LayoutChangedNotification: NotificationMessage {
    
    let messageType: MessageType = .layoutChangedNotification
    let showingEffects: Bool
    let showingPlaylist: Bool
    
    init(_ showingEffects: Bool, _ showingPlaylist: Bool) {
        self.showingEffects = showingEffects
        self.showingPlaylist = showingPlaylist
    }
}

struct MouseTrackingNotification: NotificationMessage {
    
    let messageType: MessageType
    
    init(_ messageType: MessageType) {
        self.messageType = messageType
    }
    
    static let mouseEntered = MouseTrackingNotification(.mouseEnteredView)
    static let mouseExited = MouseTrackingNotification(.mouseExitedView)
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

struct TrackGroupedNotification: NotificationMessage {
    
    let messageType: MessageType = .trackGroupedNotification
    
    let grouping: GroupedTrack
    let groupCreated: Bool
    
    init(_ grouping: GroupedTrack, _ groupCreated: Bool) {
        self.grouping = grouping
        self.groupCreated = groupCreated
    }
}

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
    
    static func fromTrackAddResult(_ result: TrackAddResult, _ progress: TrackAddedMessageProgress) -> TrackAddedNotification {
        return TrackAddedNotification(result.flatPlaylistResult, result.groupingPlaylistResults, progress)
    }
}
