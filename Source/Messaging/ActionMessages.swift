import Cocoa

// Contract for a subscriber to an ActionMessage
protocol ActionMessageSubscriber {
    
    // Every message subscriber must implement this method to consume the type of message it is interested in
    func consumeMessage(_ message: ActionMessage)
    
    var subscriberId: String {get}
}

extension ActionMessageSubscriber {

    var subscriberId: String {

        let className = String(describing: mirrorFor(self).subjectType)

        if let obj = self as? NSObject {
            return String(format: "%@-%d", className, obj.hashValue)
        }

        return className
    }
}

/*
    A message sent from one UI component to another, to request that some action be performed. Example - the master playlist view controller (PlaylistViewController) sends action messsages to its child view controllers (for each of the 4 playlist views) requesting each of them to refresh their views when new tracks are added to the playlist.
 */
protocol ActionMessage {
    
    // Specifies the type of action/function to be performed by the recipient of the message
    var actionType: ActionType {get}
}

// Enumeration of the different message types. See the various Message structs below, for descriptions of each message type.
enum ActionType {
    
    // MARK: Playlist actions
    
    // Add tracks to playlist
    case addTracks
    
    // Save playlist to file
    case savePlaylist
    
    // Clear the playlist of all tracks
    case clearPlaylist
    
    // Play the chapter selected within the chapters list
    case playSelectedChapter
    
    // Invoke the search dialog
    case search
    
    // Invoke the sort dialog
    case sort
    
    // Switch to the previous playlist view (in the tab group)
    case previousPlaylistView
    
    // Switch to the next playlist view (in the tab group)
    case nextPlaylistView
    
    // Display detailed track info popover for the selected playlist track
    case selectedTrackInfo
    
    // MARK: Playlist window actions
    
    // Show chapters list window for currently playing track
    case viewChapters
    
    // MARK: Playback actions
    
    // Play the previous available chapter
    case previousChapter
    
    // Play the next available chapter
    case nextChapter
    
    // Replay the currently playing chapter from the beginning, if there is one
    case replayChapter
    
    // Toggle the current chapter playback loop
    case toggleChapterLoop
    
    // Show detailed info for the currently playing track
    case moreInfo
    
    // MARK: Audio graph actions
    
    // Saves the current settings in a sound profile for the current track
    case saveSoundProfile
    
    case deleteSoundProfile
    
    case savePlaybackProfile
    
    case deletePlaybackProfile
    
    // MARK: Effects view actions
    
    // Switches the Effects panel tab group to a specfic tab
    case showEffectsUnitTab
    
    case updateEffectsView
    
    // MARK: View actions
    
    case bookmarkPosition
    case bookmarkLoop
    
    // MARK: Effects presets editor actions
    
    case reloadPresets
    case renameEffectsPreset
    case deleteEffectsPresets
    case applyEffectsPreset
    
    // Player view actions
    
    case setTimeElapsedDisplayFormat
    case setTimeRemainingDisplayFormat
    case showOrHideTimeElapsedRemaining
    
    // Color scheme change actions
    case applyColorScheme
    
    case changeAppLogoColor
    case changeBackgroundColor
    
    case changeViewControlButtonColor
    case changeFunctionButtonColor
    case changeTextButtonMenuColor
    case changeToggleButtonOffStateColor
    case changeSelectedTabButtonColor
    
    case changeMainCaptionTextColor
    case changeTabButtonTextColor
    case changeSelectedTabButtonTextColor
    case changeButtonMenuTextColor
    
    case changePlayerTrackInfoPrimaryTextColor
    case changePlayerTrackInfoSecondaryTextColor
    case changePlayerTrackInfoTertiaryTextColor
    case changePlayerSliderValueTextColor
    
    case changePlayerSliderColors
    
    case changePlaylistTrackNameTextColor
    case changePlaylistGroupNameTextColor
    case changePlaylistIndexDurationTextColor
    
    case changePlaylistTrackNameSelectedTextColor
    case changePlaylistGroupNameSelectedTextColor
    case changePlaylistIndexDurationSelectedTextColor
    
    case changePlaylistSummaryInfoColor
    
    case changePlaylistGroupIconColor
    case changePlaylistGroupDisclosureTriangleColor
    
    case changePlaylistSelectionBoxColor
    case changePlaylistPlayingTrackIconColor
    
    case changeEffectsFunctionCaptionTextColor
    case changeEffectsFunctionValueTextColor
    
    case changeEffectsSliderColors
    
    case changeEffectsActiveUnitStateColor
    case changeEffectsBypassedUnitStateColor
    case changeEffectsSuppressedUnitStateColor
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

// A message sent to one of the playlist view controllers, either from another playlist view controller or from another app component, to perform some action on the playlist.
struct PlaylistActionMessage: ActionMessage {
    
    var actionType: ActionType
    
    // Specifies the type of playlist to which this action applies. A nil value indicates that it is independent of playlist type, i.e. applies to all of them.
    let playlistType: PlaylistType?
    
    init(_ actionType: ActionType, _ playlistType: PlaylistType?) {
        
        self.actionType = actionType
        self.playlistType = playlistType
    }
}

// A message sent to the playback view controller to perform a playback function.
struct PlaybackActionMessage: ActionMessage {
    
    var actionType: ActionType
    var actionMode: ActionMode
    
    init(_ actionType: ActionType, _ actionMode: ActionMode = .discrete) {
        self.actionType = actionType
        self.actionMode = actionMode
    }
}

// A message sent to the audio graph view controller to perform an audio graph (i.e. sound altering) function.
struct AudioGraphActionMessage: ActionMessage {
    
    var actionType: ActionType
    var actionMode: ActionMode
    
    // A generic numerical parameter value whose meaning depends on the action type. Example, if actionType = setRate, this value represents the desired playback rate.
    var value: Float?
    
    init(_ actionType: ActionType, _ actionMode: ActionMode = .discrete, _ value: Float? = nil) {
        
        self.actionType = actionType
        self.actionMode = actionMode
        self.value = value
    }
}

// A message sent to a window/view controller to perform a view-related function.
struct ViewActionMessage: ActionMessage {
    
    var actionType: ActionType
    
    init(_ actionType: ActionType) {
        self.actionType = actionType
    }
}

struct ColorSchemeComponentActionMessage: ActionMessage {
    
    let actionType: ActionType
    let color: NSColor
    
    init(_ actionType: ActionType, _ color: NSColor) {
        
        self.actionType = actionType
        self.color = color
    }
}

struct ColorSchemeActionMessage: ActionMessage {
    
    let actionType: ActionType = .applyColorScheme
    let scheme: ColorScheme
    
    init(_ scheme: ColorScheme) {
        self.scheme = scheme
    }
}

// A message sent to the effects view controller to perform a function related to the effects view (e.g. switch to a certain effects unit tab)
struct EffectsViewActionMessage: ActionMessage {
    
    var actionType: ActionType
 
    // The effects unit that is the sender of this message
    let effectsUnit: EffectsUnit
    
    init(_ actionType: ActionType, _ effectsUnit: EffectsUnit) {
        self.actionType = actionType
        self.effectsUnit = effectsUnit
    }
}

struct BookmarkActionMessage: ActionMessage {
    
    let actionType: ActionType
    
    init(_ actionType: ActionType) {
        self.actionType = actionType
    }
}

struct SoundProfileActionMessage: ActionMessage {
    
    let actionType: ActionType
    
    private init(_ actionType: ActionType) {self.actionType = actionType}
    
    static let save: SoundProfileActionMessage = SoundProfileActionMessage(.saveSoundProfile)
    
    static let delete: SoundProfileActionMessage = SoundProfileActionMessage(.deleteSoundProfile)
}

struct PlaybackProfileActionMessage: ActionMessage {
    
    let actionType: ActionType
    
    private init(_ actionType: ActionType) {self.actionType = actionType}
    
    static let save: PlaybackProfileActionMessage = PlaybackProfileActionMessage(.savePlaybackProfile)
    
    static let delete: PlaybackProfileActionMessage = PlaybackProfileActionMessage(.deletePlaybackProfile)
}

struct EffectsPresetsEditorActionMessage: ActionMessage {
    
    let actionType: ActionType
    let effectsPresetsUnit: EffectsUnit
    
    init(_ actionType: ActionType, _ effectsPresetsUnit: EffectsUnit) {
        self.actionType = actionType
        self.effectsPresetsUnit = effectsPresetsUnit
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

// TODO: Refactor message hierarchy. This could be a child of PlaylistActionMessage ???
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

struct SetTimeElapsedDisplayFormatActionMessage: ActionMessage {
    
    let actionType: ActionType = .setTimeElapsedDisplayFormat
    
    let format: TimeElapsedDisplayType
    
    init(_ format: TimeElapsedDisplayType) {
        self.format = format
    }
}

struct SetTimeRemainingDisplayFormatActionMessage: ActionMessage {
    
    let actionType: ActionType = .setTimeRemainingDisplayFormat
    
    let format: TimeRemainingDisplayType
    
    init(_ format: TimeRemainingDisplayType) {
        self.format = format
    }
}

struct PlayerViewActionMessage: ActionMessage {
    
    let actionType: ActionType
    let viewType: PlayerViewType?
    
    init(_ actionType: ActionType, _ viewType: PlayerViewType? = nil) {
        
        self.actionType = actionType
        self.viewType = viewType
    }
}
