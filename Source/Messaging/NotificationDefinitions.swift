import Foundation

// A contract for payload objects dispatched by Messenger.
protocol NotificationPayload {
    
    // The name of the associated Notification.
    var notificationName: Notification.Name {get}
}

/*
    Signifies that a track transition has occurred, i.e. either the playback state, the current
    track, or both, have changed. eg. when changing tracks or when a playing track is stopped.
 
    Contains information required for UI elements to update themselves to reflect the new state.
 */
struct TrackTransitionNotification: NotificationPayload {

    let notificationName: Notification.Name = .player_trackTransitioned
    
    // The track that was playing before the transition (may be nil, meaning no track was playing)
    let beginTrack: Track?
    
    // Playback state before the track transition
    let beginState: PlaybackState
    
    // The track that is now current, after the transition (may be nil, meaning that playback was stopped)
    let endTrack: Track?
    
    // Playback state before the track transition
    let endState: PlaybackState
    
    // Whether or not the current track has changed as a result of this transition.
    var trackChanged: Bool {
        return beginTrack != endTrack
    }
    
    // Whether or not playback has started as a result of this transition.
    var playbackStarted: Bool {
        return endState == .playing
    }
    
    // Whether or not playback has ended/stopped as a result of this transition.
    var playbackEnded: Bool {
        return endState == .noTrack
    }
    
    // Whether or not the playback state has changed as a result of this transition.
    var stateChanged: Bool {
        return beginState != endState
    }
    
    init(beginTrack: Track?, beginState: PlaybackState, endTrack: Track?, endState: PlaybackState) {
        
        self.beginTrack = beginTrack
        self.beginState = beginState
        
        self.endTrack = endTrack
        self.endState = endState
    }
}

/*
    Signifies that a track change is about to occur. Gives observers a chance to perform some
    computation/processing before the track change occurs (eg. saving/applying audio settings).
*/
struct PreTrackChangeNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_preTrackChange
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let oldTrack: Track?
    
    // Playback state before the track change
    let oldState: PlaybackState
    
    // The track that is now playing (may be nil, meaning no track playing)
    let newTrack: Track?
}

// Notification to indicate that the currently playing chapter has changed
struct ChapterChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_chapterChanged
    
    // The chapter that was playing before the chapter change (may be nil, meaning no defined chapter was playing)
    let oldChapter: IndexedChapter?
    
    // The chapter that is now playing (may be nil, meaning no chapter playing)
    let newChapter: IndexedChapter?
}

// Notification that the app has been reopened with a set of files
struct AppReopenedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .application_reopened
    
    // Files specified as launch parameters (files that the app needs to open)
    let filesToOpen: [URL]
    
    // Whether or not the app has already sent a notification of this type very recently
    let isDuplicateNotification: Bool
}

// A command issued to the player to begin playback in response to tracks being added to the playlist
// (either automatically on startup, or manually by the user)
struct AutoplayCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_autoplay
    
    // See AutoplayCommandType
    let type: AutoplayCommandType
    
    // Whether it is ok to interrupt playback (if a track is currently playing)
    // NOTE - This value is irrelevant for commands of type beginPlayback
    let interruptPlayback: Bool
    
    // The (optional) track that was chosen by the playlist as a potential candidate for playback.
    // NOTE - This value is irrelevant for commands of type beginPlayback.
    let candidateTrack: Track?
    
    init(type: AutoplayCommandType, interruptPlayback: Bool = true, candidateTrack: Track? = nil) {
        
        self.type = type
        self.interruptPlayback = interruptPlayback
        self.candidateTrack = candidateTrack
    }
}

enum AutoplayCommandType {
    
    // The player will begin a new playback sequence (assumes no track is currently playing).
    // i.e. the track to play is not known when the autoplay command is issued and is determined on demand by the sequencer.
    // This is usually done on app startup.
    case beginPlayback
    
    // The player will play a specific track.
    // This is usually done when the user adds files to the playlist.
    case playSpecificTrack
}

// A command to initiate playback for a particular track/group
struct TrackPlaybackCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_playTrack
    
    // Type indicates whether the request parameter is an index, track, or group.
    // This is used to initialize the new playback sequence.
    let type: PlaybackCommandType
    
    // Only one of these 3 fields will be non-nil, depending on the command type
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

// Enumerates all the possible playback command types. See PlaybackCommandNotification.
enum PlaybackCommandType {
    
    // Play the track with the given index
    case index
    
    // Play the given track
    case track
    
    // Play the given group
    case group
}

// Request from the application to its components to perform an exit. Receiving components will determine
// whether or not the app may exit, by submitting appropriate responses.
class AppExitRequestNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .application_exitRequest
    
    // A collection of individual responses from all observers, indicating whether or not the app may exit.
    // NOTE - This collection will be empty at the time this notification is dispatched. Observers will
    // populate the collection as and when they receive the notification. A true value signifies it is ok
    // to exit, and false signifies not ok to exit.
    private var responses: [Bool] = []
    
    // The aggregate result of all the received responses, i.e whether or not the app may safely exit.
    // true means ok to exit, false otherwise.
    var okToExit: Bool {
        return !responses.contains(false)
    }
    
    // Accepts a single response from an observer, and adds it to the responses collection for later use.
    func acceptResponse(okToExit: Bool) {
        responses.append(okToExit)
    }
}

// Notification that the window manager has changed the window layout.
struct WindowLayoutChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .windowManager_layoutChanged

    // Whether or not the playlist window is now being shown.
    let showingPlaylistWindow: Bool
    
    // Whether or not the effects window is now being shown.
    let showingEffectsWindow: Bool
}

// Indicates that some new information has been loaded for a track (e.g. duration/display name/art, etc),
// and that the UI should refresh itself to show the new information.
struct TrackInfoUpdatedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_trackInfoUpdated
    
    // The track that has been updated
    let updatedTrack: Track
    
    // The track info fields that have been updated. Different UI components may display different fields.
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
    
    let notificationName: Notification.Name = .playlist_trackAdded
    
    // The index of the newly added track
    let trackIndex: Int
    
    // Grouping info (parent groups) for the newly added track
    let groupingInfo: [GroupType: GroupedTrackAddResult]
    
    // The current progress of the track add operation (See TrackAddOperationProgress)
    let addOperationProgress: TrackAddOperationProgress
}

// Indicates current progress associated with a TrackAddedNotification.
struct TrackAddOperationProgress {
    
    // Number of tracks added so far
    let tracksAdded: Int
    
    // Total number of tracks to add
    let totalTracks: Int
    
    // Percentage of tracks added (computed)
    var percentage: Double {totalTracks > 0 ? Double(tracksAdded) * 100 / Double(totalTracks) : 0}
}

// Signifies that an error was encountered while attempting to play back a track.
struct TrackNotPlayedNotification: NotificationPayload {
 
    let notificationName: Notification.Name = .player_trackNotPlayed
    
    // The track that was playing before this error occurred (used to refresh certain UI elements, eg. playlist).
    let oldTrack: Track?
    
    // The track that could not be played.
    let errorTrack: Track
    
    // An error object containing detailed information such as the failed track's file and the root cause.
    let error: DisplayableError
}

// A user input mode that determines how the user provided a certain input, which in turn
// determines how the corresponding command should be executed by the app.
// Certain functions, such as player seeking, use this mode.
enum UserInputMode {

    // A discrete input is one that occurs as a single separate event.
    // eg. when a user clicks a menu item.
    case discrete
    
    // A continuous input is one that occurs as part of a continuous sequence of similar events.
    // eg. when a user scrolls using a mouse or trackpad.
    // Many such events are generated one after the other.
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

// A base class for commands sent to the playlist.
class PlaylistCommandNotification: NotificationPayload {

    let notificationName: Notification.Name
    
    // Helps determine which playlist view(s) the command is intended for.
    let viewSelector: PlaylistViewSelector
    
    init(notificationName: Notification.Name, viewSelector: PlaylistViewSelector) {
        
        self.notificationName = notificationName
        self.viewSelector = viewSelector
    }
}

// Command from the playlist search dialog to the playlist, to show (i.e. select) a specific search result within the playlist.
class SelectSearchResultCommandNotification: PlaylistCommandNotification {
    
    // Encapsulates information about the search result (eg. row index)
    // that helps the playlist locate the result.
    let searchResult: SearchResult
    
    init(searchResult: SearchResult, viewSelector: PlaylistViewSelector) {
        
        self.searchResult = searchResult
        super.init(notificationName: .playlist_selectSearchResult, viewSelector: viewSelector)
    }
}

// Command from the playlist search dialog to the playlist, to show (i.e. select) a specific search result within the playlist.
struct ShowAudioUnitEditorCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .auFXUnit_showEditor

    // The audio unit that is to be edited.
    let audioUnit: HostedAudioUnitDelegateProtocol
}

struct PreAudioGraphChangeNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .audioGraph_preGraphChange

    let context: AudioGraphChangeContext
}

class AudioGraphChangeContext {
    
    var playbackSession: PlaybackSession?
    
    // The player node's seek position captured before the audio graph change.
    // This can be used by notification subscribers when responding to the change.
    var seekPosition: Double?
    
    var isPlaying: Bool = true
}

struct AudioGraphChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .audioGraph_graphChanged
    
    let context: AudioGraphChangeContext
}

struct FileSystemFileMetadataLoadedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .fileSystem_fileMetadataLoaded
    
    // The file item whose metadata was updated.
    let file: FileSystemItem
}
