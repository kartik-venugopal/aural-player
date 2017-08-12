/*
    Represents a persistent playlist (as opposed to a playing playlist)
 */
import Foundation

class SavedPlaylist {

    // The filesystem location of the playlist file referenced by this object
    var file: URL
    
    // URLs of tracks in this playlist
    var tracks: [URL]
    
    init(_ file: URL, _ tracks: [URL]) {
        self.file = file
        self.tracks = tracks
    }
}
