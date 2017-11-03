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
    let playlistType: PlaylistType?
    
    init(_ actionType: ActionType, _ playlistType: PlaylistType?) {
        self.actionType = actionType
        self.playlistType = playlistType
    }
}
