/*
 Contract for a middleman/facade between the UI and the playlist, to perform CRUD operations on the playlist
 */

import Cocoa

protocol PlaylistMutatorDelegateProtocol {
    
    func addFiles(_ files: [URL])
    
    func removeTrack(_ index: Int)
    
    // Clears the entire playlist of all tracks
    func clear()
    
    // Moves the track at the specified index, up one index, in the playlist, if it is not already at the top. Returns the new index of the track (same if it didn't move)
    func moveTrackUp(_ index: Int) -> Int
    
    // Moves the track at the specified index, down one index, in the playlist, if it is not already at the bottom. Returns the new index of the track (same if it didn't move)
    func moveTrackDown(_ index: Int) -> Int
    
    // Sorts the playlist according to the specified sort parameters
    func sort(_ sort: Sort)
}
