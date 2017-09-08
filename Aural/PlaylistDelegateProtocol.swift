/*
    Contract for a middleman/facade between the UI and the playlist, to perform CRUD operations on the playlist
 */

import Cocoa

protocol PlaylistDelegateProtocol: PlaylistAccessorDelegateProtocol, PlaylistMutatorDelegateProtocol {
 
    // Saves the current playlist to a file
    func savePlaylist(_ file: URL)
}
