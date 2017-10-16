/*
    Contract for an observer responding to changes in the playlist, e.g. PlaybackSequence needs to be recomputed when the playlist is sorted and shuffle mode is on.
 */

import Foundation

protocol PlaylistChangeListener {
    
    // A single new track has been added
    func trackAdded()
    
    // Tracks have been removed, at the given indexes
    func tracksRemoved(_ removedTrackIndexes: [Int])
    
    // A single track has been moved, from its original index to another
    func trackReordered(_ oldIndex: Int, _ newIndex: Int)
    
    // Playlist has been reordered (e.g. sorting). The newCursor argument indicates the new value of the cursor (i.e. playing track) for the playback sequence.
    func playlistReordered(_ newCursor: Int?)
    
    // The entire playlist has been cleared
    func playlistCleared()
}
