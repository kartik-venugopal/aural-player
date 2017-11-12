import Foundation

class HistoryDelegate: AsyncMessageSubscriber {
    
    private let history: History
    private let playlist: PlaylistDelegateProtocol
    private let player: PlaybackDelegateProtocol
    
    init(_ history: History, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol, _ historyState: HistoryState) {
        
        self.history = history
        self.playlist = playlist
        self.player = player
        
        AsyncMessenger.subscribe([.trackPlayed], subscriber: self, dispatchQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
        
        historyState.recentlyPlayed.reversed().forEach({history.addPlayedItem($0)})
        historyState.favorites.reversed().forEach({history.addFavorite($0)})
    }
    
    func allPlayedItems() -> [HistoryItem] {
        return history.allPlayedItems()
    }
    
    func allFavorites() -> [HistoryItem] {
        return history.allFavorites()
    }
    
    func playItem(_ item: URL, _ playlistType: PlaylistType) throws {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let newTrack = try playlist.findOrAddFile(item)
            try _ = player.play(newTrack.track, playlistType)
            
            // Notify the UI that a track has started playing
            AsyncMessenger.publishMessage(TrackChangedAsyncMessage(oldTrack, newTrack))
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, error as! InvalidTrackError))
            }
        }
    }
    
    func hasFavorite(_ track: Track) -> Bool {
        return history.hasFavorite(track)
    }
    
    func addFavorite(_ track: Track) {
        history.addFavorite(track)
    }
    
    func removeFavorite(_ track: Track) {
        history.removeFavorite(track)
    }
    
    func getPersistentState() -> HistoryState {
        
        let state = HistoryState()
        
        allFavorites().forEach({state.favorites.append($0.file)})
        allPlayedItems().forEach({state.recentlyPlayed.append($0.file)})
        
        return state
    }
    
    private func trackPlayed(_ message: TrackPlayedAsyncMessage) {
        history.addPlayedItem(message.track)
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackPlayed:
            
            trackPlayed(message as! TrackPlayedAsyncMessage)
            
        default: return
            
        }
    }
}
