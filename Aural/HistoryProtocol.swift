import Foundation

/*
    Contract for performing CRUD operations on the History model
 */
protocol HistoryProtocol {
    
    // Retrieves all items from the Recently added list, in chronological order
    func allRecentlyAddedItems() -> [AddedItem]

    // Adds items to the Recently added list
    func addRecentlyAddedItems(_ items: [URL])
    
    // Retrieves all items from the Recently played list, in chronological order
    func allRecentlyPlayedItems() -> [PlayedItem]
    
    // Adds an item, as a track, to the Recently played list
    func addRecentlyPlayedItem(_ item: Track)
    
    // Adds an item, as a filesystem file, to the Recently played list
    func addRecentlyPlayedItem(_ item: URL)
    
    // Retrieves all Favorites items
    func allFavorites() -> [FavoritesItem]
    
    // Checks if the Favorites list has a given track
    func hasFavorite(_ track: Track) -> Bool
    
    // Adds a given track to the Favorites list
    func addFavorite(_ item: Track)
    
    // Adds a given track, as a file, to the Favorites list
    func addFavorite(_ item: URL)
    
    // Removes a given track from the Favorites list
    func removeFavorite(_ item: Track)
}
