/*
    Contract for an observer responding to changes in the playlist, e.g. PlaybackSequence needs to be recomputed when the playlist is sorted and shuffle mode is on.
 */

import Foundation

protocol PlaylistChangeListener {
    
    // Signals a reordering of the playlist (e.g. sorting)
    func playlistReordered(_ newTrackIndex: Int?)
    
    // A random track has been selected for playback
    func randomTrackSelected(_ trackIndex: Int)
    
    // A single new track has been added
    func trackAdded()
    
    // A single existing track has been removed, from a particular index
    func trackRemoved(_ removedTrackIndex: Int)
    
    // A single track has been moved, from a particular index to another
    func trackReordered(_ oldIndex: Int, _ newIndex: Int)
    
    // The entire playlist has been cleared
    func playlistCleared()
}
