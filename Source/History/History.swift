import Cocoa

/*
    Model object that manages all historical information, in chronological order:
 
    - Recently added items: tracks, playlist files, folders
    - Recently played items: tracks
    - Favorites: tracks
 
 */
class History: HistoryProtocol {
    
    // Recently added items
    var recentlyAddedItems: LRUArray<AddedItem>
    
    // Recently played items
    var recentlyPlayedItems: LRUArray<PlayedItem>
    
    init(_ preferences: HistoryPreferences) {
        
        recentlyAddedItems = LRUArray<AddedItem>(preferences.recentlyAddedListSize)
        recentlyPlayedItems = LRUArray<PlayedItem>(preferences.recentlyPlayedListSize)
    }
    
    func addRecentlyAddedItem(_ file: URL, _ name: String, _ time: Date) {
        recentlyAddedItems.add(AddedItem(file, name, time))
    }
    
    func addRecentlyAddedItem(_ file: URL, _ time: Date) {
        recentlyAddedItems.add(AddedItem(file, time))
    }
    
    func addRecentlyAddedItem(_ track: Track, _ time: Date) {
        recentlyAddedItems.add(AddedItem(track, time))
    }
    
    func allRecentlyAddedItems() -> [AddedItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return recentlyAddedItems.toArray().reversed()
    }
    
    func addRecentlyPlayedItem(_ item: Track, _ time: Date) {
        recentlyPlayedItems.add(PlayedItem(item.file, item.displayName, time))
    }
    
    func addRecentlyPlayedItem(_ file: URL, _ name: String, _ time: Date) {
        recentlyPlayedItems.add(PlayedItem(file, name, time))
    }
    
    func allRecentlyPlayedItems() -> [PlayedItem] {
        
        // Reverse the array for chronological order (most recent items first)
        return recentlyPlayedItems.toArray().reversed()
    }
    
    func mostRecentlyPlayedItem() -> PlayedItem? {
        
        let allPlayedItems = recentlyPlayedItems.toArray()
        return allPlayedItems.last
    }
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int) {
        
        recentlyAddedItems.resize(recentlyAddedListSize)
        recentlyPlayedItems.resize(recentlyPlayedListSize)
    }
    
    func clearAllHistory() {
        recentlyAddedItems.clear()
        recentlyPlayedItems.clear()
    }
    
    func deleteItem(_ item: PlayedItem) {
        recentlyPlayedItems.remove(item)
    }
    
    func deleteItem(_ item: AddedItem) {
        recentlyAddedItems.remove(item)
    }
}
