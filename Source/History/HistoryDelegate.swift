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
    
    var lastPlayedTrack: Track?
    
    init(_ history: HistoryProtocol, _ playlist: PlaylistDelegateProtocol, _ player: PlaybackDelegateProtocol, _ historyState: HistoryState) {
        
        self.history = history
        self.playlist = playlist
        self.player = player
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackTransition, .itemsAdded], subscriber: self, dispatchQueue: DispatchQueue.global(qos: DispatchQoS.QoSClass.background))
        
        // Restore the history model object from persistent state
        
        historyState.recentlyAdded.reversed().forEach({history.addRecentlyAddedItem($0.file, $0.name, $0.time)})
        historyState.recentlyPlayed.reversed().forEach({history.addRecentlyPlayedItem($0.file, $0.name, $0.time)})
        
        Messenger.publish(.historyUpdated)
    }
    
    func allRecentlyAddedItems() -> [AddedItem] {
        return history.allRecentlyAddedItems()
    }
    
    func allRecentlyPlayedItems() -> [PlayedItem] {
        return history.allRecentlyPlayedItems()
    }
    
    func addItem(_ item: URL) throws {
        
        if !FileSystemUtils.fileExists(item) {
            throw FileNotFoundError(item)
        }
        
        playlist.addFiles([item])
    }
    
    func playItem(_ item: URL, _ playlistType: PlaylistType) throws {
        
        do {
            
            // First, find or add the given file
            if let newTrack = try playlist.findOrAddFile(item) {
            
                // Play it
                player.play(newTrack.track)
            }
            
        } catch let error {
            
            if let fnfError = error as? FileNotFoundError {
                
                // Log and rethrow error
                NSLog("Unable to play History item. Details: %@", fnfError.message)
                throw fnfError
            }
        }
    }
    
    func deleteItem(_ item: PlayedItem) {
        history.deleteItem(item)
    }
    
    func deleteItem(_ item: AddedItem) {
        history.deleteItem(item)
    }
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int) {
        
        history.resizeLists(recentlyAddedListSize, recentlyPlayedListSize)
        Messenger.publish(.historyUpdated)
    }
    
    var persistentState: PersistentState {
        
        let state = HistoryState()
        
        allRecentlyAddedItems().forEach({state.recentlyAdded.append(($0.file, $0.displayName, $0.time))})
        allRecentlyPlayedItems().forEach({state.recentlyPlayed.append(($0.file, $0.displayName, $0.time))})
        
        return state
    }
    
    func clearAllHistory() {
        history.clearAllHistory()
    }
    
    func compareChronologically(_ track1: URL, _ track2: URL) -> ComparisonResult {
        
        let allHistory = history.allRecentlyPlayedItems()
        
        let index1 = allHistory.firstIndex(where: {$0.file.path == track1.path})
        let index2 = allHistory.firstIndex(where: {$0.file.path == track2.path})
        
        if index1 == nil && index2 == nil {
            return .orderedSame
        }
        
        if index1 != nil && index2 != nil {
            // Assume cannot be equal (that would imply duplicates in history list)
            return index1! > index2! ? .orderedDescending : .orderedAscending
        }
        
        if index1 != nil {
            return .orderedAscending
        }
        
        return .orderedDescending
    }
    
    // Whenever a track is played by the player, add an entry in the "Recently played" list
    private func trackPlayed(_ message: TrackTransitionAsyncMessage) {
        
        if let newTrack = message.endTrack {
        
            lastPlayedTrack = newTrack
            history.addRecentlyPlayedItem(newTrack.file, newTrack.conciseDisplayName, Date())
            Messenger.publish(.historyUpdated)
        }
    }
    
    // Whenever items are added to the playlist, add entries to the "Recently added" list
    private func itemsAdded(_ message: ItemsAddedAsyncMessage) {
        
        let now = Date()
        message.files.forEach({
            
            if let track = playlist.findFile($0) {
                
                // Track
                history.addRecentlyAddedItem(track.track, now)
                
            } else {
                
                // Folder or playlist
                history.addRecentlyAddedItem($0, now)
            }
        })
        
        Messenger.publish(.historyUpdated)
    }
    
    // MARK: Message handling
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackTransition:
            
            if let trackTransitionMsg = message as? TrackTransitionAsyncMessage, trackTransitionMsg.playbackStarted {
                trackPlayed(trackTransitionMsg)
            }
            
        case .itemsAdded:
            
            itemsAdded(message as! ItemsAddedAsyncMessage)
            
        default: return
            
        }
    }
}
