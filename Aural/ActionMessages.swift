import Foundation

/*
 Contract for all subscribers of synchronous messages
 */
protocol ActionMessageSubscriber {
    
    // Every message subscriber must implement this method to consume a type of message it is interested in
    func consumeMessage(_ message: ActionMessage)
}

/*
 Defines a synchronous message. SyncMessage objects could be either 1 - notifications, indicating that some change has occurred (e.g. the playlist has been cleared), OR 2 - requests for the execution of a function (e.g. track playback).
 */
protocol ActionMessage {
    
    var actionType: ActionType {get}
}

// Enumeration of the different message types. See the various Message structs below, for descriptions of each message type.
enum ActionType {
    
    case refresh
    
    case removeTracks
    
    case clearPlaylist
    
    case showPlayingTrack
    
    case moveTracksUp
    
    case moveTracksDown
    
    case scrollToTop
    
    case scrollToBottom
}

struct PlaylistActionMessage: ActionMessage {
    
    let actionType: ActionType
    let viewType: PlaylistViewType
    
    init(_ actionType: ActionType, _ viewType: PlaylistViewType) {
        self.actionType = actionType
        self.viewType = viewType
    }
}

enum PlaylistViewType {
 
    case all
    case tracks
    case artists
    case albums
    case genres
}
