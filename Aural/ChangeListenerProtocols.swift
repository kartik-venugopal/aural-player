/*
    Contract for an observer responding to changes in the playlist, e.g. PlaybackSequence needs to be recomputed when the playlist is sorted and shuffle mode is on.
 */

import Foundation

protocol PlaylistChangeListener {
    
    // A single new track has been added
    func tracksAdded(_ addResults: [TrackAddResult])
    
    // Tracks have been removed, at the given indexes
    func tracksRemoved(_ removeResults: RemoveOperationResults)
    
    // Tracks have been moved
    func tracksReordered(_ playlistType: PlaylistType)
    
    // Playlist has been reordered (e.g. sorting). The newCursor argument indicates the new value of the cursor (i.e. playing track) for the playback sequence.
    func playlistReordered(_ playlistType: PlaylistType)
    
    // The entire playlist has been cleared
    func playlistCleared()
}

protocol TrackInfoChangeListener {
    
    // Notifies the playlist that info for this track has changed. The playlist may use the updates to re-group the track (by artist/album/genre, etc).
    func trackInfoUpdated(_ updatedTrack: Track) -> [GroupType: GroupedTrackUpdateResult]
}
