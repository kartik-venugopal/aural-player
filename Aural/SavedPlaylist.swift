/*
    Represents a persistent playlist (as opposed to a playing playlist)
*/

import Foundation

class SavedPlaylist {
    
    // The filesystem location of the playlist
    var file: URL
    
    var tracks: [Track] = [Track]()
    
    // Use for writing: Initializes an empty playlist with a reference to an (output) file
    init(outputFile: URL, sourcePlaylist: Playlist) {
        self.file = outputFile
        
        for track in sourcePlaylist.getTracks() {
            self.tracks.append(track)
        }
    }
    
    // Use for reading: Initializes a playlist from JSON deserialized from an input file
    init(inputFile: URL, jsonObject: NSArray) {
        self.file = inputFile
        
        for path in jsonObject {
            
            let _path = path as! String
            
            let track = TrackIO.loadTrack(URL(fileURLWithPath: _path))
            if (track != nil) {
                self.tracks.append(track!)
            }
        }
    }

    // Produces an equivalent object suitable for serialization as JSON
    func forWritingAsJSON() -> NSArray {
        
        var array: [String] = [String]()
        
        for track in tracks {
            array.append(track.file!.path)
        }
        
        return NSArray(array: array)
    }
}
