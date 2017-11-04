/*
    Contract for an observer responding to changes in the playlist, e.g. PlaybackSequence needs to be recomputed when the playlist is sorted and shuffle mode is on.
 */

import Foundation

protocol PlaylistChangeListenerProtocol {
    
    // A single new track has been added
    func tracksAdded(_ addResults: [TrackAddResult])
    
    // Tracks have been removed, at the given indexes
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool)
    
    // Tracks have been moved
    func tracksReordered(_ playlistType: PlaylistType)
    
    // Playlist has been reordered (e.g. sorting). The newCursor argument indicates the new value of the cursor (i.e. playing track) for the playback sequence.
    func playlistReordered(_ playlistType: PlaylistType)
    
    // The entire playlist has been cleared
    func playlistCleared()
}
