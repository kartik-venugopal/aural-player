
import Foundation

/*
    Performs I/O of playlists in the JSON format
*/
class PlaylistIO {
    
    // Save current playlist to an output file
    static func savePlaylist(_ file: URL) {
        
        let currentPlaylist: Playlist = Playlist.instance()
        let savedPlaylist: SavedPlaylist = SavedPlaylist(outputFile: file, sourcePlaylist: currentPlaylist)
        
        let outputStream = OutputStream(url: file, append: false)
        outputStream?.open()
        
        JSONSerialization.writeJSONObject(savedPlaylist.forWritingAsJSON(), to: outputStream!, options: JSONSerialization.WritingOptions.prettyPrinted, error: nil)
        
        outputStream?.close()
    }
    
    // Load playlist from file into current playlist
    static func loadPlaylist(_ file: URL) -> SavedPlaylist? {
        
        let inputStream = InputStream(url: file)
        inputStream?.open()
        
        do {
            let data = try JSONSerialization.jsonObject(with: inputStream!, options: JSONSerialization.ReadingOptions())
            
            inputStream?.close()
            
            let playlist: SavedPlaylist = SavedPlaylist(inputFile: file, jsonObject: data as! NSArray)
            return playlist
            
        } catch let error as NSError {
            NSLog("Error reading playlist file '%@': %@", file.path, error.description)
            return nil
        }
    }
}
