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
    
   // ******** WITH PAYLOAD ****************************************************************************************
    
    case changePlaylistGroupNameTextColor
    
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

struct ColorSchemeComponentActionMessage: ActionMessage {
    
    let actionType: ActionType
    let color: NSColor
    
    init(_ actionType: ActionType, _ color: NSColor) {
        
        self.actionType = actionType
        self.color = color
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
