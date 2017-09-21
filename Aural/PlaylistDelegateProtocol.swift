import Cocoa

/*
    Contract for a middleman/delegate that relays all read/write or CRUD operations to the playlist
 */
protocol PlaylistDelegateProtocol: PlaylistAccessorDelegateProtocol, PlaylistMutatorDelegateProtocol {
 
    // Saves the current playlist to a file
    func savePlaylist(_ file: URL)
}
