/*
    Represents a persistent playlist (as opposed to a playing playlist)
*/

import Foundation

class SavedPlaylist {
    
    // The filesystem location of the playlist
    var file: URL
    
    // URLs of tracks in this playlist
    var trackFiles: [URL] = [URL]()
    
    // Use for writing: Initializes a playlist with a reference to an (output) file and the URLs of files for the tracks in the source playlist
    init(outputFile: URL, sourcePlaylist: Playlist) {
        self.file = outputFile
        
        for track in sourcePlaylist.getTracks() {
            self.trackFiles.append(track.file!)
        }
    }
    
    // Use for reading: Initializes a playlist from JSON deserialized from an input file
    init(inputFile: URL, jsonObject: NSArray) {
        self.file = inputFile
        
        for path in jsonObject {
            
            let _path = path as! String
            self.trackFiles.append(URL(fileURLWithPath: _path))
        }
    }

    // Produces an equivalent object suitable for serialization as JSON
    func forWritingAsJSON() -> NSArray {
        
        var array: [String] = [String]()
        
        for trackFile in trackFiles {
            array.append(trackFile.path)
        }
        
        return NSArray(array: array)
    }
}
