/*
    Contract for an observer responding to changes in the playlist, e.g. the playback sequence needs to be recomputed when the playlist is sorted and shuffle mode is on.
 */

import Foundation

protocol PlaylistChangeListenerProtocol {
    
    // New tracks have been added
    func tracksAdded(_ addResults: [TrackAddResult])
    
    // Tracks have been removed. The playingTrackRemoved argument specifies whether the currently playing track, if one, was removed.
    func tracksRemoved(_ removeResults: TrackRemovalResults, _ playingTrackRemoved: Bool)
    
    // Tracks have been moved, in the playlist of the specified type
    func tracksReordered(_ playlistType: PlaylistType)
    
    // Playlist of the specified type has been reordered (e.g. sorting)
    func playlistReordered(_ playlistType: PlaylistType)
    
    // The entire playlist has been cleared
    func playlistCleared()
}
