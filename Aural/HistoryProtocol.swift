import Foundation

/*
    Contract for performing CRUD operations on the History model
 */
protocol HistoryProtocol {
    
    // Retrieves all items from the Recently added list, in chronological order
    func allRecentlyAddedItems() -> [AddedItem]

    // Adds items to the Recently added list. Each "time" argument represents the time the corresponding item was added to the playlist.
    func addRecentlyAddedItems(_ items: [(file: URL, time: Date)])
    
    // Retrieves all items from the Recently played list, in chronological order
    func allRecentlyPlayedItems() -> [PlayedItem]
    
    func mostRecentlyPlayedItem() -> PlayedItem?
    
    // Adds an item, as a track, to the Recently played list. The "time" argument represents the time the corresponding item was played.
    func addRecentlyPlayedItem(_ item: Track, _ time: Date)
    
    // Adds an item, as a filesystem file, to the Recently played list. The "time" argument represents the time the corresponding item was played.
    func addRecentlyPlayedItem(_ file: URL, _ time: Date)
    
    // Resizes all history lists with the given sizes
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int)
    
    func clearAllHistory()
}
