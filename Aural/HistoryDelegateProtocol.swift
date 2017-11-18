import Foundation

/*
    Contract for a delegate that performs CRUD on the History model
 */
protocol HistoryDelegateProtocol {
    
    // Retrieves all items from the Recently added list, in chronological order
    func allRecentlyAddedItems() -> [AddedItem]
    
    // Retrieves all recently played items
    func allRecentlyPlayedItems() -> [PlayedItem]
    
    // Retrieves all Favorites items
    func allFavorites() -> [FavoritesItem]
    
    // Checks if the Favorites list has a given track
    func hasFavorite(_ track: Track) -> Bool
    
    // Adds a given track to the Favorites list
    func addFavorite(_ track: Track)
    
    // Removes a given track from the Favorites list
    func removeFavorite(_ track: Track)
    
    // Adds a given item (file/folder) to the playlist
    func addItem(_ item: URL)
    
    // Plays a given item track. The "playlistType" parameter is used to initialize the new playback sequence, based on the current playlist view.
    func playItem(_ item: URL, _ playlistType: PlaylistType)
    
    func resizeLists(_ recentlyAddedListSize: Int, _ recentlyPlayedListSize: Int, _ favoritesListSize: Int)
}
