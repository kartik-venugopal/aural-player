import Foundation

protocol ActionMessageSubscriber {
    
    // Every message subscriber must implement this method to consume a type of message it is interested in
    func consumeMessage(_ message: ActionMessage)
}

/*
    A message sent from one UI component to another, to request that some action be performed. Example - the master playlist view controller (PlaylistViewController) sends action messsages to its child view controllers (for each of the 4 playlist views) requesting each of them to refresh their views when new tracks are added to the playlist.
 */
protocol ActionMessage {
    
    var actionType: ActionType {get}
}

// Enumeration of the different message types. See the various Message structs below, for descriptions of each message type.
enum ActionType {
    
    case refresh
    
    case addTracks
    
    case removeTracks
    
    case savePlaylist
    
    case clearPlaylist
    
    case showPlayingTrack
    
    case playSelectedItem
    
    case moveTracksUp
    
    case moveTracksDown
    
    case shiftTab
    
    case search
    
    case sort
    
    case scrollToTop
    
    case scrollToBottom
    
    // MARK: Playlist window actions
    
    case dockLeft
    
    case dockRight
    
    case dockBottom
    
    case maximize
    
    case maximizeHorizontal
    
    case maximizeVertical
    
    // MARK: Playback actions
    
    case playOrPause
    
    case replayTrack
    
    case previousTrack
    
    case nextTrack
    
    case seekBackward
    
    case seekForward
    
    case repeatOff
    
    case repeatOne
    
    case repeatAll
    
    case shuffleOff
    
    case shuffleOn
    
    case moreInfo
    
    // MARK: Audio graph actions
    
    case muteOrUnmute
    
    case increaseVolume
    
    case decreaseVolume
    
    case panLeft
    
    case panRight
    
    case increaseBass
    
    case decreaseBass
    
    case increaseMids
    
    case decreaseMids
    
    case increaseTreble
    
    case decreaseTreble
    
    case increasePitch
    
    case decreasePitch
    
    case setPitch
    
    case increaseRate
    
    case decreaseRate
    
    case setRate
    
    // MARK: View actions
    
    case togglePlaylist
    
    case toggleEffects
    
    // MARK: History actions
    
    case addFavorite
    
    case removeFavorite
}

struct PlaylistActionMessage: ActionMessage {
    
    var actionType: ActionType
    let playlistType: PlaylistType?
    
    init(_ actionType: ActionType, _ playlistType: PlaylistType?) {
        self.actionType = actionType
        self.playlistType = playlistType
    }
}

struct PlaybackActionMessage: ActionMessage {
    
    var actionType: ActionType
    
    init(_ actionType: ActionType) {
        self.actionType = actionType
    }
}

struct AudioGraphActionMessage: ActionMessage {
    
    var actionType: ActionType
    var value: Float?
    
    init(_ actionType: ActionType, _ value: Float? = nil) {
        self.actionType = actionType
        self.value = value
    }
}

struct ViewActionMessage: ActionMessage {
    
    var actionType: ActionType
    
    init(_ actionType: ActionType) {
        self.actionType = actionType
    }
}

struct FavoritesActionMessage: ActionMessage {
    
    var actionType: ActionType
    let track: Track
    
    init(_ actionType: ActionType, _ track: Track) {
        self.actionType = actionType
        self.track = track
    }
}
