import Foundation

struct TrackTransitionNotification: NotificationPayload {

    let notificationName: Notification.Name = .trackTransition
    
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
    
    init(beginTrack: Track?, beginState: PlaybackState, endTrack: Track?, endState: PlaybackState, gapEndTime: Date? = nil) {
        
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

// Notification that the playback rate has changed, in response to the user manipulating the time stretch effects unit controls.
struct PlaybackRateChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playbackRateChanged
    
    // The new playback rate
    let newPlaybackRate: Float
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
    
    let notificationName: Notification.Name = .player_playTrack
    
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

// Notification that the layout manager has changed the window layout
struct WindowLayoutChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .windowLayoutChanged
    
    let showingEffects: Bool
    let showingPlaylist: Bool
}

struct EditorSelectionChangedNotification: NotificationPayload {

    let notificationName: Notification.Name = .editorSelectionChanged
    let numberOfSelectedRows: Int
}

struct PlaybackGapUpdatedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .gapUpdated
    let updatedTrack: Track
}

// Indicates that playback of the currently playing track has completed
struct PlaybackCompletedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playbackCompleted
    
    // The playback session corresponding to the track that just finished playing.
    let completedSession: PlaybackSession
}

// AsyncMessage indicating that some new information has been loaded for a track (e.g. duration/display name/art, etc), and that the UI should refresh itself to show the new information
struct TrackInfoUpdatedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .trackInfoUpdated
    
    // The track that has been updated
    let updatedTrack: Track
    
    // The track info fields that have been updated
    let updatedFields: Set<UpdatedTrackInfoField>
    
    init(updatedTrack: Track, updatedFields: UpdatedTrackInfoField...) {
        
        self.updatedTrack = updatedTrack
        self.updatedFields = Set(updatedFields)
    }
}

// An enumeration of different track info fields that can be updated
enum UpdatedTrackInfoField: CaseIterable {
    
    // Album art
    case art
    
    // Track duration
    case duration
    
    // Any primary info, other than album art and duration, that is displayed in the app's main windows
    // (eg. title / artist / album, etc)
    // NOTE - This may not be a valid case because all display info (i.e. grouping info)
    // is read before the track is added to the playlist
    case displayInfo
    
    // Any info that is not essential for display in the app's main windows
    case metadata
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

struct TrackNotTranscodedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .trackNotTranscoded
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let track: Track
    
    // An error object containing detailed information such as the track file and the root cause
    let error: InvalidTrackError
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

struct TranscodingProgressNotification: NotificationPayload {

    let notificationName: Notification.Name = .transcodingProgress
    
    let track: Track
    
    let percentageTranscoded: Double
    let timeElapsed: Double
    let timeRemaining: Double
}

struct TranscodingFinishedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .transcodingFinished
    
    let track: Track
    let success: Bool
}

enum ActionMode {
    
    case discrete
    
    case continuous
}

// Helps in filtering command notifications sent to playlist views, i.e. "selects" a playlist view
// as the intended recipient of a command notification.
struct PlaylistViewSelector {
    
    // A specific playlist view, if any, that should be exclusively selected.
    // nil value means all playlist views are selected.
    let specificView: PlaylistType?
    
    private init(_ specificView: PlaylistType? = nil) {
        self.specificView = specificView
    }
    
    // Whether or not a given playlist view is included in the selection specified by this object.
    // If a specific view was specified when creating this object, this method will return true
    // only for that playlist view. Otherwise, it will return true for all playlist views.
    func includes(_ view: PlaylistType) -> Bool {
        return specificView == nil || specificView == view
    }
    
    // A selector instance that specifies a selection of all playlist views.
    static let allViews: PlaylistViewSelector = PlaylistViewSelector()
    
    // Factory method that creates a selector for a specific playlist view.
    static func forView(_ view: PlaylistType) -> PlaylistViewSelector {
        return PlaylistViewSelector(view)
    }
}

class PlaylistCommandNotification: NotificationPayload {

    let notificationName: Notification.Name
    let viewSelector: PlaylistViewSelector
    
    init(notificationName: Notification.Name, viewSelector: PlaylistViewSelector) {
        
        self.notificationName = notificationName
        self.viewSelector = viewSelector
    }
}

class DelayedPlaybackCommandNotification: PlaylistCommandNotification {
    
    let delay: Double
    
    init(delay: Double, viewSelector: PlaylistViewSelector) {
        
        self.delay = delay
        super.init(notificationName: .playlist_playSelectedItemWithDelay, viewSelector: viewSelector)
    }
}

class InsertPlaybackGapsCommandNotification: PlaylistCommandNotification {
    
    let gapBeforeTrack: PlaybackGap?
    let gapAfterTrack: PlaybackGap?
    
    init(gapBeforeTrack: PlaybackGap?, gapAfterTrack: PlaybackGap?, viewSelector: PlaylistViewSelector) {
        
        self.gapBeforeTrack = gapBeforeTrack
        self.gapAfterTrack = gapAfterTrack
        
        super.init(notificationName: .playlist_insertGaps, viewSelector: viewSelector)
    }
}

// Command from the playlist search dialog to the playlist, to show a specific search result within the playlist.
class SelectSearchResultCommandNotification: PlaylistCommandNotification {
    
    let searchResult: SearchResult
    
    init(searchResult: SearchResult, viewSelector: PlaylistViewSelector) {
        
        self.searchResult = searchResult
        super.init(notificationName: .playlist_selectSearchResult, viewSelector: viewSelector)
    }
}
