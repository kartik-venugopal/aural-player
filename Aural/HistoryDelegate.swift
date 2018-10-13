import Foundation

/*
    Concrete implementation of HistoryDelegateProtocol
 */
class HistoryDelegate: HistoryDelegateProtocol, AsyncMessageSubscriber, PersistentModelObject {
    
    // The actual underlying History model object
    private let history: HistoryProtocol
    
    // Delegate used to perform CRUD on the playlist
    private let playlist: PlaylistDelegateProtocol
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol
    
    init(_ history: HistoryProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol, _ historyState: HistoryState) {
        
        self.history = history
        self.playlist = playlist
        self.player = player
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackPlayed, .itemsAdded], subscriber: self, dispatchQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
        
        // Restore the history model object from persistent state
        
        history.addRecentlyAddedItems(historyState.recentlyAdded.reversed())
        historyState.recentlyPlayed.reversed().forEach({history.addRecentlyPlayedItem($0.file, $0.time)})
        
        AsyncMessenger.publishMessage(HistoryUpdatedAsyncMessage.instance)
    }
    
    func getID() -> String {
        return "HistoryDelegate"
    }
    
    func allRecentlyAddedItems() -> [AddedItem] {
        return history.allRecentlyAddedItems()
    }
    
    func allRecentlyPlayedItems() -> [PlayedItem] {
        return history.allRecentlyPlayedItems()
    }
    
    func addItem(_ item: URL) {
        playlist.addFiles([item])
    }
    
    func playItem(_ item: URL, _ playlistType: PlaylistType) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            // First, find or add the given file
            let newTrack = try playlist.findOrAddFile(item)
            
            // Try playing it
            try _ = player.play(newTrack.track, playlistType)
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                AsyncMessenger.publishMessage(TrackNotPlayedAsyncMessage(oldTrack, error as! InvalidTrackError))
            }
        }
    }
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int) {
        
        history.resizeLists(recentlyAddedListSize, recentlyPlayedListSize)
        AsyncMessenger.publishMessage(HistoryUpdatedAsyncMessage.instance)
    }
    
    func persistentState() -> PersistentState {
        
        let state = HistoryState()
        
        allRecentlyAddedItems().forEach({state.recentlyAdded.append(($0.file, $0.time))})
        allRecentlyPlayedItems().forEach({state.recentlyPlayed.append(($0.file, $0.time))})
        
        return state
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    private func trackPlayed(_ message: TrackPlayedAsyncMessage) {
        history.addRecentlyPlayedItem(message.track, Date())
        AsyncMessenger.publishMessage(HistoryUpdatedAsyncMessage.instance)
    }
    
    // Whenever items are added to the playlist, add entries to the "Recently added" list
    private func itemsAdded(_ message: ItemsAddedAsyncMessage) {
        
        let now = Date()
        var itemsToAdd = [(URL, Date)]()
        message.files.forEach({itemsToAdd.append(($0, now))})
        
        history.addRecentlyAddedItems(itemsToAdd)
        AsyncMessenger.publishMessage(HistoryUpdatedAsyncMessage.instance)
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackPlayed:
            
            trackPlayed(message as! TrackPlayedAsyncMessage)
            
        case .itemsAdded:
            
            itemsAdded(message as! ItemsAddedAsyncMessage)
            
        default: return
            
        }
    }
}
